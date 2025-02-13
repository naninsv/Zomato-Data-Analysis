-- Zomato Data Analysis using SQL

-- Drop existing tables if they exist
DROP TABLE IF EXISTS deliveries;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS restaurants;
DROP TABLE IF EXISTS riders;

-------------------------------------------------------------------------------------------------
CREATE TABLE restaurants (
    restaurant_id INT IDENTITY(1,1) PRIMARY KEY,
    restaurant_name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    opening_hours VARCHAR(50)
);

CREATE TABLE customers (
    customer_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    reg_date DATE
);


CREATE TABLE riders (
    rider_id INT IDENTITY(1,1) PRIMARY KEY,
    rider_name VARCHAR(100) NOT NULL,
    sign_up DATE
);


-- Create Orders table
CREATE TABLE Orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    order_item VARCHAR(255),
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    order_status VARCHAR(20) DEFAULT 'Pending',
    total_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

-- Create deliveries table
CREATE TABLE deliveries (
    delivery_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT,
    delivery_status VARCHAR(20) DEFAULT 'Pending',
    delivery_time TIME,
    rider_id INT,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (rider_id) REFERENCES riders(rider_id)
);
----------------------------------------------------------------------------------------------------
-- 1️ Orders table: Link to customers
ALTER TABLE Orders 
ADD CONSTRAINT FK_Orders_Customers FOREIGN KEY (customer_id) 
REFERENCES customers(customer_id);

-- 2️ Orders table: Link to restaurants
ALTER TABLE Orders 
ADD CONSTRAINT FK_Orders_Restaurants FOREIGN KEY (restaurant_id) 
REFERENCES restaurants(restaurant_id);

-- 3️ Deliveries table: Link to Orders
ALTER TABLE deliveries 
ADD CONSTRAINT FK_Deliveries_Orders FOREIGN KEY (order_id) 
REFERENCES Orders(order_id);

-- 4️ Deliveries table: Link to Riders
ALTER TABLE deliveries 
ADD CONSTRAINT FK_Deliveries_Riders FOREIGN KEY (rider_id) 
REFERENCES riders(rider_id);
--------------------------

-- Schemas END

----------------------------------------------------------------------------------------------------

-- Exploratory Data Analysis

SELECT * FROM customers;
SELECT * FROM restaurants;
SELECT * FROM orders;
SELECT * FROM riders;
SELECT * FROM deliveries;

-- Checking for null values in each tables

SELECT COUNT(*) FROM customers
WHERE
     customer_name IS NULL
	 OR
	 reg_date IS NULL

SELECT COUNT(*) FROM restaurants
WHERE
     restaurant_name IS NULL
	 OR
	 city IS NULL
	 OR
	 opening_hours IS NULL

SELECT COUNT(*) FROM orders
WHERE
     order_item IS NULL
	 OR
	 order_date IS NULL
	 OR
	 order_time IS NULL
	 OR
	 order_status IS NULL
	 OR
	 total_amount IS NULL

SELECT COUNT(*) FROM riders
WHERE
     rider_name IS NULL
	 OR
	 sign_up IS NULL

SELECT COUNT(*) FROM deliveries
WHERE
     delivery_status IS NULL
	 OR
	 delivery_time IS NULL
	 OR
	 rider_id IS NULL


-- -------------------------
-- Analysis & Reports
-- -------------------------


-- Q.1
-- Write a query to find the top 5 most frequently ordered dishes by customer called "Arjun Mehta" in the last 1 year.
-- 

-- join cx and orders
-- filter for last 1 year 
-- FILTER 'arjun mehta'
-- group by cx id, dishes, cnt

SELECT 
    customer_name,
    dishes,
    total_orders
FROM (
    SELECT 
        c.customer_id,
        c.customer_name,
        o.order_item AS dishes,
        COUNT(*) AS total_orders,
        DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS rank
    FROM orders AS o
    JOIN customers AS c
        ON c.customer_id = o.customer_id
    WHERE 
        o.order_date >= DATEADD(YEAR, -2, CAST(GETDATE() AS DATE))  -- Last 1 year
        AND c.customer_name = 'Arjun Mehta'
    GROUP BY c.customer_id, c.customer_name, o.order_item
) AS t1
WHERE rank <= 5;



-- 2. Popular Time Slots
-- Question: Identify the time slots during which the most orders are placed. based on 2-hour intervals.

