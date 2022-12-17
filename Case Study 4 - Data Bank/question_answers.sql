SET search_path = data_bank;

-- A. Customer Nodes Exploration

--     How many unique nodes are there on the Data Bank system?

SELECT 
	SUM(nodes_per_region) AS unique_nodes
FROM (
	SELECT 
		region_id, 
		count(DISTINCT node_id) AS nodes_per_region
	FROM customer_nodes
	GROUP BY region_id
) AS temp;

--     What is the number of nodes per region?

SELECT 
	region_name, 
	count(DISTINCT node_id) AS nodes_per_region
FROM customer_nodes
JOIN regions ON regions.region_id = customer_nodes.region_id
GROUP BY region_name;

--     How many customers are allocated to each region?

SELECT 
	region_name, 
	count(DISTINCT customer_id) AS customers_per_region
FROM customer_nodes
JOIN regions ON regions.region_id = customer_nodes.region_id
GROUP BY region_name;

--     How many days on average are customers reallocated to a different node?

SELECT
	AVG(days) AS avg_days_realloc
FROM (
	SELECT 
		*,
		end_date - start_date AS days,
		LAG(node_id) OVER(PARTITION BY customer_id ORDER BY start_date) AS previous_node
	FROM customer_nodes
	WHERE 
		DATE_PART('year', end_date) != 9999
	ORDER BY customer_id, start_date
) AS temp
WHERE previous_node != node_id;

--     What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

SELECT
	region_name,
	percentile_cont(0.5) WITHIN GROUP(ORDER BY days) AS "50_percentile",
	percentile_cont(0.8) WITHIN GROUP(ORDER BY days) AS "80_percentile",
	percentile_cont(0.95) WITHIN GROUP(ORDER BY days) AS "95_percentile"
FROM (
	SELECT 
		*,
		end_date - start_date AS days,
		LAG(node_id) OVER(PARTITION BY customer_id ORDER BY start_date) AS previous_node
	FROM customer_nodes
	WHERE 
		DATE_PART('year', end_date) != 9999
	ORDER BY customer_id, start_date
) AS temp
JOIN regions ON regions.region_id = temp.region_id
WHERE previous_node != node_id
GROUP BY region_name;



-- B. Customer Transactions

--     What is the unique count and total amount for each transaction type?

SELECT
	distinct txn_type,
	COUNT(*) AS txn_count,
	SUM(txn_amount) AS txn_total
FROM customer_transactions
GROUP BY txn_type;

--     What is the average total historical deposit counts and amounts for all customers?

SELECT 
	AVG(deposit_count),
	AVG(deposit_avg)
FROM (
	SELECT 
		customer_id,
		COUNT(*) AS deposit_count,
		avg(txn_amount) AS deposit_avg
	FROM customer_transactions
	WHERE txn_type = 'deposit'
	GROUP BY customer_id
) AS temp;

--     For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

WITH txn_flags AS (
SELECT
	*,
	EXTRACT(MONTH FROM txn_date) AS month,
	CASE
		WHEN txn_type = 'deposit' THEN 1
		ELSE 0
	END AS deposit_flag,
	CASE
		WHEN txn_type = 'withdrawal' THEN 1
		ELSE 0
	END AS withdrawal_flag,
	CASE
		WHEN txn_type = 'purchase' THEN 1
		ELSE 0
	END AS purchase_flag
FROM customer_transactions
)

SELECT 
	month,
	COUNT(customer_id)
FROM (
	SELECT
		customer_id,
		month,
		SUM(deposit_flag) AS deposit_count,
		SUM(withdrawal_flag) AS withdrawal_count,
		SUM(purchase_flag) AS purchase_count
	FROM txn_flags
	GROUP BY customer_id, month
	ORDER BY customer_id, month
) AS temp
WHERE deposit_count > 1 AND (purchase_count = 1 OR withdrawal_count = 1)
GROUP BY month
ORDER BY month;

--     What is the closing balance for each customer at the end of the month?

WITH monthly_balances AS (
SELECT
	*,
	SUM(txn_amount_signed) OVER(PARTITION BY customer_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS balance
FROM (
	SELECT
		*,
		EXTRACT(MONTH FROM txn_date) AS month,
		CASE
			WHEN txn_type != 'deposit' THEN -1 * txn_amount
			ELSE txn_amount
		END AS txn_amount_signed
	FROM customer_transactions
	ORDER BY customer_id, month, txn_date
) AS temp
)

SELECT 
	customer_id,
	month,
	balance AS closing_balance
FROM (
	SELECT
		customer_id,
		txn_date,
		month,
		balance,
		ROW_NUMBER() OVER(PARTITION BY customer_id, month ORDER BY txn_date DESC) AS row_num
	FROM monthly_balances
) AS temp
WHERE row_num = 1;


--     What is the percentage of customers who increase their closing balance by more than 5%?



