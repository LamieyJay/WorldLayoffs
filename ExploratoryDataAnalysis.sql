						--World Layoffs
					-- Exploratory Data Analysis

--Highest number of employees laid off at a time
select MAX(total_laid_off) highest_number_laid_off from StagingLayoffs


--Highest percentage laid off
SELECT MAX(PERCENTAGE_LAID_OFF) max_percentage_laid_off FROM StagingLayoffs


--Number of employees laid off in companies where ALL employees where laid off; in descending order
SELECT * FROM StagingLayoffs
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC

	--What companies, where all their employees were laid off had the highest funding?
	SELECT * FROM StagingLayoffs
	where percentage_laid_off = 1 
	ORDER BY funds_raised_millions DESC


--Total laid off per company
SELECT Company, SUM(total_laid_off) Total_laid_off FROM StagingLayoffs
GROUP BY company
ORDER BY 2 DESC

--Total laid off by industry
SELECT Industry, SUM(total_laid_off) Total_laid_off FROM StagingLayoffs
GROUP BY industry
ORDER BY 2 DESC

--Total laid off by country
SELECT country, SUM(total_laid_off) Total_laid_off FROM StagingLayoffs
GROUP BY country
ORDER BY 2 DESC

--Total laid off per year
	SELECT YEAR(DATE) [Year], SUM(Total_laid_off) Total_laid_off from StagingLayoffs
	GROUP BY Year(Date)
	order by 1

--Explore date ranges of the data
SELECT MIN(date) Oldest, MAX(date) Newest
from StagingLayoffs

--Layoff by company stage
SELECT stage, SUM(total_laid_off) Total_laid_off FROM StagingLayoffs
group by stage
order by 2 desc


--Total laid off each year per month
SELECT 
DATEPART (YEAR, DATE) [Year],
DATEPART(MONTH, DATE) [Month], 
SUM(total_laid_off) Total_Laid_off 
FROM StagingLayoffs
group by DATEPART (YEAR, DATE), DATEPART(MONTH, DATE)
ORDER BY 1, 2


--Rolling sum of total employees laid off, by month in each year
WITH Rolling_Sum AS (
	select SUBSTRING (CONVERT(VARCHAR(15), staginglayoffs.date, 112), 1, 6) as [YYYYMM], sum(total_laid_off) Total_Laid_Off
	from StagingLayoffs
	GROUP BY SUBSTRING (CONVERT(VARCHAR(15), staginglayoffs.date, 112), 1, 6)
	--ORDER BY 1 ASC
)
select [YYYYMM], Total_laid_off, sum(total_laid_off) over (order by [YYYYMM]) RollingTotal
FROM Rolling_Sum


--Total number of employees laid off by company, per year.
SELECT COMPANY, YEAR([date]) [Year], SUM(total_laid_off) Laid_off FROM StagingLayoffs
group by company, Year([date])
order by 1, 2


--Top 5 layoffs per year
WITH Company_Layoffs AS (
	SELECT Company, YEAR([date]) [Year], SUM(total_laid_off) Laid_off FROM StagingLayoffs
	group by company, Year([date])
), Company_Year_Rank AS (
	select *, DENSE_RANK() OVER (PARTITION BY [Year] ORDER BY Laid_off desc) AS Ranking 
	From Company_Layoffs
)
select * from Company_Year_Rank
WHERE Ranking <= 5




