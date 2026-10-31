/*
===============================================================================
PROJECT : Data Warehouse
FILE    : 2.bronze_ddl
PURPOSE : Create permanent table structures in the Bronze database.

TABLES CREATED:
    1. bronze.crm_customer_info
    2. bronze.crm_product_info
    3. bronze.crm_sales_info
    4. bronze.erp_customer_demographics
    5. bronze.erp_customer_locations
    6. bronze.erp_product_categories

DESIGN NOTES:
    - This script defines table structures only; it does not load CSV data.
    - CREATE TABLE IF NOT EXISTS prevents errors when a table already exists.
    - Existing tables are not recreated or overwritten by this statement.
    - If an existing table has a different structure, this script will not
      update it.
    - Schema changes must be handled separately using appropriate ALTER TABLE
      statements after reviewing the required changes.
    - No DROP TABLE statements are used to avoid accidental data loss.
    - CSV loading is handled separately in 4.bronze_load.sql.
    - Row counts are checked to verify the current contents of the tables.

EXECUTION:
    Run this script after 1.database_layers.

===============================================================================
*/





 -- WE  creatting the tables
 
 -- 1. bronze. crm_customer_info
 
 --  Create the table customer_info
CREATE TABLE IF NOT EXISTS bronze.crm_customer_info (
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(30),
    cst_lastname VARCHAR(30),
    cst_marital_status VARCHAR(10),
    cst_gndr VARCHAR(10),
    cst_create_date DATE
);

--  2.bronze. crm_product_info

 --  Create the table crm_product_info

CREATE TABLE IF NOT EXISTS bronze.crm_product_info (
    prd_id INT,
    prd_key VARCHAR(50),
    prd_nm VARCHAR(100),
    prd_cost DECIMAL(15,2),
    prd_line VARCHAR(10),
    prd_start_dt DATE,
    prd_end_dt DATE
);

-- 3. bronze. crm_sales_info



--  Create the table crm_sales_info
CREATE TABLE IF NOT EXISTS bronze.crm_sales_info (
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

-- 4. bronze. erp_customer_demographics
 
--  Create the table erp_customer_demographics
CREATE TABLE IF NOT EXISTS bronze.erp_customer_demographics (
    CID VARCHAR(50),
    BDATE DATE,
    GEN VARCHAR(30)
);

-- 5. bronze. erp_customer_locations

--  Create the table erp_customer_locations

CREATE TABLE IF NOT EXISTS bronze.erp_customer_locations (
    CID VARCHAR(30),
    CNTRY VARCHAR(30)
);

-- 6.bronze. erp_product_categories



--  Create the table erp_product_categories
CREATE TABLE IF NOT EXISTS bronze.erp_product_categories (
    ID VARCHAR(50),
    CAT VARCHAR(50),
    SUBCAT VARCHAR(50),
    MAINTENANCE VARCHAR(50)
);

 

SELECT 'crm_customer_info' AS table_name, COUNT(*) AS total_rows
FROM bronze.crm_customer_info
UNION ALL
SELECT 'crm_product_info', COUNT(*)
FROM bronze.crm_product_info
UNION ALL
SELECT 'crm_sales_info', COUNT(*)
FROM bronze.crm_sales_info
UNION ALL
SELECT 'erp_customer_demographics', COUNT(*)
FROM bronze.erp_customer_demographics
UNION ALL
SELECT 'erp_customer_locations', COUNT(*)
FROM bronze.erp_customer_locations
UNION ALL
SELECT 'erp_product_categories', COUNT(*)
FROM bronze.erp_product_categories;

