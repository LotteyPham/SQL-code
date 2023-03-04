SELECT 
	CONVERT(date,week_date,3) AS week_date,
	DATEPART(week,CONVERT(date,week_date,3)) AS week_number,
	DATEPART(month,CONVERT(date,week_date,3)) AS month_number,
	DATEPART(year,CONVERT(date,week_date,3)) AS calendar_year,
	region,
	platform,
	segment,
	CASE 
		WHEN RIGHT(segment,1) = '1'	THEN 'Young Adults'
		WHEN RIGHT(segment,1) = '2'	THEN 'Middle Aged'
		WHEN RIGHT(segment,1) = '3'	OR RIGHT(segment,1) = '4' THEN 'Retirees'
		ELSE 'unknown'
	END AS age_band,
	CASE 
		WHEN LEFT(segment,1) = 'C'	THEN 'Couples'
		WHEN LEFT(segment,1) = 'F'	THEN 'Families'
		ELSE 'unknown'
	END AS demographic,
	customer_type,
	transactions,
	CAST(sales AS bigint) AS sales,
	ROUND(CAST(sales AS FLOAT)/transactions, 2) AS avg_transaction
INTO clean_weekly_sales
FROM weekly_sales


