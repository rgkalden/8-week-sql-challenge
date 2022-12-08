/*
Query Based on:
https://github.com/iweld/8-Week-SQL-Challenge/blob/main/Case%20Study%203%20-%20Foodie-Fi/questions_and_answers.md

Using Postgres and pgAdmin
*/

-- C. Challenge Payment Question

-- The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid 
-- by each customer in the subscriptions table with the following requirements:

--    monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
--    upgrades from basic to monthly or pro plans are reduced by the current paid amount 
--		in that month and start immediately
--    upgrades from pro monthly to pro annual are paid at the end of the current billing period and also 
--		starts at the end of the month period
--    once a customer churns they will no longer make payments

SET search_path = foodie_fi;

DROP TABLE IF EXISTS subs_plans;
CREATE TEMP TABLE subs_plans AS (
	SELECT s.customer_id,
		s.plan_id,
		p.plan_name,
		p.price,
		s.start_date
	FROM subscriptions AS s
		JOIN PLANS AS p ON p.plan_id = s.plan_id
);

DROP TABLE IF EXISTS customer_payments;
CREATE TEMP TABLE customer_payments AS (
	SELECT customer_id,
		plan_id,
		plan_name,
		start_date,
		CASE
			WHEN plan_id = 1 THEN 9.90
			WHEN plan_id = 2 THEN 19.90
			WHEN plan_id = 3 THEN 199.00
			ELSE 0
		END AS amount,
		lead(plan_name) OVER (
			PARTITION BY customer_id
			ORDER BY start_date
		) AS next_plan
	FROM subs_plans
	WHERE plan_id <> 0
		AND start_date BETWEEN '2020-01-01' AND '2020-12-31'
);

SELECT customer_id,
	plan_id,
	plan_name,
	payment_date,
	CASE
		WHEN rn1 > rn2 -- If a customer upgrades
		AND lag(plan_id) OVER (
			PARTITION BY customer_id
			ORDER BY payment_date
		) < plan_id -- Make sure upgrades are within the same month or no discounted payment
		AND EXTRACT(
			MONTH
			FROM lag(payment_date) OVER (
					PARTITION BY customer_id
					ORDER BY payment_date
				)
		) = extract(
			MONTH
			FROM payment_date
		) -- Discount the current months payment from first month payment after upgrade
		THEN amount - lag(amount) OVER (
			PARTITION BY customer_id
			ORDER BY payment_date
		)
		ELSE amount
	END AS amount,
	row_number() OVER (PARTITION BY customer_id) AS payment_ord
from (
		SELECT customer_id,
			plan_id,
			plan_name,
			generate_series(start_date, end_date, '1 month')::date AS payment_date,
			amount,
			row_number() OVER (
				PARTITION BY customer_id
				ORDER BY start_date
			) AS rn1,
			row_number() OVER (
				PARTITION BY customer_id
				ORDER BY start_date desc
			) AS rn2
		from (
				SELECT customer_id,
					plan_id,
					plan_name,
					amount,
					start_date,
					CASE
						-- Customer pays monthly amount
						WHEN next_plan IS NULL
						AND plan_id != 3 THEN '2020-12-31' -- If customer upgrades from pro monthly to pro annual, pro monthly price ends the month before
						WHEN plan_id = 2
						AND next_plan = 'pro annual' THEN (
							lead(start_date) OVER (
								PARTITION BY customer_id
								ORDER BY start_date
							) - interval '1 month'
						) -- If customer churns or upgrade plans, change the start_date
						WHEN next_plan = 'churn'
						OR next_plan = 'pro monthly'
						OR next_plan = 'pro annual' THEN lead(start_date) OVER (
							PARTITION BY customer_id
							ORDER BY start_date
						) -- If customer upgrades to pro annual after trial
						WHEN plan_id = 3 THEN start_date
					END AS end_date,
					next_plan
				FROM customer_payments
			) AS tmp1
		WHERE plan_id != 4
	) AS tmp2
ORDER BY customer_id;