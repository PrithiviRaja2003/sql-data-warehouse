
/*
===============================================================================

PROJECT : Data Warehouse
FILE    : 2.gold_ctas_query
PURPOSE : Create physical Gold CTAS tables and refresh them using the
          build-and-swap method.

TABLES:
    1. gold.customers_dim_t
    2. gold.products_dim_t
    3. gold.sales_fact_t

PROCEDURE:
    gold.refresh()

PROCESS:
    1. Create physical CTAS tables from the three Gold views.
    2. Create indexes on customer_key and product_key to support
       query performance.
    3. Remove leftover _new tables from a previous failed run.
    4. Create new tables from the latest Gold view results.
    5. Create indexes on the new tables before swapping.
    6. Rename the existing CTAS tables to _old and the new tables
       to their permanent _t names using one RENAME TABLE statement.
    7. Drop the old tables after the swap.
    8. Execute gold.refresh() to refresh the Gold CTAS tables.
    9. Validate the refreshed tables by checking their row counts.

IMPORTANT:
    - CTAS creates physical tables from the results of SELECT queries.
    - CTAS does not automatically copy indexes or primary keys.
    - The refresh procedure rebuilds the tables from the Gold views.
    - New tables are prepared before the swap to reduce interruption
      while analysts query the existing tables.
    - RENAME TABLE may wait for metadata locks.
    - The original _t tables must exist before the first swap.
    - If the procedure fails, leftover _new or _old tables may require
      investigation and cleanup.
    - Row-count validation confirms table sizes, not complete data accuracy.

EXECUTION:
    CALL gold.refresh();

VALIDATION:
    SELECT COUNT(*) AS total_count FROM gold.customers_dim_t
    UNION ALL
    SELECT COUNT(*) FROM gold.products_dim_t
    UNION ALL
    SELECT COUNT(*) FROM gold.sales_fact_t;

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