# A. Customer Journey

# Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description
# about each customer’s onboarding journey.

# Try to keep it as short as possible - you may also want to run some sort of join to make your explanations 
# a bit easier!

SELECT customer_id, plans.plan_id, plan_name, price, start_date 
FROM plans
JOIN subscriptions ON subscriptions.plan_id = plans.plan_id
ORDER BY customer_id, start_date;



# B. Data Analysis Questions

#    How many customers has Foodie-Fi ever had?

SELECT COUNT(distinct customer_id) AS num_customers
FROM subscriptions;

#    What is the monthly distribution of trial plan start_date values for our dataset 
#	 - use the start of the month as the group by value

SELECT 
	MONTH(start_date) AS month_num, 
    monthname(start_date) AS month_name,
    COUNT(start_date) AS num_trial_subscriptions
FROM plans
JOIN subscriptions ON subscriptions.plan_id = plans.plan_id
WHERE plan_name = 'trial'
GROUP BY month_num
ORDER BY month_num;

#    What plan start_date values occur after the year 2020 for our dataset? 
#	 Show the breakdown by count of events for each plan_name

SELECT 
	plans.plan_id,
    plan_name, 
    COUNT(start_date)
FROM plans
JOIN subscriptions ON subscriptions.plan_id = plans.plan_id
WHERE YEAR(start_date) > 2020
GROUP BY plan_name
ORDER BY plan_id;

#    What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

SELECT 
	COUNT(DISTINCT customer_id) AS num_churned,
    ROUND(COUNT(DISTINCT customer_id) 
		/ (SELECT COUNT(distinct customer_id) AS num_customers FROM subscriptions) * 100, 1) 
			AS percent_churned
FROM plans
JOIN subscriptions ON subscriptions.plan_id = plans.plan_id
WHERE plan_name = 'churn';

#    How many customers have churned straight after their initial free trial - 
#	 what percentage is this rounded to the nearest whole number?

SELECT
	COUNT(DISTINCT customer_id) AS num_churned,
    ROUND(COUNT(DISTINCT customer_id) 
		/ (SELECT COUNT(distinct customer_id) AS num_customers FROM subscriptions) * 100) 
			AS percent_churned
FROM (
	SELECT 
		plans.plan_id,
		plan_name,
		customer_id,
		ROW_NUMBER() OVER (partition by customer_id ORDER BY plan_id) AS plan_order
	FROM plans
	JOIN subscriptions ON subscriptions.plan_id = plans.plan_id
) AS temp
WHERE plan_order = 2 AND plan_name = 'churn';

#    What is the number and percentage of customer plans after their initial free trial?

SELECT
	COUNT(DISTINCT customer_id) AS num_converted,
    ROUND(COUNT(DISTINCT customer_id) 
		/ (SELECT COUNT(distinct customer_id) AS num_customers FROM subscriptions) * 100) 
			AS percent_converted
FROM (
	SELECT 
		plans.plan_id,
		plan_name,
		customer_id,
		ROW_NUMBER() OVER (partition by customer_id ORDER BY plan_id) AS plan_order
	FROM plans
	JOIN subscriptions ON subscriptions.plan_id = plans.plan_id
) AS temp
WHERE plan_order = 2 AND plan_name IN ('basic monthly', 'pro monthly', 'pro annual');

#    What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

SELECT 
	plan_name,
    COUNT(plan_name)
FROM (
	SELECT 
		customer_id,
        plans.plan_id,
		plan_name,
        start_date,
		RANK() OVER (partition by customer_id ORDER BY plan_id DESC) AS plan_order
	FROM plans
	JOIN subscriptions ON subscriptions.plan_id = plans.plan_id
    WHERE start_date <= '2020-12-31'
) AS temp
WHERE plan_order = 1
GROUP BY plan_name
ORDER BY plan_id;

#    How many customers have upgraded to an annual plan in 2020?

SELECT COUNT(distinct customer_id)
FROM subscriptions
WHERE plan_id = 3 AND YEAR(start_date) = 2020;

#    How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

WITH 
trial_plan AS (
	SELECT customer_id, start_date AS trial_start FROM subscriptions WHERE plan_id = 0
),
annual_plan AS (
	SELECT customer_id, start_date AS annual_start FROM subscriptions WHERE plan_id = 3
)

SELECT 
	AVG(DATEDIFF(annual_start, trial_start)) AS avg_days
FROM trial_plan tp
JOIN annual_plan ap ON tp.customer_id = ap.customer_id;

#    Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

WITH 
trial_plan AS (
	SELECT customer_id, start_date AS trial_start FROM subscriptions WHERE plan_id = 0
),
annual_plan AS (
	SELECT customer_id, start_date AS annual_start FROM subscriptions WHERE plan_id = 3
),
days_to_upgrade AS (
	SELECT
		tp.customer_id,
		DATEDIFF(annual_start, trial_start) AS days_to_upgrade
	FROM trial_plan tp
	JOIN annual_plan ap ON tp.customer_id = ap.customer_id
)

SELECT 
	bucket,
	COUNT(customer_id)
FROM (
SELECT
	customer_id, 
	CASE
		WHEN days_to_upgrade <= 30 THEN '0 to 30 days'
        WHEN days_to_upgrade > 30 AND days_to_upgrade <= 60 THEN '30 to 60 days'
        WHEN days_to_upgrade > 60 AND days_to_upgrade <= 90 THEN '60 to 90 days'
        WHEN days_to_upgrade > 90 THEN '90 days or more'
	END AS bucket
FROM days_to_upgrade
) AS temp
GROUP BY bucket
ORDER BY bucket;

#    How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

SELECT
	COUNT(*) AS num_downgraded
FROM (
SELECT 
	customer_id,
    plans.plan_id,
    plan_name,
    start_date,
    LEAD(plans.plan_id, 1) OVER(PARTITION BY customer_id ORDER BY plan_id) AS next_plan
FROM plans
JOIN subscriptions on subscriptions.plan_id = plans.plan_id
) AS next_plans
WHERE YEAR(start_date) = 2020
	AND plan_id = 2
    AND next_plan = 1;
