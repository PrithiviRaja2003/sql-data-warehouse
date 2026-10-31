/*
===============================================================================

PROJECT : Data Warehouse
FILE    : 6.silver_ddl
PURPOSE : Create Silver tables in the Silver database.

OVERVIEW:
    Create six Silver tables to store cleaned and standardized data
    transformed from the permanent Bronze tables.

DESIGN:
    - Create six tables in the Silver database.
    - Use CREATE TABLE IF NOT EXISTS to avoid recreating existing tables.
    - Rename source-specific column names to meaningful business-friendly names.
    - Define appropriate columns and data types for the Silver layer.
    - Add a load_timestamp metadata column to record when each row is inserted.
    - Keep Silver tables separate from permanent Bronze tables.

IMPORTANT:
    - CREATE TABLE IF NOT EXISTS does not modify the structure of an existing
      table.
    - Existing Silver data is preserved when the tables already exist.
    - The load_timestamp column uses DEFAULT CURRENT_TIMESTAMP to automatically
      assign the current date and time when an INSERT does not provide a value.
    - This script creates table structures only; it does not load or transform
      data from Bronze into Silver.
    - Bronze tables are not created or modified by this script.

TABLES CREATED:
    1. silver.crm_customer_info
    2. silver.crm_product_info
    3. silver.crm_sales_info
    4. silver.erp_customer_demographics
    5. silver.erp_customer_locations
    6. silver.erp_product_categories

===============================================================================
*/



-- WE  creatting the tables
 
 -- 1. silver. crm_customer_info
 
 --  Create the table customer_info
CREATE TABLE IF NOT EXISTS silver.crm_customer_info (
    customer_id INT,
    customer_key VARCHAR(50),
    customer_firstname VARCHAR(30),
    customer_lastname VARCHAR(30),
    customer_marital_status VARCHAR(10),
   customer_gender VARCHAR(10),
   customer_create_date DATE,
   load_timestamp datetime default (current_timestamp()),
   updtaed_timestamp datetime default null on update  current_timestamp()
);

--  2.silver. crm_product_info

 --  Create the table crm_product_info

CREATE TABLE IF NOT EXISTS silver.crm_product_info (
    product_id INT,
    product_key VARCHAR(50),
    category_id VARCHAR(50),
    product_name VARCHAR(100),
    product_cost DECIMAL(15,2),
    product_line VARCHAR(50),
    product_start_dt DATE,
    product_end_dt DATE,
    load_timestamp datetime default (current_timestamp()),
    updtaed_timestamp datetime default null on update  current_timestamp()
);

-- 3. silver. crm_sales_info



--  Create the table crm_sales_info
CREATE TABLE IF NOT EXISTS silver.crm_sales_info (
    sales_order_number VARCHAR(50),
    sales_product_key VARCHAR(50),
    sales_customer_id INT,
    sales_order_date DATE,
    sales_shipping_date DATE,
    sales_due_date DATE,
    sales_amount DECIMAL(15,2),
    sales_quantity INT,
    sales_price DECIMAL(15,2),
    load_timestamp datetime default (current_timestamp()),
     updtaed_timestamp datetime default null on update  current_timestamp()
);

-- 4. silver. erp_customer_demographics
 
--  Create the table erp_customer_demographics
CREATE TABLE IF NOT EXISTS silver.erp_customer_demographics (
    customer_ID VARCHAR(50),
    customer_birth_date DATE,
    gender VARCHAR(30),
    load_timestamp datetime default (current_timestamp()),
     updtaed_timestamp datetime default null on update  current_timestamp()
);

-- 5. silver. erp_customer_locations

--  Create the table erp_customer_locations

CREATE TABLE IF NOT EXISTS silver.erp_customer_locations (
    customer_ID VARCHAR(30),
    customer_country VARCHAR(30),
    load_timestamp datetime default (current_timestamp()),
     updtaed_timestamp datetime default null on update  current_timestamp()
);

-- 6.silver. erp_product_categories

--  Create the table erp_product_categories
CREATE TABLE IF NOT EXISTS silver.erp_product_categories (
    Product_Category_ID VARCHAR(50),
    Product_category VARCHAR(50),
    Sub_category VARCHAR(50),
    MAINTENANCE VARCHAR(50),
    load_timestamp datetime default (current_timestamp()),
     updtaed_timestamp datetime default null on update  current_timestamp()
);

 

SELECT 'crm_customer_info' AS table_name, COUNT(*) AS total_rows
FROM silver.crm_customer_info
UNION ALL
SELECT 'crm_product_info', COUNT(*)
FROM silver.crm_product_info
UNION ALL
SELECT 'crm_sales_info', COUNT(*)
FROM silver.crm_sales_info
UNION ALL
SELECT 'erp_customer_demographics', COUNT(*)
FROM silver.erp_customer_demographics
UNION ALL
SELECT 'erp_customer_locations', COUNT(*)
FROM silver.erp_customer_locations
UNION ALL
SELECT 'erp_product_categories', COUNT(*)
FROM silver.erp_product_categories;

drop TABLE silver.crm_customer_info;

drop TABLE silver.crm_product_info;

drop TABLE silver.crm_sales_info;

drop TABLE silver.erp_customer_demographics;

drop TABLE silver.erp_customer_locations;

drop TABLE silver.erp_product_categories;