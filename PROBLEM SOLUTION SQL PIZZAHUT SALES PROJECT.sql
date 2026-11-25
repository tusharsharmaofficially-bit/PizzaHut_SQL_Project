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


 SELECT * FROM pizzas;

-- BUSINESS PROBLEMS 

-- 1. Retrieve the total number of orders placed.

       SELECT 
	   count(order_id) AS total_orders 
	   FROM orders;

-- 2. Calculate the total revenue generated from pizza sales.

	   SELECT 
	   ROUND(SUM(order_details.quantity * pizzas.price),
	   2) AS total_sales
	   FROM 
	   order_details 
	   JOIN 
	   pizzas ON pizzas.pizza_id = order_details.pizza_id

-- 3. Identify the highest-priced pizza.

	  SELECT pizza_types.name_of_pizza, pizzas.price
	  FROM pizza_types 
	  JOIN pizzas 
	  ON pizza_types.pizza_type_id = pizzas.pizza_type_id
	  ORDER BY pizzas.price 
	  DESC LIMIT 1;

-- 4. Identify the most common pizza size ordered.

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

-- 5. List the top 5 most ordered pizza types along with their quantities.	

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

-- 6. Join the necessary tables to find the total quantity of each pizza category ordered. 

      SELECT pizza_types.category,
	  SUM(order_details.quantity) AS quantity
	  FROM pizza_types JOIN pizzas
	  ON pizza_types.pizza_type_id = pizzas.pizza_type_id
	  JOIN order_details
	  ON order_details.pizza_id = pizzas.pizza_id
	  GROUP BY pizza_types.category ORDER BY quantity DESC;

-- 7.  Determine the distribution of orders by hour of the day.

       SELECT
       EXTRACT(HOUR FROM time_col) AS hour,
       COUNT(order_id) AS order_count
       FROM orders
       GROUP BY EXTRACT(HOUR FROM time_col)
       ORDER BY hour;
	  
-- 8.  Join relevant tables to find the category-wise distribution of pizzas.  

       SELECT category, 
	   COUNT(name_of_pizza) 
	   FROM pizza_types
	   GROUP BY category;
	  
-- 9.  Group the orders by date and calculate the average number of pizzas ordered per day. 

       SELECT ROUND(AVG(quantity),0) FROM
       (SELECT orders.date_col, SUM(order_details.quantity) AS quantity
	   FROM orders JOIN order_details
	   ON orders.order_id = order_details.order_id
	   GROUP BY orders.date_col) AS order_quantity;

-- 10. Determine the top 3 most ordered pizza types based on revenue.

       SELECT pizza_types.name_of_pizza,
	   SUM(order_details.quantity * pizzas.price) AS revenue
	   FROM pizza_types JOIN pizzas
	   ON pizzas.pizza_type_id = pizza_types.pizza_type_id
	   JOIN order_details
	   ON order_details.pizza_id = pizzas.pizza_id
	   GROUP BY pizza_types.name_of_pizza ORDER BY revenue DESC LIMIT 3;

-- 11. Calculate the percentage contribution of each pizza type to total revenue.

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

-- 12. Analyze the cumulative revenue generated over time.

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
	
-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

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
	   
       