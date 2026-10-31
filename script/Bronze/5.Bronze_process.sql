/*
===============================================================================

PROJECT : Data Warehouse
FILE    : 5.bronze_process
PURPOSE : Process data from Bronze staging tables into permanent Bronze tables.
PROCEDURE: bronze.refresh()

PROCESS:
    1. Read data from the six Bronze staging tables.
    2. Compare staging records with records in the corresponding permanent
       Bronze tables.
    3. Insert staging records that do not have an exact matching record in
       the permanent Bronze table.
    4. Use NULL-safe comparisons (<=>) to compare column values, including NULLs.
    5. Preserve source data and repeated IDs for further investigation in the
       Silver layer.
    6. Validate permanent Bronze table row counts using the
       bronze.count_tables_rows() procedure.

IMPORTANT:
    - Load or refresh CSV data in the staging tables before calling bronze.refresh().
    - The refresh procedure does not directly import CSV files.
    - Do not truncate permanent Bronze tables during normal incremental loading.
    - Repeated IDs do not automatically mean duplicate records.
    - Exact matching across all columns is the current record-matching strategy.
    - Identical repeated records within staging may still be inserted more than
      once in a single execution; duplicate-safe processing needs further testing.
    - Investigate and clean source data issues in the Silver layer.

EXECUTION:
    CALL bronze.refresh();
    CALL bronze.count_tables_rows();

===============================================================================
*/


/* ===============================================================================================================================================================
                                                    Insert new rows
    ===============================================================================================================================================================*/

Delimiter //
create procedure bronze.refresh()
begin

-- 1. Insert new rows into crm_customer_info

insert into bronze.crm_customer_info
( cst_id ,
    cst_key ,
    cst_firstname ,
    cst_lastname ,
    cst_marital_status ,
    cst_gndr ,
    cst_create_date)
select
           s.cst_id ,
           s.cst_key ,
           s.cst_firstname ,
           s.cst_lastname ,
           s.cst_marital_status ,
           s.cst_gndr ,
		   s.cst_create_date 
                    from bronze.stg_crm_customer_info as s
			where not exists ( 
                              select 1 from  bronze.crm_customer_info as b
                              where     b.cst_id <=> s.cst_id
									and b.cst_key <=>  s.cst_key
                                    and b.cst_firstname <=>  s.cst_firstname
									and b.cst_lastname <=>  s.cst_lastname
                                    and b.cst_marital_status <=>  s.cst_marital_status
									 and b.cst_gndr <=>   s.cst_gndr
		                             and b.cst_create_date <=>  s.cst_create_date );
                    

-- 2. Insert new rows into crm_product_info

insert into bronze.crm_product_info
(   prd_id ,
    prd_key ,
    prd_nm,
    prd_cost ,
    prd_line ,
	prd_start_dt ,
    prd_end_dt)

select  s.prd_id ,
		s.prd_key ,
        s.prd_nm,
        s.prd_cost ,
        s.prd_line ,
	    s.prd_start_dt ,
        s.prd_end_dt 
               from bronze.stg_crm_product_info as s
			where not exists (
                                  select 1 from  bronze.crm_product_info as b
                                  where 
                                               b.prd_id   <=>  s.prd_id
                                          and  b.prd_key  <=>  s.prd_key 
										  and  b.prd_nm   <=>  s.prd_nm
										  and  b.prd_cost  <=>  s.prd_cost
                                          and  b.prd_line <=>  s.prd_line
	                                      and  b.prd_start_dt <=>  s.prd_start_dt
										  and  b.prd_end_dt <=>  s.prd_end_dt );
                                          
    
                      
  -- 3. Insert new rows into crm_sales_info             

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
         s.sls_ord_num,
         s.sls_prd_key,
	     s.sls_cust_id,
		 s.sls_order_dt,
		 s.sls_ship_dt,
		 s.sls_due_dt,
		 s.sls_sales,
		 s.sls_quantity,
		 s.sls_price 
                    from bronze.stg_crm_sales_info as s
                   where not exists  (
                                       select 1 from bronze.crm_sales_info as b
									 where   
                                           b.sls_ord_num        <=> s.sls_ord_num
                                          and b.sls_prd_key     <=>  s.sls_prd_key
                                          and b.sls_cust_id     <=>  s.sls_cust_id
                                          and b.sls_order_dt    <=>  s.sls_order_dt
                                          and b.sls_ship_dt     <=>  s.sls_ship_dt
                                          and b.sls_due_dt      <=>  s.sls_due_dt
                                          and b.sls_sales       <=>  s.sls_sales
                                          and b.sls_quantity    <=>  s.sls_quantity
                                          and b.sls_price       <=>  s.sls_price );
                                      

 
    
-- 4. Insert new rows into erp_customer_demographics

insert into 
              bronze.erp_customer_demographics  
                                                  (CID,
			                                       BDATE,
                                                   GEN)
              
select  
			  s.CID,
			  s.BDATE,
              s.GEN
                     from bronze.stg_erp_customer_demographics as s
                      where 
                           Not Exists ( 
                                         Select 1 from  bronze.erp_customer_demographics as b
                                         where  
                                                    b.CID    <=>  s.CID
			                                     and b.BDATE  <=>  s.BDATE
                                                 and b.GEN    <=>  s.GEN  );
  
											
-- 5. Insert new rows into erp_customer_locations

insert into  
             bronze.erp_customer_locations
                                           (CID,
			                                CNTRY)
               
select        
               s.CID,
			   s.CNTRY
                       from bronze.stg_erp_customer_locations as s
					Where Not Exists (  select 1 from bronze.erp_customer_locations as b
                                        where      b.CID    <=>  s.CID
			                                   and b.CNTRY  <=>   s.CNTRY );
	
     	
-- 6. Insert new rows into erp_product_categories

insert into 
			bronze.erp_product_categories 
                                                (ID,
												 CAT,
                                                 SUBCAT,
                                                 MAINTENANCE)
select 
         s.ID,
		 s.CAT,
		 s.SUBCAT,
		 s.MAINTENANCE
                        from bronze.stg_erp_product_categories as s
					where Not Exists ( Select 1 from bronze.erp_product_categories  as b
                                        Where  
                                                 b.ID                     <=> s.ID
		                                         and b.CAT                <=>  s.CAT
		                                         and b.SUBCAT             <=>  s.SUBCAT
		                                         and b. MAINTENANCE        <=>  s.MAINTENANCE);

END //
Delimiter ;
Drop  procedure if exists bronze.refresh;
call bronze.refresh();

-- to check

                        

Delimiter //
create procedure bronze.count_tables_rows()
begin

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
end//

Delimiter ;

call bronze.count_tables_rows();

 Delimiter //
 create procedure bronze.truncates ()
 begin

TRUNCATE TABLE bronze.crm_customer_info;

TRUNCATE TABLE bronze.crm_product_info;

TRUNCATE TABLE bronze.crm_sales_info;

TRUNCATE TABLE bronze.erp_customer_demographics;

TRUNCATE TABLE bronze.erp_customer_locations;

TRUNCATE TABLE bronze.erp_product_categories;
end//
 Delimiter ;
 call bronze.truncates ();



