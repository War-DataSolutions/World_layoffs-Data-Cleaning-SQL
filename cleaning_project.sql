-- Project: world layoffs data cleaning & EDA
-- Tools: MY SQL Workbench
   use world_layoffs;
-- SQL Data Cleaning Project
-- Dataset: World Layoffs (2020-2023)
-- Goal: Transform raw data into a clean dataset for analysis

-- 1. Create a Staging Table (To keep original data safe)
CREATE TABLE layoffs_staging LIKE layoffs;
INSERT layoffs_staging SELECT * FROM layoffs;

-- 2. Remove Duplicates
-- Identifying duplicates using ROW_NUMBER()
WITH duplicate_cte AS (
SELECT *, ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging
)
select*
from duplicate_cte;
-- We need to create a new table to delete duplicates permanently
drop table if exists layoffs_staging2;
CREATE TABLE `layoffs_staging2` (
`company` text, `location` text, `industry` text, `total_laid_off` int DEFAULT NULL,
`percentage_laid_off` text, `date` text, `stage` text, `country` text,
`funds_raised_millions` int DEFAULT NULL, `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;
select*
from layoffs_staging2;
DELETE FROM layoffs_staging2 WHERE row_num > 1;

-- 3. Standardizing Data
UPDATE layoffs_staging2 SET company = TRIM(company);
UPDATE layoffs_staging2 SET industry = 'Crypto' WHERE industry LIKE 'Crypto%';
UPDATE layoffs_staging2 SET country = TRIM(TRAILING '.' FROM country) WHERE country LIKE 'United States%';

-- Converting Date column from Text to Date Format
UPDATE layoffs_staging2 SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
ALTER TABLE layoffs_staging2 MODIFY COLUMN `date` DATE;

-- 4. Handling Nulls and Blank Values
select t1.industry,t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company=t2.company
where (t1.industry is null or t1.industry='')
and t2.industry is not null;
update layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company=t2.company
set t1.industry=t2.industry
where (t1.industry is null)
and t2.industry is not null;
select*
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null; 
-- 5. Removing Unnecessary Columns/Rows
DELETE FROM layoffs_staging2 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;
ALTER TABLE layoffs_staging2 DROP COLUMN row_num;

SELECT * FROM layoffs_staging2;


-- EXPLORATORY DATA ANALYSIS (EDA)
select*
from layoffs_staging2;
select max(total_laid_off),max(percentage_laid_off)
from layoffs_staging2;
SELECT*
FROM layoffs_staging2
WHERE percentage_laid_off=1
order by funds_raised_millions desc;
select company,sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;
select min(`date`),max(`date`)
from layoffs_staging2;
select industry,sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;
select country,sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;
select `date`,sum(total_laid_off)
from layoffs_staging2
group by `date`
order by 1 desc;
select year(`date`),sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 1 desc;
select stage,sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;
select company,avg(percentage_laid_off)
from layoffs_staging2
group by company
order by 2 desc;
select substring(`date`,1,7) as `month`,sum(total_laid_off)
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc;
with rolling_total as
(select substring(`date`,1,7) as `month`,sum(total_laid_off) as laid_off
from layoffs_staging2 where substring(`date`,1,7) is not null
group by `month`
order by 1 asc)
select `month`,laid_off,sum(laid_off) over(order by `month`) as rolling_total
from rolling_total;
select company,year(`date`) years,sum(total_laid_off) laid_off
from layoffs_staging2
group by company,year(`date`)
order by 3 desc;
with company_year as
(select company,year(`date`) years,sum(total_laid_off) laid_off
from layoffs_staging2
group by company,year(`date`)
)
select*
from company_year;
with company_year as
(select company,year(`date`) years,sum(total_laid_off) laid_off
from layoffs_staging2
group by company,year(`date`)
)
select*, dense_rank () over(partition by years order by laid_off desc) as ranking
from company_year
where years is not null
order by ranking asc;
with company_year as
(select company,year(`date`) years,sum(total_laid_off) laid_off
from layoffs_staging2
group by company,year(`date`)
),company_year_rank as
(select*, dense_rank () over(partition by years order by laid_off desc) as ranking
from company_year
where years is not null)
select*
from company_year_rank
where ranking<=5;
