-- ============================================================
-- RetailEdge Analytics | PostgreSQL
-- Script 03: Create Bronze (Raw) Tables
-- All columns TEXT to handle any raw data format.
-- ============================================================

DROP TABLE IF EXISTS bronze.raw_order_items  CASCADE;
DROP TABLE IF EXISTS bronze.raw_returns      CASCADE;
DROP TABLE IF EXISTS bronze.raw_orders       CASCADE;
DROP TABLE IF EXISTS bronze.raw_customers    CASCADE;
DROP TABLE IF EXISTS bronze.raw_products     CASCADE;
DROP TABLE IF EXISTS bronze.raw_regions      CASCADE;
DROP TABLE IF EXISTS bronze.raw_sales_channels CASCADE;
DROP TABLE IF EXISTS bronze.raw_promotions   CASCADE;

CREATE TABLE bronze.raw_customers (
    customer_id         TEXT, first_name TEXT, last_name TEXT,
    email TEXT, phone TEXT, dob TEXT, gender TEXT,
    city TEXT, state TEXT, country TEXT,
    registration_date TEXT, customer_segment TEXT,
    dwh_load_ts TIMESTAMP DEFAULT NOW()
);

CREATE TABLE bronze.raw_products (
    product_id TEXT, product_name TEXT, category TEXT, subcategory TEXT,
    brand TEXT, unit_cost TEXT, unit_price TEXT, weight_kg TEXT,
    is_active TEXT, launch_date TEXT,
    dwh_load_ts TIMESTAMP DEFAULT NOW()
);

CREATE TABLE bronze.raw_regions (
    region_id TEXT, region_name TEXT, country TEXT, state TEXT,
    zone TEXT, manager_name TEXT,
    dwh_load_ts TIMESTAMP DEFAULT NOW()
);

CREATE TABLE bronze.raw_sales_channels (
    channel_id TEXT, channel_name TEXT, channel_type TEXT,
    commission_pct TEXT, is_active TEXT,
    dwh_load_ts TIMESTAMP DEFAULT NOW()
);

CREATE TABLE bronze.raw_promotions (
    promo_id TEXT, promo_name TEXT, start_date TEXT, end_date TEXT,
    discount_type TEXT, discount_value TEXT, applicable_category TEXT,
    dwh_load_ts TIMESTAMP DEFAULT NOW()
);

CREATE TABLE bronze.raw_orders (
    order_id TEXT, customer_id TEXT, order_date TEXT, order_status TEXT,
    channel TEXT, region_id TEXT, shipping_date TEXT, delivery_date TEXT,
    discount_pct TEXT, payment_method TEXT,
    dwh_load_ts TIMESTAMP DEFAULT NOW()
);

CREATE TABLE bronze.raw_order_items (
    item_id TEXT, order_id TEXT, product_id TEXT, quantity TEXT,
    unit_price TEXT, discount_amount TEXT, line_total TEXT,
    dwh_load_ts TIMESTAMP DEFAULT NOW()
);

CREATE TABLE bronze.raw_returns (
    return_id TEXT, order_id TEXT, product_id TEXT, return_date TEXT,
    return_reason TEXT, refund_amount TEXT, return_status TEXT,
    dwh_load_ts TIMESTAMP DEFAULT NOW()
);
