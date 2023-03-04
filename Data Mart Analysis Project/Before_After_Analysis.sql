--What is the total sales for the 4 weeks before and after 2020-06-15? 
--What is the growth or reduction rate in actual values and percentage of sales?

--Find the week_number of '2020-06-15' @week_number_event =25)
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
FROM salesChanges;


--What about the entire 12 weeks before and after?
DECLARE @week_number_event INT = (
  SELECT DISTINCT week_number
  FROM clean_weekly_sales
  WHERE week_date = '2020-06-15');

--Find the total sales of 12 weeks before and after @week_number_event
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

--How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
-- COMPARE 4 weeks before and after event
DECLARE @week_number_event INT = (
  SELECT DISTINCT week_number
  FROM clean_weekly_sales
  WHERE week_date = '2020-06-15');

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


-- COMPARE 12 weeks before and after event
DECLARE @week_number_event INT = (
  SELECT DISTINCT week_number
  FROM clean_weekly_sales
  WHERE week_date = '2020-06-15');

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