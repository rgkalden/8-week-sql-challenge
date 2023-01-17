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