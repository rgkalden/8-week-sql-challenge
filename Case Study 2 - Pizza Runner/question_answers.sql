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

SELECT num_pizzas, AVG(prep_time)
FROM (
	SELECT c.order_id, 
		   COUNT(pizza_id) AS num_pizzas,
		   timestampdiff(MINUTE, order_time, pickup_time) AS prep_time
	FROM customer_orders_clean c
	JOIN runner_orders_clean r ON c.order_id = r.order_id
	WHERE pickup_time IS NOT NULL
	GROUP BY c.order_id
) AS temp
GROUP BY num_pizzas;


#    What was the average distance travelled for each customer?

SELECT customer_id, AVG(distance)
FROM customer_orders_clean c
JOIN runner_orders_clean r ON c.order_id = r.order_id
WHERE pickup_time IS NOT NULL
GROUP BY customer_id;

#    What was the difference between the longest and shortest delivery times for all orders?

SELECT MAX(duration) - MIN(duration)
FROM customer_orders_clean c
JOIN runner_orders_clean r ON c.order_id = r.order_id
WHERE pickup_time IS NOT NULL;

#    What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT c.order_id, 
	   c.customer_id,
       r.runner_id,
       COUNT(pizza_id) AS num_pizzas,
       distance / (duration / 60) AS avg_speed
FROM customer_orders_clean c
JOIN runner_orders_clean r ON c.order_id = r.order_id
WHERE pickup_time IS NOT NULL
GROUP BY c.order_id;

#    What is the successful delivery percentage for each runner?

SELECT runner_id, 
	   SUM(success) / COUNT(success) * 100 AS success_delivery_percent
FROM (
	SELECT runner_id,
		   CASE
			WHEN pickup_time IS NULL THEN 0
			ELSE 1
		   END AS success
	FROM runner_orders_clean
) AS temp
GROUP BY runner_id;


# C. Ingredient Optimisation

#    What are the standard ingredients for each pizza?

SELECT pizza_names.pizza_id, pizza_name, toppings 
FROM pizza_recipes
JOIN pizza_names ON pizza_recipes.pizza_id = pizza_names.pizza_id;

#    What was the most commonly added extra?

# Work in progress
SELECT *,
	SUBSTRING_INDEX(extras, ',', 1) AS extras1,
    substring_index(extras, ',', -1) AS extras2
FROM customer_orders_clean
WHERE extras IS NOT NULL;

#    What was the most common exclusion?



#    Generate an order item for each record in the customers_orders table in the format of one of the following:
#        Meat Lovers
#        Meat Lovers - Exclude Beef
#        Meat Lovers - Extra Bacon
#        Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers



#    Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
#        For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"



#    What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?


# D. Pricing and Ratings

#    If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes 
#    - how much money has Pizza Runner made so far if there are no delivery fees?

SELECT 
	SUM(pizza_cost) AS revenue
FROM (
	SELECT
		pizza_name,
		CASE
			WHEN pizza_name = 'Meatlovers' THEN 12
			WHEN pizza_name = 'Vegetarian' THEN 10
		END AS pizza_cost
	FROM customer_orders_clean
	JOIN pizza_names ON pizza_names.pizza_id = customer_orders_clean.pizza_id
    JOIN runner_orders_clean ON runner_orders_clean.order_id = customer_orders_clean.order_id
    WHERE pickup_time IS NOT NULL
) AS temp;

#    What if there was an additional $1 charge for any pizza extras?
#        Add cheese is $1 extra

SELECT 
	SUM(pizza_cost + num_extras * 1) AS revenue
FROM (
	SELECT
		pizza_name,
        extras,
		CASE
			WHEN pizza_name = 'Meatlovers' THEN 12
			WHEN pizza_name = 'Vegetarian' THEN 10
		END AS pizza_cost,
        CASE
			WHEN extras LIKE '_' THEN 1
            WHEN extras LIKE '%,%' THEN LENGTH(REPLACE(extras, ', ', ''))
            ELSE 0
		END AS num_extras
	FROM customer_orders_clean
	JOIN pizza_names ON pizza_names.pizza_id = customer_orders_clean.pizza_id
    JOIN runner_orders_clean ON runner_orders_clean.order_id = customer_orders_clean.order_id
    WHERE pickup_time IS NOT NULL
) AS temp;

#    The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner,
#    how would you design an additional table for this new dataset - 
#    generate a schema for this new table and insert your own data for ratings for each successful 
#    customer order between 1 to 5.

DROP TABLE IF EXISTS runner_ratings;
CREATE TABLE runner_ratings (
  rating_id INTEGER,
  order_id INTEGER,
  runner_id INTEGER,
  rating_time DATETIME,
  rating INTEGER
);

INSERT INTO runner_ratings
  (rating_id, order_id, runner_id, rating_time, rating)
VALUES
  ('1', '1', '1', '2020-01-01 18:15:34', '5'),
  ('2', '2', '1', '2020-01-01 19:10:54', '4'),
  ('3', '3', '1', '2020-01-03 00:12:37', '3'),
  ('4', '4', '2', '2020-01-04 13:53:03', '5'),
  ('5', '5', '3', '2020-01-08 21:10:57', '5'),
  ('6', '7', '2', '2020-01-08 21:30:45', '4'),
  ('7', '8', '2', '2020-01-10 00:15:02', '2'),
  ('8', '10', '1', '2020-01-11 18:50:20', '5');

#    Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
#        customer_id
#        order_id
#        runner_id
#        rating
#        order_time
#        pickup_time
#        Time between order and pickup
#        Delivery duration
#        Average speed
#        Total number of pizzas

SELECT
	customer_id,
    co.order_id,
    ro.runner_id,
    rating,
    order_time,
    pickup_time,
    timestampdiff(MINUTE, order_time, pickup_time) AS prep_time,
    duration,
    distance / (duration / 60) AS avg_speed,
    COUNT(pizza_id) AS num_pizzas
FROM customer_orders_clean co
JOIN runner_orders_clean ro ON co.order_id = ro.order_id
JOIN runner_ratings rr ON rr.order_id = co.order_id
GROUP BY co.customer_id, co.order_id;

#    If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is 
#	 paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

SELECT 
	SUM(pizza_cost) - SUM(runner_cost)
FROM (
	SELECT
		pizza_name,
		CASE
			WHEN pizza_name = 'Meatlovers' THEN 12
			WHEN pizza_name = 'Vegetarian' THEN 10
		END AS pizza_cost,
        distance,
        distance * 0.30 AS runner_cost
	FROM customer_orders_clean
	JOIN pizza_names ON pizza_names.pizza_id = customer_orders_clean.pizza_id
    JOIN runner_orders_clean ON runner_orders_clean.order_id = customer_orders_clean.order_id
    WHERE pickup_time IS NOT NULL AND distance IS NOT NULL
) AS temp;

# E. Bonus Questions

# If Danny wants to expand his range of pizzas - how would this impact the existing data design? 
# Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the 
# toppings was added to the Pizza Runner menu?

INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (3, 'Supreme');
  
INSERT INTO pizza_recipes
(pizza_id, toppings)
VALUES
  (3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');
  
SELECT pizza_names.pizza_id, pizza_name, toppings
FROM pizza_names
JOIN pizza_recipes ON pizza_names.pizza_id = pizza_recipes.pizza_id



