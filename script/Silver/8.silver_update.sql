/*
===============================================================================
PROJECT : Data Warehouse
FILE    : 8.silver_update
PURPOSE : Update existing Silver records when source data changes.

OVERVIEW:
    Compare cleaned and standardized Bronze source data with existing Silver
    records and update only records whose tracked values have changed.

PROCESS:
    1. Clean source data using Common Table Expressions (CTEs).
    2. Standardize customer names, gender, marital status, countries,
       product categories, and other descriptive values.
    3. Correct invalid sales amounts and prices using the defined business rules.
    4. Recalculate product end dates using LEAD() and the next product start date.
    5. Match source records with existing Silver records using JOIN conditions.
    6. Use NULL-safe comparisons (<=>) to detect changes, including NULL values.
    7. Update only rows where at least one tracked value differs.
    8. Preserve existing load_timestamp values during updates.
    9. Allow updated_timestamp to record the latest actual row modification,
       when the column is defined with ON UPDATE CURRENT_TIMESTAMP().

IMPORTANT:
    - This procedure updates existing records; it does not insert missing records.
    - New records must be handled by the separate Silver INSERT procedure.
    - UPDATE statements affect only records that match their JOIN conditions.
    - Matching source keys should be unique to avoid ambiguous source matches.
    - Indexes may improve JOIN performance, but their effectiveness should be
      verified using EXPLAIN and actual query performance.
    - CREATE INDEX statements should be maintained separately from this procedure.
    - CREATE INDEX statements are not required every time this procedure runs.
    - CREATE TABLE IF NOT EXISTS does not modify existing table structures.
    - updated_timestamp must be spelled consistently with the actual table schema.
    - This procedure does not load new CSV files into Bronze.

TABLES UPDATED:
    1. silver.crm_customer_info
    2. silver.crm_product_info
    3. silver.crm_sales_info
    4. silver.erp_customer_demographics
    5. silver.erp_customer_locations
    6. silver.erp_product_categories

EXECUTION:
    CALL silver.update_values();

VALIDATION:
    - Verify updated records and compare Silver values with cleaned Bronze values.
    - Confirm rows with no changes are not unnecessarily updated.
    - Check indexes separately using SHOW INDEX.
    - Review execution plans when performance issues occur.

===============================================================================
*/

-- creating index for silver.crm_customer_info
create index  index_customer_id
on silver.crm_customer_info (customer_id);

-- creating index for silver.crm_product_info
CREATE INDEX idx_product_id
ON silver.crm_product_info (product_id);

 -- creating index for silver.crm_sales_info
CREATE INDEX idx_sales_order_number
ON silver.crm_sales_info (sales_order_number);

 -- creating index for silver.erp_customer_demographics
 create index   dem_customer_ID
on silver.erp_customer_demographics (customer_ID);

-- creating index for silver.erp_customer_locations
create index loc__customer_ID
on silver.erp_customer_locations(customer_ID);

-- creating index for silver.erp_product_categories
create index Category_ID
on silver.erp_product_categories (Product_Category_ID);

