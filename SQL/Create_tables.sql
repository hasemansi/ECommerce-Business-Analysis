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

