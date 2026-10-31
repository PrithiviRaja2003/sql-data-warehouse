/*
===============================================================================
PROJECT : Data Warehouse
FILE    : 7.silver_load.sql
PURPOSE : Insert cleaned and standardized data from Bronze into Silver tables.

OVERVIEW:
    Load new records from the Bronze layer into the six Silver tables.
    Clean and standardize source data before inserting it into Silver.

PROCESS:
    1. Clean and standardize source data using Common Table Expressions (CTEs).
    2. Remove unwanted spaces and prefixes where required.
    3. Standardize customer gender, marital status, country, and product categories.
    4. Handle missing or invalid values, including future customer birth dates.
    5. Correct invalid sales amounts and prices using the defined business rules.
    6. Calculate product end dates using LEAD() and the next product start date.
    7. Use NOT EXISTS to prevent inserting records whose business keys already
       exist in the corresponding Silver tables.
    8. Preserve existing Silver records instead of truncating and reloading them.

IMPORTANT:
    - This procedure inserts new records only; it does not update existing records.
    - UPDATE logic is maintained separately in the Silver update procedure/script.
    - Duplicate prevention depends on the matching keys used in each INSERT query.
    - Source IDs must be checked for uniqueness after any cleaning or transformation.
    - The procedure does not automatically reload new CSV files into Bronze.
    - load_timestamp is populated automatically when an INSERT omits that column.
    - updated_timestamp is designed to remain NULL for new rows and record the
      latest actual row modification when an existing row changes, if the column
      is defined with ON UPDATE CURRENT_TIMESTAMP().
    - Calling this procedure again should insert only newly available records
      whose keys do not already exist in Silver.

TABLES LOADED:
    1. silver.crm_customer_info
    2. silver.crm_product_info
    3. silver.crm_sales_info
    4. silver.erp_customer_demographics
    5. silver.erp_customer_locations
    6. silver.erp_product_categories

EXECUTION:
    CALL silver.insert_values();

===============================================================================
*/

Delimiter // 
create  procedure  silver.insert_values()
begin
-- insert value in silver table customer_info
insert into
    silver.crm_customer_info (
        customer_id,
        customer_key,
        customer_firstname,
        customer_lastname,
        customer_marital_status,
        customer_gender,
        customer_create_date
    ) with clean_bronze_crm_customer_info as (
        -- cte table
        select
            trim(t.cst_id) as cst_id,
            trim(t.cst_key) as cst_key,
            trim(t.cst_firstname) as cst_firstname,
            trim(t.cst_lastname) as cst_lastname,
            CASE
                WHEN UPPER(TRIM(t.cst_marital_status)) = 'M' THEN 'Married'
                WHEN UPPER(TRIM(t.cst_marital_status)) = 'S' THEN 'Single'
                ELSE 'Unknown'
            END as cst_marital_status,
            --  -- Convert marital status codes into readable values
            CASE
                WHEN upper(trim(t.cst_gndr)) = 'F' THEN 'Female'
                WHEN upper(trim(t.cst_gndr)) = 'M' THEN 'Male'
                ELSE 'Unknown'
            END as cst_gndr,
            --  -- Convert gender codes into readable values
            t.cst_create_date
        from
            --  Keep valid customers separate  (sub_query)
            (
                select
                    *,
                    row_number () over (
                        partition by cst_id
                        order by
                            cst_create_date desc
                    ) as new_values
                from
                    bronze.crm_customer_info
                where
                    cst_id is not null
                    and cst_id <> 0
            ) as t
        where
            new_values = 1
    )
select
    b.cst_id,
    b.cst_key,
    b.cst_firstname,
    b.cst_lastname,
    b.cst_marital_status,
    b.cst_gndr,
    b.cst_create_date
from
    clean_bronze_crm_customer_info as b
where
    not exists (
        select
            1
        from
            silver.crm_customer_info as S
        where
            b.cst_id <=> s.customer_id
    );



    