Delimiter //
create procedure silver.update_values ()
begin
-- Update existing customers when their details change
with clean_bronze_crm_customer_info as (
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
update
    silver.crm_customer_info as s
    join clean_bronze_crm_customer_info as b on s.customer_id = b.cst_id
set
    s.customer_key = b.cst_key,
    s.customer_firstname = b.cst_firstname,
    s.customer_lastname = b.cst_lastname,
    s.customer_marital_status = b.cst_marital_status,
    s.customer_gender = b.cst_gndr,
    s.customer_create_date = b.cst_create_date
where
       not (b.cst_key <=> s.customer_key)
    or not (b.cst_firstname <=> s.customer_firstname)
    or not (b.cst_lastname <=> s.customer_lastname)
    or not (b.cst_marital_status <=> s.customer_marital_status)
    or not (b.cst_gndr <=> s.customer_gender)
    or not (b.cst_create_date <=> s.customer_create_date);
    
-- Update existing products when their details change
    
  with clean_bronze_crm_product_info as -- cte table
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
update
	 silver.crm_product_info as s 
     join  clean_bronze_crm_product_info as b on  s.product_id = b.prd_id
set
        s.product_key  = b.prd_key,
        s.category_id  = b.cat_id,
        s.product_name = b.prd_nm,
        s.product_cost = b.prd_cost,
        s.product_line = b.prd_line,
        s.product_start_dt = b.prd_start_dt,
        s.product_end_dt =  b.prd_end_dt
     
where  
    not(b.prd_key <=> s.product_key)
 or not(b.cat_id <=>s.category_id)
 or not (b.prd_nm <=>s.product_name)
 or not (b.prd_cost <=>s.product_cost)
 or not (b.prd_line <=>s.product_line)
 or not (b.prd_start_dt <=>s.product_start_dt)
 or not (b.prd_end_dt <=>s.product_end_dt);

-- Update existing sales when their details change
    


with clean_silver_crm_sales_info as (
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
        end as sls_sales,
        sls_quantity,
        case
            when sls_price is null
            or sls_price <= 0 then round(
                abs(sls_sales) / nullif(abs((sls_quantity)), 0),
                2
            )
            else sls_price
        end as sls_price
    from
        bronze.crm_sales_info
)
update
    silver.crm_sales_info as s
    inner join clean_silver_crm_sales_info as b on s.sales_order_number = b.sls_ord_num
    and s.sales_product_key = b.sls_prd_key
set
    s.sales_customer_id = b.sls_cust_id,
    s.sales_order_date = b.sls_order_dt,
    s.sales_shipping_date = b.sls_ship_dt,
    s.sales_due_date = b.sls_due_dt,
    s.sales_amount = b.sls_sales,
    s.sales_quantity = b.sls_quantity,
    s.sales_price = b.sls_price
where
    not (b.sls_cust_id <=> s.sales_customer_id)
    or not (b.sls_order_dt <=> s.sales_order_date)
    or not (b.sls_ship_dt <=> s.sales_shipping_date)
    or not (b.sls_due_dt <=> s.sales_due_date)
    or not (b.sls_sales <=> s.sales_amount)
    or not (b.sls_quantity <=> s.sales_quantity)
    or not (b.sls_price <=> s.sales_price);
    
    -- Update existing customer_demographic when their details change   
with clean_bronze_erp_customer_demographics as (
    select
        case
            when cid regexp "^NAS" then substring(cid, 4, length(cid))
            else cid
        end as cid,
        case
            when bdate > current_date() then null
            else bdate
        end as bdate,
        case
            when upper(trim(gen)) in ("F", "FEMALE") then "Female"
            when upper(trim(gen)) in ("M", "MALE") then "Male"
            else "Unknown"
        end as gen
    from
        bronze.erp_customer_demographics
)
update
    silver.erp_customer_demographics as s
    inner join clean_bronze_erp_customer_demographics as b on s.customer_ID = b.cid
set
    s.customer_birth_date = b.bdate,
    s.gender = b.gen
where
    not (s.customer_birth_date <=> b.bdate)
    or not(s.gender <=> b.gen);
    
  --  Update existing location  when their details change
    
    with clean_bronze_erp_customer_locations as (
    select
        trim(replace(cid, "-", "")) as cid,
        case
            when trim(cntry) = "DE" then "Germany"
            when trim(cntry) in("US", "USA") then "United States"
            when trim(cntry) is null
            or trim(cntry) = "" then "Unknown"
            else trim(cntry)
        end as cntry
    from
        bronze.erp_customer_locations
)
update
    silver.erp_customer_locations as s
    inner join clean_bronze_erp_customer_locations as b on s.customer_ID = b.cid
set
    s.customer_country = b.cntry
where
    not (s.customer_country <=> b.cntry);
    
-- Update existing product_categorie  when their details change
with clean_bronze_erp_product_categories as (
    select
        ID,
        case
            when trim(CAT) is null
            or trim(CAT) = "" then "Unknown"
            else trim(CAT)
        end as CAT,
        case
            when trim(SUBCAT) is null
            or trim(SUBCAT) = "" then "Unknown"
            else trim(SUBCAT)
        end as SUBCAT,
        case
            when trim(MAINTENANCE) is null
            or trim(MAINTENANCE) = "" then "Unknown"
            else trim(MAINTENANCE)
        end as MAINTENANCE
    from
        bronze.stg_erp_product_categories
)
update
    silver.erp_product_categories as s
    inner join clean_bronze_erp_product_categories as b on s.Product_Category_ID = b.ID
set
    s.Product_category = b.CAT,
    s.Sub_category = b.SUBCAT,
    s.MAINTENANCE = b.MAINTENANCE
where
    not (s.Product_category <=> b.CAT)
    or not (s.Sub_category <=> b.SUBCAT)
    or not (s.MAINTENANCE <=> b.MAINTENANCE);
    
    end //
    delimiter ;
    drop procedure silver.update_values;
    
    call silver.update_values ();
    
    SHOW INDEX FROM silver.crm_customer_info;
   


