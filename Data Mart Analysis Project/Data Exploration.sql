-- What day of the week is used for each week_date value?
SELECT
	DISTINCT DATENAME(WEEKDAY,week_date) AS day_of_week
FROM clean_weekly_sales

--What range of week numbers are missing from the dataset?
WITH Row_nums AS ( -- create a temporary table containing the number 1~52
SELECT 1   AS Row_num
UNION ALL
SELECT Row_num + 1 AS Row_num
FROM Row_nums
WHERE Row_num +1 <= 52
)
SELECT 
	Row_num,
	week_number
FROM Row_nums
LEFT JOIN clean_weekly_sales ON Row_num = week_number
WHERE week_number IS NULL
ORDER BY Row_num

--How many total transactions were there for each year in the dataset?
SELECT
	calendar_year,
	FORMAT(SUM(transactions),'N0') AS total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year

--What is the total sales for each region for each month?
SELECT
	region,
	month_number,
	FORMAT(SUM(sales),'N0') AS total_sales
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number

--What is the total count of transactions for each platform?

SELECT 
	platform,
	FORMAT(SUM(transactions),'N0') AS count_of_transactions
FROM clean_weekly_sales
GROUP BY platform

-- What is the percentage of sales for Retail vs Shopify for each month?
WITH sales_by_platform AS (
SELECT
	calendar_year,
	month_number,
	platform, 
	SUM(sales)  AS Monthly_sales
FROM clean_weekly_sales
GROUP BY calendar_year, month_number, platform
)
SELECT
	calendar_year,
	month_number,
	CAST(100.0 * MAX(CASE WHEN platform = 'Retail' THEN Monthly_sales END) / SUM(Monthly_sales) AS decimal(5,2))  AS PCT_Retail,
	CAST(100.0 * MAX(CASE WHEN platform = 'Shopify' THEN Monthly_sales END) / SUM(Monthly_sales) AS decimal(5,2))  AS PCT_Shopify
	
FROM sales_by_platform
GROUP BY calendar_year, month_number
ORDER BY calendar_year, month_number

--What is the percentage of sales by demographic for each year in the dataset?
WITH sales_by_demographic AS (
SELECT
	calendar_year,
	demographic, 
	SUM(sales)  AS Yearly_sales
FROM clean_weekly_sales
GROUP BY calendar_year, demographic
)
SELECT
	calendar_year,
	CAST(100.0 * MAX(CASE WHEN demographic = 'Couples' THEN Yearly_sales END) / SUM(Yearly_sales) AS decimal(5,2))  AS PCT_Couples,
	CAST(100.0 * MAX(CASE WHEN demographic = 'Families' THEN Yearly_sales END) / SUM(Yearly_sales) AS decimal(5,2))  AS PCT_Families,
	CAST(100.0 * MAX(CASE WHEN demographic = 'unknown' THEN Yearly_sales END) / SUM(Yearly_sales) AS decimal(5,2))  AS PCT_unknown
FROM sales_by_demographic
GROUP BY calendar_year
ORDER BY calendar_year

--Which age_band and demographic values contribute the most to Retail sales?
SELECT
	age_band,
	demographic,
	FORMAT(SUM(sales),'N') AS sales,
	CAST(100.0 * SUM(sales) / (SELECT SUM(sales) FROM clean_weekly_sales WHERE platform = 'Retail') AS decimal(5,2)) AS contribution
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY 4 DESC

--Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? 
--If not - how would you calculate it instead?
SELECT 
  calendar_year,
  platform,
  ROUND(AVG(avg_transaction), 0) AS avg_transaction_use_column,
  SUM(sales) / SUM(transactions) AS avg_transaction_calculate_groupby
FROM clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform
