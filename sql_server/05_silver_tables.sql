-- ============================================================
-- RetailEdge Analytics | SQL Server
-- Script 05: Create Silver (Cleaned) Tables
-- Proper data types enforced after transformation.
-- ============================================================

USE RetailEdgeWarehouse;
GO

DROP TABLE IF EXISTS silver.order_items;
DROP TABLE IF EXISTS silver.returns;
DROP TABLE IF EXISTS silver.orders;
DROP TABLE IF EXISTS silver.customers;
DROP TABLE IF EXISTS silver.products;
DROP TABLE IF EXISTS silver.regions;
DROP TABLE IF EXISTS silver.sales_channels;
DROP TABLE IF EXISTS silver.promotions;
GO

CREATE TABLE silver.customers (
    customer_id         INT             NOT NULL,
    first_name          NVARCHAR(100)   NOT NULL,
    last_name           NVARCHAR(100)   NOT NULL,
    full_name           NVARCHAR(200),
    email               NVARCHAR(200),
    phone               NVARCHAR(50),
    dob                 DATE,
    gender              NVARCHAR(10),
    city                NVARCHAR(100),
    state               NVARCHAR(50),
    country             NVARCHAR(50),
    registration_date   DATE,
    customer_segment    NVARCHAR(50),
    dwh_load_ts         DATETIME        DEFAULT GETDATE(),
    CONSTRAINT pk_silver_customers PRIMARY KEY (customer_id)
);
GO

CREATE TABLE silver.products (
    product_id          INT             NOT NULL,
    product_name        NVARCHAR(300),
    category            NVARCHAR(100),
    subcategory         NVARCHAR(100),
    brand               NVARCHAR(100),
    unit_cost           DECIMAL(10,2),
    unit_price          DECIMAL(10,2),
    weight_kg           DECIMAL(6,2),
    is_active           BIT,
    launch_date         DATE,
    dwh_load_ts         DATETIME        DEFAULT GETDATE(),
    CONSTRAINT pk_silver_products PRIMARY KEY (product_id)
);
GO

CREATE TABLE silver.regions (
    region_id           INT             NOT NULL,
    region_name         NVARCHAR(100),
    country             NVARCHAR(50),
    state               NVARCHAR(50),
    zone                NVARCHAR(50),
    manager_name        NVARCHAR(100),
    dwh_load_ts         DATETIME        DEFAULT GETDATE(),
    CONSTRAINT pk_silver_regions PRIMARY KEY (region_id)
);
GO

CREATE TABLE silver.sales_channels (
    channel_id          INT             NOT NULL,
    channel_name        NVARCHAR(100),
    channel_type        NVARCHAR(50),
    commission_pct      DECIMAL(5,2),
    is_active           BIT,
    dwh_load_ts         DATETIME        DEFAULT GETDATE(),
    CONSTRAINT pk_silver_channels PRIMARY KEY (channel_id)
);
GO

CREATE TABLE silver.promotions (
    promo_id            INT             NOT NULL,
    promo_name          NVARCHAR(200),
    start_date          DATE,
    end_date            DATE,
    discount_type       NVARCHAR(50),
    discount_value      DECIMAL(10,2),
    applicable_category NVARCHAR(100),
    dwh_load_ts         DATETIME        DEFAULT GETDATE(),
    CONSTRAINT pk_silver_promos PRIMARY KEY (promo_id)
);
GO

CREATE TABLE silver.orders (
    order_id            INT             NOT NULL,
    customer_id         INT,
    order_date          DATE,
    order_status        NVARCHAR(30),
    channel_id          INT,
    region_id           INT,
    shipping_date       DATE,
    delivery_date       DATE,
    discount_pct        DECIMAL(5,2),
    payment_method      NVARCHAR(50),
    dwh_load_ts         DATETIME        DEFAULT GETDATE(),
    CONSTRAINT pk_silver_orders PRIMARY KEY (order_id)
);
GO

CREATE TABLE silver.order_items (
    item_id             INT             NOT NULL,
    order_id            INT,
    product_id          INT,
    quantity            INT,
    unit_price          DECIMAL(10,2),
    discount_amount     DECIMAL(10,2),
    line_total          DECIMAL(10,2),
    dwh_load_ts         DATETIME        DEFAULT GETDATE(),
    CONSTRAINT pk_silver_items PRIMARY KEY (item_id)
);
GO

CREATE TABLE silver.returns (
    return_id           INT             NOT NULL,
    order_id            INT,
    product_id          INT,
    return_date         DATE,
    return_reason       NVARCHAR(300),
    refund_amount       DECIMAL(10,2),
    return_status       NVARCHAR(30),
    dwh_load_ts         DATETIME        DEFAULT GETDATE(),
    CONSTRAINT pk_silver_returns PRIMARY KEY (return_id)
);
GO

PRINT 'All silver tables created successfully.';
