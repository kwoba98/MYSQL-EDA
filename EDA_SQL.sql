-- Use the 'layoffs_data' database
USE layoffs_data;

-- Select all records from 'layoffs_staging3' table for review
SELECT * FROM layoffs_staging3;

-- Find the maximum number of layoffs and the highest layoff percentage
SELECT MAX(total_laid_off) AS max_total_laid_off, MAX(percentage_laid_off) AS max_percentage_laid_off
FROM layoffs_staging3;

-- Retrieve companies where 100% of employees were laid off, ordered by total layoffs (highest first)
SELECT *
FROM layoffs_staging3
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- Retrieve companies where 100% of employees were laid off, ordered by funds raised (highest first)
SELECT *
FROM layoffs_staging3
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Sum total layoffs per company and order by the total number of layoffs (highest first)
SELECT company, SUM(total_laid_off) AS total_laid_off_sum
FROM layoffs_staging3
GROUP BY company
ORDER BY total_laid_off_sum DESC;

-- Find the earliest and latest dates in the dataset
SELECT MIN(`date`) AS earliest_date, MAX(`date`) AS latest_date
FROM layoffs_staging3;

-- Sum total layoffs per industry and order by total number of layoffs (highest first)
SELECT industry, SUM(total_laid_off) AS total_laid_off_sum
FROM layoffs_staging3
GROUP BY industry
ORDER BY total_laid_off_sum DESC;

-- Sum total layoffs per country and order by total number of layoffs (highest first)
SELECT country, SUM(total_laid_off) AS total_laid_off_sum
FROM layoffs_staging3
GROUP BY country
ORDER BY total_laid_off_sum DESC;

-- Sum total layoffs per year and order by year (most recent first)
SELECT YEAR(`date`) AS year, SUM(total_laid_off) AS total_laid_off_sum
FROM layoffs_staging3
GROUP BY year
ORDER BY year DESC;

-- Sum total layoffs per stage of the company and order by total layoffs (highest first)
SELECT stage, SUM(total_laid_off) AS total_laid_off_sum
FROM layoffs_staging3
GROUP BY stage
ORDER BY total_laid_off_sum DESC;

-- Calculate rolling sum of total layoffs per month
WITH rolling_total AS (
  SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off) AS total_off
  FROM layoffs_staging3
  WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
  GROUP BY `month`
  ORDER BY `month` ASC
)
SELECT `month`, total_off, 
SUM(total_off) OVER(ORDER BY `month`) AS rolling_sum
FROM rolling_total;

-- Get total layoffs per company, grouped by year
SELECT company, YEAR(`date`) AS year, SUM(total_laid_off) AS total_laid_off_sum
FROM layoffs_staging3
GROUP BY company, year
ORDER BY total_laid_off_sum DESC;

-- Rank companies by total layoffs per year and select top 5 per year
WITH company_year AS (
  SELECT company, YEAR(`date`) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging3
  GROUP BY company, years
), 
company_year_rank AS (
  SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM company_year
  WHERE years IS NOT NULL
)
SELECT *
FROM company_year_rank
WHERE ranking <= 5;
