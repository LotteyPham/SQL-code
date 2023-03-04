## D. Bonus Question
  
Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?
  * ```region```
  * ```platform```
  * ```age_band```
  * ```demographic```
  * ```customer_type```
Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?

---
Do the same the previous questions to find `@week_number_event` of `'2020-06-15'`

```TSQL
DECLARE @week_number_event INT = (
  SELECT DISTINCT week_number
  FROM clean_weekly_sales
  WHERE week_date = '2020-06-15');
```
Then, depend on areas we analyze, change `SELECT` and `GROUP BY`

---
### **Sales by Region**

```TSQL
WITH salesChanges_region AS (
SELECT
	region,
	SUM(CASE WHEN week_number BETWEEN @week_number_event-12 AND @week_number_event-1 THEN sales END) AS before_changes,
	SUM(CASE WHEN week_number BETWEEN @week_number_event AND @week_number_event+11 THEN sales END) AS after_changes
FROM clean_weekly_sales
WHERE calendar_year = 2020
GROUP BY region)

SELECT 
	*,
	CAST(100.0 * (after_changes-before_changes)/before_changes AS decimal(5,2)) AS pct_change
FROM salesChanges_region
ORDER BY pct_change
```
Result:

|region		|before_changes	|after_changes	|pct_change|
|-----------------|-----------------|-----------------|-------------|
|ASIA			|1637244466		|1583807621		|-3.26|
|OCEANIA		|2354116790		|2282795690		|-3.03|
|SOUTH AMERICA	|213036207		|208452033		|-2.15|
|CANADA		|426438454		|418264441		|-1.92|
|USA			|677013558		|666198715		|-1.60|
|AFRICA		|1709537105		|1700390294		|-0.54|
|EUROPE		|108886567		|114038959		|4.73|

**Insights and recommendations:**
 * Overall, the sales of most regions decreased after changing packages.
 * The highest negative impact was in ASIA with 3.26%. The company should reduce the number of products with sustainable packages here. 
 * Only EUROPE get a significant increase of 4.73%. The company should invest more in Europe.
---
### **Sales by Platform**

```TSQL
WITH salesChanges_platform AS (
SELECT
	platform,
	SUM(CASE WHEN week_number BETWEEN @week_number_event-12 AND @week_number_event-1 THEN sales END) AS before_changes,
	SUM(CASE WHEN week_number BETWEEN @week_number_event AND @week_number_event+11 THEN sales END) AS after_changes
FROM clean_weekly_sales
WHERE calendar_year = 2020
GROUP BY platform)

SELECT 
	*,
	CAST(100.0 * (after_changes-before_changes)/before_changes AS decimal(5,2)) AS pct_change
FROM salesChanges_platform
ORDER BY pct_change
```
Result:

|platform	|before_changes	|after_changes	|pct_change
|-----------|-----------------|-----------------|-------------
|Retail	|6906861113		|6738777279		|-2.43
|Shopify	|219412034		|235170474		|7.18

**Insights and recommendations:**
 * Retail has the negative impact, while Shopify has the positive impact. 
 * The company should put products with sustainable packages more in Shopify stores.
---
### **Sales by Age_band**

```TSQL
WITH salesChanges_age_band AS (
SELECT
	age_band,
	SUM(CASE WHEN week_number BETWEEN @week_number_event-12 AND @week_number_event-1 THEN sales END) AS before_changes,
	SUM(CASE WHEN week_number BETWEEN @week_number_event AND @week_number_event+11 THEN sales END) AS after_changes
FROM clean_weekly_sales
WHERE calendar_year = 2020
GROUP BY age_band)

SELECT 
	*,
	CAST(100.0 * (after_changes-before_changes)/before_changes AS decimal(5,2)) AS pct_change
FROM salesChanges_age_band
ORDER BY pct_change
```
Result:

|age_band		|before_changes	|after_changes	|pct_change|
|-----------------|-----------------|-----------------|-------------|
|unknown		|2764354464		|2671961443		|-3.34|
|Middle Aged	|1164847640		|1141853348		|-1.97|
|Retirees		|2395264515		|2365714994		|-1.23|
|Young Adults	|801806528		|794417968		|-0.92|

**Insights and recommendations:**
 * Overall, the sales decreased in all bands.
 * Middle Aged and Retirees had more negative impact than Young Adults. The company should promote new package products to Young Adults more.
 
---
### **Sales by demographic**

```TSQL
WITH salesChanges_demographic AS (
SELECT
	demographic,
	SUM(CASE WHEN week_number BETWEEN @week_number_event-12 AND @week_number_event-1 THEN sales END) AS before_changes,
	SUM(CASE WHEN week_number BETWEEN @week_number_event AND @week_number_event+11 THEN sales END) AS after_changes
FROM clean_weekly_sales
WHERE calendar_year = 2020
GROUP BY demographic)

SELECT 
	*,
	CAST(100.0 * (after_changes-before_changes)/before_changes AS decimal(5,2)) AS pct_change
FROM salesChanges_demographic
ORDER BY pct_change
```
Result:

|demographic	|before_changes	|after_changes	|pct_change|
|-----------------|-----------------|-----------------|-------|
|unknown		|2764354464		|2671961443		|-3.34|
|Families		|2328329040		|2286009025		|-1.82|
|Couples		|2033589643		|2015977285		|-0.87|

**Insights and recommendations:**
 * Overall, the sales decreased in all demographics.
 * Families had more negative impact than Couples. The company should promote new package products to Couples.

---
### **Sales by customer_type**

```TSQL
WITH salesChanges_customer_type AS (
SELECT
	customer_type,
	SUM(CASE WHEN week_number BETWEEN @week_number_event-12 AND @week_number_event-1 THEN sales END) AS before_changes,
	SUM(CASE WHEN week_number BETWEEN @week_number_event AND @week_number_event+11 THEN sales END) AS after_changes
FROM clean_weekly_sales
WHERE calendar_year = 2020
GROUP BY customer_type)

SELECT 
	*,
	CAST(100.0 * (after_changes-before_changes)/before_changes AS decimal(5,2)) AS pct_change
FROM salesChanges_customer_type
ORDER BY pct_change
```
Result:

|customer_type	|before_changes	|after_changes	|pct_change|
|-----------------|-----------------|-----------------|-------------|
|Guest		|2573436301		|2496233635		|-3.00|
|Existing		|3690116427		|3606243454		|-2.27|
|New			|862720419		|871470664		|1.01|

**Insights and recommendations:**
 * The sales for Guests and Existing customers decreased, but increased for New customers.
 * Further analysis should be taken to understand why New customers were interested in sustainable packages.

---
**[Go Back Case Study](https://github.com/LotteyPham/SQL-code/blob/main/Data%20Mart%20Analysis%20Project/Readme.md)**

