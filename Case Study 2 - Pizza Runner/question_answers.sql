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



#    What was the maximum number of pizzas delivered in a single order?
#    For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
#    How many pizzas were delivered that had both exclusions and extras?
#    What was the total volume of pizzas ordered for each hour of the day?
#    What was the volume of orders for each day of the week?
