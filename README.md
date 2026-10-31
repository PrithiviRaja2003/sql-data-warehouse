# SQL Data Warehouse Project

## 📌 Project Overview

This project demonstrates the design and implementation of a SQL-based Data Warehouse using **MySQL**. It follows the Medallion Architecture (Bronze, Silver, and Gold layers) to organize, clean, transform, and prepare raw data for analytical reporting.

The project integrates data from CRM and ERP source systems, applies data quality checks and transformations, and builds structured analytical tables to support business analysis and reporting.

## 🎯 Project Objectives

- Design a structured Data Warehouse using MySQL.
- Implement Bronze, Silver, and Gold layers.
- Integrate data from CRM and ERP source systems.
- Perform data cleaning and standardization.
- Handle missing values, duplicates, and inconsistent data.
- Implement SQL transformations and stored procedures.
- Create analytical views and queries.
- Perform Exploratory Data Analysis (EDA).
- Prepare business-ready datasets for reporting and analysis.

## 🏗️ Data Architecture

The project follows the Medallion Architecture.

### 1. Bronze Layer – Raw Data

- Stores raw data from CRM and ERP source systems.
- Maintains the original source structure.
- Loads data into staging tables.
- Preserves source data for further processing.

### 2. Silver Layer – Cleaned and Transformed Data

- Performs data cleaning and standardization.
- Handles NULL values and duplicates.
- Resolves inconsistent formats.
- Applies data type conversions.
- Ensures data quality and consistency.

### 3. Gold Layer – Business-Ready Data

- Creates analytical tables and views.
- Implements fact and dimension structures.
- Supports business-level analysis.
- Provides data for reporting and decision-making.

## 🔄 Data Flow

```text
       CRM Source System       ERP Source System
              |                       |
              v                       v
       +-----------------------------------+
       |          BRONZE LAYER             |
       |       Raw Data / Staging          |
       +-----------------------------------+
                       |
                       v
       +-----------------------------------+
       |          SILVER LAYER             |
       |  Cleaning / Transformation        |
       |       Data Quality Checks         |
       +-----------------------------------+
                       |
                       v
       +-----------------------------------+
       |           GOLD LAYER              |
       |   Fact & Dimension Structures     |
       |      Analytical Views             |
       +-----------------------------------+
                       |
                       v
             Business Analytics
```

## 🛠️ Technologies Used

| Technology | Purpose |
|---|---|
| MySQL | Database management and data processing |
| SQL | Data extraction, transformation and analysis |
| Stored Procedures | Automating database operations |
| Views | Reusable analytical queries |
| CTAS | Creating tables from query results |
| Draw.io | Data architecture and modelling diagrams |
| Git | Version control |
| GitHub | Project hosting and documentation |

## 📂 Project Structure

```text
sql-data-warehouse/
│
├── dataset/
│   ├── source_crm/
│   │   ├── crm_customer_info.csv
│   │   ├── crm_product_info.csv
│   │   └── crm_sales_info.csv
│   │
│   └── source_erp/
│       ├── PX_CAT_G1V2.csv
│       ├── erp_customer_demographics.csv
│       └── erp_customer_locations.csv
│
├── drawing/
│   ├── io files/
│   │   ├── Data_flow Diagram.drawio
│   │   ├── Data_intergration_Diagram.drawio
│   │   └── data_modelling_ Diagram.drawio
│   │
│   └── png files/
│       ├── Data_flow Diagram.drawio.png
│       ├── Data_intergration_Diagram.drawio.png
│       └── data_modelling_ Diagram.drawio.png
│
├── script/
│   ├── Bronze/
│   │   ├── 1.database_layers.sql
│   │   ├── 2.bronze_ddl.sql
│   │   ├── 3.bronze_staging_ddl.sql
│   │   ├── 4.bronze_load.sql
│   │   └── 5.Bronze_process.sql
│   │
│   ├── Silver/
│   │   ├── 6.silver_ddl.sql
│   │   ├── 7.silver_insert.sql
│   │   └── 8.silver_update.sql
│   │
│   └── gold/
│       ├── 1.gold_view.sql
│       ├── 2.Gold_CTAS_Query.sql
│       ├── 3.Exploratory_data_analysis.sql
│       └── 4.Gold_Advance_data_Analytics.sql
│
└── README.md
```

## 📊 Data Sources

The project uses two primary source systems:

**CRM (Customer Relationship Management)**
- Customer information
- Product information
- Sales information

**ERP (Enterprise Resource Planning)**
- Customer demographics
- Customer locations
- Product categories

## ⚙️ Implementation Workflow

1. Design the database architecture.
2. Create Bronze, Silver, and Gold databases.
3. Create raw and staging tables.
4. Load source CSV datasets into Bronze.
5. Transform and clean data in Silver.
6. Build analytical tables and views in Gold.
7. Perform Exploratory Data Analysis.
8. Execute advanced SQL analytical queries.

## 📈 SQL Concepts Implemented

- Database creation and management
- DDL and DML operations
- Primary and foreign keys
- Joins and subqueries
- Aggregate functions
- CASE statements
- Window functions
- Common Table Expressions (CTEs)
- Stored Procedures
- Dynamic SQL
- Views
- CREATE TABLE AS SELECT (CTAS)
- Data cleaning and standardization
- Date and string functions

## 🚀 Getting Started

### Prerequisites

- MySQL Server
- MySQL Workbench
- Git
- Draw.io (for viewing architecture diagrams)

### Setup Instructions

**Step 1: Clone the repository**

```bash
git clone https://github.com/PrithiviRaja2003/sql-data-warehouse.git
```

**Step 2: Open the project**

Open the downloaded project folder in VS Code or your preferred editor.

**Step 3: Review the architecture**

Explore the `drawing/` folder to understand the data flow, integration architecture, and data model.

**Step 4: Create the databases**

Execute the database creation scripts available in the Bronze layer.

**Step 5: Load the source data**

Use the Bronze loading scripts to import the CRM and ERP CSV files into the staging tables.

**Step 6: Execute transformations**

Run the Silver layer scripts followed by the Gold layer scripts.

**Step 7: Perform analysis**

Execute the analytical queries and explore the Gold layer views.

## 📚 Key Learning Outcomes

- Understanding Data Warehouse architecture.
- Practical implementation of Medallion Architecture.
- Working with multiple source systems.
- Developing SQL-based data transformation pipelines.
- Improving data quality through SQL.
- Designing analytical fact and dimension structures.
- Writing advanced SQL queries for business analysis.

## 👨‍💻 Author

**Prithivi Raja**

GitHub: [@PrithiviRaja2003](https://github.com/PrithiviRaja2003)

Project Repository: [SQL Data Warehouse](https://github.com/PrithiviRaja2003/sql-data-warehouse)

---

⭐ If you find this project useful, feel free to explore the repository and learn from the implementation.