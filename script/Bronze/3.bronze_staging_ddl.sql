/*
===============================================================================

PROJECT : Data Warehouse
FILE    : 3.bronze_staging_ddl.
PURPOSE : Create staging tables in the Bronze database.

OVERVIEW:
    Create six staging tables to hold source data before it is processed into
    the permanent Bronze tables.

DESIGN:
    - Create six regular staging tables in the Bronze database.
    - Use CREATE TABLE IF NOT EXISTS to avoid recreating existing tables.
    - Define columns and data types to match the expected source data.
    - Keep staging tables separate from permanent Bronze tables.
    - Allow staging tables to retain their data between database sessions.

IMPORTANT:
    - CREATE TABLE IF NOT EXISTS does not modify the structure of an existing
      table.
    - Existing staging data is preserved when the tables already exist.
    - Staging data can be truncated and reloaded when required.
    - Permanent Bronze tables are not created or modified by this script.

TABLES CREATED:
    1. bronze.stg_crm_customer_info
    2. bronze.stg_crm_product_info
    3. bronze.stg_crm_sales_info
    4. bronze.stg_erp_customer_demographics
    5. bronze.stg_erp_customer_locations
    6. bronze.stg_erp_product_categories

===============================================================================
*/


-- WE  creatting staging tables
 
 -- 1. bronze. stg_crm_customer_info
 
 --  Create the table stg_crm_customer_info
CREATE TABLE IF NOT EXISTS bronze.stg_crm_customer_info (
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(30),
    cst_lastname VARCHAR(30),
    cst_marital_status VARCHAR(10),
    cst_gndr VARCHAR(10),
    cst_create_date DATE
);

--  2.bronze. stg_crm_product_info

 --  Create the table stg_crm_product_info

CREATE TABLE IF NOT EXISTS bronze.stg_crm_product_info (
    prd_id INT,
    prd_key VARCHAR(50),
    prd_nm VARCHAR(100),
    prd_cost DECIMAL(15,2),
    prd_line VARCHAR(10),
    prd_start_dt DATE,
    prd_end_dt DATE
);

-- 3. bronze. stg_crm_sales_info



--  Create the table stg_crm_sales_info
CREATE TABLE IF NOT EXISTS bronze.stg_crm_sales_info (
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales DECIMAL(15,2),
    sls_quantity INT,
    sls_price DECIMAL(15,2)
);

-- 4. bronze. stg_erp_customer_demographics
 
--  Create the table stg_erp_customer_demographics
CREATE TABLE IF NOT EXISTS bronze.stg_erp_customer_demographics (
    CID VARCHAR(50),
    BDATE DATE,
    GEN VARCHAR(30)
);

-- 5. bronze. stg_erp_customer_locations

--  Create the table stg_erp_customer_locations

CREATE TABLE IF NOT EXISTS bronze.stg_erp_customer_locations (
    CID VARCHAR(30),
    CNTRY VARCHAR(30)
);

-- 6.bronze. stg_erp_product_categories



--  Create the table stg_erp_product_categories
CREATE TABLE IF NOT EXISTS bronze.stg_erp_product_categories (
    ID VARCHAR(50),
    CAT VARCHAR(50),
    SUBCAT VARCHAR(50),
    MAINTENANCE VARCHAR(50)
);