-- Approach 1
SELECT 
    (DATEPART(HOUR, order_time) / 2) * 2 AS start_time,
    (DATEPART(HOUR, order_time) / 2) * 2 + 2 AS end_time,
    COUNT(*) AS total_orders
FROM Orders
GROUP BY (DATEPART(HOUR, order_time) / 2) * 2
ORDER BY total_orders DESC;

-- 23:55PM /2 -- 11 * 2 = 22 start, 22 +2 
22-11:59:59 PM

-- SELECT 00:59:59AM -- 0
-- SELECT 01:59:59AM -- 1
-- 0
-- Approach 2
SELECT 
    CASE 
        WHEN DATEPART(HOUR, order_time) BETWEEN 0 AND 1 THEN '00:00 - 02:00'
        WHEN DATEPART(HOUR, order_time) BETWEEN 2 AND 3 THEN '02:00 - 04:00'
        WHEN DATEPART(HOUR, order_time) BETWEEN 4 AND 5 THEN '04:00 - 06:00'
        WHEN DATEPART(HOUR, order_time) BETWEEN 6 AND 7 THEN '06:00 - 08:00'
        WHEN DATEPART(HOUR, order_time) BETWEEN 8 AND 9 THEN '08:00 - 10:00'
        WHEN DATEPART(HOUR, order_time) BETWEEN 10 AND 11 THEN '10:00 - 12:00'
        WHEN DATEPART(HOUR, order_time) BETWEEN 12 AND 13 THEN '12:00 - 14:00'
        WHEN DATEPART(HOUR, order_time) BETWEEN 14 AND 15 THEN '14:00 - 16:00'
        WHEN DATEPART(HOUR, order_time) BETWEEN 16 AND 17 THEN '16:00 - 18:00'
        WHEN DATEPART(HOUR, order_time) BETWEEN 18 AND 19 THEN '18:00 - 20:00'
        WHEN DATEPART(HOUR, order_time) BETWEEN 20 AND 21 THEN '20:00 - 22:00'
        WHEN DATEPART(HOUR, order_time) BETWEEN 22 AND 23 THEN '22:00 - 00:00'
    END AS time_slot,
    COUNT(order_id) AS order_count
FROM Orders
GROUP BY 
    CASE 
        WHEN DATEPART(HOUR, order_time) BETWEEN 0 AND 1 THEN '00:00 - 02:00'
        WHEN DATEPART(HOUR, order_time) BETWEEN 2 AND 3 THEN '02:00 - 04:00'
        WHEN DATEPART(HOUR, order_time) BETWEEN 4 AND 5 THEN '04:00 - 06:00'
        WHEN DATEPART(HOUR, order_time) BETWEEN 6 AND 7 THEN '06:00 - 08:00'
        WHEN DATEPART(HOUR, order_time) BETWEEN 8 AND 9 THEN '08:00 - 10:00'
        WHEN DATEPART(HOUR, order_time) BETWEEN 10 AND 11 THEN '10:00 - 12:00'
        WHEN DATEPART(HOUR, order_time) BETWEEN 12 AND 13 THEN '12:00 - 14:00'
        WHEN DATEPART(HOUR, order_time) BETWEEN 14 AND 15 THEN '14:00 - 16:00'
        WHEN DATEPART(HOUR, order_time) BETWEEN 16 AND 17 THEN '16:00 - 18:00'
        WHEN DATEPART(HOUR, order_time) BETWEEN 18 AND 19 THEN '18:00 - 20:00'
        WHEN DATEPART(HOUR, order_time) BETWEEN 20 AND 21 THEN '20:00 - 22:00'
        WHEN DATEPART(HOUR, order_time) BETWEEN 22 AND 23 THEN '22:00 - 00:00'
    END
ORDER BY order_count DESC;



-- 3. Order Value Analysis
-- Question: Find the average order value per customer who has placed more than 750 orders.
-- Return customer_name, and aov(average order value)


SELECT 
    c.customer_name,
    AVG(o.total_amount) AS aov
FROM Orders AS o
JOIN Customers AS c
    ON c.customer_id = o.customer_id
GROUP BY c.customer_name
HAVING COUNT(o.order_id) > 750;



-- 4. High-Value Customers
-- Question: List the customers who have spent more than 100K in total on food orders.
-- return customer_name, and customer_id!


SELECT 
    c.customer_id,
    c.customer_name,
    SUM(o.total_amount) AS total_spent
FROM Orders AS o
JOIN Customers AS c
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(o.total_amount) > 100000;



