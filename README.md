# Pizza Hut Data Analysis using SQL
<p align="center">
  <img src="https://raw.githubusercontent.com/tusharsharmaofficially-bit/PizzaHut_SQL_Project/main/Pizza%20Hut%20Logo.png" width="400" alt="Pizza Hut Logo">
</p>

## Overview
This Pizza Hut Sales Analysis project was performed using SQL to explore customer ordering behavior, sales performance, revenue trends, and product popularity. Multiple business questions were solved by querying and analyzing data from orders, order details, pizzas, and pizza types tables.

The project focuses on transforming raw transactional data into actionable business insights. Through data aggregation, joins, ranking functions, window functions, and revenue analysis, the project identifies top-performing pizzas, customer ordering patterns, peak sales periods, category performance, and overall revenue growth.

Several visualizations were created to represent the findings effectively, enabling stakeholders to make data-driven decisions regarding inventory planning, product offerings, pricing strategies, and sales optimization.

## Objectives

• Analyze overall sales performance of Pizza Hut.
• Measure revenue generated from pizza sales.
• Identify the most popular pizza types and categories.
• Understand customer ordering behavior across different hours of the day.
• Analyze pizza size preferences among customers.
• Evaluate category-wise sales contribution.
• Track daily ordering trends and average pizzas sold.
• Determine high-revenue products and categories.
• Monitor cumulative revenue growth over time.
• Generate business insights through SQL queries and visual analytics.

## Schema

```sql
CREATE TABLE order_details
(
    order_details_id INT,
     order_id   INT,
     pizza_id   VARCHAR(20),
     quantity	INT 
);

CREATE TABLE orders
(
    order_id INT,
     Date_col DATE,
     time_col TIME
);

CREATE TABLE pizza_types
(
    pizza_type_id VARCHAR(20),
    name_pizza VARCHAR(100),
     category   VARCHAR(50),
     ingredients VARCHAR(255)
);

CREATE TABLE pizzas
(
   pizza_id VARCHAR(20),
     pizza_type_id VARCHAR(20),
     size_of_pizza VARCHAR(5),
     Price DECIMAL(10,2)
);
```
## Business Problems and Solutions

### 1. Retrieve the total number of orders placed.

```sql
SELECT 
	   count(order_id) AS total_orders 
	   FROM orders;
```

**Objective:** Determine the overall volume of customer orders to understand business activity and customer engagement levels.

### 2. Calculate the total revenue generated from pizza sales.

```sql
SELECT 
	   ROUND(SUM(order_details.quantity * pizzas.price),
	   2) AS total_sales
	   FROM 
	   order_details 
	   JOIN 
	   pizzas ON pizzas.pizza_id = order_details.pizza_id
```

**Objective:** Measure the total income generated from pizza sales to evaluate overall business performance and profitability.

### 3. Identify the highest-priced pizza.

```sql
SELECT pizza_types.name_of_pizza, pizzas.price
	  FROM pizza_types 
	  JOIN pizzas 
	  ON pizza_types.pizza_type_id = pizzas.pizza_type_id
	  ORDER BY pizzas.price 
	  DESC LIMIT 1;
```

**Objective:** Find the premium pizza product offered by the business and understand pricing strategy effectiveness.

### 4. Identify the most common pizza size ordered.

```sql
SELECT pizzas.size_of_pizza, 
	  COUNT(order_details.order_details_id) 
	  AS order_count
	  FROM
	  pizzas 
	  JOIN
	  order_details 
	  ON pizzas.pizza_id = order_details.pizza_id
	  GROUP BY pizzas.size_of_pizza
	  ORDER BY order_count 
	  DESC;
```

**Objective:** Analyze customer preference for pizza sizes to support inventory management and menu planning.

### 5. List the top 5 most ordered pizza types along with their quantities.

```sql
SELECT 
	  pizza_types.name_of_pizza, SUM(order_details.quantity) AS quantity
	  FROM pizza_types
	  JOIN pizzas 
	  ON pizza_types.pizza_type_id = pizzas.pizza_type_id
	  JOIN order_details 
	  ON order_details.pizza_id = pizzas.pizza_id
	  GROUP BY pizza_types.name_of_pizza
	  ORDER BY quantity DESC 
	  LIMIT 5;
```

