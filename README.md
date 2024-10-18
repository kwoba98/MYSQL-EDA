
# Layoffs Data Analysis Script
**Overview**
This script is designed to clean, aggregate, and analyze data from a table containing company layoff information (layoffs_staging3). It includes SQL queries that perform data transformations, summary statistics, and trend analysis. The dataset contains information on layoffs, including company details, industry, country, total laid-off employees, percentage laid off, and funding.

**Prerequisites**
MySQL Server
Layoffs data stored in the layoffs_staging3 table within the layoffs_data database.
Script Workflow
Set Database Context:

The script begins by switching to the layoffs_data database, where the layoffs data is stored.
**sql**
USE layoffs_data;

Basic Data Retrieval:
The script retrieves all records from the layoffs_staging3 table to inspect the full dataset.
**sql**
SELECT * FROM layoffs_staging3;

Maximum Layoff Values:
Find the maximum values for total_laid_off and percentage_laid_off in the dataset.
**sql**
SELECT MAX(total_laid_off), MAX(percentage_laid_off) FROM layoffs_staging3;
Filtering Companies with 100% Layoffs:

Identify companies that laid off 100% of their workforce, sorting them by either total layoffs or the amount of funds raised.
**sql**
SELECT * FROM layoffs_staging3 WHERE percentage_laid_off = 1 ORDER BY total_laid_off DESC;
SELECT * FROM layoffs_staging3 WHERE percentage_laid_off = 1 ORDER BY funds_raised_millions DESC;

Summing Layoffs by Company:
Sum the total layoffs per company and sort in descending order by layoffs.
**sql**
SELECT company, SUM(total_laid_off) FROM layoffs_staging3 GROUP BY company ORDER BY SUM(total_laid_off) DESC;

Date Range of Layoffs:
Retrieve the earliest and latest dates in the dataset to understand the time span covered by the data.
**sql**
SELECT MIN(`date`), MAX(`date`) FROM layoffs_staging3;

Summing Layoffs by Industry:
Aggregate total layoffs per industry and order by the highest total layoffs.
**sql**
SELECT industry, SUM(total_laid_off) FROM layoffs_staging3 GROUP BY industry ORDER BY SUM(total_laid_off) DESC;

Summing Layoffs by Country:
Aggregate total layoffs per country and order by the highest total layoffs.
**sql**
SELECT country, SUM(total_laid_off) FROM layoffs_staging3 GROUP BY country ORDER BY SUM(total_laid_off) DESC;

Summing Layoffs by Year:
Group the total layoffs by year and order by year in descending order.
**sql**
SELECT YEAR(`date`), SUM(total_laid_off) FROM layoffs_staging3 GROUP BY YEAR(`date`) ORDER BY YEAR(`date`) DESC;

Summing Layoffs by Company Stage:
Sum layoffs by the company’s stage (e.g., startup, growth) and order by total layoffs.
**sql**
SELECT stage, SUM(total_laid_off) FROM layoffs_staging3 GROUP BY stage ORDER BY SUM(total_laid_off) DESC;

Rolling Sum of Layoffs by Month:
Compute a rolling sum of layoffs per month to track trends over time.
**sql**
WITH rolling_total AS (
  SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off) AS total_off
  FROM layoffs_staging3
  GROUP BY `month`
)
SELECT `month`, total_off, SUM(total_off) OVER(ORDER BY `month`) AS rolling_sum FROM rolling_total;
Layoffs by Company and Year:

Group total layoffs by company and year, and rank the top 5 companies per year by layoffs.
**sql**
WITH company_year AS (
  SELECT company, YEAR(`date`) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging3
  GROUP BY company, years
), 
company_year_rank AS (
  SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM company_year
)
SELECT * FROM company_year_rank WHERE ranking <= 5;

**#Key SQL Concepts Used**
1. Window Functions: Used to compute rolling sums and rankings.
2. Common Table Expressions (CTEs): Used to simplify complex queries and organize the ranking and rolling total logic.
3. Aggregations: SUM, MAX, MIN functions are used to calculate total layoffs and identify extremes in the dataset.
4. Filtering: Specific queries to filter companies based on criteria like 100% layoffs.

**Output**
-The script provides insights into the dataset by:
-Identifying companies with the largest layoffs.
-Finding trends over time.
-Grouping layoffs by industry, country, and company stage.
-Producing rolling sums and ranking top companies per year based on layoffs.

**Notes**
The script assumes that the layoffs_staging3 table is already populated with clean data.
Adjustments can be made for specific filtering needs or different table structures.

**Future Improvements**
Additional transformations can be added for more advanced analyses.
Consider creating indexes on columns frequently used in queries to optimize performance.
