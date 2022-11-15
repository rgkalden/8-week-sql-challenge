# A. Pizza Metrics

#    How many pizzas were ordered?

SELECT COUNT(pizza_id) AS num_pizzas
FROM customer_orders;

#    How many unique customer orders were made?

SELECT COUNT(distinct(order_id)) AS num_unique_orders
FROM customer_orders;

#    How many successful orders were delivered by each runner?

SELECT runner_id, COUNT(order_id) AS num_successful_orders
FROM runner_orders_clean
WHERE cancellation IS NULL
GROUP BY runner_id;

#    How many of each type of pizza was delivered?

SELECT pizza_name, COUNT(c.pizza_id) AS num_delivered
FROM customer_orders_clean c
JOIN runner_orders_clean r ON c.order_id = r.order_id
JOIN pizza_names p ON p.pizza_id = c.pizza_id
WHERE cancellation IS NULL
GROUP BY c.pizza_id;

#    How many Vegetarian and Meatlovers were ordered by each customer?

SELECT customer_id, pizza_name, count(pizza_name) AS num_pizzas
FROM customer_orders_clean c
JOIN runner_orders_clean r ON c.order_id = r.order_id
JOIN pizza_names p ON p.pizza_id = c.pizza_id
GROUP BY customer_id, pizza_name
ORDER BY customer_id;

#    What was the maximum number of pizzas delivered in a single order?

SELECT MAX(num_pizzas) AS max_pizzas_delivered
FROM (
	SELECT c.order_id, COUNT(pizza_id) AS num_pizzas
	FROM customer_orders_clean c
	JOIN runner_orders_clean r ON c.order_id = r.order_id
    WHERE cancellation IS NULL
	GROUP BY c.order_id
) AS temp;

#    For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT customer_id,
	SUM(
	   CASE
		WHEN c.exclusions IS NOT NULL OR c.extras IS NOT NULL THEN 1
        ELSE 0
	   END
       ) AS at_least_1_change,
	SUM(
		CASE
		 WHEN c.exclusions IS NULL AND c.extras IS NULL THEN 1
         ELSE 0
	   END
       ) AS no_change
FROM customer_orders_clean c
JOIN runner_orders_clean r ON c.order_id = r.order_id
WHERE cancellation IS NULL
GROUP BY customer_id;

#    How many pizzas were delivered that had both exclusions and extras?

SELECT
	SUM(
	   CASE
		WHEN c.exclusions IS NOT NULL AND c.extras IS NOT NULL THEN 1
        ELSE 0
	   END
       ) AS exclude_and_extras
FROM customer_orders_clean c
JOIN runner_orders_clean r ON c.order_id = r.order_id
WHERE cancellation IS NULL;

#    What was the total volume of pizzas ordered for each hour of the day?

SELECT HOUR(order_time) AS hour_of_day, COUNT(pizza_id) AS num_pizzas
FROM customer_orders_clean
GROUP BY hour_of_day
ORDER BY hour_of_day;

#    What was the volume of orders for each day of the week?

SELECT WEEKDAY(order_time) AS day_of_week, COUNT(order_id) AS num_orders
FROM customer_orders_clean
GROUP BY day_of_week
ORDER BY day_of_week;


# B. Runner and Customer Experience

#    How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT WEEK(registration_date, 1) AS week_number, COUNT(runner_id) 
FROM runners
GROUP BY week_number;

#    What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

SELECT runner_id, AVG(timestampdiff(MINUTE, order_time, pickup_time)) AS avg_time
FROM customer_orders_clean c
JOIN runner_orders_clean r ON c.order_id = r.order_id
WHERE pickup_time IS NOT NULL
GROUP BY runner_id;

#    Is there any relationship between the number of pizzas and how long the order takes to prepare?



#    What was the average distance travelled for each customer?
#    What was the difference between the longest and shortest delivery times for all orders?
#    What was the average speed for each runner for each delivery and do you notice any trend for these values?
#    What is the successful delivery percentage for each runner?


