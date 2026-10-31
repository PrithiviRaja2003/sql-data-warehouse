# SQL Data Warehouse Project

## Project Overview

Designed and implemented a **MySQL-based Data Warehouse** using the **Medallion Architecture (Bronze, Silver, and Gold)** to integrate CRM and ERP data, perform data cleaning and transformations, and build business-ready analytical datasets.

## Architecture

**Bronze → Silver → Gold**

- **Bronze:** Loaded raw CRM and ERP CSV files into staging tables.
- **Silver:** Cleaned, standardized, and validated data by handling NULLs, duplicates, and inconsistent formats.
- **Gold:** Created analytical views and fact and dimension structures for business analysis.

## Technologies & Tools

| Technology / Tool | Purpose |
|---|---|
| MySQL | Database creation and SQL data processing |
| MySQL Workbench | Writing and executing SQL queries |
| Git | Tracking changes and managing project versions |
| GitHub | Hosting and sharing the project repository |
| Draw.io | Designing data architecture and data modelling diagrams |

## Data Sources

Integrated data from two source systems:

- **CRM:** Customer Information, Product Information, Sales Information.
- **ERP:** Customer Demographics, Customer Locations, Product Categories.

## SQL Concepts Implemented

- DDL and DML Operations
- Joins and Subqueries
- Aggregate Functions and CASE Statements
- Window Functions and CTEs
- Stored Procedures
- Views and CTAS
- Data Cleaning and Standardization
- Date and String Functions

## Implementation Workflow

1. Designed the Data Warehouse architecture and data model.
2. Created Bronze, Silver, and Gold database layers.
3. Loaded CRM and ERP CSV datasets into Bronze staging tables.
4. Cleaned and transformed data in Silver.
5. Built analytical views and fact/dimension structures in Gold.
6. Performed Exploratory Data Analysis (EDA) and advanced SQL analysis.

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

## Key Outcomes

- Implemented a three-layer Data Warehouse architecture.
- Integrated multiple CRM and ERP source datasets.
- Developed SQL-based data cleaning and transformation workflows.
- Built analytical data structures using fact and dimension tables.
- Applied advanced SQL concepts for business analysis.

## Author

**Prithivi Raja**

GitHub: [@PrithiviRaja2003](https://github.com/PrithiviRaja2003)

Project Repository: [SQL Data Warehouse](https://github.com/PrithiviRaja2003/sql-data-warehouse)

---

If you find this project useful, feel free to explore the repository.