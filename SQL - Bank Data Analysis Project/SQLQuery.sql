--A. Customer Nodes Exploration
--1.	How many unique nodes are there on the Data Bank system?
select
	sum(n_node) as total_unique_nodes
from	(--count unique nodes for each region 
		select 
			region_id,
			count(distinct node_id) as n_node
		from customer_nodes
		group by region_id
		) a 

--2.	What is the number of nodes per region?
select
	region_name,
	count(distinct node_id) as no_of_nodes
from customer_nodes n
inner join regions r on n.region_id =  r.region_id
group by region_name

--3.	How many customers are allocated to each region?
select
	region_name,
	count(distinct customer_id) as no_of_cust
from customer_nodes n
inner join regions r on n.region_id =  r.region_id
group by region_name

--4.	How many days on average are customers reallocated to a different node?
with diff_node as (	
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

--5.	What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
with diff_node as (	
	select 
	customer_id, 
	region_id,
	node_id,
	cast((end_date - start_date) as float) as total_dif,			
	lag(node_id) over(partition by customer_id order by start_date) as prev_node
	from customer_nodes
	where year(end_date) != 9999
)
select 
	distinct region_name as region_name,  
	percentile_disc(0.5) within group (order by total_dif)  over (partition by s.region_id) as median,
	percentile_disc(0.8) within group (order by total_dif)  over (partition by s.region_id) as percentile_80,
	percentile_disc(0.95) within group (order by total_dif)  over (partition by s.region_id) as percentile_95
from diff_node s
inner join regions r on s.region_id =  r.region_id
where node_id != prev_node

--B. Customer Transactions
--1.	What is the unique count and total amount for each transaction type?
select
	txn_type,
	count(customer_id) as count_transaction,
	sum(txn_amount) as total_amount
from customer_transactions
group by txn_type
--2.	What is the average total historical deposit counts and amounts for all customers?
select
	count(txn_type) / count(distinct customer_id) as avg_count_transaction,
	avg(txn_amount) as avg_amount
from customer_transactions
group by txn_type
having txn_type ='deposit'

--3.	For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
select 
  month, 
  count(distinct customer_id) as count_cust 
from 
  (select 
      customer_id, 
      month(txn_date) as month, 
      sum(case when txn_type = 'deposit' then 1 else 0 end) as deposit_count, 
      sum(case when txn_type = 'purchase' then 1 else 0 end) as purchase_count, 
      sum(case when txn_type = 'withdrawal' then 1 else 0 end) as withdrawal_count 
    from customer_transactions 
    group by customer_id, month(txn_date)
  ) as b 
where 
  deposit_count > 1 and (purchase_count >= 1 or withdrawal_count >= 1) 
group by month 
order by month


--4.	What is the closing balance for each customer at the end of the month?
with monthly_balances as (
  select 
    customer_id, 
    eomonth(txn_date) as closing_month,  
    sum(
      case when txn_type = 'deposit' then txn_amount else (- txn_amount) end
    ) as transaction_balance -- indentify inflow and outflow'
  from customer_transactions 
  group by customer_id, eomonth(txn_date)
), 
-- Create a series of last day of month for each customer
last_day as (
  select 
    distinct customer_id, 
    eomonth(txn_date) as ending_month 
  from customer_transactions 
  union 
  select 
    distinct customer_id, 
    eomonth(dateadd(month, 1, txn_date)) as ending_month 
  from customer_transactions
)
--Create closing balance for each month using Window function SUM() to add changes during the month

select 
    ld.customer_id, 
    ld.ending_month, 
    coalesce(mb.transaction_balance, 0) as monthly_change, --replace null by 0
    sum(mb.transaction_balance) over (partition by ld.customer_id order by 
        ld.ending_month rows between unbounded preceding and current row
    ) as closing_balance
into #table_q4
from 
    last_day ld 
    left join monthly_balances mb on ld.ending_month = mb.closing_month 
    and ld.customer_id = mb.customer_id

select * from #table_q4

--5.	What is the percentage of customers who increase their closing balance by more than 5%?
with first_month_balance as (
	select
		customer_id,
		closing_balance as balance_1st
	from	(select 
				*, 
				row_number() over(partition by customer_id order by ending_month) as row_no
			from #table_q4) a
	where row_no = 1
),
current_balance as (
	select
		customer_id,
		closing_balance as balance_cur
	from	(select 
				*, 
				row_number() over(partition by customer_id order by ending_month desc) as row_no
			from #table_q4) b
	where row_no = 1
),
variance_cte as (
	select 
		fb.customer_id, 
		balance_1st, 
		balance_cur,
		case 
			when balance_cur <= 0  then null 
			else round((balance_cur - balance_1st)*100 / balance_1st, 2) 
		end as variance
	from first_month_balance fb
	left join current_balance cb on fb.customer_id = cb.customer_id
)
select
	format(count(customer_id)*1.0/ (SELECT count(distinct customer_id) FROM customer_transactions),'P') AS over_5_pct_increase
from variance_cte
where variance > 5.0