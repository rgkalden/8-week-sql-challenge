USE dannys_diner;

#    What is the total amount each customer spent at the restaurant?

SELECT customer_id, SUM(price) AS total_amount
FROM sales
JOIN menu
ON sales.product_id = menu.product_id
GROUP BY customer_id;

#    How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(DISTINCT(order_date)) AS num_days
FROM sales
GROUP BY customer_id;

#    What was the first item from the menu purchased by each customer?
SELECT customer_id, product_name
FROM (
	SELECT customer_id, sales.order_date, menu.product_name, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY sales.order_date) AS ranking
	FROM sales
	JOIN menu
	ON sales.product_id = menu.product_id
) AS temp
WHERE ranking = 1;

#    What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT menu.product_name, COUNT(menu.product_id) AS num_purchases
FROM sales
JOIN menu
ON sales.product_id = menu.product_id
GROUP BY menu.product_name
ORDER BY num_purchases DESC
LIMIT 1;

#    Which item was the most popular for each customer?
SELECT customer_id, product_name, num_ordered
FROM (
	SELECT
	customer_id,
	product_name,
	count(sales.product_id) as num_ordered,
	dense_rank() over (partition by customer_id order by count(sales.product_id) desc) as ranking
	FROM sales
	JOIN menu ON sales.product_id = menu.product_id
	GROUP BY customer_id, product_name
) AS temp
WHERE ranking = 1;

#    Which item was purchased first by the customer after they became a member?
SELECT customer_id, product_name, order_date, join_date
FROM (
	SELECT sales.customer_id, order_date, product_name, join_date,
		   ROW_NUMBER() OVER(PARTITION BY sales.customer_id ORDER BY order_date) AS ranking
	FROM sales
	JOIN menu ON sales.product_id = menu.product_id
	JOIN members ON sales.customer_id = members.customer_id
	WHERE order_date >= join_date
) AS temp
WHERE ranking = 1;

#    Which item was purchased just before the customer became a member?

SELECT customer_id, product_name, order_date, join_date
FROM (
	SELECT sales.customer_id, order_date, product_name, join_date,
		   ROW_NUMBER() OVER(PARTITION BY sales.customer_id ORDER BY order_date DESC) AS ranking
	FROM sales
	JOIN menu ON sales.product_id = menu.product_id
	JOIN members ON sales.customer_id = members.customer_id
	WHERE order_date < join_date
) AS temp
WHERE ranking = 1;

#    What is the total items and amount spent for each member before they became a member?

SELECT
sales.customer_id,
product_name,
count(sales.product_id) as num_ordered,
SUM(menu.price) AS amount_spent
FROM sales
JOIN menu ON sales.product_id = menu.product_id
JOIN members ON sales.customer_id = members.customer_id
WHERE order_date < join_date
GROUP BY customer_id
ORDER BY customer_id;

#    If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT customer_id, SUM(points)
FROM (
SELECT customer_id, product_name, price,
	   CASE
		WHEN product_name = 'sushi' THEN price * 10 * 2
        ELSE price * 10
        END AS points
FROM sales
JOIN menu ON menu.product_id = sales.product_id
) AS temp
GROUP BY customer_id;

#    In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

WITH dates_cte AS (
	SELECT *, 
		DATE_ADD(join_date, INTERVAL 6 DAY) AS valid_date, 
		'2021-01-31' AS last_date
	FROM members
)

SELECT
	s.customer_id,
	sum(CASE
		WHEN s.product_id = 1 THEN price * 10 * 2
		WHEN s.order_date between d.join_date and d.valid_date THEN price * 10 * 2
		ELSE price * 10 
	END) as total_points
FROM
	dates_cte d
JOIN sales s ON s.customer_id = d.customer_id
JOIN menu m ON m.product_id = s.product_id
WHERE
	s.order_date <= d.last_date
GROUP BY s.customer_id;

#	Bonus Question 1

SELECT sales.customer_id, order_date, product_name, price,
		CASE
        WHEN order_date < join_date THEN 'N'
        ELSE 'Y'
        END AS member
FROM sales
JOIN menu ON menu.product_id = sales.product_id
JOIN members ON sales.customer_id = members.customer_id
ORDER BY customer_id, order_date, product_name;

# Bonus Question 2

SELECT customer_id, order_date, product_name, price, member,
	CASE
        WHEN member = 'Y' THEN RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date)
        ELSE NULL
        END AS ranking
FROM (
SELECT sales.customer_id, order_date, product_name, price,
		CASE
        WHEN order_date < join_date THEN 'N'
        ELSE 'Y'
        END AS member
FROM sales
JOIN menu ON menu.product_id = sales.product_id
JOIN members ON sales.customer_id = members.customer_id
ORDER BY customer_id, order_date, product_name
) AS temp;


