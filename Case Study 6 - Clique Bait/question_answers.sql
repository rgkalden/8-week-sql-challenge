SET search_path = clique_bait;

-- 2. Digital Analysis

-- Using the available datasets - answer the following questions using a single query for each one:

--     How many users are there?

SELECT COUNT(DISTINCT user_id) FROM users;

--     How many cookies does each user have on average?

WITH num_cookies_user AS (
	SELECT 
		user_id,
		COUNT(cookie_id) AS num_cookies
	FROM users
	GROUP BY user_id
)

SELECT AVG(num_cookies) FROM num_cookies_user;

--     What is the unique number of visits by all users per month?

SELECT
	EXTRACT(MONTH FROM event_time) AS month,
	COUNT(DISTINCT visit_id)
FROM users u
JOIN events e ON u.cookie_id = e.cookie_id
GROUP BY month
ORDER BY month;

--     What is the number of events for each event type?

SELECT
	e.event_type,
	event_name,
	COUNT(e.event_type)
FROM events e
JOIN event_identifier i ON e.event_type = i.event_type
GROUP BY e.event_type, event_name
ORDER BY e.event_type;

--     What is the percentage of visits which have a purchase event?

SELECT
	SUM(
		CASE
			WHEN i.event_name = 'Purchase' THEN 1
			ELSE 0
		END
		
	) :: float / COUNT(DISTINCT visit_id) * 100 AS purchase_percentage
FROM users u
JOIN events e ON u.cookie_id = e.cookie_id
JOIN event_identifier i ON e.event_type = i.event_type;

--     What is the percentage of visits which view the checkout page but do not have a purchase event?

WITH event_flags AS (
SELECT
	visit_id,
	SUM(
		CASE
			WHEN event_name = 'Page View' AND page_name = 'Checkout' THEN 1
			ELSE 0
		END
		) AS viewed_checkout,
	SUM (
		CASE
			WHEN i.event_name = 'Purchase' THEN 1
			ELSE 0
		END
		)  AS made_purchase
FROM events e 
JOIN event_identifier i ON e.event_type = i.event_type
JOIN page_hierarchy p ON e.page_id = p.page_id
GROUP BY visit_id
)

SELECT
	(SELECT COUNT(*) FROM event_flags WHERE viewed_checkout = 1 AND made_purchase = 0 LIMIT 1) / 
		COUNT(*) :: float * 100
FROM event_flags;


--     What are the top 3 pages by number of views?

SELECT
	page_name,
	COUNT(event_name) AS view_count
FROM events e 
JOIN event_identifier i ON e.event_type = i.event_type
JOIN page_hierarchy p ON e.page_id = p.page_id
WHERE event_name = 'Page View'
GROUP BY page_name
ORDER BY view_count DESC
LIMIT 3;


--     What is the number of views and cart adds for each product category?

SELECT
	product_category,
	SUM (
		CASE
			WHEN event_name = 'Page View' THEN 1
			ELSE 0
		END
	) AS num_views,
	SUM (
		CASE
			WHEN event_name = 'Add to Cart' THEN 1
			ELSE 0
		END
	) AS num_add_to_cart
FROM events e 
JOIN event_identifier i ON e.event_type = i.event_type
JOIN page_hierarchy p ON e.page_id = p.page_id
WHERE product_category IS NOT NULL
GROUP BY product_category
ORDER BY num_views DESC;

--     What are the top 3 products by purchases?

WITH purchase_flag AS (
	SELECT
		visit_id
	FROM events
	WHERE event_type = 3
)

SELECT
	page_name,
	COUNT(page_name) AS num_purchases
FROM events e 
JOIN event_identifier i ON e.event_type = i.event_type
JOIN page_hierarchy p ON e.page_id = p.page_id
JOIN purchase_flag f ON f.visit_id = e.visit_id
WHERE page_name NOT IN('All Products', 'Checkout', 'Confirmation', 'Home Page')
GROUP BY page_name
ORDER BY num_purchases DESC
LIMIT 3;



