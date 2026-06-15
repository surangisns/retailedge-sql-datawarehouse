-- ============================================================
-- RetailEdge Analytics | PostgreSQL
-- Script 05: Create Silver (Cleaned) Tables
-- ============================================================

DROP TABLE IF EXISTS silver.order_items CASCADE;
DROP TABLE IF EXISTS silver.returns     CASCADE;
DROP TABLE IF EXISTS silver.orders      CASCADE;
DROP TABLE IF EXISTS silver.customers   CASCADE;
DROP TABLE IF EXISTS silver.products    CASCADE;
DROP TABLE IF EXISTS silver.regions     CASCADE;
DROP TABLE IF EXISTS silver.sales_channels CASCADE;
DROP TABLE IF EXISTS silver.promotions  CASCADE;

CREATE TABLE silver.customers (
    customer_id       INT PRIMARY KEY, first_name VARCHAR(100) NOT NULL,
    last_name         VARCHAR(100) NOT NULL, full_name VARCHAR(200),
    email             VARCHAR(200), phone VARCHAR(50), dob DATE,
    gender            VARCHAR(10), city VARCHAR(100), state VARCHAR(50),
    country           VARCHAR(50), registration_date DATE,
    customer_segment  VARCHAR(50), dwh_load_ts TIMESTAMP DEFAULT NOW()
);

CREATE TABLE silver.products (
    product_id   INT PRIMARY KEY, product_name VARCHAR(300),
    category     VARCHAR(100), subcategory VARCHAR(100), brand VARCHAR(100),
    unit_cost    NUMERIC(10,2), unit_price NUMERIC(10,2),
    weight_kg    NUMERIC(6,2), is_active BOOLEAN, launch_date DATE,
    dwh_load_ts  TIMESTAMP DEFAULT NOW()
);

CREATE TABLE silver.regions (
    region_id    INT PRIMARY KEY, region_name VARCHAR(100),
    country      VARCHAR(50), state VARCHAR(50), zone VARCHAR(50),
    manager_name VARCHAR(100), dwh_load_ts TIMESTAMP DEFAULT NOW()
);

CREATE TABLE silver.sales_channels (
    channel_id     INT PRIMARY KEY, channel_name VARCHAR(100),
    channel_type   VARCHAR(50), commission_pct NUMERIC(5,2),
    is_active      BOOLEAN, dwh_load_ts TIMESTAMP DEFAULT NOW()
);

CREATE TABLE silver.promotions (
    promo_id      INT PRIMARY KEY, promo_name VARCHAR(200),
    start_date    DATE, end_date DATE, discount_type VARCHAR(50),
    discount_value NUMERIC(10,2), applicable_category VARCHAR(100),
    dwh_load_ts   TIMESTAMP DEFAULT NOW()
);

CREATE TABLE silver.orders (
    order_id       INT PRIMARY KEY, customer_id INT, order_date DATE,
    order_status   VARCHAR(30), channel_id INT, region_id INT,
    shipping_date  DATE, delivery_date DATE, discount_pct NUMERIC(5,2),
    payment_method VARCHAR(50), dwh_load_ts TIMESTAMP DEFAULT NOW()
);

CREATE TABLE silver.order_items (
    item_id         INT PRIMARY KEY, order_id INT, product_id INT,
    quantity        INT, unit_price NUMERIC(10,2),
    discount_amount NUMERIC(10,2), line_total NUMERIC(10,2),
    dwh_load_ts     TIMESTAMP DEFAULT NOW()
);

CREATE TABLE silver.returns (
    return_id      INT PRIMARY KEY, order_id INT, product_id INT,
    return_date    DATE, return_reason VARCHAR(300),
    refund_amount  NUMERIC(10,2), return_status VARCHAR(30),
    dwh_load_ts    TIMESTAMP DEFAULT NOW()
);
