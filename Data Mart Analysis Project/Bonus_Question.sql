 --Which areas of the business have the highest negative impact in sales metrics performance in 2020 
 --for the 12 week before and after period?

-- By region
DECLARE @week_number_event INT = (
  SELECT DISTINCT week_number
  FROM clean_weekly_sales
  WHERE week_date = '2020-06-15');

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

-- By Platform
DECLARE @week_number_event INT = (
  SELECT DISTINCT week_number
  FROM clean_weekly_sales
  WHERE week_date = '2020-06-15');

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

-- By Age_band
DECLARE @week_number_event INT = (
  SELECT DISTINCT week_number
  FROM clean_weekly_sales
  WHERE week_date = '2020-06-15');

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

-- By demographic
DECLARE @week_number_event INT = (
  SELECT DISTINCT week_number
  FROM clean_weekly_sales
  WHERE week_date = '2020-06-15');

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

-- By customer_type
DECLARE @week_number_event INT = (
  SELECT DISTINCT week_number
  FROM clean_weekly_sales
  WHERE week_date = '2020-06-15');

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