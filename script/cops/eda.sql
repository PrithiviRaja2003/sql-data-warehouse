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
-- -----------------------
-- magnitude

-- Find the total customer by countries
select customer_country ,count(customer_key) as Total_customers
from gold.customers_dim
group by customer_country
order by Total_customers desc;

-- Find the customer by gender
select gender,count(customer_key) as Total_customers
from gold.customers_dim
group by gender
order by Total_customers desc;


-- what is total average costs in each category ?
select coalesce(Product_category,"Unknown") as Product_category,count(product_key) as Total_products
from gold.products_dim
group by Product_category
order by Total_products desc;

-- find the revenue generated for each category ?
select coalesce(Product_category,"UnKnown") as Product_category,avg(product_cost) as Average_cost
from gold.products_dim
group by Product_category
order by Average_cost desc;

-- find the total revenue generated for each categoty
select p.Product_category,sum(s.sales_amount) as Total_revenue
from gold.products_dim as p left join gold.sales_fact as s on p.product_key = s.product_key
group by p.Product_category
order by Total_revenue desc;

select p.Product_category, sum(s.sales_amount)as total_revenue
from gold.products_dim as p left join gold.sales_fact as s on p.product_key = s.product_key
group by p.Product_category
order by total_revenue desc;

SHOW INDEX FROM gold.sales_fact;
SHOW INDEX FROM gold.products_dim;
describe gold.customers_dim;

-- waht is the of sold iteam across countries ?

    

-- ---------------------------------------------------------------------------------------------

--  create a report that all key metrics of the business

select "Total Sales" as  measure_name, sum(sales_amount) as measure_value from gold.sales_fact
union all 
select " Sales Quantity" as  measure_name, sum(sales_quantity) as measure_value from gold.sales_fact
union all
select " Average Price" as  measure_name, round(avg(sales_price),2) as measure_value from gold.sales_fact
union all
select " Total Order Count" as  measure_name, count(distinct sales_order_number) as measure_value from gold.sales_fact
union all
select " Total Products Count" as  measure_name, count(distinct product_id)as measure_value from gold.products_dim
union all
select " Total Customers Count" as  measure_name, count(distinct customer_id)as measure_value from gold.customers_dim;