-- 5. Orders Without Delivery
-- Question: Write a query to find orders that were placed but not delivered. 
-- Return each restuarant name, city and number of not delivered orders 

SELECT 
    r.restaurant_name,
    r.city,
    COUNT(o.order_id) AS cnt_not_delivered_orders
FROM Orders AS o
LEFT JOIN Restaurants AS r
    ON r.restaurant_id = o.restaurant_id
LEFT JOIN Deliveries AS d
    ON d.order_id = o.order_id
WHERE d.delivery_id IS NULL  -- Orders without a delivery entry
GROUP BY r.restaurant_name, r.city
ORDER BY cnt_not_delivered_orders DESC;





-- Q. 6
-- Restaurant Revenue Ranking: 
-- Rank restaurants by their total revenue from the last year, including their name, 
-- total revenue, and rank within their city.

WITH ranking_table AS (
    SELECT 
        r.city,
        r.restaurant_name,
        SUM(o.total_amount) AS revenue,
        RANK() OVER(PARTITION BY r.city ORDER BY SUM(o.total_amount) DESC) AS rank
    FROM orders AS o
    JOIN restaurants AS r
    ON r.restaurant_id = o.restaurant_id
    WHERE o.order_date >= DATEADD(YEAR, -2, GETDATE())  -- Now considering last 2 years
    GROUP BY r.city, r.restaurant_name
)
SELECT * 
FROM ranking_table
WHERE rank = 1;  -- Top restaurant in each city


-- Q. 7
-- Most Popular Dish by City: 
-- Identify the most popular dish in each city based on the number of orders.
WITH dish_ranking AS (
    SELECT 
        r.city,
        o.order_item AS dish,
        COUNT(o.order_id) AS total_orders,
        RANK() OVER (PARTITION BY r.city ORDER BY COUNT(o.order_id) DESC) AS rank
    FROM orders AS o
    JOIN restaurants AS r
        ON r.restaurant_id = o.restaurant_id
    WHERE o.order_item IS NOT NULL  -- Ensure we exclude NULL values
    GROUP BY r.city, o.order_item
)
SELECT city, dish, total_orders
FROM dish_ranking
WHERE rank = 1;  -- Get the most popular dish in each city



-- Q.8 Customer Churn: 
-- Find customers who haven’t placed an order in 2024 but did in 2023.

-- find cx who has done orders in 2023
-- find cx who has not done orders in 2024
-- compare 1 and 2

SELECT DISTINCT customer_id 
FROM orders
WHERE 
    YEAR(order_date) = 2023
    AND customer_id NOT IN 
        (SELECT DISTINCT customer_id FROM orders
         WHERE YEAR(order_date) = 2024);



-- Q.9 Cancellation Rate Comparison: 
-- Calculate and compare the order cancellation rate for each restaurant between the 
-- current year and the previous year.

WITH cancel_ratio_23 AS (
    SELECT 
        o.restaurant_id,
        COUNT(o.order_id) AS total_orders,
        COUNT(CASE WHEN d.delivery_id IS NULL THEN 1 END) AS not_delivered
    FROM orders AS o
    LEFT JOIN deliveries AS d
        ON o.order_id = d.order_id
    WHERE YEAR(o.order_date) = 2023
    GROUP BY o.restaurant_id
),
cancel_ratio_24 AS (
    SELECT 
        o.restaurant_id,
        COUNT(o.order_id) AS total_orders,
        COUNT(CASE WHEN d.delivery_id IS NULL THEN 1 END) AS not_delivered
    FROM orders AS o
    LEFT JOIN deliveries AS d
        ON o.order_id = d.order_id
    WHERE YEAR(o.order_date) = 2024
    GROUP BY o.restaurant_id
),
last_year_data AS (
    SELECT 
        restaurant_id,
        total_orders,
        not_delivered,
        ROUND(CAST(not_delivered AS FLOAT) / NULLIF(CAST(total_orders AS FLOAT), 0) * 100, 2) AS cancel_ratio
    FROM cancel_ratio_23
),
current_year_data AS (
    SELECT 
        restaurant_id,
        total_orders,
        not_delivered,
        ROUND(CAST(not_delivered AS FLOAT) / NULLIF(CAST(total_orders AS FLOAT), 0) * 100, 2) AS cancel_ratio
    FROM cancel_ratio_24
)	
SELECT 
    c.restaurant_id AS restaurant_id,
    c.cancel_ratio AS current_year_cancel_ratio,
    l.cancel_ratio AS last_year_cancel_ratio