**Objective:** Identify the best-selling pizzas and understand customer taste preferences for product optimization.

### 6. Join the necessary tables to find the total quantity of each pizza category ordered. 

```sql
SELECT pizza_types.category,
	  SUM(order_details.quantity) AS quantity
	  FROM pizza_types JOIN pizzas
	  ON pizza_types.pizza_type_id = pizzas.pizza_type_id
	  JOIN order_details
	  ON order_details.pizza_id = pizzas.pizza_id
	  GROUP BY pizza_types.category ORDER BY quantity DESC;
```

**Objective:** Evaluate category performance by measuring demand across different pizza categories.

### 7. Determine the distribution of orders by hour of the day.

```sql
SELECT
       EXTRACT(HOUR FROM time_col) AS hour,
       COUNT(order_id) AS order_count
       FROM orders
       GROUP BY EXTRACT(HOUR FROM time_col)
       ORDER BY hour;
```

**Objective:** Identify peak ordering hours and customer purchasing patterns to optimize staffing and operations.

### 8. Join relevant tables to find the category-wise distribution of pizzas.  

```sql
SELECT category, 
	   COUNT(name_of_pizza) 
	   FROM pizza_types
	   GROUP BY category;
```

**Objective:** Understand the variety of pizzas available within each category and assess menu composition.

### 9. Group the orders by date and calculate the average number of pizzas ordered per day.

```sql
SELECT ROUND(AVG(quantity),0) FROM
       (SELECT orders.date_col, SUM(order_details.quantity) AS quantity
	   FROM orders JOIN order_details
	   ON orders.order_id = order_details.order_id
	   GROUP BY orders.date_col) AS order_quantity;
```

**Objective:** Measure average daily sales volume to evaluate operational demand and forecast future requirements.

### 10. Determine the top 3 most ordered pizza types based on revenue.

```sql
SELECT pizza_types.name_of_pizza,
	   SUM(order_details.quantity * pizzas.price) AS revenue
	   FROM pizza_types JOIN pizzas
	   ON pizzas.pizza_type_id = pizza_types.pizza_type_id
	   JOIN order_details
	   ON order_details.pizza_id = pizzas.pizza_id
	   GROUP BY pizza_types.name_of_pizza ORDER BY revenue DESC LIMIT 3;
```

**Objective:** Identify the most profitable pizza products and understand which items contribute the most to sales revenue.

### 11. Calculate the percentage contribution of each pizza type to total revenue.

```sql
SELECT pizza_types.category,
	   round(sum(order_details.quantity*pizzas.price)/(SELECT 
	   round(sum(order_details.quantity*pizzas.price),2)AS total_sales
	   FROM order_details JOIN
	   pizzas ON pizzas.pizza_id = order_details.pizza_id) *100,2) AS revenue
	   FROM pizza_types JOIN pizzas
	   ON pizza_types.pizza_type_id = pizzas.pizza_type_id
	   JOIN order_details
	   ON order_details.pizza_id = pizzas.pizza_id
	   GROUP BY pizza_types.category ORDER BY revenue DESC;
```

**Objective:** Analyze revenue contribution across pizza categories to identify the strongest revenue-generating segments.

### 12. Analyze the cumulative revenue generated over time.

```sql
SELECT date_col,
	   SUM(revenue)OVER(order by date_col) AS cum_revenue
	   FROM
	   (SELECT orders.date_col,
	   SUM(order_details.quantity * pizzas.price) AS revenue
	   FROM order_details JOIN pizzas
	   on order_details.pizza_id = pizzas.pizza_id
	   JOIN orders
	   ON orders.order_id = order_details.order_id
	   GROUP BY orders.date_col) AS sales;
```

**Objective:** Monitor revenue growth trends over time and evaluate business performance progression.

### 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

