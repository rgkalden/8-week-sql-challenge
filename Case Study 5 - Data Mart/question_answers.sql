SET search_path = data_mart;

-- 1. Data Cleansing

DROP TABLE IF EXISTS clean_weekly_sales;
CREATE TABLE clean_weekly_sales AS (
	SELECT 
		TO_DATE(week_date, 'DD/MM/YY') AS week_day,
		DATE_PART('week', TO_DATE(week_date, 'DD/MM/YY')) AS week_number,
		DATE_PART('month', TO_DATE(week_date, 'DD/MM/YY')) AS month_number,
		DATE_PART('year', TO_DATE(week_date, 'DD/MM/YY')) AS calendar_year,
		region,
		platform,
		CASE
			WHEN segment IS NOT NULL THEN segment
			WHEN segment = 'null' THEN 'unknown'
			ELSE 'unknown'
		END AS segment,
		CASE
			WHEN substring(segment, 2, 1) = '1' THEN 'Young Adults'
			WHEN substring(segment, 2, 1) = '2' THEN 'Middle Aged'
			WHEN substring(segment, 2, 1) = '3'
			OR substring(segment, 2, 1) = '4' THEN 'Retirees'
			ELSE 'unknown'
		END AS age_band,
		CASE
			WHEN substring(segment, 1, 1) = 'C' THEN 'Couples'
			WHEN substring(segment, 1, 1) = 'F' THEN 'Families'
			ELSE 'unknown'
		END AS demographic,
		customer_type,
		transactions,
		sales,
		ROUND(sales / transactions, 2) AS average_transaction
	FROM weekly_sales
);

SELECT * FROM clean_weekly_sales;


-- 2. Data Exploration


--    What day of the week is used for each week_date value?

SELECT 
	DISTINCT DATE_PART('dow', week_day) AS day_of_week 
FROM clean_weekly_sales;

--    What range of week numbers are missing from the dataset?

WITH week_number_cte AS (
	SELECT 
		*
	FROM generate_series(1, 52) AS week_number
)

SELECT
	DISTINCT a.week_number
FROM week_number_cte a
LEFT JOIN clean_weekly_sales b ON a.week_number = b.week_number
WHERE b.week_number IS NULL;

--    How many total transactions were there for each year in the dataset?

SELECT
	calendar_year,
	SUM(transactions)
FROM clean_weekly_sales
GROUP BY calendar_year;

--    What is the total sales for each region for each month?

SELECT
	region,
	month_number,
	SUM(sales)
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number;

--    What is the total count of transactions for each platform

SELECT
	platform,
	SUM(transactions)
FROM clean_weekly_sales
GROUP BY platform;

--    What is the percentage of sales for Retail vs Shopify for each month?

WITH monthly_platform_sales AS (
SELECT
	month_number,
	platform,
	SUM(sales) AS sales
FROM clean_weekly_sales
GROUP BY platform, month_number
ORDER BY month_number
),

total_monthly_sales AS (
SELECT 
	month_number, 
	SUM(sales) AS total_sales
FROM monthly_platform_sales 
GROUP BY month_number
)

SELECT 
	m.month_number,
	platform,
	sales,
	ROUND(sales / total_sales * 100, 1) AS percentage
FROM monthly_platform_sales m
JOIN total_monthly_sales t ON m.month_number = t.month_number;

--    What is the percentage of sales by demographic for each year in the dataset?

WITH yearly_demographic_sales AS (
SELECT
	calendar_year,
	demographic,
	SUM(sales) AS sales
FROM clean_weekly_sales
GROUP BY calendar_year, demographic
ORDER BY calendar_year, demographic
),

total_yearly_sales AS (
SELECT 
	calendar_year, 
	SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY calendar_year
)

SELECT 
	y.calendar_year,
	demographic,
	sales,
	sales / total_sales :: float * 100 AS percentage
FROM yearly_demographic_sales y
JOIN total_yearly_sales t ON y.calendar_year = t.calendar_year;

--    Which age_band and demographic values contribute the most to Retail sales?

SELECT
	age_band,
	demographic,
	SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE platform = 'Retail' AND age_band != 'unknown'
GROUP BY age_band, demographic
ORDER BY total_sales DESC;

--    Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? 
--    If not - how would you calculate it instead?

-- No, cannot take the average of an average. Instead:

WITH yearly_totals AS (
SELECT
	calendar_year,
	platform,
	SUM(transactions) AS total_transactions,
	SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform
)

SELECT
	calendar_year,
	platform,
	total_sales / total_transactions AS avg_transaction_size
FROM yearly_totals;
