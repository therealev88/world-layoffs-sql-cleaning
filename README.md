# World Layoffs Data Cleaning Project (MySQL)

## 📖 Overview
This project demonstrates an end-to-end SQL data cleaning pipeline using MySQL.
The objective was to transform a raw layoffs dataset into a clean, structured,
and analysis-ready table by applying industry-standard data cleaning techniques.

The project focuses on safe, reproducible transformations using staged tables,
ensuring that each step can be audited and rolled back if necessary.

## 🗂 Dataset
- Dataset: World layoffs dataset
- Format: CSV
- Records: ~2,300 rows
- Description: Company layoffs across industries, countries, and funding stages

The dataset contains information such as company name, industry, total employees laid off,
percentage laid off, date of layoff, country, and funds raised.

## 🛠 Tools & Technologies
- MySQL
- MySQL Workbench
- SQL (Window functions, joins, subqueries)
- Git & GitHub


## 🔄 Data Cleaning Pipeline

The data cleaning process was implemented in structured stages to ensure data integrity,
traceability, and reproducibility.

### Stage 0 – Raw Data Preservation
- Imported the dataset without modification
- Created a working copy to preserve the original data

### Stage 1 – Duplicate Removal
- Identified duplicate records using `ROW_NUMBER()`
- Removed exact duplicate rows

### Stage 2 – Data Standardization
- Trimmed whitespace from text fields
- Normalized categorical values such as industry and country
- Standardized date formats

### Stage 3 – NULL Handling & Enrichment
- Converted empty strings to NULL values
- Filled missing industry values using company-level data
- Removed records with no layoff information

### Stage 4 – Final Dataset Preparation
- Removed helper columns
- Selected only analysis-relevant fields
- Created a clean, analysis-ready table
