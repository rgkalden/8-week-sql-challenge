# Clean customer_orders table

CREATE TABLE customer_orders_clean AS

SELECT order_id, customer_id, pizza_id,
	CASE
		WHEN exclusions = '' THEN NULL
        WHEN exclusions = 'null' THEN NULL
        ELSE exclusions
	END AS exclusions,
    CASE
		WHEN extras LIKE '' THEN null
        WHEN extras LIKE 'null' THEN null
        ELSE extras
	END AS extras,
    order_time
FROM customer_orders;


# Clean runner_orders table

CREATE TABLE runner_orders_clean AS

SELECT order_id, runner_id,
	CASE
		WHEN pickup_time LIKE 'null' THEN null
        ELSE pickup_time
	END AS pickup_time,
    CASE
		WHEN distance LIKE '%km' THEN TRIM('km' FROM distance)
        WHEN distance LIKE 'null' THEN null
        ELSE distance
	END AS distance,
    CASE
		WHEN duration LIKE '%minutes' THEN TRIM('minutes' FROM duration)
        WHEN duration LIKE '%mins' THEN TRIM('mins' FROM duration)
        WHEN duration LIKE '%minute' THEN TRIM('minute' FROM duration)
        WHEN duration LIKE 'null' THEN null
        ELSE duration
	END AS duration,
    CASE
		WHEN cancellation LIKE '' THEN NULL
        WHEN cancellation LIKE 'null' THEN null
        ELSE cancellation
	END AS cancellation
FROM runner_orders;

ALTER TABLE runner_orders_clean
MODIFY COLUMN pickup_time DATETIME,
MODIFY COLUMN distance FLOAT,
MODIFY COLUMN duration INT;

