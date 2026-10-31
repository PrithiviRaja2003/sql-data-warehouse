/*
===============================================================================

PROJECT : Data Warehouse
FILE    : 2.gold_ctas_query.sql

PURPOSE :
    Create physical Gold CTAS tables and refresh them using the
    build-and-swap method.

TABLES:

    DIMENSION AND FACT TABLES:
        1. gold.customers_dim_t
        2. gold.products_dim_t
        3. gold.sales_fact_t

    REPORT TABLES:
        4. gold.customer_report_t
        5. gold.products_report_t

PROCEDURES:

    1. gold.refresh()
       - Refreshes dimension and fact CTAS tables.

    2. gold.report_refresh()
       - Refreshes customer and product report CTAS tables.

PROCESS:

    1. Create physical dimension and fact CTAS tables from Gold views.
    2. Create indexes on customer_key and product_key.
    3. Remove leftover _new tables from previous failed runs.
    4. Create new dimension and fact tables from the latest Gold views.
    5. Create indexes on the new tables before swapping.
    6. Rename existing CTAS tables to _old and new tables to their
       permanent _t names using one RENAME TABLE statement.
    7. Drop old dimension and fact tables.
    8. Execute gold.refresh() and validate row counts.

    9. Create customer and product report CTAS tables from:
       - gold.customer_report
       - gold.products_report

    10. Create indexes on customer_key and product_key in the
        respective report tables.

    11. Remove leftover report _new tables from previous failed runs.
    12. Create new report tables from the latest report views.
    13. Create indexes on the new report tables before swapping.
    14. Rename existing report tables to _old and new tables to
        their permanent _t names.
    15. Drop old report tables.
    16. Execute gold.report_refresh().

IMPORTANT:

    - CTAS creates physical tables from SELECT query results.
    - CTAS does not automatically copy indexes or primary keys.
    - Both refresh procedures rebuild tables from their respective
      Gold views.
    - New tables are prepared before the swap to reduce interruption
      while analysts query the existing tables.
    - RENAME TABLE may wait for metadata locks.
    - Original _t tables must exist before the first swap.
    - If a procedure fails, leftover _new or _old tables may require
      investigation and cleanup.
    - Row-count validation confirms table sizes, not complete data accuracy.
    - gold.refresh() and gold.report_refresh() are separate procedures.

EXECUTION:

    1. CALL gold.refresh();
    2. CALL gold.report_refresh();

VALIDATION:

    -- Dimension and fact tables
    SELECT COUNT(*) AS total_count FROM gold.customers_dim_t
    UNION ALL
    SELECT COUNT(*) FROM gold.products_dim_t
    UNION ALL
    SELECT COUNT(*) FROM gold.sales_fact_t;

    -- Report tables
    SELECT COUNT(*) AS total_count FROM gold.customer_report_t
    UNION ALL
    SELECT COUNT(*) FROM gold.products_report_t;

===============================================================================
*/


-- created ctas table 

create table  gold.customers_dim_t as select *from gold.customers_dim;
create table  gold.products_dim_t as select *from gold.products_dim;
create table  gold.sales_fact_t as select *from gold.sales_fact;

-- creating index
create index inx_customer_key
on gold.customers_dim_t (customer_key);

create index inx_product_key
on gold.products_dim_t (product_key);

create index inx_customer_key
on gold.sales_fact_t (customer_key);

create index inx_product_key
on gold.sales_fact_t (product_key);

Delimiter // 
create procedure gold.refresh()
begin 

-- to pervent the filed run 
drop table if exists
	gold.customers_dim_new,
    gold.products_dim_new,
    gold.sales_fact_new;

-- created new table to swap the data
create table gold.customers_dim_new as select * from gold.customers_dim;
create table gold.products_dim_new as select * from gold.products_dim;
create table gold.sales_fact_new as select * from   gold.sales_fact;

-- create index for new swap tables
create index inx_customer_key
on gold.customers_dim_new (customer_key);

create index inx_product_key
on gold.products_dim_new (product_key);

create index inx_customer_key
on gold.sales_fact_new (customer_key);

create index inx_product_key
on  gold.sales_fact_new(product_key);



-- rename the tbales
rename table
	gold.customers_dim_t to gold.customers_dim_old,
    gold.customers_dim_new to gold.customers_dim_t,
    gold.products_dim_t to gold.products_dim_old,
    gold.products_dim_new to gold.products_dim_t,
    gold.sales_fact_t to gold.sales_fact_old,
    gold.sales_fact_new to gold.sales_fact_t;

-- drop the old table
drop table
	gold.customers_dim_old,
    gold.products_dim_old,
    gold.sales_fact_old;
    
    end//
    delimiter ;
    
    call gold.refresh();
    
    select count(*) as total_count from gold.customers_dim_t 
    union all
	select count(*) from gold.products_dim_t
    union all
	select count(*) from gold.sales_fact_t  ;
    
 -- ------------------------------------------------------------------------------  
--  Create CTAS tables for report
    
create table gold.customer_report_t as
select * from gold.customer_report ;

create table gold.products_report_t as
select * from gold.products_report ;

select * from gold.products_report_t ;
select * from gold.customer_report_t;

-- Customer Report Index
create index idx_customer_ksy
on gold.customer_report_t (customer_key);

-- Product Report Index
create index idx_product_key
on gold.products_report_t (product_key);

Delimiter // 
create procedure gold.report_refresh()
begin 

-- to pervent the filed run 
drop table if exists
	gold.customer_report_t_new,
    gold.products_report_t_new;
    
-- created new table to swap the data
create table gold.customer_report_t_new as select * from gold.customer_report;
create table gold.products_report_t_new as select * from gold.products_report;


-- create index for new swap tables
create index inx_customer_key
on gold.customer_report_t_new (customer_key);

create index inx_product_key
on gold.products_report_t_new (product_key);


-- rename the tbales
rename table
	gold.customer_report_t to gold.customer_report_t_old,
    gold.customer_report_t_new to gold.customer_report_t,
    gold.products_report_t to gold.products_report_t_old,
    gold.products_report_t_new to gold.products_report_t;

-- drop the old table
drop table
	gold.customer_report_t_old,
    gold.products_report_t_old;
    
    end//
    delimiter ;
    
    call gold.report_refresh();