## B. Customer Transactions
  
1. What is the unique count and total amount for each transaction type?
2. What is the average total historical deposit counts and amounts for all customers?
3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
4. What is the closing balance for each customer at the end of the month?
5. What is the percentage of customers who increase their closing balance by more than 5%?

---
### 1. What is the unique count and total amount for each transaction type?

```TSQL
SELECT
	txn_type,
	COUNT(customer_id) AS count_transaction,
	SUM(txn_amount) AS total_amount
FROM customer_transactiONs
GROUP BY txn_type
```
Result:

|txn_type	|count_transaction|total_amount|
|-----------|-----------------|------------|
|withdrawal	|1580			|793003	|
|deposit	|2671			|1359168	|
|purchase	|1617			|806537	|

---
### 2. What is the average total historical deposit counts and amounts for all customers?

```TSQL
SELECT
	COUNT(txn_type) / COUNT(DISTINCT customer_id) AS avg_count_transaction,
	SUM(txn_amount) / COUNT(DISTINCT customer_id) AS avg_amount
FROM customer_transactions
GROUP BY txn_type
HAVING txn_type ='deposit'
```
Result:

|avg_count_transaction	|avg_amount|
|----------------------|-----------|
|5	|2718|

---
### 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

```TSQL
SELECT 
  month, 
  COUNT(customer_id) AS count_cust 
FROM 
  (SELECT 
      customer_id, 
      MONTH(txn_date) AS month, 
      SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS deposit_count, 
      SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_count, 
      SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawal_count 
    FROM customer_transactions 
    GROUP BY customer_id, MONTH(txn_date)
  ) AS b 
WHERE 
  deposit_count > 1 and (purchase_count = 1 or withdrawal_count = 1) 
GROUP BY month 
ORDER BY month
```
Result:

|month	|count_cust|
|-----------|-----|
|1	|115|
|2	|108|
|3	|113|
|4	|50|

---
### 4. What is the closing balance for each customer at the end of the month?
 * Create CTE `monthly_balances` to find indentify inflow and outflow and the balance of all transactions in every month for each customer
 * Create CTE `last_day` to make a series of last day of month for each customer
 * Find closing balance for each month using Window function SUM() to add changes during the month

```TSQL
WITH monthly_balances AS (
  SELECT 
    customer_id, 
    EOMONTH(txn_date) AS closing_month,  
    SUM(
      CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE (- txn_amount) END
    ) AS transaction_balance -- indentify inflow and outflow'
  FROM customer_transactions 
  GROUP BY customer_id, EOMONTH(txn_date)
), 
last_day AS (
  SELECT 
    DISTINCT customer_id, 
    EOMONTH(txn_date) AS ending_month 
  FROM customer_transactiONs 
  UNION 
  SELECT 
    DISTINCT customer_id, 
    EOMONTH(DATEADD(MONTH, 1, txn_date)) AS ending_month 
  FROM customer_transactions
  WHERE EOMONTH(DATEADD(MONTH, 1, txn_date)) <= (SELECT EOMONTH(MAX(txn_date)) FROM customer_transactions) -- Max last_day of each customer 
)
SELECT 
    ld.customer_id, 
    ld.ending_month, 
    COALESCE(mb.transaction_balance, 0) AS monthly_change, --replace null by 0
    SUM(mb.transaction_balance) OVER (PARTITION BY ld.customer_id Order By 
        ld.ending_month ROWS between UNBOUNDED PRECEDING and CURRENT ROW
    ) AS closing_balance
FROM 
    last_day ld 
    LEFT JOIN monthly_balances mb ON ld.ending_month = mb.closing_month 
    AND ld.customer_id = mb.customer_id
```
Result: (Part of 1970 rows)

