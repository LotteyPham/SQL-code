--B. Customer transactions
--1.	What is the unique count and total amount for each transaction type?
SELECT
	txn_type,
	COUNT(customer_id) AS count_transaction,
	SUM(txn_amount) AS total_amount
FROM customer_transactiONs
GROUP BY txn_type
--2.	What is the average total historical deposit counts and amounts for all customers?
SELECT
	COUNT(txn_type) / COUNT(DISTINCT customer_id) AS avg_count_transaction,
	SUM(txn_amount) / COUNT(DISTINCT customer_id) AS avg_amount
FROM customer_transactions
GROUP BY txn_type
HAVING txn_type ='deposit'

--3.	For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
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


--4.	What is the closing balance for each customer at the end of the month?
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
)
--Find closing balance for each month using Window function SUM() to add changes during the month

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


--5.	What is the percentage of customers who increase their closing balance by more than 5%?
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
