				 --World Layoffs
		-- Data Cleaning
USE WorldLayoffs

--Create a copy of the table
SELECT * INTO StagingLayoffs
FROM layoffs



				-- Remove Duplicates
SELECT ROW_NUMBER() OVER(ORDER BY Company) 
		row_number, company, staginglayoffs.location, industry, total_laid_off, percentage_laid_off, staginglayoffs.date, stage, country, funds_raised_millions
FROM StagingLayoffs


--Partition the data to find duplicates
SELECT ROW_NUMBER() 
	OVER(
		PARTITION BY company, staginglayoffs.location, industry, total_laid_off, percentage_laid_off, staginglayoffs.date, stage, country, funds_raised_millions
		ORDER BY Company) 
		row_number, company, staginglayoffs.location, industry, total_laid_off, percentage_laid_off, staginglayoffs.date, stage, country, funds_raised_millions
FROM StagingLayoffs


--Select entries with a row number greater than 1 in each partition
WITH Duplicate_cte AS (
SELECT ROW_NUMBER() 
	OVER(
		PARTITION BY company, staginglayoffs.location, industry, total_laid_off, percentage_laid_off, staginglayoffs.date, stage, country, funds_raised_millions
		ORDER BY Company) 
		row_number, company, staginglayoffs.location, industry, total_laid_off, percentage_laid_off, staginglayoffs.date, stage, country, funds_raised_millions
FROM StagingLayoffs
)
select * from duplicate_cte
where row_number > 1


--Delete the rows with a row number that is greater than 1 in each partition
WITH Duplicate_cte AS (
SELECT ROW_NUMBER() 
	OVER(
		PARTITION BY company, staginglayoffs.location, industry, total_laid_off, percentage_laid_off, staginglayoffs.date, stage, country, funds_raised_millions
		ORDER BY Company) 
		row_number, company, staginglayoffs.location, industry, total_laid_off, percentage_laid_off, staginglayoffs.date, stage, country, funds_raised_millions
FROM StagingLayoffs
)
/*DELETE FROM Duplicate_cte 
WHERE row_number > 1*/


							-- Standardize the data
SELECT Company FROM StagingLayoffs
ORDER BY Company

--Company
--Remove dead spaces before company names. 
UPDATE StagingLayoffs
SET Company = TRIM(Company)

--Industry
--Update redundant industry entries. 
SELECT * FROM StagingLayoffs
WHERE industry like 'Crypto%'
order by 1

UPDATE StagingLayoffs
SET industry = 'Crypto'
where industry LIKE 'Crypto%'

--Country
--Remove duplicate country entry. Remove trailing period. 
SELECT DISTINCT Country from StagingLayoffs
order by country

SELECT TRIM('.' FROM COUNTRY) AS Country
FROM StagingLayoffs

UPDATE StagingLayoffs
SET Country = TRIM('.' FROM COUNTRY)
WHERE Country LIKE 'United States%'


-- Change date column type from text to date
-- Change the NULL (text) values to legitimate NULL values
UPDATE StagingLayoffs
SET date = NULL
Where date = 'NULL'

--CAST text values as date values
SELECT CAST(StagingLayoffs.date AS date) as NewDate from StagingLayoffs

--Change column type from varchar(50) to date
ALTER TABLE StagingLayoffs
ALTER COLUMN date date

---- Change the NULL (text) values to legitimate NULL values
UPDATE StagingLayoffs
SET total_laid_off = NULL
Where total_laid_off = 'NULL'

UPDATE StagingLayoffs
SET percentage_laid_off = NULL
Where percentage_laid_off = 'NULL'

UPDATE StagingLayoffs
SET funds_raised_millions = NULL
Where funds_raised_millions = 'NULL'


--Change column type from varchar(50) to int/float
ALTER TABLE StagingLayoffs
ALTER COLUMN percentage_laid_off float

ALTER TABLE StagingLayoffs
ALTER COLUMN total_laid_off int

ALTER TABLE StagingLayoffs
ALTER COLUMN funds_raised_millions float

							--Fix NULL/Blank values
SELECT * FROM StagingLayoffs
WHERE industry IS NULL

-- Change the NULL (text) values to legitimate NULL values
UPDATE StagingLayoffs
set industry = NULL 
WHERE industry = 'NULL'

-- Find the companies with null industry values, where the industry is populated in other rows
SELECT * FROM StagingLayoffs T1 
JOIN StagingLayoffs T2 
	ON T1.company = T2.company 
	AND T1.location = T2.location
WHERE (T1.industry IS NULL)
AND (T2.industry IS NOT NULL)

--Update the industry for the null entries using the entries that aren't null 
UPDATE t1
set industry = t2.industry
from StagingLayoffs T1 JOIN StagingLayoffs T2 
	ON t1.company = t2.company 
where (T1.industry IS NULL)
AND T2.industry <> 'NULL'



						-- Remove unneccessary columns/rows
-- Leaving the rows with a blank total_laid_off and percentage_laid_off values. Assuming that these companies did not do any layoffs.

--Removing rows without a layoff date
SELECT * FROM StagingLayoffs WHERE DATE IS NULL -- one row returned

DELETE StagingLayoffs
where date is null

-- Explore the total_laid_off and percentage_laid_off values
SELECT * FROM StagingLayoffs where percentage_laid_off IS NULL and total_laid_off IS NOT NULL
SELECT * FROM StagingLayoffs where total_laid_off IS NULL AND percentage_laid_off IS NOT NULL