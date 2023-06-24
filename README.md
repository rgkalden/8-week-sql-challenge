# 8 Week SQL Challenge

Practice analyzing data with SQL through eight different case studies

## Table of Contents

- [Case Study 1 - Danny's Diner](#case-study-1---dannys-diner)
- [Case Study 2 - Pizza Runner](#case-study-2---pizza-runner)
- [Case Study 3 - Foodie-Fi](#case-study-3---foodie-fi)
- [Case Study 4 - Data Bank](#case-study-4---data-bank)
- [Case Study 5 - Data Mart](#case-study-5---data-mart)
- [Case Study 6 - Clique Bait](#case-study-6---clique-bait)
- [Case Study 7 - Balanced Tree](#case-study-7---balanced-tree)

## Background

This project involves taking on eight different case studies, found at [https://8weeksqlchallenge.com/](https://8weeksqlchallenge.com/). Each study involves using SQL to answer questions related to the business problems involved.

## Folder Structure

In this repo, there is a folder for each case study.

For each case study, there are two SQL scripts: 
- `create_schema.sql` creates the database
- `question_answers.sql` contains the queries used to answer the questions

There may also be a `data_cleaning.sql` file for any data cleaning, and additional markdown or SQL scripts to answer further questions if required.

Information about each case study is provided in this README.

## Technical Information

MySQL Community Server and MySQL Workbench are used to create the databases and run queries for cases 1-3 (Case 3 uses Postgres to answer the question for Part C).

Postgres and pgAdmin are used for Case 4 onwards.

## Case Study 1 - Danny's Diner

Information on this case study can be found at [https://8weeksqlchallenge.com/case-study-1/](https://8weeksqlchallenge.com/case-study-1/). 

### Problem Statement

From the website:

> Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers. 
>
>He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.
>
>Danny has provided you with a sample of his overall customer data due to privacy issues - but he hopes that these examples are enough for you to write fully functioning SQL queries to help him answer his questions!

### Entity Relationship Diagram

<img src="diagrams/case study 1.png"/>

### Questions


1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?


## Case Study 2 - Pizza Runner

Information on this case study can be found at [https://8weeksqlchallenge.com/case-study-2/](https://8weeksqlchallenge.com/case-study-2/). 

### Problem Statement

From the website:

>Did you know that over 115 million kilograms of pizza is consumed daily worldwide??? (Well according to Wikipedia anyway…)
>
>Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!”
>
>Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so Pizza Runner was launched!
>
>Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.

### Entity Relationship Diagram

<img src="diagrams/case study 2.png"/>

### Questions

A. Pizza Metrics

1. How many pizzas were ordered?
2. How many unique customer orders were made?
3. How many successful orders were delivered by each runner?
4. How many of each type of pizza was delivered?
5. How many Vegetarian and Meatlovers were ordered by each customer?
6. What was the maximum number of pizzas delivered in a single order?
7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
8. How many pizzas were delivered that had both exclusions and extras?
9. What was the total volume of pizzas ordered for each hour of the day?
10. What was the volume of orders for each day of the week?

B. Runner and Customer Experience

1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
4. What was the average distance travelled for each customer?
5. What was the difference between the longest and shortest delivery times for all orders?
6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
7. What is the successful delivery percentage for each runner?

C. Ingredient Optimisation

1. What are the standard ingredients for each pizza?
2. What was the most commonly added extra?
3. What was the most common exclusion?
4. Generate an order item for each record in the customers_orders table in the format of one of the following:
    - Meat Lovers
    - Meat Lovers - Exclude Beef
    - Meat Lovers - Extra Bacon
    - Meat Lovers - Exclude Cheese, Bacon - Extra - Mushroom, Peppers
5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
    - For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

D. Pricing and Ratings

1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
2. What if there was an additional $1 charge for any pizza extras?
    - Add cheese is $1 extra
3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
    - customer_id
    - order_id
    - runner_id
    - rating
    - order_time
    - pickup_time
    - Time between order and pickup
    - Delivery duration
    - Average speed
    - Total number of pizzas
5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

E. Bonus Questions

If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

## Case Study 3 - Foodie-Fi

Information on this case study can be found at [https://8weeksqlchallenge.com/case-study-3/](https://8weeksqlchallenge.com/case-study-3/). 

### Problem Statement

From the website:

>Subscription based businesses are super popular and Danny realised that there was a large gap in the market - he wanted to create a new streaming service that only had food related content - something like Netflix but with only cooking shows!
>
>Danny finds a few smart friends to launch his new startup Foodie-Fi in 2020 and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world!
>
>Danny created Foodie-Fi with a data driven mindset and wanted to ensure all future investment decisions and new features were decided using data. This case study focuses on using subscription style digital data to answer important business questions.

### Entity Relationship Diagram

<img src="diagrams/case study 3.png"/>

### Questions

A. Customer Journey

Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

B. Data Analysis Questions

1. How many customers has Foodie-Fi ever had?
2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
6. What is the number and percentage of customer plans after their initial free trial?
7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
8. How many customers have upgraded to an annual plan in 2020?
9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

C. Challenge Payment Question

The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
- once a customer churns they will no longer make payments

D. Outside The Box Questions

The following are open ended questions which might be asked during a technical interview for this case study - there are no right or wrong answers, but answers that make sense from both a technical and a business perspective make an amazing impression!

1. How would you calculate the rate of growth for Foodie-Fi?
2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?
3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?
4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?
5. What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?

## Case Study 4 - Data Bank

Information on this case study can be found at [https://8weeksqlchallenge.com/case-study-4/](https://8weeksqlchallenge.com/case-study-4/). 

### Problem Statement

From the website:

>There is a new innovation in the financial industry called Neo-Banks: new aged digital only banks without physical branches.
>
>Danny thought that there should be some sort of intersection between these new age banks, cryptocurrency and the data world…so he decides to launch a new initiative - Data Bank!
>
>Data Bank runs just like any other digital bank - but it isn’t only for banking activities, they also have the world’s most secure distributed data storage platform!
>
>Customers are allocated cloud data storage limits which are directly linked to how much money they have in their accounts. There are a few interesting caveats that go with this business model, and this is where the Data Bank team need your help!
>
>The management team at Data Bank want to increase their total customer base - but also need some help tracking just how much data storage their customers will need.
>
>This case study is all about calculating metrics, growth and helping the business analyse their data in a smart way to better forecast and plan for their future developments!

### Entity Relationship Diagram

<img src="diagrams/case study 4.png"/>

### Questions

A. Customer Nodes Exploration

1. How many unique nodes are there on the Data Bank system?
2. What is the number of nodes per region?
3. How many customers are allocated to each region?
4. How many days on average are customers reallocated to a different node?
5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

B. Customer Transactions

1. What is the unique count and total amount for each transaction type?
2. What is the average total historical deposit counts and amounts for all customers?
3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
4. What is the closing balance for each customer at the end of the month?
5. What is the percentage of customers who increase their closing balance by more than 5%?


## Case Study 5 - Data Mart

Information on this case study can be found at [https://8weeksqlchallenge.com/case-study-5/](https://8weeksqlchallenge.com/case-study-5/). 

### Problem Statement

From the website:

>Data Mart is Danny’s latest venture and after running international operations for his online supermarket that specialises in fresh produce - Danny is asking for your support to analyse his sales performance.
>
>In June 2020 - large scale supply changes were made at Data Mart. All Data Mart products now use sustainable packaging methods in every single step from the farm all the way to the customer.
>
>Danny needs your help to quantify the impact of this change on the sales performance for Data Mart and it’s separate business areas.

### Entity Relationship Diagram

<img src="diagrams/case study 5.png"/>

### Questions

1. Data Cleansing Steps

In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:

- Convert the week_date to a DATE format
- Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
- Add a month_number with the calendar month for each week_date value as the 3rd column
- Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
- Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value

```
    segment 	age_band
    1 	        Young Adults
    2 	        Middle Aged
    3 or 4 	    Retirees
```

Add a new demographic column using the following mapping for the first letter in the segment values:

```
    segment 	demographic
    C 	        Couples
    F 	        Families
```

Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns

Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record

2. Data Exploration

- What day of the week is used for each week_date value?
-    What range of week numbers are missing from the dataset?
-    How many total transactions were there for each year in the dataset?
-    What is the total sales for each region for each month?
-    What is the total count of transactions for each platform
-    What is the percentage of sales for Retail vs Shopify for each month?
-    What is the percentage of sales by demographic for each year in the dataset?
-    Which age_band and demographic values contribute the most to Retail sales?
-    Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

3. Before & After Analysis

This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.

We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before

Using this analysis approach - answer the following questions:

- What is the total sales for the 4 weeks before and after 2020-06-15? 
- What is the growth or reduction rate in actual values and percentage of sales?
- What about the entire 12 weeks before and after?


## Case Study 6 - Clique Bait

Information on this case study can be found at [https://8weeksqlchallenge.com/case-study-6/](https://8weeksqlchallenge.com/case-study-6/). 

### Problem Statement

From the website:

>Clique Bait is not like your regular online seafood store - the founder and CEO Danny, was also a part of a digital data analytics team and wanted to expand his knowledge into the seafood industry!
>
>In this case study - you are required to support Danny’s vision and analyse his dataset and come up with creative solutions to calculate funnel fallout rates for the Clique Bait online store.

### Entity Relationship Diagram

<img src="diagrams/case study 6.png"/>

### Questions

2. Digital Analysis

Using the available datasets - answer the following questions using a single query for each one:

- How many users are there?
- How many cookies does each user have on average?
- What is the unique number of visits by all users per month?
- What is the number of events for each event type?
- What is the percentage of visits which have a purchase event?
- What is the percentage of visits which view the checkout page but do not have a purchase event?
- What are the top 3 pages by number of views?
- What is the number of views and cart adds for each product category?
- What are the top 3 products by purchases?

3. Product Funnel Analysis

Using a single SQL query - create a new output table which has the following details:

- How many times was each product viewed?
- How many times was each product added to cart?
- How many times was each product added to a cart but not purchased (abandoned)?
- How many times was each product purchased?

Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.

Use your 2 new output tables - answer the following questions:

- Which product had the most views, cart adds and purchases?
- Which product was most likely to be abandoned?
- Which product had the highest view to purchase percentage?
- What is the average conversion rate from view to cart add?
- What is the average conversion rate from cart add to purchase?

3. Campaigns Analysis

Generate a table that has 1 single row for every unique visit_id record and has the following columns:

    user_id
    visit_id
    visit_start_time: the earliest event_time for each visit
    page_views: count of page views for each visit
    cart_adds: count of product cart add events for each visit
    purchase: 1/0 flag if a purchase event exists for each visit
    campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
    impression: count of ad impressions for each visit
    click: count of ad clicks for each visit
    (Optional column) cart_products: a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the sequence_number)



Some ideas you might want to investigate further include:

- Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event
- Does clicking on an impression lead to higher purchase rates?
- What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click?
- What metrics can you use to quantify the success or failure of each campaign compared to eachother?



## Case Study 7 - Balanced Tree

Information on this case study can be found at [https://8weeksqlchallenge.com/case-study-7/](https://8weeksqlchallenge.com/case-study-7/). 

### Problem Statement

From the website:

> Balanced Tree Clothing Company prides themselves on providing an optimised range of clothing and lifestyle wear for the modern adventurer!
>
>Danny, the CEO of this trendy fashion company has asked you to assist the team’s merchandising teams analyse their sales performance and generate a basic financial report to share with the wider business.

### Questions

High Level Sales Analysis

-    What was the total quantity sold for all products?
-    What is the total generated revenue for all products before discounts?
-    What was the total discount amount for all products?

Transaction Analysis

 -   How many unique transactions were there?
-  What is the average unique products purchased in each transaction?
- What are the 25th, 50th and 75th percentile values for the revenue per transaction?
-What is the average discount value per transaction?
- What is the percentage split of all transactions for members vs non-members?
 - What is the average revenue for member transactions and non-member transactions?

Product Analysis

- What are the top 3 products by total revenue before discount?
- What is the total quantity, revenue and discount for each segment?
- What is the top selling product for each segment?
- What is the total quantity, revenue and discount for each category?
- What is the top selling product for each category?
- What is the percentage split of revenue by product for each segment?
- What is the percentage split of revenue by segment for each category?
- What is the percentage split of total revenue by category?
- What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
- What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
