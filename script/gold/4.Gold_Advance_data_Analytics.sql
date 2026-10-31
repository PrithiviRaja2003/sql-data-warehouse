/*
===============================================================================

PROJECT : Data Warehouse
FILE    : 4.gold_advanced_data_analytics.sql

PURPOSE :
    To perform advanced data analytics using Gold layer tables and create
    customer-level and product-level reports.

ANALYSIS SECTIONS:

    1. Change Over Time Analysis
       - Monthly analysis
       - Yearly analysis

    2. Cumulative Analysis
       - Monthly sales and running total across months
       - Monthly sales and yearly running total
       - Yearly sales and running average price

    3. Performance Analysis
       - Product yearly sales performance
       - Average sales comparison
       - Previous year sales comparison using LAG()

    4. Part-to-Whole Analysis
       - Category sales contribution
       - Percentage contribution to overall sales

    5. Data Segmentation
       - Product segmentation by cost range
       - Customer segmentation by spending and lifespan

VIEWS CREATED:

    1. gold.customer_report
       - Customer details and age
       - Age group and customer segment
       - Total orders, sales, quantity and products
       - Customer lifespan and recency
       - Average order value
       - Average monthly spend

    2. gold.products_report
       - Product details and category
       - Product performance segment
       - Total customers, orders, sales and quantity
       - Product lifespan and recency
       - Average selling price
       - Average order value
       - Average monthly spend

IMPORTANT:
    - Uses Gold layer tables as the source.
    - Uses window functions for running totals, averages and comparisons.
    - Uses LAG() for previous year sales comparison.
    - Uses CTEs and subqueries for analytical calculations.
    - Uses NULLIF() to prevent division-by-zero errors.
    - Creates customer and product reports as Gold views.

EXECUTION:
    1. Execute the analysis queries section by section.
    2. Create gold.customer_report.
    3. Create gold.products_report.
    4. Validate both reports using SELECT *.

===============================================================================
*/

-- =============================================================================================
-- =============================================================================================

-- change over time analysis

--  month over analysis

select
	year(sales_order_date) as order_year,
    monthname(sales_order_date) as order_month,
    count(distinct customer_key) as toltal_customer,
    sum(sales_quantity) as total_quantity,
    sum(sales_amount) as total_sales
from gold.sales_fact_t
where sales_order_date is not null
group by order_year,order_month,month(sales_order_date) 
order by order_year asc , month(sales_order_date) asc;

--  Year over analysis
select
	year(sales_order_date) as order_year,
	count(distinct customer_key) as toltal_customer,
    sum(sales_quantity) as total_quantity,
    sum(sales_amount) as total_sales
from gold.sales_fact_t
where sales_order_date is not null
group by order_year
order by order_year asc ;

    
    
-- =============================================================================================
-- =============================================================================================

-- Cumulative analysis

-- calculte the total sales per month
-- and runing total of sales  time across month
 
 select
	order_year,
    order_month,
    total_sales,
    sum( total_sales) over(order by order_year asc,order_month_num asc ) as running_total_sales
from
	(	 
	 select 
		year(sales_order_date) as order_year,
		monthname(sales_order_date) as order_month,
        month(sales_order_date) as order_month_num,
		sum(sales_amount) as total_sales
	from gold.sales_fact_t
	where sales_order_date is not null
	group by order_year , order_month ,order_month_num) as t;
    
    
    --   Calculate Monthly Sales and Yearly Running Total
    
     select
	order_year,
    order_month,
    total_sales,
    sum( total_sales) over(partition by order_year   order by order_year asc,order_month_num asc ) as running_total_sales
from
	(	 
	 select 
		year(sales_order_date) as order_year,
		monthname(sales_order_date) as order_month,
        month(sales_order_date) as order_month_num,
		sum(sales_amount) as total_sales
	from gold.sales_fact_t
	where sales_order_date is not null
	group by order_year , order_month ,order_month_num) as t;

-- calculte the total sales per month 
-- and runing total of sales  and moving avg price time across year

select
	order_year,
    total_sales,
    sum( total_sales) over(order by order_year asc ) as running_total_sales,
    round(avg(avg_price) over(order by order_year asc ),2) as running_Average_price
from
	(	 
	 select 
		year(sales_order_date) as order_year,
		sum(sales_amount) as total_sales,
        avg(sales_price)as avg_price
	from gold.sales_fact_t
	where sales_order_date is not null
	group by order_year) as t;
    
-- =============================================================================================
-- =============================================================================================

-- Performance analysis