-- insert value in silver table product_info
insert into
    silver.crm_product_info (
        product_id,
        product_key,
        category_id,
        product_name,
        product_cost,
        product_line,
        product_start_dt,
        product_end_dt
    ) with clean_bronze_crm_product_info as -- cte table
    (
        select
            prd_id,
            substring(prd_key, 7, length(prd_key)) as prd_key,  -- Extract category ID cat id for  cat table 
            replace(substring(prd_key, 1, 5), "-", "_") as cat_id, --  sales_prd_key in sales table
            prd_nm,
            coalesce(prd_cost, 0) as prd_cost,     -- Replace missing product cost with 0
            case
                when upper(trim(prd_line)) = "R" then "Road"
                when upper(trim(prd_line)) = "S" then "Others Sales"
                when upper(trim(prd_line)) = "M" then "Mountain"
                when upper(trim(prd_line)) = "T" then "Touring"
                else "Unknown"
            end as prd_line,
            -- -- change the  sprd_line to readable
            prd_start_dt,
            date_sub(
                lead(prd_start_dt) over (
                    partition by prd_key
                    order by
                        prd_start_dt asc
                ),
                interval 1 day
            ) prd_end_dt   -- End a product version one day before the next version starts
        from
            bronze.crm_product_info

)
select
    b.prd_id,
    b.prd_key,
    b.cat_id,
    b.prd_nm,
    b.prd_cost,
    b.prd_line,
    b.prd_start_dt,
    b.prd_end_dt
from
    clean_bronze_crm_product_info as b
where
    not exists (
select
    1
from
    silver.crm_product_info as s
where
    b.prd_id <=> s.product_id
    );
    
-- insert value in silver table sales_info    
insert into
    silver.crm_sales_info (
        sales_order_number,
        sales_product_key,
        sales_customer_id,
        sales_order_date,
        sales_shipping_date,
        sales_due_date,
        sales_amount,
        sales_quantity,
        sales_price
    ) with clean_silver_crm_sales_info as (
        select
            trim(sls_ord_num) as sls_ord_num, 
            trim(sls_prd_key) as sls_prd_key,
            trim(sls_cust_id) as sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            case
                when sls_sales is null
                or sls_sales <= 0
                or sls_sales != abs(sls_quantity) * abs(sls_price) then round(
                    abs((sls_quantity)) *(
                        case
                            when sls_price is null
                            or sls_price <= 0 then abs(sls_sales) / nullif(abs((sls_quantity)), 0)
                            else sls_price
                        end
                    ), 
                    2
                )
                else sls_sales
            end as sls_sales, -- recaulcate sales if original values is invaild
            sls_quantity,
            case
                when sls_price is null
                or sls_price <= 0 then round(abs(sls_sales) / nullif(abs((sls_quantity)), 0), 2)
                else sls_price
            end as sls_price  -- recaulcate sales price if original values is invaild
        from
            bronze.crm_sales_info
    )
select
    b.sls_ord_num,
    b.sls_prd_key,
    b.sls_cust_id,
    b.sls_order_dt,
    b.sls_ship_dt,
    b.sls_due_dt,
    b.sls_sales,
    b.sls_quantity,
    b.sls_price
from
    clean_silver_crm_sales_info as b
where
    not exists (
        select
            1
        from
            silver.crm_sales_info as s
        where
            b.sls_ord_num <=> s.sales_order_number
            and b.sls_prd_key <=> s.sales_product_key
    );
    -- insert value in silver table customer_demographics
insert into
    silver.erp_customer_demographics (
        customer_ID,
        customer_birth_date,
        gender
    ) with clean_bronze_erp_customer_demographics as (
        select
            case
                when cid regexp "^NAS" then substring(cid, 4, length(cid))  -- remove "NAS" prefix  if present
                else cid
            end as cid,
            case
                when bdate > current_date() then null --  null the future date 
                else bdate
            end as bdate,
            case
                when upper(trim(gen)) in ("F", "FEMALE") then "Female" 
                when upper(trim(gen)) in ("M", "MALE") then "Male"
                else "Unknown"
            end as gen -- change str to readble and handle the unknowm 
        from
            bronze.erp_customer_demographics
    )
select
    b.CID,
    b.BDATE,
    b.GEN
from
    clean_bronze_erp_customer_demographics as b
where
    not exists (
        select
            1
        from
            silver.erp_customer_demographics as s
        where
            b.CID <=> s.customer_ID
    );
    
