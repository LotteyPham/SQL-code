<h1>Bank Data Exploration</h1>
The following case study questions include some general data exploration analysis for the nodes and transactions
<h2>A. Customer Nodes Exploration</h2>
1.	How many unique nodes are there on the Data Bank system?<br />
<p>with diff_node as (	
	select 
	customer_id, 
	node_id,
	cast((end_date - start_date) as int) as total_dif,			
	lag(node_id) over(partition by customer_id order by start_date) as prev_node
	from customer_nodes
	where year(end_date) != 9999
)
select round(avg(total_dif),0) as agv_reallocated_days
from diff_node 
where node_id != prev_node

Result:
agv_reallocated_days
----------------------
14</p>
2.	What is the number of nodes per region?<br />
3.	How many customers are allocated to each region?<br />
4.	How many days on average are customers reallocated to a different node?<br />
5.	What is the median, 80th and 95th percentile for this same reallocation days metric for each region?<br />
<h2>B. Customer Transactions</h2>
1.	What is the unique count and total amount for each transaction type?<br />
2.	What is the average total historical deposit counts and amounts for all customers?<br />
3.	For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?<br />
4.	What is the closing balance for each customer at the end of the month?<br />
5.	What is the percentage of customers who increase their closing balance by more than 5%?<br />
