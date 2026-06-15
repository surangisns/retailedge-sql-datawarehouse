-- ============================================================
-- RetailEdge Analytics | SQL Server
-- Script 07: Create and Load Gold Dimension Tables
-- Star schema dimensions with surrogate keys.
-- ============================================================

USE RetailEdgeWarehouse;
GO

-- ── dim_date (full date spine 2019–2025) ─────────────────────
DROP TABLE IF EXISTS gold.dim_date;
CREATE TABLE gold.dim_date (
    date_key        INT             NOT NULL,   -- YYYYMMDD
    full_date       DATE            NOT NULL,
    year            INT,
    quarter         INT,
    quarter_name    NVARCHAR(6),
    month_number    INT,
    month_name      NVARCHAR(12),
    week_number     INT,
    day_of_month    INT,
    day_name        NVARCHAR(12),
    is_weekend      BIT,
    is_weekday      BIT,
    CONSTRAINT pk_dim_date PRIMARY KEY (date_key)
);
GO

-- Populate date spine
DECLARE @start DATE = '2019-01-01', @end DATE = '2025-12-31', @d DATE;
SET @d = @start;
WHILE @d <= @end BEGIN
    INSERT INTO gold.dim_date VALUES (
        CAST(FORMAT(@d,'yyyyMMdd') AS INT), @d,
        YEAR(@d), DATEPART(QUARTER,@d),
        'Q' + CAST(DATEPART(QUARTER,@d) AS NVARCHAR),
        MONTH(@d), DATENAME(MONTH,@d),
        DATEPART(WEEK,@d), DAY(@d), DATENAME(WEEKDAY,@d),
        CASE WHEN DATEPART(WEEKDAY,@d) IN (1,7) THEN 1 ELSE 0 END,
        CASE WHEN DATEPART(WEEKDAY,@d) NOT IN (1,7) THEN 1 ELSE 0 END
    );
    SET @d = DATEADD(DAY,1,@d);
END;
GO
PRINT 'dim_date populated.';

-- ── dim_customer ─────────────────────────────────────────────
DROP TABLE IF EXISTS gold.dim_customer;
CREATE TABLE gold.dim_customer (
    customer_key        BIGINT IDENTITY(1,1) NOT NULL,
    customer_id         INT,
    full_name           NVARCHAR(200),
    email               NVARCHAR(200),
    gender              NVARCHAR(10),
    age_band            NVARCHAR(20),
    city                NVARCHAR(100),
    state               NVARCHAR(50),
    country             NVARCHAR(50),
    customer_segment    NVARCHAR(50),
    registration_year   INT,
    dwh_load_ts         DATETIME DEFAULT GETDATE(),
    CONSTRAINT pk_dim_customer PRIMARY KEY (customer_key)
);

INSERT INTO gold.dim_customer (
    customer_id, full_name, email, gender, age_band,
    city, state, country, customer_segment, registration_year
)
SELECT
    customer_id, full_name, email, gender,
    CASE
        WHEN DATEDIFF(YEAR, dob, GETDATE()) BETWEEN 18 AND 24 THEN '18-24'
        WHEN DATEDIFF(YEAR, dob, GETDATE()) BETWEEN 25 AND 34 THEN '25-34'
        WHEN DATEDIFF(YEAR, dob, GETDATE()) BETWEEN 35 AND 44 THEN '35-44'
        WHEN DATEDIFF(YEAR, dob, GETDATE()) BETWEEN 45 AND 54 THEN '45-54'
        WHEN DATEDIFF(YEAR, dob, GETDATE()) >= 55 THEN '55+'
        ELSE 'Unknown'
    END,
    city, state, country, customer_segment,
    YEAR(registration_date)
FROM silver.customers;
GO

-- ── dim_product ──────────────────────────────────────────────
DROP TABLE IF EXISTS gold.dim_product;
CREATE TABLE gold.dim_product (
    product_key     BIGINT IDENTITY(1,1) NOT NULL,
    product_id      INT,
    product_name    NVARCHAR(300),
    category        NVARCHAR(100),
    subcategory     NVARCHAR(100),
    brand           NVARCHAR(100),
    unit_cost       DECIMAL(10,2),
    unit_price      DECIMAL(10,2),
    margin_pct      DECIMAL(5,2),
    is_active       BIT,
    launch_year     INT,
    dwh_load_ts     DATETIME DEFAULT GETDATE(),
    CONSTRAINT pk_dim_product PRIMARY KEY (product_key)
);

INSERT INTO gold.dim_product (
    product_id, product_name, category, subcategory, brand,
    unit_cost, unit_price, margin_pct, is_active, launch_year
)
SELECT
    product_id, product_name, category, subcategory, brand,
    unit_cost, unit_price,
    CASE WHEN unit_price > 0
         THEN ROUND((unit_price - unit_cost) / unit_price * 100, 2)
         ELSE NULL END,
    is_active,
    YEAR(launch_date)
FROM silver.products;
GO

-- ── dim_region ───────────────────────────────────────────────
DROP TABLE IF EXISTS gold.dim_region;
CREATE TABLE gold.dim_region (
    region_key      BIGINT IDENTITY(1,1) NOT NULL,
    region_id       INT,
    region_name     NVARCHAR(100),
    state           NVARCHAR(50),
    country         NVARCHAR(50),
    zone            NVARCHAR(50),
    CONSTRAINT pk_dim_region PRIMARY KEY (region_key)
);

INSERT INTO gold.dim_region (region_id, region_name, state, country, zone)
SELECT region_id, region_name, state, country, zone
FROM silver.regions;
GO

-- ── dim_sales_channel ────────────────────────────────────────
DROP TABLE IF EXISTS gold.dim_sales_channel;
CREATE TABLE gold.dim_sales_channel (
    channel_key     BIGINT IDENTITY(1,1) NOT NULL,
    channel_id      INT,
    channel_name    NVARCHAR(100),
    channel_type    NVARCHAR(50),
    commission_pct  DECIMAL(5,2),
    CONSTRAINT pk_dim_channel PRIMARY KEY (channel_key)
);

INSERT INTO gold.dim_sales_channel (channel_id, channel_name, channel_type, commission_pct)
SELECT channel_id, channel_name, channel_type, commission_pct
FROM silver.sales_channels;
GO

PRINT 'All gold dimension tables created and loaded.';