-- analyze	 the yearly perfomace of products by comparing their sales
-- to both the average sales performace of the product and the previous year sales

select
	order_year
    product_name,
    current_sales,
    -- year over year
	round(avg(current_sales)  over (partition by product_name),2)as avg_sales,
    current_sales-  round(avg(current_sales)  over (partition by product_name),2) as diff_sales,
    case when current_sales-  round(avg(current_sales)  over (partition by product_name),2) >0 then "Above Avg"
    when current_sales-  round(avg(current_sales)  over (partition by product_name),2) <0 then "Below Avg"
    else "Avg" end  as Avg_criteria,
    lag(current_sales) over (partition by product_name order by order_year) as py_sales,
    current_sales-  lag(current_sales) over (partition by product_name order by order_year) as py_year_dif,
    case when current_sales-  lag(current_sales) over (partition by product_name order by order_year)  >0 then "Increase"
    when current_sales-  lag(current_sales) over (partition by product_name order by order_year)  <0 then "Decrease"
    when current_sales-  lag(current_sales) over (partition by product_name order by order_year) = 0 then "No Change"
    else "No Previous year " end  as py_year_criteria
from 
(
	select 
		year(s.sales_order_date) as order_year,
		p.product_name,
		sum(s.sales_amount) as current_sales
	from gold.sales_fact_t as s
	left join gold.products_dim_t as p 
	on s.product_key = p.product_key
	where year(s.sales_order_date) is not  null
	group by order_year, p.product_name
    order by  p.product_name asc ,  order_year asc) as t;
    
-- =============================================================================================
-- =============================================================================================
-- Part to  whole analysis

-- Which categoties contribute the most to overall sales

with sales_category as 
(
select
	p.Product_category,
	sum(s.sales_amount) as total_sales
from gold.sales_fact_t as s
left join gold.products_dim_t as p
on s.product_key = p.product_key
group by p.Product_category 
)
select 
	Product_category,
    total_sales,
    sum(total_sales) over () as overall_sales,
   concat(round((total_sales/sum(total_sales) over ()*100),2),"%") as percentage_of_sales
from sales_category
order by total_sales desc;

-- =============================================================================================
-- =============================================================================================

-- Data Segmentation

-- Segment products into cost range and count how many product fall into each segement

with segment_product as
(
select 
	product_key,
    product_name,
    product_cost,
    case when product_cost <100 then "Below 100"
    when product_cost between 100 and 500 then "100 - 500"
    when product_cost between 501 and 1000 then "501 - 1000"
    else "Above 1000" end as cost_range
from gold.products_dim_t
)
select 
	cost_range,
    count(product_key) as total_products
    from segment_product 
    group by cost_range
    order by total_products desc;
    
/*  group customer into three segment based on there spending behavior
-- VIP : customer with at least 12 months of history and spending more than 5000
-- regular:customer with at least 12 months of history and spending 5000 or less
-- new customer with lifespan less than 12 months
and find the total number of customer by each group */



with sales as
(
select
     c.customer_key,
     sum(s.sales_amount) total_spending,
     min(s.sales_order_date) as first_order,
     max(s.sales_order_date) as last_order,
     timestampdiff(month,min(s.sales_order_date),max(s.sales_order_date)) as life_span
from gold.sales_fact_t as s
left join gold.customers_dim_t as c
on s.customer_key = c.customer_key
group by c.customer_key
)
select
	case when life_span >= 12 and total_spending>5000 then "VIP Customer"
	when life_span >= 12 and total_spending <=5000 then "Regular Customer"
    else "New Customer" end as customer_segment ,
    count(customer_key) as total_customer
from sales
group by customer_segment 
order by total_customer  desc;

-- =============================================================================================
-- =============================================================================================

-- Build customer report

/*
-- =============================================================================================
      Customer Report
-- =============================================================================================

pupose
- this report consolidates key customer metrics and behaviors

Highlights :

1. Gathers essential fields such as names ,ages , and transaction details
2. segments customers into categories (vip , regular , new ) and age groups
3. Aggregates customers  - level metrics :
   - total orders
   - total sales
   - total quantity purchased
   - total products
   - lifespan in  months
4 calculates valuble Kpi

   -- Recency (Month since last order)
   -- average order values
   -- average monthly spend
  -- ============================================================================================= */
  
  -- 1) Base Query Retrieves core colums from tbales
