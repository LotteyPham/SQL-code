## A. Customer Nodes Exploration
  
1. How many unique nodes are there on the Data Bank system?
2. What is the number of nodes per region?
3. How many customers are allocated to each region?
4. How many days on average are customers reallocated to a different node?
5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

---
### 1. How many unique nodes are there on the Data Bank system? 

```TSQL
SELECT
	SUM(n_node) AS total_unique_nodes
FROM	(--COUNT unique nodes for each region 
		SELECT 
			region_id,
			COUNT(DISTINCT node_id) AS n_node
		FROM customer_nodes
		GROUP BY region_id
		)
```
Result:
|total_unique_nodes|
|-----------|
|  25	|

---
### 2. What is the number of nodes per region?

```TSQL
SELECT
	region_name,
	COUNT(DISTINCT node_id) AS no_of_nodes
FROM customer_nodes n
INNER JOIN regions r ON n.region_id =  r.region_id
GROUP BY region_name
```
Result: 

|region_name	|no_of_nodes|
|-----------------|------|
|Africa	|5|
|America	|5|
|Asia		|5|
|Australia	|5|
|Europe	|5|

---
### 3. How many customers are allocated to each region?

```TSQL
SELECT
	region_name,
	COUNT(DISTINCT customer_id) AS no_of_cust
FROM customer_nodes n
INNER JOIN regions r ON n.region_id =  r.region_id
GROUP BY region_name
```
Result:

|region_name	|no_of_cust|
|-----------------|-----|
|Africa	|102|
|America	|105|
|Asia		|95|
|Australia	|110|
|Europe	|88|

---
4. How many days on average are customers reallocated to a different node?
 * Create CTE `first_start_date` to find MIN start_date of each customer in each node
 * Create CTE `reallocated` To calculate the difference in days between the first date in this node and the first date in next node
 * Take the average of those day differences 

```TSQL
WITH first_start_date AS (	
SELECT 
	customer_id, 
	region_id,
	node_id,
	MIN(start_date) AS first_start		
FROM customer_nodes
WHERE YEAR(end_date) != 9999
GROUP BY customer_id, region_id, node_id
),
reallocated AS (
SELECT
	customer_id, 
	region_id,
	node_id,
	DATEDIFF(DAY,first_start, LEAD(first_start) OVER(PARTITION BY customer_id ORDER BY first_start)) AS total_diff
FROM first_start_date
)

SELECT 
	AVG(CAST(total_diff AS FLOAT)) AS agv_reallocated_days
FROM reallocated 
```
Result: 

|agv_reallocated_days|
|--------------|
|21.995597945708|


---
### 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

Using 2 CTEs in the previous questions `first_start_date` and `reallocated` to calculate the median, 80th and 95th percentile for reallocation days in each region

```TSQL
WITH first_start_date AS (	
SELECT 
	customer_id, 
	region_id,
	node_id,
	MIN(start_date) AS first_start		
FROM customer_nodes
WHERE YEAR(end_date) != 9999
GROUP BY customer_id, region_id, node_id
),
reallocated AS (
SELECT
	customer_id, 
	region_id,
	node_id,
	DATEDIFF(DAY,first_start, LEAD(first_start) OVER(PARTITION BY customer_id ORDER BY first_start)) AS total_diff
FROM first_start_date
)
SELECT 
	DISTINCT region_name AS region_name,  
	PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY total_diff)  OVER (PARTITION BY s.region_id) AS median,
	PERCENTILE_DISC(0.8) WITHIN GROUP (ORDER BY total_diff)  OVER (PARTITION BY s.region_id) AS percentile_80,
	PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY total_diff)  OVER (PARTITION BY s.region_id) AS percentile_95
FROM reallocated s
INNER JOIN regions r ON s.region_id =  r.region_id
```
Result:

|region_name	|median	|percentile_80	|percentile_95|
|-----------------|-----------|-----------------|--------------|
|Africa		|20		|30			|50|
|America		|21		|31			|53|
|Europe		|21		|30			|51|
|Australia		|20		|30			|48|
|Asia			|21		|31			|48|


---
Go to next step: **[Customer transactions](https://github.com/LotteyPham/SQL-code/blob/main/Bank%20Data%20Analysis%20Project/IMG/B.CustomerTransactions.md)**