-- insert value in silver table customer_locations 
insert into
    silver.erp_customer_locations (customer_ID, customer_country) with clean_bronze_erp_customer_locations as (
        select
            trim(replace(cid, "-", "")) as cid,  -- removeing unwanter prex like nas 
            case
                when trim(cntry) = "DE" then "Germany"
                when trim(cntry) in("US", "USA") then "United States"
                when trim(cntry) is null
                or trim(cntry) = "" then "Unknown"
                else trim(cntry)
            end as cntry  -- change the values as readbale 
        from
            bronze.erp_customer_locations
    )
select
    b.CID,
    b.CNTRY
from
    clean_bronze_erp_customer_locations as b
where
    not exists (
        select
            1
        from
            silver.erp_customer_locations as s
        where
            s.customer_ID <=> b.CID
    );
    
    
    -- insert value in   silver.erp_product_categories
    insert into
    silver.erp_product_categories (
        Product_Category_ID,
        Product_category,
        Sub_category,
		MAINTENANCE
    ) with clean_bronze_erp_product_categories as (
        select
            ID,
            case
                when trim(CAT) is null
                or trim(CAT) = "" then "Unknown"
                else trim(CAT)
            end as CAT, --  handle null and empty stg
            case
                when trim(SUBCAT) is null
                or trim(SUBCAT) = "" then "Unknown"
                else trim(SUBCAT)
            end as SUBCAT, --  handle null and empty stg
            case
                when trim(MAINTENANCE) is null
                or trim(MAINTENANCE) = "" then "Unknown"
                else trim(MAINTENANCE)
            end as  MAINTENANCE --  handle null and empty stg
        from
            bronze.stg_erp_product_categories
    )
select
    b.ID,
    b.CAT,
    b.SUBCAT,
    b. MAINTENANCE
from
    clean_bronze_erp_product_categories as b
where
    not exists (
        select
            1
        from
            silver.erp_product_categories as s
        where
            s.Product_Category_ID <=> b.ID
    );
    end // 
    Delimiter ;
drop procedure silver.insert_values;
   call  silver.insert_values();
   
   Delimiter //
create procedure silver.count_tables_rows()
begin

 SELECT "silver.crm_customer_info"as table_name ,COUNT(*) as total_rows FROM silver.crm_customer_info
 union all
 SELECT "silver.crm_product_info",COUNT(*) as total_rows FROM silver.crm_product_info
  union all
 SELECT "silver.crm_sales_info",COUNT(*) as total_rows FROM silver.crm_sales_info
 union all
SELECT "silver.erp_customer_demographics",COUNT(*) as total_rows FROM silver.erp_customer_demographics
 union all
SELECT "silver.erp_customer_locations",COUNT(*) as total_rows  FROM silver.erp_customer_locations
 union all
SELECT"silver.erp_product_categories", COUNT(*) as total_rows from silver.erp_product_categories
 union all
 select "Total",sum(total_rows) from 
 (SELECT "silver.crm_customer_info"as table_name ,COUNT(*) as total_rows FROM silver.crm_customer_info
 union all
 SELECT "silver.crm_product_info",COUNT(*) as total_rows FROM silver.crm_product_info
  union all
 SELECT "silver.crm_sales_info",COUNT(*) as total_rows FROM silver.crm_sales_info
 union all
SELECT "silver.erp_customer_demographics",COUNT(*) as total_rows FROM silver.erp_customer_demographics
 union all
SELECT "silver.erp_customer_locations",COUNT(*) as total_rows  FROM silver.erp_customer_locations
 union all
SELECT"silver.erp_product_categories", COUNT(*) as total_rows from silver.erp_product_categories)
as toltal;
end//

Delimiter ;
call silver.count_tables_rows();
   
Delimiter // 
create procedure silver.truncates () begin TRUNCATE TABLE silver.crm_customer_info;

TRUNCATE TABLE silver.crm_product_info;

TRUNCATE TABLE silver.crm_sales_info;

TRUNCATE TABLE silver.erp_customer_demographics;

TRUNCATE TABLE silver.erp_customer_locations;

TRUNCATE TABLE silver.erp_product_categories;

end // 
Delimiter ;
 call silver.truncates ();
 
