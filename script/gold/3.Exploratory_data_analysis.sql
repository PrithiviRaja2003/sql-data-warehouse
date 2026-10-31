
/*
===============================================================================

PROJECT : Data Warehouse
FILE    : 3.gold_exploratory_data_analysis
PURPOSE : Explore Gold data to understand business performance, customer
          behavior, product performance, and sales trends.

ANALYSIS SECTIONS:
    1. Database Exploration
    2. Dimensions Exploration
    3. Business Metrics Report
    4. Date Exploration
    5. Measures Exploration
    6. Magnitude Analysis
    7. Ranking Analysis

PROCESS:
    1. Explore database tables and columns using INFORMATION_SCHEMA.
    2. Identify the countries customers come from and explore product
       categories, subcategories, and product names.
    3. Generate a business KPI report containing total sales, sales
       quantity, average price, order count, product count, and customer count.
    4. Explore the first and last order dates and calculate the available
       sales period in months and years.
    5. Calculate total sales, total quantity sold, average selling price,
       order count, product count, and customer count.
    6. Identify customers who have placed orders.
    7. Analyze customer distribution by country and gender.
    8. Analyze product counts and average product costs by category.
    9. Calculate revenue by product category and customer.
   10. Analyze the distribution of sold items across customer countries.
   11. Rank products by revenue to identify the top five and bottom five
       performing products.
   12. Identify the top ten customers by revenue and the three customers
       with the fewest recorded orders.

IMPORTANT:
    - DISTINCT is used to identify unique values.
    - SUM(), AVG(), and COUNT() are used to calculate business metrics.
    - COUNT(DISTINCT ...) counts unique values and avoids counting
      repeated values multiple times.
    - MIN() and MAX() identify the first and last order dates.
    - PERIOD_DIFF() and TIMESTAMPDIFF() are used for date-range analysis.
    - GROUP BY aggregates results by country, gender, category, or customer.
    - COALESCE() replaces NULL values with a specified value.
    - LEFT JOIN connects sales with customer and product information.
    - ORDER BY and LIMIT are used to identify top and bottom performers.
    - ROW_NUMBER() assigns a sequential ranking to query results.
    - Some analyses use Gold views, while revenue and ranking analyses
      also use the physical Gold CTAS tables.
    - LIMIT 3 returns three rows; it does not necessarily include every
      customer tied for the fewest orders.

EXECUTION:
    Run the relevant analysis queries individually to explore the data
    and review business performance.

===============================================================================
*/


-- =============================================================================================
-- =============================================================================================

--  Explore all object in database

select * from information_schema.tables;

-- Explore all coloums in the database
select * from information_schema.columns
where table_schema = "gold" and table_name = "customers_dim";

-- =============================================================================================
-- =============================================================================================
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
-- =============================================================================================
-- =============================================================================================
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
select coalesce(Product_category,"UnKnown") as Product_category,round(avg(product_cost),0)as Average_cost
from gold.products_dim
group by Product_category
order by Average_cost desc;

-- find the total revenue generated for each categoty

SELECT 
    COALESCE(p.Product_category, 'Unknown') AS Product_category,
    COALESCE(SUM(s.sales_amount), 0) AS total_revenue
FROM
    gold.sales_fact_t AS s
        LEFT JOIN
    gold.products_dim_t AS p ON p.product_key = s.product_key
GROUP BY p.Product_category
ORDER BY total_revenue DESC;

-- find the total renvenue is generated by each customer
select
	c.customer_key,
	c.customer_firstname,
    c.customer_lastname,
    sum(s.sales_amount) as sales_amount
from gold.sales_fact_t as s 
left join gold.customers_dim_t as c on s.customer_key = c.customer_key
group by c.customer_key,
		 c.customer_firstname,
         c.customer_lastname
order by sales_amount desc;

-- what is the  distribution of sold items across countries ?
select
	c.customer_country,
    sum(s.sales_quantity) as total_sold_items
from gold.sales_fact_t as s 
left join gold.customers_dim_t as c on s.customer_key = c.customer_key
group by c.customer_country
order by total_sold_items desc;
-- =============================================================================================
-- =============================================================================================
-- ranking 
-- which 5 product gnerate the highest revnue 
SELECT
    COALESCE(p.product_name, 'Unknown') AS product_name,
    COALESCE(SUM(s.sales_amount), 0) AS total_revenue,
    row_number () over (order by COALESCE(SUM(s.sales_amount), 0) desc ) as rank_products
FROM
    gold.sales_fact_t AS s
        LEFT JOIN
    gold.products_dim_t AS p ON p.product_key = s.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC
limit 5;

-- what are the 5 wost performaing product in terms of sales
SELECT
    COALESCE(p.product_name, 'Unknown') AS product_name,
    COALESCE(SUM(s.sales_amount), 0) AS total_revenue
FROM
    gold.sales_fact_t AS s
        LEFT JOIN
    gold.products_dim_t AS p ON p.product_key = s.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC
limit 5;

-- Find the top 10 customers who have gnerated the hight revenue
SELECT 
    c.customer_key,
    c.customer_firstname,
    c.customer_lastname,
    SUM(s.sales_amount) AS sales_amount
FROM
    gold.sales_fact_t AS s
        LEFT JOIN
    gold.customers_dim_t AS c ON s.customer_key = c.customer_key
GROUP BY c.customer_key , c.customer_firstname , c.customer_lastname
ORDER BY sales_amount DESC
LIMIT 10;

-- the 3 customer with fewst order places

SELECT 
    c.customer_key,
    c.customer_firstname,
    c.customer_lastname,
    count(distinct s.sales_order_number) AS total_orders
FROM
    gold.sales_fact_t AS s
        LEFT JOIN
    gold.customers_dim_t AS c ON s.customer_key = c.customer_key
GROUP BY c.customer_key , c.customer_firstname , c.customer_lastname
ORDER BY total_orders ASC
LIMIT 3;

-- =============================================================================================
-- =============================================================================================


	