|customer_id	|ending_month	|monthly_change	|closing_balance|
|-----------------|-----------------|-----------------|-------------|
|1	|2020-01-31	|312	|312|
|1	|2020-02-29	|0	|312|
|1	|2020-03-31	|-952	|-640|
|1	|2020-04-30	|0	|-640|
|2	|2020-01-31	|549	|549|
|2	|2020-02-29	|0	|549|
|2	|2020-03-31	|61	|610|
|2	|2020-04-30	|0	|610|
|3	|2020-01-31	|144	|144|
|3	|2020-02-29	|-965	|-821|
|3	|2020-03-31	|-401	|-1222|
|3	|2020-04-30	|493	|-729|
|4	|2020-01-31	|848	|848|
|4	|2020-02-29	|0	|848|
|4	|2020-03-31	|-193	|655|
|4	|2020-04-30	|0	|655|

---
### 5. What is the percentage of customers who increase their closing balance by more than 5%?

 * Copy 2 CTEs in the previous question.
 * Create a CTE `current_balance` by using the calculation for the closing balance in the previous question.
 * Create a new CTE `next_balance` to calculate the closing balance next month: `next_month_balance`
 * The percentage increase of the closing balance = 100 * (next balance - closing balance) / closing balance.
 * Create a temporary table `#variance` to prevent the error `"Warning: Null value is eliminated by an aggregate or other SET operation"`.
 * Count the number of customers increasing their closing balance by more than 5%, then divide that by the total number of customers.


```TSQL
-- CTE monthly_balances to find indentify inflow and outflow and the balance of all transactions in every month for each customer
WITH monthly_balances AS (
  SELECT 
    customer_id, 
    EOMONTH(txn_date) AS closing_month,  
    SUM(
      CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE (- txn_amount) END
    ) AS transaction_balance -- indentify inflow and outflow'
  FROM customer_transactions 
  GROUP BY customer_id, EOMONTH(txn_date)
), 
-- Create CTE last_day to make a series of last day of month for each customer
last_day AS (
  SELECT 
    DISTINCT customer_id, 
    EOMONTH(txn_date) AS ending_month 
  FROM customer_transactions 
  UNION 
  SELECT 
    DISTINCT customer_id, 
    EOMONTH(DATEADD(MONTH, 1, txn_date)) AS ending_month 
  FROM customer_transactions
  WHERE EOMONTH(DATEADD(MONTH, 1, txn_date)) <= (SELECT EOMONTH(MAX(txn_date)) FROM customer_transactions) -- Max last_day of each customer 
),
--CTE `current_balance` Closing balance of each customer by monthly
current_balance AS (
SELECT 
    ld.customer_id, 
    ld.ending_month, 
    COALESCE(mb.transaction_balance, 0) AS monthly_change, --replace null by 0
    SUM(mb.transaction_balance) OVER (PARTITION BY ld.customer_id Order By 
        ld.ending_month ROWS between UNBOUNDED PRECEDING and CURRENT ROW
    ) AS closing_balance
FROM 
    last_day ld 
    LEFT JOIN monthly_balances mb ON ld.ending_month = mb.closing_month 
    AND ld.customer_id = mb.customer_id
),
-- CTE add next month balance
next_balance AS (
SELECT 
    *, 
    LEAD(closing_balance) OVER (PARTITION BY customer_id ORDER BY ending_month) AS next_month_balance
FROM current_balance
)
SELECT
	*,
    100.0*(next_month_balance - closing_balance) /closing_balance AS variance_pct
INTO #variance
FROM next_balance
WHERE closing_balance !=0 AND next_month_balance IS NOT NULL

SELECT
	CAST(COUNT(DISTINCT customer_id)*100.0/ (SELECT COUNT(DISTINCT customer_id) FROM customer_transactions) AS DECIMAL(5,2)) AS pct_customer
FROM #variance
WHERE variance_pct > 5.0
```

Result:

|pct_customer|
|------------|
|75.80| 

---
**[Go Back Case Study](https://github.com/LotteyPham/SQL-code/tree/main/Bank%20Data%20Analysis%20Project#readme)**

