--  Explore all oject in database

select * from information_schema.tables;

-- Explore all coloums in the database
select * from information_schema.columns
where table_schema = "gold" and table_name = "customers_dim";

-- -- --------------------------------------------------
-- Dimensions Exploration

-- 1 . Explore all countries our customer come from

select distinct
	customer_country
from gold.customers_dim;

-- 2. Explore all categories "The major Division"

select distinct
	Product_category,
    Sub_category,
    product_name
from gold.products_dim
order by 1,2,3;

-- --------------------------------------------------------
-- Date Exloration
-- find the date of first and last order 
-- how many year of sales are avaiable

select
	min(sales_order_date) as first_order_date,
    max(sales_order_date) as last_order_date,
    period_diff(date_format(max(sales_order_date),"%y%m"),date_format(min(sales_order_date) ,"%y%m")) as  order_range_month,
   year(max(sales_order_date)) - year(min(sales_order_date)) as order_range_years
from gold.sales_fact;

--
select
	min(sales_order_date) as first_order_date,
    max(sales_order_date) as last_order_date,
	timestampdiff(month,min(sales_order_date), max(sales_order_date)) as order_range_month,
    timestampdiff(year,min(sales_order_date), max(sales_order_date)) as order_range_years
    from gold.sales_fact;
    
-- -- --------------------------------------
-- Mesures Exprolration
-- find the total sales
select 
	sum(sales_amount) as total_sales
from gold.sales_fact;

-- find the how many item are sold
select 
	sum(sales_quantity) as total_quantity
from gold.sales_fact;

-- find the average selling price
select 
	round(avg(sales_price),2) as average_selling_price
from gold.sales_fact;

-- find the the tolat number of orders
select 
	count( sales_order_number) as total_orders
from gold.sales_fact;

select 
	count(distinct sales_order_number) as total_orders
from gold.sales_fact;

-- find the total number of products
select 
	count(product_id)as total_product
from gold.products_dim;
select 
	count(distinct product_id)as total_product
from gold.products_dim;

-- find the total number customer
select 
	count( customer_id)as total_customer
from gold.customers_dim;
select 
	count(distinct customer_id)as total_customer
from gold.customers_dim;
-- find the total number of customer that has place an order
select 
	count(distinct c.customer_id) as order_customers
from gold.customers_dim as c
inner join gold.sales_fact as s on c.customer_key = s.customer_key;

select 
	count(distinct customer_key)as total_customer
from gold.sales_fact;



    



