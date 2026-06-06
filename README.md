# World Layoffs: Data Cleaning and Exploratory Data Analysis

## Project Overview
This project contains a comprehensive SQL workflow using global company layoffs data from 2020 to 2023. The project is divided into two major parts: cleaning the raw dataset using MySQL to ensure data integrity, and performing Exploratory Data Analysis (EDA) to discover historical employment trends.

---

## Tools Used
* Database Management: MySQL
* Environment: MySQL Workbench
* Language: SQL

---

## Phase 1: Data Cleaning Process
To prepare the dataset for analysis, I performed the following data cleaning steps sequentially:

### 1. Staging Data
* Created a clone table named `layoffs_staging` to safely run operations without modifying the original raw dataset.

### 2. Duplicate Removal
* Used Window Functions (`ROW_NUMBER()` with `PARTITION BY`) inside a CTE to find duplicate rows.
* Built a second staging table (`layoffs_staging2`) to permanently delete duplicate records where the row count was greater than 1.

### 3. Data Standardization
* Used `TRIM()` to remove unwanted spaces from company names.
* Standardized variations in text columns, such as merging all 'Crypto%' subcategories into a single 'Crypto' industry name.
* Fixed country formatting issues, like changing 'United States.' to 'United States'.
* Converted the `date` column from text format to SQL proper format using `STR_TO_DATE()`, then modified the column type using `ALTER TABLE`.

### 4. Handling Nulls and Blanks
* Applied a Self-Join to update and populate missing `industry` fields by referencing data from the same companies.
* Filtered and removed useless records where both `total_laid_off` and `percentage_laid_off` were null.

### 5. Column Cleanup
* Dropped the temporary `row_num` column using `ALTER TABLE` to keep the final output dataset clean and structured.

---

## Phase 2: Exploratory Data Analysis (EDA)
After cleaning, I ran multiple analytical queries to find insights within the data:

* Checked the maximum values for layoffs and identified companies that shut down completely (100% layoffs) along with their funding details.
* Grouped and aggregated total layoffs by Company, Industry, Country, and Funding Stage to find the hardest-hit sectors.
* Analyzed layoffs by year and month to identify patterns over time.
* Calculated a rolling total of monthly layoffs using window functions (`SUM() OVER()`) to observe cumulative growth.
* Created an advanced query using CTEs and `DENSE_RANK()` to filter and display the top 5 companies with the highest layoffs for each individual year.

---

## Core SQL Skills Applied
* Advanced Window Functions (`ROW_NUMBER`, `DENSE_RANK`)
* Common Table Expressions (CTEs)
* Self-Joins and Aggregate Functions
* Data Type Conversion and Schema Modifications
* String Manipulation Functions (`TRIM`, `SUBSTRING`, `LIKE`)

---

## Author
* GitHub Profile: [War-DataSolutions](http://github.com
* Git Hub Profile: [War-DataSolutions](https://github.com)
