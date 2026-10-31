-- check for un water spces
-- exp : no result 

select 
	prd_key
from bronze.crm_product_info
where prd_key <> trim(prd_key);

select 
	prd_nm
from bronze.crm_product_info
where prd_nm <> trim(prd_nm);

select 
	prd_line
from bronze.crm_product_info
where prd_line <> trim(prd_line);


-- ckeck for null or negative number 
-- expection no result 
select 
    prd_id,
	prd_cost
from bronze.crm_product_info
where prd_cost <= 0  or prd_cost is null;

-- to see chage to reabel
select 
	distinct(prd_line) 
    from bronze.crm_product_info;



select 
	prd_id ,
    replace(substring(prd_key ,1,5),"-","_") as cat_id,  -- cat id in cat table
    substring(prd_key,1,length(prd_key)) as prd_key ,--  sales_prd_key in sales table
    prd_nm,
    coalesce(prd_cost,0) as prd_cost,
     case when upper(trim(prd_line)) = "R" then "Road"
     when upper(trim(prd_line)) = "S" then"Others Sales"
     when upper(trim(prd_line)) = "M" then"Mountain"
     when upper(trim(prd_line)) = "T" then"Touring"
     else "Unkown" end  as prd_line, -- change the  sprd_line to readable
	prd_start_dt ,
    date_sub(lead(prd_start_dt)over (partition by prd_key order by prd_start_dt asc),interval 1 day)prd_end_dt
from bronze.crm_product_info;




select prd_line,
case upper(trim(prd_line))
 when   "R" then "Road"
     when "S" then"Others Sales"
     when"M" then"Mountain"
     when"T" then"Touring"
     else "Unkown" end  as prd_line from bronze.crm_product_info;
     
-- check the in valid date oreders
select * from bronze.crm_product_info
where  prd_end_dt < prd_start_dt ;
-- for test 
select * ,
date_sub(lead(prd_start_dt)over (partition by prd_key order by prd_start_dt asc),interval 1 day) as test from bronze.crm_product_info
where  prd_key in ("AC-HE-HL-U509-R","AC-HE-HL-U509") ;

alter table silver.crm_product_info
add column category_id VARCHAR(50) after product_key;

ALTER TABLE silver.crm_product_info
MODIFY COLUMN category_id VARCHAR(50) AFTER product_key;
describe silver.crm_product_info;

select
	prd_id ,
    count(prd_id) as counts
from bronze.crm_product_info
group by prd_id 
having counts > 1;
alter table silver.crm_product_info
modify product_line varchar(50);


select * from silver.crm_product_info;

-- sales table 

select
	trim(sls_ord_num)as sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	 case when sls_sales is null or sls_sales <=0 or sls_sales!=abs(sls_quantity)*abs(sls_price)
    then round(abs((sls_quantity))*(  case when sls_price is null or sls_price <=0
    then  abs(sls_sales)/nullif(abs((sls_quantity)),0)
    else sls_price end  ),2)
    else sls_sales end as sls_sales,
	sls_quantity,
	case when sls_price is null or sls_price <=0
    then round( abs(sls_sales)/nullif(abs((sls_quantity)),0),2)
    else sls_price end  as sls_price
from bronze.crm_sales_info;
-- to ckaeck the sales orddr id unquie

select sls_ord_num ,count(sls_ord_num) as counts
from bronze.crm_sales_info
group by sls_ord_num
having counts >1 ;

select
	* 
from bronze.crm_sales_info where sls_ord_num = "SO51415";
-- ckeck the in valied date
select
	* 
from bronze.crm_sales_info
where  sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt ;

--  check data consistency between sales , quantity and price
-- >> sales = quantity * price
-- >> values mucst not be null ,zero,negative
select distinct
	sls_sales as old_sls_sales,
    sls_quantity,
    sls_price as old_sls_price,
    case when sls_sales is null or sls_sales <=0 or sls_sales!=abs(sls_quantity)*abs(sls_price)
    then round(abs((sls_quantity))*(  case when sls_price is null or sls_price <=0
    then  abs(sls_sales)/nullif(abs((sls_quantity)),0)
    else sls_price end  ),2)
    else sls_sales end as sls_sales  ,
    case when sls_price is null or sls_price <=0
    then round( abs(sls_sales)/nullif(abs((sls_quantity)),0),2)
    else sls_price end  as sls_price

