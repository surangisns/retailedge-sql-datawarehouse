-- ============================================================
-- RetailEdge Analytics | PostgreSQL
-- Script 07: Create and Load Gold Dimension Tables
-- ============================================================

-- ── dim_date ─────────────────────────────────────────────────
DROP TABLE IF EXISTS gold.dim_date CASCADE;
CREATE TABLE gold.dim_date (
    date_key     INT PRIMARY KEY, full_date DATE NOT NULL,
    year INT, quarter INT, quarter_name VARCHAR(6),
    month_number INT, month_name VARCHAR(12),
    week_number INT, day_of_month INT, day_name VARCHAR(12),
    is_weekend BOOLEAN, is_weekday BOOLEAN
);

INSERT INTO gold.dim_date
SELECT
    TO_CHAR(d,'YYYYMMDD')::INT, d,
    EXTRACT(YEAR FROM d)::INT,
    EXTRACT(QUARTER FROM d)::INT,
    'Q' || EXTRACT(QUARTER FROM d)::TEXT,
    EXTRACT(MONTH FROM d)::INT,
    TO_CHAR(d,'Month'),
    EXTRACT(WEEK FROM d)::INT,
    EXTRACT(DAY FROM d)::INT,
    TO_CHAR(d,'Day'),
    EXTRACT(ISODOW FROM d) IN (6,7),
    EXTRACT(ISODOW FROM d) NOT IN (6,7)
FROM generate_series('2019-01-01'::DATE, '2025-12-31'::DATE, '1 day') AS d;

-- ── dim_customer ─────────────────────────────────────────────
DROP TABLE IF EXISTS gold.dim_customer CASCADE;
CREATE TABLE gold.dim_customer (
    customer_key     BIGSERIAL PRIMARY KEY,
    customer_id      INT, full_name VARCHAR(200), email VARCHAR(200),
    gender VARCHAR(10), age_band VARCHAR(20), city VARCHAR(100),
    state VARCHAR(50), country VARCHAR(50), customer_segment VARCHAR(50),
    registration_year INT, dwh_load_ts TIMESTAMP DEFAULT NOW()
);

INSERT INTO gold.dim_customer (customer_id, full_name, email, gender, age_band, city, state, country, customer_segment, registration_year)
SELECT customer_id, full_name, email, gender,
    CASE
        WHEN EXTRACT(YEAR FROM AGE(dob)) BETWEEN 18 AND 24 THEN '18-24'
        WHEN EXTRACT(YEAR FROM AGE(dob)) BETWEEN 25 AND 34 THEN '25-34'
        WHEN EXTRACT(YEAR FROM AGE(dob)) BETWEEN 35 AND 44 THEN '35-44'
        WHEN EXTRACT(YEAR FROM AGE(dob)) BETWEEN 45 AND 54 THEN '45-54'
        WHEN EXTRACT(YEAR FROM AGE(dob)) >= 55 THEN '55+'
        ELSE 'Unknown'
    END,
    city, state, country, customer_segment,
    EXTRACT(YEAR FROM registration_date)::INT
FROM silver.customers;

-- ── dim_product ──────────────────────────────────────────────
DROP TABLE IF EXISTS gold.dim_product CASCADE;
CREATE TABLE gold.dim_product (
    product_key  BIGSERIAL PRIMARY KEY,
    product_id   INT, product_name VARCHAR(300),
    category     VARCHAR(100), subcategory VARCHAR(100), brand VARCHAR(100),
    unit_cost    NUMERIC(10,2), unit_price NUMERIC(10,2), margin_pct NUMERIC(5,2),
    is_active    BOOLEAN, launch_year INT, dwh_load_ts TIMESTAMP DEFAULT NOW()
);

INSERT INTO gold.dim_product (product_id, product_name, category, subcategory, brand, unit_cost, unit_price, margin_pct, is_active, launch_year)
SELECT product_id, product_name, category, subcategory, brand, unit_cost, unit_price,
    CASE WHEN unit_price > 0 THEN ROUND((unit_price - unit_cost) / unit_price * 100, 2) ELSE NULL END,
    is_active, EXTRACT(YEAR FROM launch_date)::INT
FROM silver.products;

-- ── dim_region ───────────────────────────────────────────────
DROP TABLE IF EXISTS gold.dim_region CASCADE;
CREATE TABLE gold.dim_region (
    region_key  BIGSERIAL PRIMARY KEY,
    region_id   INT, region_name VARCHAR(100), state VARCHAR(50),
    country     VARCHAR(50), zone VARCHAR(50)
);
INSERT INTO gold.dim_region (region_id, region_name, state, country, zone)
SELECT region_id, region_name, state, country, zone FROM silver.regions;

-- ── dim_sales_channel ────────────────────────────────────────
DROP TABLE IF EXISTS gold.dim_sales_channel CASCADE;
CREATE TABLE gold.dim_sales_channel (
    channel_key    BIGSERIAL PRIMARY KEY,
    channel_id     INT, channel_name VARCHAR(100),
    channel_type   VARCHAR(50), commission_pct NUMERIC(5,2)
);
INSERT INTO gold.dim_sales_channel (channel_id, channel_name, channel_type, commission_pct)
SELECT channel_id, channel_name, channel_type, commission_pct FROM silver.sales_channels;
