
/*
===============================================================================

PROJECT : Data Warehouse
FILE    : 1.gold_view
PURPOSE : Create Gold views for customer dimensions, product dimensions,
          and sales fact data.

VIEWS:
    1. gold.customers_dim
    2. gold.products_dim
    3. gold.sales_fact

PROCESS:
    1. Create the customer dimension view using Silver customer data,
       customer demographics, and customer location data.
    2. Generate customer_key using ROW_NUMBER() and handle NULL values
       using COALESCE().
    3. Apply customer gender logic, prioritizing CRM gender and using
       demographic gender when CRM gender is Unknown.
    4. Create the product dimension view by joining Silver product data
       with product category information.
    5. Generate product_key using ROW_NUMBER() and exclude historical
       products where product_end_dt IS NOT NULL.
    6. Create the sales fact view by joining sales data with customer
       and product dimension views.
    7. Retrieve customer_key and product_key for sales records through
       the dimension joins.

IMPORTANT:
    - These are views, not physical tables.
    - Views retrieve data from their underlying source tables when queried.
    - Customer and product keys are generated using ROW_NUMBER().
    - Product history is filtered using product_end_dt IS NULL.
    - The sales fact view uses LEFT JOINs to connect sales with dimensions.
    - The views are the source for the Gold CTAS tables.

EXECUTION:
    SELECT * FROM gold.customers_dim;
    SELECT * FROM gold.products_dim;
    SELECT * FROM gold.sales_fact;

===============================================================================
*/


-- view  for gold.dim
create view gold.customers_dim as
select
   coalesce( row_number () over (
        order by
            customer_id),0
    ) as customer_key,
    cu.customer_id,
    cu.customer_key as customer_number,
    cu.customer_firstname,
    cu.customer_lastname,
    lo.customer_country,
    cu.customer_marital_status,
    case
        when cu.customer_gender != "Unknown" then cu.customer_gender -- crm is the master for gender info
        else coalesce(de.gender, "Unknown")
    end as gender,
    de.customer_birth_date,
    cu.customer_create_date
from
    silver.crm_customer_info as cu
    left join silver.erp_customer_demographics as de on cu.customer_key = de.customer_id
    left join silver.erp_customer_locations as lo on cu.customer_key = lo.customer_id;
select * from gold.customers_dim  ;
drop view gold.customers_dim ;


-- view  for product.dim
create view gold.products_dim as
select
    row_number() over (
        order by
            pr.product_start_dt,
            pr.product_id
    ) as product_key,
    pr.product_id,
    pr.product_key as product_number,
    pr.product_name,
    pr.category_id,
    p.Product_category,
    p.Sub_category,
    pr.product_cost,
    pr.product_line,
    p.MAINTENANCE as maintenance,
    pr.product_start_dt
from
    silver.crm_product_info as pr
    left join silver.erp_product_categories as p on pr.category_id = p.Product_Category_ID
where
    pr.product_end_dt is null; -- filter out all historical data

select * from gold.products_dim;

-- view  for sales.dim
create view gold.sales_fact as
	select
		s.sales_order_number,
		p.product_key,
		c.customer_key,
		s.sales_order_date,
		s.sales_shipping_date,
		s.sales_due_date,
		s.sales_amount,
		s.sales_quantity,
		s.sales_price
from  silver.crm_sales_info as s left join gold.customers_dim as c  on s.sales_customer_id = c.customer_id
left join gold.products_dim as p on  s.sales_product_key = p.product_number;

select * from gold.sales_fact;




