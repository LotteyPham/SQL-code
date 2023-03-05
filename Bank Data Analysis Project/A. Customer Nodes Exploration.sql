--A. Customer Nodes Exploration
--1.	How many unique nodes are there ON the Data Bank system?
SELECT
	SUM(n_node) AS total_unique_nodes
FROM	(--COUNT unique nodes for each region 
		SELECT 
			region_id,
			COUNT(DISTINCT node_id) AS n_node
		FROM customer_nodes
		GROUP BY region_id
		) a 

--2.	What is the number of nodes per region?
SELECT
	region_name,
	COUNT(DISTINCT node_id) AS no_of_nodes
FROM customer_nodes n
INNER JOIN regions r ON n.region_id =  r.region_id
GROUP BY region_name

--3.	How many customers are allocated to each region?
SELECT
	region_name,
	COUNT(DISTINCT customer_id) AS no_of_cust
FROM customer_nodes n
INNER JOIN regions r ON n.region_id =  r.region_id
GROUP BY region_name

--4.	How many days on average are customers reallocated to a different node?
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


--5.	What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
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


