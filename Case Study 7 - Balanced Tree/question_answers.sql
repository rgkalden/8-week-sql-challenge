SET search_path = balanced_tree;

-- High Level Sales Analysis

--     What was the total quantity sold for all products?

SELECT SUM(qty) FROM sales;

--     What is the total generated revenue for all products before discounts?

SELECT SUM(qty * price) FROM sales;

--     What was the total discount amount for all products?

SELECT
	SUM(qty * price * (discount :: float / 100)) AS total_discount
FROM sales;

-- Transaction Analysis

--     How many unique transactions were there?

SELECT COUNT(DISTINCT txn_id) FROM sales;

--     What is the average unique products purchased in each transaction?

WITH num_distinct_products AS (
	SELECT 
		txn_id,
		COUNT(DISTINCT prod_id) AS num_distinct_products
	FROM sales
	GROUP BY txn_id
)

SELECT ROUND(AVG(num_distinct_products)) AS num_disctinct_products FROM num_distinct_products;

--     What are the 25th, 50th and 75th percentile values for the revenue per transaction?

WITH revenue AS (
	SELECT
		txn_id,
		SUM(qty * price * (1 - discount ::float / 100)) AS revenue
	FROM sales
	GROUP BY txn_id
)

SELECT
	percentile_disc(0.25) WITHIN GROUP (ORDER BY revenue) AS percentile_25,
	percentile_disc(0.50) WITHIN GROUP (ORDER BY revenue) AS percentile_50,
	percentile_disc(0.75) WITHIN GROUP (ORDER BY revenue) AS percentile_75
FROM revenue;


--     What is the average discount value per transaction?

WITH discounts AS (
	SELECT
		txn_id,
		SUM(qty * price * (discount :: float / 100)) AS discount_amount
	FROM sales
	GROUP BY txn_id
)

SELECT AVG(discount_amount) FROM discounts;

--     What is the percentage split of all transactions for members vs non-members?

SELECT
	(SELECT COUNT(DISTINCT txn_id) FROM sales WHERE member = true) ::float / COUNT(DISTINCT txn_id) * 100 AS txn_percent_member,
	(SELECT COUNT(DISTINCT txn_id) FROM sales WHERE member = false) ::float / COUNT(DISTINCT txn_id) * 100 AS txn_percent_non_member
FROM sales;

--     What is the average revenue for member transactions and non-member transactions?

WITH revenue_members AS (
	SELECT
		txn_id,
		SUM(qty * price * (1 - discount ::float / 100)) AS revenue
	FROM sales
	WHERE member = true
	GROUP BY txn_id
),
revenue_non_members AS (
	SELECT
		txn_id,
		SUM(qty * price * (1 - discount ::float / 100)) AS revenue
	FROM sales
	WHERE member = false
	GROUP BY txn_id
)

SELECT AVG(revenue) FROM revenue_members

UNION

SELECT AVG(revenue) FROM revenue_non_members;

-- Product Analysis

--     What are the top 3 products by total revenue before discount?
--     What is the total quantity, revenue and discount for each segment?
--     What is the top selling product for each segment?
--     What is the total quantity, revenue and discount for each category?
--     What is the top selling product for each category?
--     What is the percentage split of revenue by product for each segment?
--     What is the percentage split of revenue by segment for each category?
--     What is the percentage split of total revenue by category?
--     What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
--     What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
