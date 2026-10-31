 -- Creating 3 Database 
 
 -- 1st
 create database bronze;
 -- 2nd
 create database silver;
 -- 3rd
 create database gold;
 -- -- -- -- -- -- --- -- ----------------------------------------------------------------------------------------------------------------------------------------------------
 
 -- WE  creatting the tables
 
 -- bronze. crm_customer_info
 
 -- Drop the table if it already exists
 DROP TABLE IF EXISTS bronze.crm_customer_info;
 
 --  Create the table customer_info
 CREATE TABLE bronze.crm_customer_info(
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(30),
    cst_lastname VARCHAR(30),
    cst_marital_status VARCHAR(10),
    cst_gndr VARCHAR(10),
    cst_create_date DATE
);


--  truncate the tables to refresh
truncate table bronze.crm_customer_info;

-- Allow to isert the values
SET GLOBAL local_infile = 1;

-- insert the values 
load data local infile "C:/PRITHIVI RAJA/D/MY_SQL/Source_crm/customer_info.csv"
into table bronze.crm_customer_info
fields terminated by ','
optionally enclosed by ""
ignore 1 lines
( cst_id ,
    cst_key ,
    cst_firstname ,
    cst_lastname ,
    cst_marital_status ,
    cst_gndr ,
    @cst_create_date)
set cst_create_date = str_to_date(@cst_create_date,'%Y-%m-%d');
    -- to view
    select * from bronze.crm_customer_info;


 
  -- bronze. crm_product_info
   -- Drop the table if it already exists
 DROP TABLE IF EXISTS bronze.crm_product_info;
 
 --  Create the table crm_product_info

CREATE TABLE bronze.crm_product_info (
    prd_id INT,
    prd_key VARCHAR(50),
    prd_nm varchar (100),
    prd_cost INT,
    prd_line VARCHAR(10),
    prd_start_dt DATE,
    prd_end_dt DATE
);
--  truncate the tables to refresh
truncate table bronze.crm_product_info;
-- insert the values 
load data local infile "C:/PRITHIVI RAJA/D/MY_SQL/Source_crm/product_info.csv"
into table bronze.crm_product_info
fields terminated by ","
optionally enclosed by ""
ignore 1 lines
( prd_id ,
    prd_key ,
    prd_nm,
    prd_cost ,
    prd_line ,
    @prd_start_dt ,
    @prd_end_dt)
    set prd_start_dt = str_to_date(@prd_start_dt,'%Y-%m-%d'),
      prd_end_dt = str_to_date( @prd_end_dt,'%Y-%m-%d');
    
    -- to view
    select * from bronze.crm_product_info;
    

-- bronze. crm_sales_info

 -- Drop the table if it already exists
 Drop table if exists bronze.crm_sales_info ;

--  Create the table crm_sales_info
CREATE TABLE bronze.crm_sales_info (
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);
--  truncate the tables to refresh
truncate table bronze.crm_sales_info;

-- insert the values 
load data local infile "C:/PRITHIVI RAJA/D/MY_SQL/Source_crm/sales_details.csv"
into table bronze.crm_sales_info
fields terminated by ","
optionally enclosed by ""
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

 -- to view
    select * from bronze.crm_sales_info;

-- bronze. erp_customer_demographics

--  Create the table erp_customer_demographics
 
 -- Drop the table if it already exists

Drop table if exists bronze.erp_customer_demographics;

--  Create the table crm_sales_info
CREATE TABLE bronze.erp_customer_demographics (
    CID VARCHAR(50),
    BDATE DATE,
    GEN VARCHAR(30)
);
--   truncate the tables to refresh
truncate table bronze.erp_customer_demographics;

-- insert the values 
load data local infile "C:/PRITHIVI RAJA/D/MY_SQL/Source_erp/customer_demographics.csv"
into table bronze.erp_customer_demographics
fields terminated by ","
optionally enclosed by ""
ignore 1 lines
(CID,
@BDATE,
GEN)
set BDATE=str_to_date(@BDATE,"%Y-%m-%d");
 -- to view
select * from bronze.erp_customer_demographics;


-- bronze. erp_customer_locations

--  Create the table erp_customer_locations

 -- Drop the table if it already exists
Drop table if exists bronze.erp_customer_locations;

--  Create the table erp_customer_demographics

create table bronze.erp_customer_locations
(CID varchar(30),CNTRY varchar(30));

 --   truncate the tables to refresh
 truncate table bronze.erp_customer_locations;
 
 -- insert the values 
 load data local infile "C:/PRITHIVI RAJA/D/MY_SQL/Source_erp/customer_locations.csv"
 into table  bronze.erp_customer_locations
 fields terminated by ","
 optionally enclosed by ""
 ignore 1 lines
 (CID,
 CNTRY);
 
  -- to view
    select * from bronze.erp_customer_locations;
    
-- bronze. erp_product_categories

--  Create the table erp_product_categories

 -- Drop the table if it already exists
Drop table if exists bronze.erp_product_categories;

--  Create the table erp_customer_demographics

CREATE TABLE bronze.erp_product_categories (
    ID VARCHAR(50),
    CAT VARCHAR(50),
    SUBCAT VARCHAR(50),
    MAINTENANCE VARCHAR(50)
);

 --   truncate the tables to refresh
 truncate table bronze.erp_product_categories;
 
 -- insert the values 
 load data local infile "C:/PRITHIVI RAJA/D/MY_SQL/Source_erp/product_categories.csv"
 into table bronze.erp_product_categories
 fields terminated by ","
 optionally enclosed by ""
 ignore 1 lines
 (ID,
 CAT,
 SUBCAT,
 MAINTENANCE);


 
  -- to view
    select * from bronze.erp_product_categories;


