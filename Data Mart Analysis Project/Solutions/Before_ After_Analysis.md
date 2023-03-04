## C. Before & After Analysis
  
This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.
Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.
We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before.

Using this analysis approach - answer the following questions:

1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?

* First, we find the week_number of '2020-06-15' and declare @week_number_event
* Then, Find the total sales of 4 weeks before and after @week_number_event

```TSQL
DECLARE @week_number_event INT = (
  SELECT DISTINCT week_number
  FROM clean_weekly_sales
  WHERE week_date = '2020-06-15');

--Find the total sales of 4 weeks before and after @week_number_event
WITH salesChanges AS (
SELECT
	SUM(CASE WHEN week_number BETWEEN @week_number_event-4 AND @week_number_event-1 THEN sales END) AS before_changes,
	SUM(CASE WHEN week_number BETWEEN @week_number_event AND @week_number_event+3 THEN sales END) AS after_changes
FROM clean_weekly_sales
WHERE calendar_year = 2020
)

SELECT 
	*,
	(after_changes-before_changes) AS actual_values_change,
	CAST(100.0 * (after_changes-before_changes)/before_changes AS decimal(5,2)) AS pct_change
FROM salesChanges
```
Result:

|before_changes	|after_changes	|actual_values_change	|pct_change|
|--------------	|-----------------|-----------------------|----------------|
|2345878357		|2318994169		|-26884188			|-1.15|

2. What about the entire 12 weeks before and after?

* Do the same to find the week_number of '2020-06-15
* Then, Find the total sales of 12 weeks before and after @week_number_event

```TSQL
WITH salesChanges AS (
SELECT
	SUM(CASE WHEN week_number BETWEEN @week_number_event-12 AND @week_number_event-1 THEN sales END) AS before_changes,
	SUM(CASE WHEN week_number BETWEEN @week_number_event AND @week_number_event+11 THEN sales END) AS after_changes
FROM clean_weekly_sales
WHERE calendar_year = 2020
)

SELECT 
	*,
	(after_changes-before_changes) AS actual_values_change,
	CAST(100.0 * (after_changes-before_changes)/before_changes AS decimal(5,2)) AS pct_change
FROM salesChanges
```
Result:

|before_changes	|after_changes	|actual_values_change	|pct_change|
|-----------------|-----------------|-----------------------|--------------|
|7126273147		|6973947753		|-152325394			|-2.14|

3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

* 4 weeks before and after event

```TSQL
WITH salesChanges AS (
SELECT
	calendar_year,
	SUM(CASE WHEN week_number BETWEEN @week_number_event-4 AND @week_number_event-1 THEN sales END) AS before_changes,
	SUM(CASE WHEN week_number BETWEEN @week_number_event AND @week_number_event+3 THEN sales END) AS after_changes
FROM clean_weekly_sales
GROUP BY calendar_year
)

SELECT 
	*,
	CAST(100.0 * (after_changes-before_changes)/before_changes AS decimal(5,2)) AS pct_change
FROM salesChanges
ORDER BY calendar_year
```
Result:

|calendar_year	|before_changes	|after_changes	|pct_change|
|-----------------|-----------------|-----------------|-------------|
|2018			|2125140809		|2129242914		|0.19|
|2019			|2249989796		|2252326390		|0.10|
|2020			|2345878357		|2318994169		|-1.15|

* 12 weeks before and after event

```TSQL
WITH salesChanges AS (
SELECT
	calendar_year,
	SUM(CASE WHEN week_number BETWEEN @week_number_event-12 AND @week_number_event-1 THEN sales END) AS before_changes,
	SUM(CASE WHEN week_number BETWEEN @week_number_event AND @week_number_event+11 THEN sales END) AS after_changes
FROM clean_weekly_sales
GROUP BY calendar_year
)

SELECT 
	*,
	CAST(100.0 * (after_changes-before_changes)/before_changes AS decimal(5,2)) AS pct_change
FROM salesChanges
ORDER BY calendar_year
```
Result:

|calendar_year	|before_changes	|after_changes	|pct_change|
|-----------------|-----------------|-----------------|-------------|
|2018			|6396562317		|6500818510		|1.63|
|2019			|6883386397		|6862646103		|-0.30|
|2020			|7126273147		|6973947753		|-2.14|

---
Go to next step: **[Bonus_Question](https://github.com/LotteyPham/SQL-code/blob/main/Data%20Mart%20Analysis%20Project/Solutions/Bonus_Question.md)**

