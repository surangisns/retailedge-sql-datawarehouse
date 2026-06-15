-- ============================================================
-- RetailEdge Analytics | SQL Server
-- Script 03: Create Bronze (Raw) Tables
-- Raw data is loaded exactly as-is from CSV files.
-- All columns are NVARCHAR to handle messy source data.
-- ============================================================

USE RetailEdgeWarehouse;
GO

-- Drop and recreate for clean load
DROP TABLE IF EXISTS bronze.raw_order_items;
DROP TABLE IF EXISTS bronze.raw_returns;
DROP TABLE IF EXISTS bronze.raw_orders;
DROP TABLE IF EXISTS bronze.raw_customers;
DROP TABLE IF EXISTS bronze.raw_products;
DROP TABLE IF EXISTS bronze.raw_regions;
DROP TABLE IF EXISTS bronze.raw_sales_channels;
DROP TABLE IF EXISTS bronze.raw_promotions;
GO

-- Customers
CREATE TABLE bronze.raw_customers (
    customer_id         NVARCHAR(20),
    first_name          NVARCHAR(100),
    last_name           NVARCHAR(100),
    email               NVARCHAR(200),
    phone               NVARCHAR(50),
    dob                 NVARCHAR(30),
    gender              NVARCHAR(20),
    city                NVARCHAR(100),
    state               NVARCHAR(50),
    country             NVARCHAR(50),
    registration_date   NVARCHAR(30),
    customer_segment    NVARCHAR(50),
    dwh_load_ts         DATETIME DEFAULT GETDATE()
);
GO

-- Products
CREATE TABLE bronze.raw_products (
    product_id          NVARCHAR(20),
    product_name        NVARCHAR(300),
    category            NVARCHAR(100),
    subcategory         NVARCHAR(100),
    brand               NVARCHAR(100),
    unit_cost           NVARCHAR(20),
    unit_price          NVARCHAR(20),
    weight_kg           NVARCHAR(20),
    is_active           NVARCHAR(10),
    launch_date         NVARCHAR(30),
    dwh_load_ts         DATETIME DEFAULT GETDATE()
);
GO

-- Regions
CREATE TABLE bronze.raw_regions (
    region_id           NVARCHAR(20),
    region_name         NVARCHAR(100),
    country             NVARCHAR(50),
    state               NVARCHAR(50),
    zone                NVARCHAR(50),
    manager_name        NVARCHAR(100),
    dwh_load_ts         DATETIME DEFAULT GETDATE()
);
GO

-- Sales Channels
CREATE TABLE bronze.raw_sales_channels (
    channel_id          NVARCHAR(20),
    channel_name        NVARCHAR(100),
    channel_type        NVARCHAR(50),
    commission_pct      NVARCHAR(20),
    is_active           NVARCHAR(10),
    dwh_load_ts         DATETIME DEFAULT GETDATE()
);
GO

-- Promotions
CREATE TABLE bronze.raw_promotions (
    promo_id            NVARCHAR(20),
    promo_name          NVARCHAR(200),
    start_date          NVARCHAR(30),
    end_date            NVARCHAR(30),
    discount_type       NVARCHAR(50),
    discount_value      NVARCHAR(20),
    applicable_category NVARCHAR(100),
    dwh_load_ts         DATETIME DEFAULT GETDATE()
);
GO

-- Orders
CREATE TABLE bronze.raw_orders (
    order_id            NVARCHAR(20),
    customer_id         NVARCHAR(20),
    order_date          NVARCHAR(30),
    order_status        NVARCHAR(30),
    channel             NVARCHAR(20),
    region_id           NVARCHAR(20),
    shipping_date       NVARCHAR(30),
    delivery_date       NVARCHAR(30),
    discount_pct        NVARCHAR(20),
    payment_method      NVARCHAR(50),
    dwh_load_ts         DATETIME DEFAULT GETDATE()
);
GO

-- Order Items
CREATE TABLE bronze.raw_order_items (
    item_id             NVARCHAR(20),
    order_id            NVARCHAR(20),
    product_id          NVARCHAR(20),
    quantity            NVARCHAR(10),
    unit_price          NVARCHAR(20),
    discount_amount     NVARCHAR(20),
    line_total          NVARCHAR(20),
    dwh_load_ts         DATETIME DEFAULT GETDATE()
);
GO

-- Returns
CREATE TABLE bronze.raw_returns (
    return_id           NVARCHAR(20),
    order_id            NVARCHAR(20),
    product_id          NVARCHAR(20),
    return_date         NVARCHAR(30),
    return_reason       NVARCHAR(300),
    refund_amount       NVARCHAR(20),
    return_status       NVARCHAR(30),
    dwh_load_ts         DATETIME DEFAULT GETDATE()
);
GO

PRINT 'All bronze tables created successfully.';