from bronze.crm_sales_info
where sls_sales != sls_quantity *   sls_price 
or sls_sales is null or sls_quantity is null or sls_price is null
or sls_sales <=0 or sls_quantity <=0 or sls_price <=0
order by 	sls_sales,sls_quantity,sls_price ;
select * from silver.crm_sales_info;


-- erp_customer_demographics
select 
    case when cid regexp "^NAS" then substring(cid ,4,length(cid))
    else  cid end as cid_2,
    case when bdate>current_date() then null
    else bdate end  as bdate,
    case 
when upper(trim(gen)) in ("F","FEMALE") then "Female"
when upper(trim(gen)) in ("M","MALE") then "Male"
else "Unkown" end as gen
from bronze.erp_customer_demographics;
-- date  out of range 
select distinct
bdate from bronze.erp_customer_demographics
where bdate or bdate > current_date();

-- gen dta consistency
select distinct trim(gen),
case 
when upper(trim(gen)) in ("F","FEMALE") then "Female"
when upper(trim(gen)) in ("M","MALE") then "Male"
else "Unkown" end as gen_2
from  bronze.erp_customer_demographics;


--   to ckeck unqi

select  
	cid ,
    count(cid) as counts from bronze.erp_customer_demographics
    group by cid
    having counts> 1 or  counts is null ;
    
select
    case when cid regexp "^NAS" then substring(cid ,4,length(cid))
    else  cid end as cid_2,
    count(case when cid regexp "^NAS" then substring(cid ,4,length(cid))
    else  cid end ) as counts from bronze.erp_customer_demographics
    group by  cid_2
    having counts>1;
    

SELECT DISTINCT gen,
CASE
    WHEN UPPER(TRIM(REPLACE(REPLACE(gen, '\r', ''), '\n', ''))) IN ('F','FEMALE') THEN 'Female'
    WHEN UPPER(TRIM(REPLACE(REPLACE(gen, '\r', ''), '\n', ''))) IN ('M','MALE')   THEN 'Male'
    ELSE 'Unknown'
END AS gen_2
FROM bronze.erp_customer_demographics;

-- LINES TERMINATED BY '\r\n'

select * from bronze.crm_customer_info;

select *,length(maintenance) from bronze.erp_product_categories;



-- bronze.erp_customer_locations 
select
	replace(cid,"-","") as cid,
     case
	when trim(cntry) = "DE" then "Germany"
    when trim(cntry) in( "US","USA") then "United States"
     when trim(cntry) is null or trim(cntry) = "" then "Unknown"
    else trim(cntry) end as cntry
from 
	bronze.erp_customer_locations;
    
-- ckeck unwi in cid 
select 
	replace(cid,"-","") as cid_2,
    count(replace(cid,"-","") ) as counts
    from bronze.erp_customer_locations
    group by cid_2
    having counts >1 or  counts is null;
    
-- check the country

select  distinct
	trim(cntry),
    length(trim(cntry)),
    case 
    when trim(cntry) = "DE" then "Germany"
    when trim(cntry) in( "US","USA") then "United States"
    when trim(cntry) is null or trim(cntry) = "" then "Unknown"
    else trim(cntry) end as cntry
from 
	bronze.erp_customer_locations;
    
 -- --------------------------------------------
 -- bronze.stg_erp_product_categories
 
select 
         ID,
		 CAT,
		 SUBCAT,
		 MAINTENANCE
                        from bronze.stg_erp_product_categories ;
                        
-- data standrdiztion 
select distinct
trim(CAT) as CAT
from bronze.stg_erp_product_categories ;
-- 
select distinct
trim(SUBCAT) as SUBCAT
from bronze.stg_erp_product_categories ;
-- 
select distinct
trim( MAINTENANCE) as  MAINTENANCE
from bronze.stg_erp_product_categories ;

                        
	-- id unique 
    
select 
         trim(ID) as id_1,
        count(trim(ID)) as counts
          from bronze.stg_erp_product_categories
        group by id_1
        having counts >1 or counts is null;
