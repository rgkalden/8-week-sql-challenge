# 8 Week SQL Challenge

Practice analyzing data with SQL through eight different case studies

## Background

This project involves taking on eight different case studies, found at [https://8weeksqlchallenge.com/](https://8weeksqlchallenge.com/). Each study involves using SQL to answer questions related to the business problems involved.

## Folder Structure

In this repo, there is a folder for each case study.

For each case study, there are two SQL scripts: 
- `create_schema.sql` creates the database
- `question_answers.sql` contains the queries used to answer the questions

Information about each case study is provided in this README.

## Technical Information

MySQL Community Server and MySQL Workbench are used to create the databases and run queries for the case studies. 

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
