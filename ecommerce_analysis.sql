CREATE DATABASE ecommerce_analytics;
USE ecommerce_analytics;

-- ===============================
-- 1. REGIONS
-- ===============================
CREATE TABLE regions (
    region_id INT PRIMARY KEY,
    region_name VARCHAR(50),
    manager_name VARCHAR(100)
);

-- ===============================
-- 2. CUSTOMERS
-- ===============================
CREATE TABLE customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(120),
    signup_date DATE,
    segment VARCHAR(20),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50)
);

-- ===============================
-- 3. PRODUCTS
-- ===============================
CREATE TABLE products (
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(150),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    unit_price DECIMAL(10,2),
    cost_price DECIMAL(10,2)
);

-- ===============================
-- 4. ORDERS
-- ===============================
CREATE TABLE orders (
    order_id VARCHAR(12) PRIMARY KEY,
    customer_id VARCHAR(10),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(30),
    region_id INT,
    order_status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (region_id) REFERENCES regions(region_id)
);

-- ===============================
-- 5. ORDER ITEMS
-- ===============================
CREATE TABLE order_items (
    order_item_id BIGINT PRIMARY KEY,
    order_id VARCHAR(12),
    product_id VARCHAR(10),
    quantity INT,
    sales_amount DECIMAL(10,2),
    discount DECIMAL(4,2),
    profit DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ===============================
-- 6. RETURNS
-- ===============================
CREATE TABLE returns (
    return_id VARCHAR(12) PRIMARY KEY,
    order_id VARCHAR(12),
    return_date DATE,
    return_reason VARCHAR(100),
    refund_amount DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

LOAD DATA LOCAL INFILE "C:/Users/hi/Downloads/regions (1).csv"
INTO TABLE regions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE "C:/Users/hi/Downloads/customers (1).csv"
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE "C:/Users/hi/Downloads/products (1).csv"
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE "C:/Users/hi/Downloads/orders (1).csv"
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE "C:/Users/hi/Downloads/order_items.csv"
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE "C:/Users/hi/Downloads/returns.csv"
INTO TABLE returns
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM returns;

CREATE OR REPLACE VIEW sales_fact AS
SELECT
    o.order_id,
    o.order_date,
    o.ship_date,
    o.ship_mode,
    o.order_status,

    c.customer_id,
    c.customer_name,
    c.segment,
    c.city,
    c.state,

    r.region_name,

    p.product_id,
    p.product_name,
    p.category,
    p.sub_category,

    oi.quantity,
    oi.sales_amount,
    oi.discount,
    oi.profit

FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN regions r ON o.region_id = r.region_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;

-- TOTAL REVENUE
SELECT ROUND(SUM(sales_amount),2) AS total_revenue
FROM sales_fact;

-- TOTAL ORDERS
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM sales_fact;

-- AVERAGE ORDER values
SELECT 
    ROUND(SUM(sales_amount) / COUNT(DISTINCT order_id),2) AS avg_order_value
FROM sales_fact;

-- MONTHLY SALES TREND
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    ROUND(SUM(sales_amount),2) AS monthly_sales
FROM sales_fact
GROUP BY order_month
ORDER BY order_month;

-- SALES BY REGION
SELECT
    region_name,
    ROUND(SUM(sales_amount),2) AS regional_sales
FROM sales_fact
GROUP BY region_name
ORDER BY regional_sales DESC;

-- Top 10 Products
SELECT
    product_name,
    ROUND(SUM(sales_amount),2) AS product_sales
FROM sales_fact
GROUP BY product_name
ORDER BY product_sales DESC
LIMIT 10;

-- Return Rate
SELECT
    ROUND(
        COUNT(DISTINCT r.order_id) * 100.0 /
        COUNT(DISTINCT o.order_id),
    2) AS return_rate_percent
FROM orders o
LEFT JOIN returns r
ON o.order_id = r.order_id;

-- Top Customers by Revenue
SELECT
    customer_name,
    ROUND(SUM(sales_amount),2) AS customer_revenue
FROM sales_fact
GROUP BY customer_name
ORDER BY customer_revenue DESC
LIMIT 10;

-- Profit by Category
SELECT
    category,
    ROUND(SUM(profit),2) AS total_profit
FROM sales_fact
GROUP BY category
ORDER BY total_profit DESC;

-- Monthly Growth %
SELECT
    order_month,
    monthly_sales,
    ROUND(
        (monthly_sales - LAG(monthly_sales) OVER (ORDER BY order_month))
        * 100.0 /
        LAG(monthly_sales) OVER (ORDER BY order_month),
    2) AS growth_percent
FROM (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS order_month,
        SUM(sales_amount) AS monthly_sales
    FROM sales_fact
    GROUP BY order_month
) t;

