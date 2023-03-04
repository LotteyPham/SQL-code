## B. Data Exploration
  
1. What day of the week is used for each ```week_date``` value?

```TSQL
SELECT
	DISTINCT DATENAME(WEEKDAY,week_date) AS day_of_week
FROM clean_weekly_sales
```
Result:
|day_of_week|
|-----------|
|  Monday	|


2. What range of week numbers are missing from the dataset?

* Create a temporary table containing the number 1~52
* Then using ```LEFT JOIN``` to join with table ```clean_weekly_sales```  and find ```week_number``` is ```NULL```

```TSQL
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
```
Result: (12 first rows)

|Row_num    |week_number|
|-----------|-----------|
|1          |NULL		|
|2          |NULL		|
|3          |NULL		|
|4          |NULL		|
|5          |NULL		|
|6          |NULL		|
|7          |NULL		|
|8          |NULL		|
|9          |NULL		|
|10         |NULL		|
|11         |NULL		|
|12         |NULL		|

The range of week numbers missing are 1-12 and 37-52

3. How many total transactions were there for each year in the dataset?

```TSQL
SELECT
	calendar_year,
	SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year
```
Result:

|calendar_year|total_transactions|
|-------------|------------------|
|2018         |346406460|
|2019         |365639285|
|2020         |375813651|

4. What is the total sales for each region for each month?

```TSQL
SELECT
	region,
	month_number,
	SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number
```
Result: (10 irst rows)

|region       | month_number| total_sales|
|-------------| ------------| --------------------|
|AFRICA       | 3           | 567767480|
|AFRICA       | 4           | 1911783504|
|AFRICA       | 5           | 1647244738|
|AFRICA       | 6           | 1767559760|
|AFRICA       | 7           | 1960219710|
|AFRICA       | 8           | 1809596890|
|AFRICA       | 9           | 276320987|
|ASIA         | 3           | 529770793|
|ASIA         | 4           | 1804628707|
|ASIA         | 5           | 1526285399|

5. What is the total count of transactions for each platform?

```TSQL
SELECT 
	platform,
	SUM(transactions) AS count_of_transactions
FROM clean_weekly_sales
GROUP BY platform
```
Result:

|platform| count_of_transactions|
|--------| ---------------------|
|Retail  | 1081934227|
|Shopify | 5925169|

6. What is the percentage of sales for Retail vs Shopify for each month?

```TSQL
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
```
Result:

|calendar_year| month_number| PCT_Retail    | PCT_Shopify	|
|-------------| ------------| --------------| -------------|
|2018         | 3           | 97.92         | 2.08|
|2018         | 4           | 97.93         | 2.07|
|2018         | 5           | 97.73         | 2.27|
|2018         | 6           | 97.76         | 2.24|
|2018         | 7           | 97.75         | 2.25|
|2018         | 8           | 97.71         | 2.29|
|2018         | 9           | 97.68         | 2.32|
|2019         | 3           | 97.71         | 2.29|
|2019         | 4           | 97.80         | 2.20|
|2019         | 5           | 97.52         | 2.48|
|2019         | 6           | 97.42         | 2.58|
|2019         | 7           | 97.35         | 2.65|
|2019         | 8           | 97.21         | 2.79|
|2019         | 9           | 97.09         | 2.91|
|2020         | 3           | 97.30         | 2.70|
|2020         | 4           | 96.96         | 3.04|
|2020         | 5           | 96.71         | 3.29|
|2020         | 6           | 96.80         | 3.20|
|2020         | 7           | 96.67         | 3.33|
|2020         | 8           | 96.51         | 3.49|

7. What is the percentage of sales by demographic for each year in the dataset?

```TSQL
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
```
Result:

|calendar_year| PCT_Couples                            | PCT_Families                           | PCT_unknown|
|-------------| ---------------------------------------| ---------------------------------------| ------------|
|2018         | 26.38                                  | 31.99                                  | 41.63|
|2019         | 27.28                                  | 32.47                                  | 40.25|
|2020         | 28.72                                  | 32.73                                  | 38.55|


8. Which ```age_band``` and ```demographic``` values contribute the most to Retail sales?

```TSQL
SELECT
	age_band,
	demographic,
	SUM(sales) AS sales,
	CAST(100.0 * SUM(sales) / (SELECT SUM(sales) FROM clean_weekly_sales WHERE platform = 'Retail') AS decimal(5,2)) AS contribution
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY 4 DESC
```
Result:

|age_band    | demographic| sales               | contribution|
|------------| -----------| --------------------| ----------------|
|unknown     | unknown    | 16067285533         | 40.52|
|Retirees    | Families   | 6634686916          | 16.73|
|Retirees    | Couples    | 6370580014          | 16.07|
|Middle Aged | Families   | 4354091554          | 10.98|
|Young Adults| Couples    | 2602922797          | 6.56|
|Middle Aged | Couples    | 1854160330          | 4.68|
|Young Adults| Families   | 1770889293          | 4.47|

* We can see that the Families - Retirees group contributes the most to the retail sale with 16.73%, the next is Couples - Retirees group -16.07% 

9. Can we use the ```avg_transaction``` column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

```TSQL
SELECT 
  calendar_year,
  platform,
  ROUND(AVG(avg_transaction), 0) AS avg_transaction_use_column,
  SUM(sales) / SUM(transactions) AS avg_transaction_calculate_groupby
FROM clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform
```
Result:

|calendar_year| platform| avg_transaction_use_column| avg_transaction_calculate_groupby|
|-------------| --------| --------------------------| ---------------------------------|
|2018         | Retail  | 43                        | 36|
|2018         | Shopify | 188                       | 192|
|2019         | Retail  | 42                        | 36|
|2019         | Shopify | 178                       | 183|
|2020         | Retail  | 41                        | 36|
|2020         | Shopify | 175                       | 179|

* ```avg_transaction_use_column``` : Use column ```avg_transaction``` to calculate, that we use ```AVG``` twice will have errors
* ```avg_transaction_calculate_groupby``` : Use ```GROUP BY``` to calculate will have a more accurate result. 

---
Go to next step: **[Before_After_Analysis](https://github.com/LotteyPham/SQL-code/blob/main/Data%20Mart%20Analysis%20Project/Solutions/Before_%20After_Analysis.md)**

