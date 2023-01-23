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
--     What is the percentage of visits which view the checkout page but do not have a purchase event?
--     What are the top 3 pages by number of views?
--     What is the number of views and cart adds for each product category?
--     What are the top 3 products by purchases?
