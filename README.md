# SQL Data Warehouse & Analytics Project

## Project Overview

Designed and implemented an end-to-end **MySQL Data Warehouse** using Medallion Architecture (Bronze, Silver, Gold) to integrate CRM and ERP data, perform data cleaning, and develop business-ready analytical datasets.

Performed **Exploratory Data Analysis (EDA)** and **Advanced Data Analytics** using SQL to identify business trends, evaluate customer behaviour, and analyze product performance.

## Architecture

**Bronze → Silver → Gold**

- **Bronze:** Loaded raw CRM and ERP CSV datasets.
- **Silver:** Cleaned, standardized, and validated data.
- **Gold:** Developed fact and dimension tables and analytical views.

## Data Analytics

**1. Exploratory Data Analysis (EDA)**
- Analyzed business KPIs: Total Sales, Quantity, Orders, Products and Customers.
- Explored customer distribution by country and gender.
- Analyzed product categories, revenue and customer spending.
- Identified top and bottom-performing products and customers.

**2. Advanced Data Analytics**
- **Change Over Time:** Analyzed monthly and yearly sales trends.
- **Cumulative Analysis:** Calculated running sales totals and averages.
- **Performance Analysis:** Compared product sales with historical performance using `LAG()`.
- **Part-to-Whole:** Evaluated category-wise sales contribution and percentages.
- **Data Segmentation:** Classified customers into VIP, Regular and New segments, and products by cost range.
- **Analytical Reports:** Created customer and product reports with KPIs such as recency, lifespan, average order value and monthly spending.

## Technologies & Tools

| Technology | Purpose |
|---|---|
| MySQL | Data processing, transformation and analytics |
| MySQL Workbench | SQL development and execution |
| Git & GitHub | Version control and project hosting |
| Draw.io | Data architecture and modelling diagrams |

## SQL Concepts Implemented

DDL, DML, Joins, Subqueries, CTEs, Window Functions, Aggregate Functions, CASE Statements, Stored Procedures, Views, CTAS, Date and String Functions.

## Key Outcomes

- Built a three-layer MySQL Data Warehouse.
- Integrated and transformed CRM and ERP datasets.
- Developed SQL-based EDA and advanced analytical queries.
- Created reusable customer and product analytical views.
- Applied business-focused analysis to evaluate sales, customer behaviour and product performance.

## Repository Structure

```text
sql-data-warehouse/
├── dataset/
│   ├── source_crm/
│   └── source_erp/
├── drawing/
│   ├── io files/
│   └── png files/
├── script/
│   ├── Bronze/
│   ├── Silver/
│   └── gold/
└── README.md
```

## Author

**Prithivi Raja**

GitHub: [@PrithiviRaja2003](https://github.com/PrithiviRaja2003)

**Project Repository:** [SQL Data Warehouse](https://github.com/PrithiviRaja2003/sql-data-warehouse)

