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
		end_date - start_date + 1 AS days,
		LAG(node_id) OVER(PARTITION BY customer_id ORDER BY start_date) AS previous_node
	FROM customer_nodes
	WHERE 
		DATE_PART('year', end_date) != 9999
	ORDER BY customer_id, start_date
) AS temp
WHERE previous_node != node_id;

--     What is the median, 80th and 95th percentile for this same reallocation days metric for each region?





-- B. Customer Transactions

--     What is the unique count and total amount for each transaction type?
--     What is the average total historical deposit counts and amounts for all customers?
--     For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
--     What is the closing balance for each customer at the end of the month?
--     What is the percentage of customers who increase their closing balance by more than 5%?