FROM current_year_data AS c
JOIN last_year_data AS l
ON c.restaurant_id = l.restaurant_id;


-- Q.10 Rider Average Delivery Time: 
-- Determine each rider's average delivery time.

SELECT 
    d.rider_id,
    AVG(DATEDIFF(MINUTE, o.order_time, d.delivery_time)) AS avg_delivery_time_in_minutes
FROM orders AS o
JOIN deliveries AS d
    ON o.order_id = d.order_id
WHERE d.delivery_status = 'Delivered'
GROUP BY d.rider_id;



-- Q.11 Monthly Restaurant Growth Ratio: 
-- Calculate each restaurant's growth ratio based on the total number of delivered orders since its joining

last 20
cm -- 30

cs - ls/ls
30-20/20 * 100

WITH growth_ratio AS (
    SELECT 
        o.restaurant_id,
        YEAR(o.order_date) AS year,
        MONTH(o.order_date) AS month,
        COUNT(o.order_id) AS cr_month_orders,
        LAG(COUNT(o.order_id), 1) OVER (
            PARTITION BY o.restaurant_id 
            ORDER BY YEAR(o.order_date), MONTH(o.order_date)
        ) AS prev_month_orders
    FROM orders AS o
    JOIN deliveries AS d
        ON o.order_id = d.order_id
    WHERE d.delivery_status = 'Delivered'
    GROUP BY o.restaurant_id, YEAR(o.order_date), MONTH(o.order_date)
)
SELECT
    restaurant_id,
    year,
    month,
    prev_month_orders,
    cr_month_orders,
    CASE 
        WHEN prev_month_orders = 0 OR prev_month_orders IS NULL THEN NULL 
        ELSE ROUND(((cr_month_orders - prev_month_orders) * 100.0 / prev_month_orders), 2) 
    END AS growth_ratio
FROM growth_ratio
ORDER BY restaurant_id, year, month;



-- Q.12 Customer Segmentation: 
-- Customer Segmentation: Segment customers into 'Gold' or 'Silver' groups based on their total spending 
-- compared to the average order value (AOV). If a customer's total spending exceeds the AOV, 
-- label them as 'Gold'; otherwise, label them as 'Silver'. Write an SQL query to determine each segment's 
-- total number of orders and total revenue

-- cx total spend
-- aov
-- gold
-- silver
-- each category and total orders and total rev


WITH customer_spending AS (
    SELECT 
        customer_id,
        SUM(total_amount) AS total_spent,
        COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
),
aov AS (
    SELECT AVG(total_amount) AS avg_order_value FROM orders
)
SELECT 
    cx_category,
    SUM(total_orders) AS total_orders,
    SUM(total_spent) AS total_revenue
FROM (
    SELECT 
        c.customer_id,
        c.total_spent,
        c.total_orders,
        CASE 
            WHEN c.total_spent > (SELECT avg_order_value FROM aov) THEN 'Gold'
            ELSE 'Silver'
        END AS cx_category
    FROM customer_spending c
) AS categorized_customers
GROUP BY cx_category;


SELECT AVG(total_amount) FROM orders -- 322



-- Q.13 Rider Monthly Earnings: 
-- Calculate each rider's total monthly earnings, assuming they earn 8% of the order amount.

SELECT 
    d.rider_id,
    FORMAT(o.order_date, 'MM-yy') AS month,
    SUM(o.total_amount) AS revenue,
    SUM(o.total_amount) * 0.08 AS riders_earning
FROM orders AS o
JOIN deliveries AS d
ON o.order_id = d.order_id
WHERE d.delivery_status = 'Delivered'  -- Ensuring only completed deliveries are considered
GROUP BY d.rider_id, FORMAT(o.order_date, 'MM-yy')
ORDER BY d.rider_id, month;




-- Q.14 Rider Ratings Analysis: 
-- Find the number of 5-star, 4-star, and 3-star ratings each rider has.
-- riders receive this rating based on delivery time.
-- If orders are delivered less than 15 minutes of order received time the rider get 5 star rating,
-- if they deliver 15 and 20 minute they get 4 star rating 
-- if they deliver after 20 minute they get 3 star rating.