```sql
SELECT name_of_pizza, revenue FROM
       (SELECT category, name_of_pizza, revenue,
	   RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rn
	   FROM 
       (SELECT pizza_types.category, pizza_types.name_of_pizza,
	   SUM((order_details.quantity) * pizzas.price) AS revenue
	   FROM pizza_types JOIN pizzas
	   ON pizza_types.pizza_type_id =pizzas.pizza_type_id
	   JOIN order_details
	   ON order_details.pizza_id = pizzas.pizza_id
	   GROUP BY pizza_types.category, pizza_types.name_of_pizza) AS a) as b
	   WHERE rn <= 3;
```

**Objective:** Identify category-wise top-performing pizzas to support targeted marketing and menu optimization decisions.


## Findings

1. The business receives a substantial number of customer orders, indicating consistent customer demand.
2. Pizza sales generate significant revenue, demonstrating strong business performance.
3. Premium-priced pizzas contribute higher revenue per order and represent high-value menu items.
4. Certain pizza sizes are preferred significantly more than others, revealing customer size preferences.
5. A small group of pizza varieties drives a large portion of total orders, highlighting customer favorites.
6. Some pizza categories outperform others in terms of overall quantity sold.
7. Orders are concentrated during specific hours, indicating clear peak business periods.
8. The menu is diversified across multiple categories, providing customers with a broad selection.
9. Daily ordering volumes remain relatively stable, helping forecast future demand more effectively.
10. Revenue generation is concentrated among a few high-performing pizza types.
11. Revenue contribution varies across categories, showing which product segments are most profitable.
12. Cumulative revenue demonstrates continuous growth over time, reflecting positive sales momentum.
13. Each category contains a few standout pizza types that consistently generate higher revenue than others.

## Conclusion

The Pizza Hut Sales Analysis project successfully utilized SQL to transform transactional data into meaningful business insights. Through comprehensive analysis of orders, revenue, pizza categories, customer preferences, and sales trends, valuable patterns were uncovered that can support strategic business decision-making.
The analysis revealed key revenue drivers, top-selling products, popular pizza sizes, category performance, and customer ordering behavior. Advanced SQL concepts such as joins, aggregate functions, subqueries, window functions, ranking functions, and revenue calculations were effectively applied to solve real-world business problems.
Additionally, the visualizations created throughout the project enhanced the interpretation of results and made complex data easier to understand. Overall, this project demonstrates strong SQL analytical skills and showcases the ability to derive actionable insights from raw business data to support operational efficiency and revenue growth.



## Author - Tushar Sharma

Welcome to my portfolio project repository.

This project is part of my Data Analytics portfolio and reflects my passion for transforming raw data into meaningful insights that support informed decision-making. Through my projects, I focus on solving real-world business problems by analyzing data, identifying trends, and presenting actionable insights.

Each project is designed to strengthen my analytical thinking, problem-solving abilities, and technical skills while working with practical business scenarios. I enjoy exploring datasets, understanding the story behind the data, and converting complex information into clear and valuable business insights.

To achieve this, I utilize industry-relevant tools and technologies, including:

- Microsoft Excel
- Power BI
- Tableau
- SQL
- Python

My goal is to continuously improve my expertise in data analytics, business intelligence, data cleaning, data exploration, dashboard development, reporting, and data visualization while building projects that demonstrate both technical proficiency and business understanding.


This portfolio represents my ongoing learning journey and commitment to becoming a skilled Data Analyst. Every project contributes to expanding my knowledge, refining my analytical approach, and gaining hands-on experience with real-world data.

### Connect With Me

📧 **Email:** tusharsharma.officially@gmail.com
🔗 **LinkedIn:** www.linkedin.com/in/heistushar

I am always open to connecting with fellow data professionals, recruiters, hiring managers, and analytics enthusiasts. Whether you would like to discuss a project, share feedback, exchange ideas, or explore collaboration opportunities, I would be happy to connect.

Thank you for taking the time to review my work. I appreciate your interest and look forward to connecting with professionals who share a passion for data, analytics, and continuous learning.