create view gold.customer_report as
with base as
(
select 
	s.sales_order_number,
    s.product_key,
    s.sales_order_date,
    s.sales_amount,
    s.sales_quantity,
    c.customer_key,
    c.customer_number,
    concat(c.customer_firstname," ",c.customer_lastname) as customer_name,
    timestampdiff(year,c.customer_birth_date,current_date()) as customer_age
from gold.sales_fact_t as s
left join gold.customers_dim_t as c
on s.customer_key = c.customer_key
where sales_order_date is not null
)
,base_2 as
(
select
	  customer_key,
      customer_number,
      customer_name,
	  customer_age,
      count(sales_order_number) as total_orders,
      count(distinct product_key) as total_product,
      sum(sales_amount) as total_sales,
      sum(sales_quantity) as total_quantity,
      max(sales_order_date) as last_order,
      timestampdiff(month,min(sales_order_date),max(sales_order_date)) as life_span
from base
group by
	  customer_key,
      customer_number,
      customer_name,
	  customer_age
)
-- =============================================================================================
   -- final query to  customers Report
-- =============================================================================================
select 
	  customer_key,
      customer_number,
      customer_name,
	  customer_age,
      case when customer_age <20 then "Under 20"
		   when customer_age between 20 and 29 then "20-29"
           when customer_age between 30 and 39 then "30-39"
           when customer_age between 40 and 49 then "40-49"
           else "50 Above" end as age_group,
	  case when life_span >= 12 and total_sales>5000 then "VIP Customer"
	  when life_span >= 12 and total_sales <=5000 then "Regular Customer"
      else "New Customer" end as customer_segment,
 	  last_order,
      timestampdiff(month ,last_order,current_date()) as recency,   
      total_orders,
      total_sales,
      total_quantity,
      total_product,
	  life_span,
      -- compuate average order values (avg)
       round((total_sales /nullif(total_orders,0)),2) as avg_order_values,
	 -- computae average monthly spend
        (total_sales/nullif(life_span,0)) as avg_monthly_spend
from base_2;
      
select * from gold.customer_report;

-- =============================================================================================
-- =============================================================================================

    
 /*
-- =============================================================================================
  Product Report
-- =============================================================================================
Purpose :
  -- this report consolidates key product metrics and behaviors.

Highlights ;

1. Gathers essential fields such as product name , category ,subcategory and cost
2. segment products by revue to identify  high-performers, mid-range , or low- performers.
3. aggregates products - level metrics
	- total orders
    - total sales
    - total quantity (unique)
    - lifespan (in months)
4 . calculated valuable Kpi 
	-- rency (months since last sale)
    -- average order revenue (AOR)
    -- average monthly revenue */
 
 create view gold.products_report as
with base as
(
select 
	p.product_key,
    p.product_name,
    p.Product_category,
    p.Sub_category,
    p.product_cost,
    s.customer_key,
    s.sales_order_number,
    s.sales_quantity,
    s.sales_amount,
    s.sales_order_date
from gold.sales_fact_t as s
left join gold.products_dim_t as p
on s.product_key = p.product_key
where s.sales_order_date is not null -- only consider vaild sales date
)
, base_2 as
(
select
    product_key,
    product_name,
    Product_category,
    Sub_category,
    product_cost,
    count(distinct customer_key) as total_customer,
	sum(sales_amount) as total_sales,
    count(distinct sales_order_number) as total_orders,
    sum(sales_quantity) as total_quantity,
	max(sales_order_date) as last_order,  
	timestampdiff(month,min(sales_order_date),max(sales_order_date)) as life_span,
   round(sum(sales_amount)/nullif(sum(sales_quantity),0),2) as avg_selling_price
from base
group by     
	product_key,
    product_name,
    Product_category,
    Sub_category,
    product_cost
)
-- =============================================================================================
   -- final query to  Product Report
-- =============================================================================================
select
    product_key,
    product_name,
    Product_category,
    Sub_category,
    product_cost,
	  case when  total_sales>50000 then "High Performers"
	  when total_sales <=10000 then "Mid Range"
      else "Low Performers" end as product_segment,
	 life_span,
     total_orders,
     total_quantity,
     total_sales,
     total_customer,
	 last_order,
     avg_selling_price,
     timestampdiff(month ,last_order,current_date()) as recency,
	 -- compuate average order revenue (avg)
      round(total_sales /nullif(total_orders,0),2) as avg_order_values,
	 -- computae average monthly spend
        round((total_sales/nullif(life_span,0)),2) as avg_monthly_spend
from base_2; 

select * from gold.products_report;	

-- =============================================================================================
-- =============================================================================================

    
