# SQL-Data-Warehouse-Project

# Data Warehouse and Analytics Project

⚠️ This project was developed as a hands-on learning exercise based on a YouTube tutorial by "Data with Baraa". The project structure and concepts were guided by the tutorial; however, all SQL queries, transformations, and data modeling work were independently implemented, tested, and fully understood to strengthen practical skills in data warehousing and analytics.

---

## 🏗️ Data Architecture

The data architecture in this project is based on the **Medallion Architecture**, organized into three layers:

1. **Bronze Layer**: Raw data is ingested directly from source systems (CSV files) into SQL Server with minimal transformation.
2. **Silver Layer**: Data is cleaned, standardized, and transformed to ensure consistency and reliability for analysis.
3. **Gold Layer**: Business-ready data is structured into a star schema optimized for reporting and analytical queries.

---

## 📖 Project Overview

This project covers the following key components:

1. **Data Architecture Design**: Implementation of a modern data warehouse using the Medallion (Bronze, Silver, Gold) architecture.
2. **ETL Processes**: Extraction, transformation, and loading of data from ERP and CRM source systems into the warehouse.
3. **Data Modeling**: Creation of fact and dimension tables designed for analytical performance.
4. **Analytics & Reporting**: Development of SQL-based analysis to generate actionable business insights around customers, products, and sales trends.

---

## 🚀 Project Requirements

### Building the Data Warehouse (Data Engineering)

#### Objective
Design and implement a modern data warehouse using SQL Server to integrate sales-related data and enable structured analytical reporting.

#### Specifications
- **Data Sources**: Two source systems (ERP and CRM) provided as CSV files.
- **Data Quality**: Perform data cleansing and resolve inconsistencies before analysis.
- **Integration**: Consolidate both sources into a unified analytical data model.
- **Scope**: Focus on the most recent dataset; historical tracking (historization) is not included.
- **Documentation**: Provide clear documentation of the data model for both technical and business users.

---

### BI: Analytics & Reporting (Data Analysis)

#### Objective
Develop SQL-based analytics to uncover insights related to:
- Customer behavior
- Product performance
- Sales trends

These insights support data-driven decision-making and business strategy.

## 📂 Data-warehouse-project/
│
├── datasets/                           # Raw datasets (ERP and CRM sources)
│
├── docs/                               # Documentation and architecture design
│   ├── etl                             # ETL workflows and design diagrams
│   ├── data_architecture               # Medallion architecture (Bronze/Silver/Gold)
│   ├── data_catalog.md                 # Dataset metadata and field descriptions
│   ├── data_flow                       # Data flow diagrams
│   ├── data_models                     # Star schema data model design
│
├── scripts/                            # SQL scripts for ETL and transformations
│   ├── bronze/                         # Raw data ingestion layer
│   ├── silver/                         # Data cleaning and transformation layer
│   ├── gold/                           # Analytical and reporting layer
│
├── tests/                              # Data validation and quality checks
│
├── README.md                           # Project documentation


## 📂 Repository Structure
