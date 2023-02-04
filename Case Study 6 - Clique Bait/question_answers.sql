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


-- 3. Product Funnel Analysis

-- Using a single SQL query - create a new output table which has the following details:

--     How many times was each product viewed?
--     How many times was each product added to cart?
--     How many times was each product added to a cart but not purchased (abandoned)?
--     How many times was each product purchased?

DROP TABLE IF EXISTS product_info;
CREATE TABLE product_info AS (
WITH product_views AS (
	SELECT
		e.page_id,
		COUNT(event_name) AS n_page_views
	FROM events e 
	JOIN event_identifier i ON e.event_type = i.event_type
	JOIN page_hierarchy p ON e.page_id = p.page_id
	WHERE event_name = 'Page View'
	GROUP BY e.page_id
),

add_to_cart AS (
	SELECT
		e.page_id,
		SUM (
			CASE
				WHEN event_name = 'Add to Cart' THEN 1
				ELSE 0
			END
		) AS n_added_to_cart
	FROM events e 
	JOIN event_identifier i ON e.event_type = i.event_type
	JOIN page_hierarchy p ON e.page_id = p.page_id
	WHERE product_category IS NOT NULL
	GROUP BY e.page_id
),

abandoned AS (
	SELECT
		e.page_id,
		SUM (
			CASE
				WHEN event_name = 'Add to Cart' THEN 1
				ELSE 0
			END
		) AS abandoned_in_cart
	FROM events e 
	JOIN event_identifier i ON e.event_type = i.event_type
	JOIN page_hierarchy p ON e.page_id = p.page_id
	WHERE product_category IS NOT NULL
		AND NOT exists(
				SELECT visit_id
				FROM events
				WHERE event_type = 3
					AND e.visit_id = visit_id
			)
	GROUP BY e.page_id
),

purchased AS (
	SELECT
		e.page_id,
		SUM (
			CASE
				WHEN e.event_type = '2' THEN 1
				ELSE 0
			END
		) AS purchased_from_cart
	FROM events e 
	JOIN event_identifier i ON e.event_type = i.event_type
	JOIN page_hierarchy p ON e.page_id = p.page_id
	WHERE page_name NOT IN('All Products', 'Checkout', 'Confirmation', 'Home Page')
		AND EXISTS(
					SELECT
						visit_id
					FROM events
					WHERE event_type = 3 AND e.visit_id = visit_id
					)
	GROUP BY e.page_id
)

SELECT ph.page_id,
		ph.page_name,
		ph.product_category,
		pv.n_page_views,
		ac.n_added_to_cart,
		pp.purchased_from_cart,
		pa.abandoned_in_cart
	FROM page_hierarchy AS ph
		JOIN product_views AS pv ON pv.page_id = ph.page_id
		JOIN purchased AS pp ON pp.page_id = ph.page_id
		JOIN abandoned AS pa ON pa.page_id = ph.page_id
		JOIN add_to_cart AS ac ON ac.page_id = ph.page_id
);

SELECT *
FROM product_info;


-- Additionally, create another table which further aggregates the data for the above points
-- but this time for each product category instead of individual products.

DROP TABLE IF EXISTS category_info;
CREATE TABLE category_info AS (
	SELECT product_category,
		sum(n_page_views) AS total_page_view,
		sum(n_added_to_cart) AS total_added_to_cart,
		sum(purchased_from_cart) AS total_purchased,
		sum(abandoned_in_cart) AS total_abandoned
	FROM product_info
	GROUP BY product_category
);
SELECT *
FROM category_info;


-- Use your 2 new output tables - answer the following questions:

--     Which product had the most views, cart adds and purchases?

WITH rankings AS (
	SELECT
		page_name,
		n_page_views,
		RANK() OVER(ORDER BY n_page_views DESC) AS page_views_rank,
		n_added_to_cart,
		RANK() OVER(ORDER BY n_added_to_cart DESC) AS added_to_cart_rank,
		purchased_from_cart,
		RANK() OVER(ORDER BY purchased_from_cart DESC) AS purchased_from_cart_rank,
		abandoned_in_cart,
		RANK() OVER(ORDER BY abandoned_in_cart DESC) AS abandoned_in_cart_rank	
	FROM product_info
)

SELECT
	page_name,
	'Most Viewed' AS ranking
FROM rankings
WHERE page_views_rank = 1

UNION

SELECT
	page_name,
	'Most Added' AS ranking
FROM rankings
WHERE added_to_cart_rank = 1

UNION

SELECT
	page_name,
	'Most Purchased' AS ranking
FROM rankings
WHERE purchased_from_cart_rank = 1;

--     Which product was most likely to be abandoned?

WITH rankings AS (
	SELECT
		page_name,
		n_page_views,
		RANK() OVER(ORDER BY n_page_views DESC) AS page_views_rank,
		n_added_to_cart,
		RANK() OVER(ORDER BY n_added_to_cart DESC) AS added_to_cart_rank,
		purchased_from_cart,
		RANK() OVER(ORDER BY purchased_from_cart DESC) AS purchased_from_cart_rank,
		abandoned_in_cart,
		RANK() OVER(ORDER BY abandoned_in_cart DESC) AS abandoned_in_cart_rank	
	FROM product_info
)

SELECT 
	page_name
FROM rankings
WHERE abandoned_in_cart_rank = 1;

--     Which product had the highest view to purchase percentage?

SELECT 
	page_name,
	purchased_from_cart / n_page_views :: float * 100 AS purchase_view_percent
FROM product_info
ORDER BY purchase_view_percent DESC
LIMIT 1;

--     What is the average conversion rate from view to cart add?

SELECT
	AVG(n_added_to_cart / n_page_views :: float * 100 ) AS cart_conversion
FROM product_info;

--     What is the average conversion rate from cart add to purchase?

SELECT
	AVG(purchased_from_cart / n_added_to_cart :: float * 100 ) AS purchase_conversion
FROM product_info;


