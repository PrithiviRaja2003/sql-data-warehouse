/*
===============================================================================

PROJECT : Data Warehouse
FILE    : 4.bronze_load.
PURPOSE : Load source CSV files into Bronze staging tables.

PROCESS:
    1. Truncate the existing data in the six Bronze staging tables.
    2. Load CSV data into the corresponding staging tables using
       LOAD DATA LOCAL INFILE.
    3. Convert source date formats into valid MySQL DATE values where required.
    4. Validate the number of records loaded into each staging table.
    5. Calculate the total number of records across all six staging tables.

IMPORTANT:
    - Only staging tables are truncated and reloaded by this script.
    - Permanent Bronze tables are not modified by this script.
    - CSV files must be available at the specified file paths.
    - Each CSV file's column order and format must match the load configuration.
    - Review row counts to verify that the data was loaded as expected.

===============================================================================
*/


-- to on the load data
set global local_infile =1;
-- Clear previous staging data
TRUNCATE TABLE bronze.stg_crm_customer_info;
-- 1. insert the values into table bronze.stg_crm_customer_info
load data local infile "C:/PRITHIVI RAJA/D/MY_SQL/Source_crm/customer_info.csv"
into table bronze.stg_crm_customer_info
fields terminated by ','
optionally enclosed by '"'
lines terminated by'\r\n'
ignore 1 lines
( cst_id ,
    cst_key ,
    cst_firstname ,
    cst_lastname ,
    cst_marital_status ,
    cst_gndr ,
    @cst_create_date)
set cst_create_date = str_to_date(@cst_create_date,'%Y-%m-%d');
  
  -- Clear previous staging data
TRUNCATE TABLE bronze.stg_crm_product_info;
-- 2. insert the values into table bronze.stg_crm_product_info

load data local infile "C:/PRITHIVI RAJA/D/MY_SQL/Source_crm/product_info.csv"
into table bronze.stg_crm_product_info
fields terminated by ","
optionally enclosed by  '"'
lines terminated by'\r\n'
ignore 1 lines
(  prd_id ,
    prd_key ,
    prd_nm,
    prd_cost ,
    prd_line ,
    @prd_start_dt ,
    @prd_end_dt)
    set prd_start_dt = str_to_date(@prd_start_dt,'%Y-%m-%d'),
      prd_end_dt = str_to_date( @prd_end_dt,'%Y-%m-%d');
    
-- Clear previous staging data
TRUNCATE TABLE bronze.stg_crm_sales_info;
-- 3.insert the values bronze.stg_crm_sales_info
load data local infile "C:/PRITHIVI RAJA/D/MY_SQL/Source_crm/sales_details.csv"
into table bronze.stg_crm_sales_info
fields terminated by ","
optionally enclosed by  '"'
lines terminated by'\r\n'
ignore 1 lines
(sls_ord_num,
sls_prd_key,
sls_cust_id,
@sls_order_dt,
@sls_ship_dt,
@sls_due_dt,
sls_sales,
sls_quantity,
sls_price)
set sls_order_dt = str_to_date(@sls_order_dt,'%Y%m%d'),
sls_ship_dt = str_to_date(@sls_ship_dt,'%Y%m%d'),
sls_due_dt = str_to_date(@sls_due_dt,'%Y%m%d');

  
-- Clear previous staging data
TRUNCATE TABLE bronze.stg_erp_customer_demographics;

-- 4.insert the values bronze.stg_erp_customer_demographics
load data local infile "C:/PRITHIVI RAJA/D/MY_SQL/Source_erp/customer_demographics.csv"
into table bronze.stg_erp_customer_demographics
fields terminated by ","
optionally enclosed by  '"'
lines terminated by'\r\n'
ignore 1 lines
(CID,
@BDATE,
GEN)
set BDATE=str_to_date(@BDATE,"%Y-%m-%d");
  
-- Clear previous staging data
TRUNCATE TABLE bronze.stg_erp_customer_locations;
    
 -- 5.insert the values bronze.stg_erp_customer_locations
 load data local infile "C:/PRITHIVI RAJA/D/MY_SQL/Source_erp/customer_locations.csv"
 into table  bronze.stg_erp_customer_locations
 fields terminated by ","
 optionally enclosed by  '"'
 lines terminated by'\r\n'
 ignore 1 lines
 (CID,
 CNTRY);
 

-- Clear previous staging data
TRUNCATE TABLE bronze.stg_erp_product_categories;
 -- 6.insert the values  into table bronze.stg_erp_product_categories
 load data local infile "C:/PRITHIVI RAJA/D/MY_SQL/Source_erp/product_categories.csv"
 into table bronze.stg_erp_product_categories
 fields terminated by ","
 optionally enclosed by  '"'
 lines terminated by'\r\n'
 ignore 1 lines
 (ID,
 CAT,
 SUBCAT,
 MAINTENANCE);
 
  -- to check
 

 Delimiter //
 create procedure bronze.count_stg_tables_rows()
begin 

 SELECT "bronze.stg_crm_customer_info"as table_name ,COUNT(*) as total_rows FROM bronze.stg_crm_customer_info
 union all
 SELECT "bronze.stg_crm_product_info",COUNT(*) as total_rows FROM bronze.stg_crm_product_info
  union all
 SELECT "bronze.stg_crm_sales_info",COUNT(*) as total_rows FROM bronze.stg_crm_sales_info
 union all
SELECT "bronze.stg_erp_customer_demographics",COUNT(*) as total_rows FROM bronze.stg_erp_customer_demographics
 union all
SELECT "bronze.stg_erp_customer_locations",COUNT(*) as total_rows  FROM bronze.stg_erp_customer_locations
 union all
SELECT"bronze.stg_erp_product_categories", COUNT(*) as total_rows from bronze.stg_erp_product_categories
 union all
 select "Total",sum(total_rows) from 
 (SELECT "bronze.stg_crm_customer_info"as table_name ,COUNT(*) as total_rows FROM bronze.stg_crm_customer_info
 union all
 SELECT "bronze.stg_crm_product_info",COUNT(*) as total_rows FROM bronze.stg_crm_product_info
  union all
 SELECT "bronze.stg_crm_sales_info",COUNT(*) as total_rows FROM bronze.stg_crm_sales_info
 union all
SELECT "bronze.stg_erp_customer_demographics",COUNT(*) as total_rows FROM bronze.stg_erp_customer_demographics
 union all
SELECT "bronze.stg_erp_customer_locations",COUNT(*) as total_rows  FROM bronze.stg_erp_customer_locations
 union all
SELECT"bronze.stg_erp_product_categories", COUNT(*) as total_rows from bronze.stg_erp_product_categories)
as toltal;

end //
Delimiter ;

call bronze.count_stg_tables_rows();
  
 Delimiter //
 create procedure bronze.stg_truncate ()
 begin
 TRUNCATE TABLE bronze.stg_crm_customer_info;

TRUNCATE TABLE bronze.stg_crm_product_info;

TRUNCATE TABLE bronze.stg_crm_sales_info;

TRUNCATE TABLE bronze.stg_erp_customer_demographics;

TRUNCATE TABLE bronze.stg_erp_customer_locations;

TRUNCATE TABLE bronze.stg_erp_product_categories;
end//
 Delimiter ;

 call bronze.stg_truncate ()
 
