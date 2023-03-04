## A. Data Cleansing Steps
| Columns          | Actions to take                                                                                                                                          |
|------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------|
| week_date        | Convert to ```DATE``` using ```CONVERT```                                                                                                                |
| week_number*     | Extract number of week using ```DATEPART```                                                                                                              |
| month_number*    | Extract month using ```DATEPART```                                                                                                                       |
| calendar_year*   | Extract year using ```DATEPART```                                                                                                                        |
| region           | No changes                                                                                                                                               |
| platform         | No changes                                                                                                                                               |
| segment          | No changes                                                                                                                                               |
| customer_type    | No changes                                                                                                                                               |
| age_band*        | Use ```CASE WHEN``` to categorize ```segment```: |
| demographic*     | Use ```CASE WHEN``` to categorize ```segment```:                                       |
| transactions     | No changes                                                                                                                                               |
| sales            | ```CAST``` to ```bigint``` for further aggregations                                                                                                         |
| avg_transaction* | Divide ```sales``` by ```transactions``` and round up to 2 decimal places                     

Then save all into new table ```clean_weekly_sales```

```TSQL
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
FROM weekly_sales;
```
Go to next step: **[Data Exploration](--)**