WITH DeliveryTimes AS (
    SELECT 
        d.rider_id,
        DATEDIFF(MINUTE, o.order_time, d.delivery_time) AS delivery_took_time
    FROM orders AS o
    JOIN deliveries AS d
    ON o.order_id = d.order_id
    WHERE d.delivery_status = 'Delivered'
),
Ratings AS (
    SELECT 
        rider_id,
        CASE 
            WHEN delivery_took_time < 15 THEN '5 star'
            WHEN delivery_took_time BETWEEN 15 AND 20 THEN '4 star'
            ELSE '3 star'
        END AS stars
    FROM DeliveryTimes
)
SELECT 
    rider_id,
    stars,
    COUNT(*) AS total_stars
FROM Ratings
GROUP BY rider_id, stars
ORDER BY rider_id, total_stars DESC;


-- Q.15 Order Frequency by Day: 
-- Analyze order frequency per day of the week and identify the peak day for each restaurant.

WITH OrderFrequency AS (
    SELECT 
        r.restaurant_name,
        DATENAME(WEEKDAY, o.order_date) AS order_day,
        COUNT(o.order_id) AS total_orders,
        RANK() OVER(PARTITION BY r.restaurant_name ORDER BY COUNT(o.order_id) DESC) AS rank_order
    FROM orders AS o
    JOIN restaurants AS r
    ON o.restaurant_id = r.restaurant_id
    GROUP BY r.restaurant_name, DATENAME(WEEKDAY, o.order_date)
)
SELECT restaurant_name, order_day, total_orders
FROM OrderFrequency
WHERE rank_order = 1;



-- Q.16 Customer Lifetime Value (CLV): 
-- Calculate the total revenue generated by each customer over all their orders.

SELECT 
    o.customer_id,
    c.customer_name,
    SUM(o.total_amount) AS customer_lifetime_value
FROM orders AS o
JOIN customers AS c
ON o.customer_id = c.customer_id
GROUP BY o.customer_id, c.customer_name
ORDER BY customer_lifetime_value DESC;  -- Sorting to see top customers by revenue




-- Q.17 Monthly Sales Trends: 
-- Identify sales trends by comparing each month's total sales to the previous month.

WITH sales_trends AS (
    SELECT 
        YEAR(order_date) AS year,
        MONTH(order_date) AS month,
        SUM(total_amount) AS total_sales,
        LAG(SUM(total_amount), 1) OVER (ORDER BY YEAR(order_date), MONTH(order_date)) AS prev_month_sales
    FROM orders
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT 
    year,
    month,
    total_sales,
    prev_month_sales,
    ROUND(
        (total_sales - prev_month_sales) * 100.0 / NULLIF(prev_month_sales, 0), 2
    ) AS growth_percentage
FROM sales_trends
ORDER BY year, month;




-- Q.18 Rider Efficiency: 
-- Evaluate rider efficiency by determining average delivery times and identifying those with the lowest and highest averages.


WITH delivery_times AS (
    SELECT 
        d.rider_id,
        DATEDIFF(MINUTE, o.order_time, d.delivery_time) AS delivery_time_in_min
    FROM orders AS o
    JOIN deliveries AS d ON o.order_id = d.order_id
    WHERE d.delivery_status = 'Delivered'
),
rider_avg_times AS (
    SELECT 
        rider_id,
        AVG(delivery_time_in_min) AS avg_delivery_time
    FROM delivery_times
    GROUP BY rider_id
)
SELECT 
    MIN(avg_delivery_time) AS min_avg_delivery_time,
    MAX(avg_delivery_time) AS max_avg_delivery_time
FROM rider_avg_times;



-- Q.19 Order Item Popularity: 
-- Track the popularity of specific order items over time and identify seasonal demand spikes.

SELECT 
    order_item,
    season,
    COUNT(order_id) AS total_orders
FROM (
    SELECT 
        order_id,
        order_item,
        CASE 
            WHEN MONTH(order_date) BETWEEN 3 AND 5 THEN 'Spring'
            WHEN MONTH(order_date) BETWEEN 6 AND 8 THEN 'Summer'
            WHEN MONTH(order_date) BETWEEN 9 AND 11 THEN 'Fall'
            ELSE 'Winter'
        END AS season
    FROM orders
) AS seasonal_orders
GROUP BY order_item, season
ORDER BY order_item, total_orders DESC;


-- Q.20 Rank each city based on the total revenue for last year 2023 

SELECT 
    r.city,
    SUM(o.total_amount) AS total_revenue,
    RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS city_rank
FROM orders AS o
JOIN restaurants AS r
ON o.restaurant_id = r.restaurant_id
WHERE YEAR(o.order_date) = 2023  -- Filter only last year's data
GROUP BY r.city;



-- End of Reports