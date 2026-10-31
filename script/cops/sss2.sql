-- corss ckecking 

select customer_id,count(*) from
(select 
	cu.customer_id,
    cu.customer_key,
    cu.customer_firstname,
    cu.customer_lastname,
    cu.customer_gender,
    cu.customer_create_date,
    de.customer_birth_date,
    de.gender,
    lo.customer_country
from 
silver.crm_customer_info as cu
left join  silver.erp_customer_demographics as de on cu.customer_key = de.customer_id
left join silver.erp_customer_locations as lo on cu.customer_key = lo.customer_id) as t
group by customer_id
having count(*) >1
;

-- data intergation 

select  distinct
    cu.customer_gender,
	de.gender,
    case when cu.customer_gender !="Unknown" then cu.customer_gender  -- crm is the master for gender info
    else coalesce(de.gender,"Unknown" ) end as new_gen
    
from 
silver.crm_customer_info as cu
left join  silver.erp_customer_demographics as de on cu.customer_key = de.customer_id
left join silver.erp_customer_locations as lo on cu.customer_key = lo.customer_id
order by 1,2;


-- product 
select product_id,count(*) from
(
select  
	pr.product_id,
    pr.product_key,
	pr.category_id,
    pr.product_name,
    pr.product_cost,
    pr.product_line,
    pr.product_start_dt,
    p.Product_category ,
    p.Sub_category ,
    p.MAINTENANCE
from silver.crm_product_info as pr  left join  silver.erp_product_categories as p on pr.category_id = p.Product_Category_ID

 where pr.product_end_dt is null)-- filter out all historical data
 as t group by product_id
having count(*) >1;
select * from silver.erp_product_categories;


--

select sales_order_number,count(sales_order_number)as counts
from silver.crm_sales_info
group by sales_order_number
having counts >1;
-- fk interrity  (dimensions)
select * from gold.sales_fact as f
left join gold.customers_dim as c
on c.customer_key = f.customer_key
left join gold.products_dim as p 
on p.product_key = f.product_key
where  c.customer_key is null and p.product_key ;



