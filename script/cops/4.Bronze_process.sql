/*
===============================================================================
PURPOSE : Process data from Bronze staging tables into permanent Bronze tables.
===============================================================================

PROCESS:
    1. Read data from the staging tables.
    2. Insert all source records into the corresponding permanent Bronze tables
       during the initial load, including records with repeated IDs.
    3. Preserve all source records without removing duplicates in the Bronze layer.
    4. Prevent previously loaded records from being inserted again during
       subsequent incremental loads, without losing genuinely new records.
    5. Validate the number of records processed.

IMPORTANT:
    - Do not truncate permanent Bronze tables during normal processing.
    - Repeated IDs in the source data do not automatically mean duplicate records.
    - Preserve source data issues for investigation and cleaning in the Silver layer.
    - Define a reliable record-matching strategy before incremental loading.

===============================================================================
*/

-- 1. insert value in bronze.crm_customer_info
insert into bronze.crm_customer_info
( cst_id ,
    cst_key ,
    cst_firstname ,
    cst_lastname ,
    cst_marital_status ,
    cst_gndr ,
    cst_create_date)
select
           cst_id ,
    cst_key ,
    cst_firstname ,
    cst_lastname ,
    cst_marital_status ,
    cst_gndr ,
    cst_create_date 
                    from bronze.stg_crm_customer_info;
                    
                    
-- 2.insert value in bronze.crm_product_info

insert into bronze.crm_product_info
( prd_id ,
    prd_key ,
    prd_nm,
    prd_cost ,
    prd_line ,
	prd_start_dt ,
    prd_end_dt)

select prd_id ,
    prd_key ,
    prd_nm,
    prd_cost ,
    prd_line ,
	prd_start_dt ,
    prd_end_dt 
               from bronze.stg_crm_product_info;
               
-- 3. insert value in bronze.crm_sales_info

insert into bronze.crm_sales_info
(sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price)

select
         sls_ord_num,
         sls_prd_key,
	     sls_cust_id,
		 sls_order_dt,
		 sls_ship_dt,
		 sls_due_dt,
		 sls_sales,
		 sls_quantity,
		 sls_price 
                    from bronze.stg_crm_sales_info;
                    
-- 4. insert value in bronze.erp_customer_demographics
insert into 
              bronze.erp_customer_demographics  
                                                  (CID,
			                                       BDATE,
                                                   GEN)
              
select  
			  CID,
			  BDATE,
              GEN
                     from bronze.stg_erp_customer_demographics;
                     
                     
-- 5 insert value in bronze.erp_customer_locations
insert into  
             bronze.erp_customer_locations
                                           (CID,
			                                CNTRY)
               
select        
               CID,
			   CNTRY
                       from bronze.stg_erp_customer_locations;
                       
-- 6 insert value in bronze.erp_customer_locations

insert into 
			bronze.erp_product_categories 
                                                (ID,
												 CAT,
                                                 SUBCAT,
                                                 MAINTENANCE)
select 
         ID,
		 CAT,
		 SUBCAT,
		 MAINTENANCE
                        from bronze.stg_erp_product_categories ;
                        


-- to check

 SELECT "bronze.crm_customer_info"as table_name ,COUNT(*) as total_rows FROM bronze.crm_customer_info
 union all
 SELECT "bronze.crm_product_info",COUNT(*) as total_rows FROM bronze.crm_product_info
  union all
 SELECT "bronze.crm_sales_info",COUNT(*) as total_rows FROM bronze.crm_sales_info
 union all
SELECT "bronze.erp_customer_demographics",COUNT(*) as total_rows FROM bronze.erp_customer_demographics
 union all
SELECT "bronze.erp_customer_locations",COUNT(*) as total_rows  FROM bronze.erp_customer_locations
 union all
SELECT"bronze.erp_product_categories", COUNT(*) as total_rows from bronze.erp_product_categories
 union all
 select "Total",sum(total_rows) from 
 (SELECT "bronze.crm_customer_info"as table_name ,COUNT(*) as total_rows FROM bronze.crm_customer_info
 union all
 SELECT "bronze.crm_product_info",COUNT(*) as total_rows FROM bronze.crm_product_info
  union all
 SELECT "bronze.crm_sales_info",COUNT(*) as total_rows FROM bronze.crm_sales_info
 union all
SELECT "bronze.erp_customer_demographics",COUNT(*) as total_rows FROM bronze.erp_customer_demographics
 union all
SELECT "bronze.erp_customer_locations",COUNT(*) as total_rows  FROM bronze.erp_customer_locations
 union all
SELECT"bronze.erp_product_categories", COUNT(*) as total_rows from bronze.erp_product_categories)
as toltal;
