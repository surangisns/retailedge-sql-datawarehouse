-- ============================================================
-- RetailEdge Analytics | SQL Server
-- Script 06: Transform Bronze → Silver
-- Cleans, standardises, and deduplicates all raw data.
-- ============================================================

USE RetailEdgeWarehouse;
GO

-- ── Customers ────────────────────────────────────────────────
TRUNCATE TABLE silver.customers;

INSERT INTO silver.customers (
    customer_id, first_name, last_name, full_name, email, phone,
    dob, gender, city, state, country, registration_date, customer_segment
)
SELECT
    TRY_CAST(customer_id AS INT),
    TRIM(first_name),
    TRIM(last_name),
    TRIM(first_name) + ' ' + TRIM(last_name),
    LOWER(TRIM(email)),
    TRIM(phone),
    -- Normalise mixed date formats
    CASE
        WHEN dob LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
             THEN TRY_CONVERT(DATE, dob, 23)
        WHEN dob LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]'
             THEN TRY_CONVERT(DATE, dob, 103)
        ELSE NULL
    END,
    -- Standardise gender
    CASE UPPER(TRIM(gender))
        WHEN 'M'      THEN 'Male'
        WHEN 'MALE'   THEN 'Male'
        WHEN 'F'      THEN 'Female'
        WHEN 'FEMALE' THEN 'Female'
        ELSE 'Other'
    END,
    TRIM(city),
    TRIM(state),
    CASE WHEN TRIM(country) IN ('', 'AU', 'Aus') THEN 'Australia'
         WHEN TRIM(country) = '' OR country IS NULL THEN 'Australia'
         ELSE TRIM(country) END,
    CASE
        WHEN registration_date LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
             THEN TRY_CONVERT(DATE, registration_date, 23)
        WHEN registration_date LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]'
             THEN TRY_CONVERT(DATE, registration_date, 103)
        ELSE NULL
    END,
    LOWER(TRIM(customer_segment))
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY LOWER(TRIM(email)) ORDER BY TRY_CAST(customer_id AS INT)) AS rn
    FROM bronze.raw_customers
    WHERE customer_id IS NOT NULL AND email IS NOT NULL AND TRIM(email) != ''
) deduped
WHERE rn = 1;
GO

PRINT CAST(@@ROWCOUNT AS NVARCHAR) + ' customers loaded to silver.';

-- ── Products ─────────────────────────────────────────────────
TRUNCATE TABLE silver.products;

INSERT INTO silver.products (
    product_id, product_name, category, subcategory, brand,
    unit_cost, unit_price, weight_kg, is_active, launch_date
)
SELECT
    TRY_CAST(product_id AS INT),
    TRIM(product_name),
    TRIM(category),
    NULLIF(TRIM(subcategory), ''),
    TRIM(brand),
    ABS(TRY_CAST(unit_cost AS DECIMAL(10,2))),   -- Fix negative costs
    ABS(TRY_CAST(unit_price AS DECIMAL(10,2))),
    TRY_CAST(weight_kg AS DECIMAL(6,2)),
    CASE UPPER(TRIM(is_active))
        WHEN 'Y' THEN 1 WHEN 'YES' THEN 1 WHEN '1' THEN 1
        ELSE 0
    END,
    CASE
        WHEN launch_date LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
             THEN TRY_CONVERT(DATE, launch_date, 23)
        WHEN launch_date LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]'
             THEN TRY_CONVERT(DATE, launch_date, 103)
        ELSE NULL
    END
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY TRY_CAST(product_id AS INT) ORDER BY TRY_CAST(product_id AS INT)) AS rn
    FROM bronze.raw_products
    WHERE product_id IS NOT NULL AND TRY_CAST(product_id AS INT) IS NOT NULL
) d WHERE rn = 1;
GO

-- ── Regions ──────────────────────────────────────────────────
TRUNCATE TABLE silver.regions;

INSERT INTO silver.regions (region_id, region_name, country, state, zone, manager_name)
SELECT DISTINCT
    TRY_CAST(region_id AS INT),
    TRIM(region_name),
    CASE UPPER(TRIM(country))
        WHEN 'AU'        THEN 'Australia'
        WHEN 'AUS'       THEN 'Australia'
        WHEN 'AUSTRALIA' THEN 'Australia'
        ELSE TRIM(country)
    END,
    NULLIF(TRIM(state), ''),
    NULLIF(TRIM(zone), ''),
    NULLIF(TRIM(manager_name), '')
FROM bronze.raw_regions
WHERE TRY_CAST(region_id AS INT) IS NOT NULL;
GO

-- ── Sales Channels ───────────────────────────────────────────
TRUNCATE TABLE silver.sales_channels;

INSERT INTO silver.sales_channels (channel_id, channel_name, channel_type, commission_pct, is_active)
SELECT
    TRY_CAST(channel_id AS INT),
    TRIM(channel_name),
    LOWER(TRIM(channel_type)),
    CASE WHEN TRY_CAST(commission_pct AS DECIMAL(5,2)) > 100 THEN NULL
         ELSE TRY_CAST(commission_pct AS DECIMAL(5,2)) END,
    CASE UPPER(TRIM(is_active))
        WHEN 'Y' THEN 1 WHEN 'YES' THEN 1 WHEN '1' THEN 1
        ELSE 0
    END
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY TRY_CAST(channel_id AS INT) ORDER BY TRY_CAST(channel_id AS INT)) AS rn
    FROM bronze.raw_sales_channels
    WHERE TRY_CAST(channel_id AS INT) IS NOT NULL
) d WHERE rn = 1;
GO

-- ── Orders ───────────────────────────────────────────────────
TRUNCATE TABLE silver.orders;

INSERT INTO silver.orders (
    order_id, customer_id, order_date, order_status, channel_id,
    region_id, shipping_date, delivery_date, discount_pct, payment_method
)
SELECT
    TRY_CAST(o.order_id AS INT),
    TRY_CAST(o.customer_id AS INT),
    TRY_CONVERT(DATE, o.order_date, 23),
    LOWER(TRIM(o.order_status)),
    TRY_CAST(o.channel AS INT),
    TRY_CAST(o.region_id AS INT),
    TRY_CONVERT(DATE, o.shipping_date, 23),
    -- Fix delivery before shipping: set to NULL
    CASE WHEN TRY_CONVERT(DATE, o.delivery_date, 23) < TRY_CONVERT(DATE, o.shipping_date, 23)
         THEN NULL
         ELSE TRY_CONVERT(DATE, o.delivery_date, 23)
    END,
    CASE WHEN TRY_CAST(o.discount_pct AS DECIMAL(5,2)) > 100 THEN NULL
         ELSE TRY_CAST(o.discount_pct AS DECIMAL(5,2)) END,
    LOWER(TRIM(o.payment_method))
FROM bronze.raw_orders o
-- Only orders with a valid customer
INNER JOIN silver.customers c ON TRY_CAST(o.customer_id AS INT) = c.customer_id
WHERE TRY_CAST(o.order_id AS INT) IS NOT NULL;
GO

-- ── Order Items ──────────────────────────────────────────────
TRUNCATE TABLE silver.order_items;

INSERT INTO silver.order_items (item_id, order_id, product_id, quantity, unit_price, discount_amount, line_total)
SELECT
    TRY_CAST(item_id AS INT),
    TRY_CAST(order_id AS INT),
    TRY_CAST(product_id AS INT),
    ABS(TRY_CAST(quantity AS INT)),   -- Fix negative quantities
    TRY_CAST(unit_price AS DECIMAL(10,2)),
    TRY_CAST(discount_amount AS DECIMAL(10,2)),
    -- Recalculate line_total to fix mismatches
    ABS(TRY_CAST(quantity AS INT)) * TRY_CAST(unit_price AS DECIMAL(10,2))
      - TRY_CAST(discount_amount AS DECIMAL(10,2))
FROM bronze.raw_order_items
WHERE TRY_CAST(item_id AS INT) IS NOT NULL
  AND TRY_CAST(order_id AS INT) IN (SELECT order_id FROM silver.orders)
  AND TRY_CAST(product_id AS INT) IN (SELECT product_id FROM silver.products);
GO

-- ── Returns ──────────────────────────────────────────────────
TRUNCATE TABLE silver.returns;

INSERT INTO silver.returns (return_id, order_id, product_id, return_date, return_reason, refund_amount, return_status)
SELECT
    TRY_CAST(r.return_id AS INT),
    TRY_CAST(r.order_id AS INT),
    TRY_CAST(r.product_id AS INT),
    TRY_CONVERT(DATE, r.return_date, 23),
    TRIM(r.return_reason),
    TRY_CAST(r.refund_amount AS DECIMAL(10,2)),
    LOWER(TRIM(r.return_status))
FROM bronze.raw_returns r
-- Exclude returns where date is before order date
LEFT JOIN silver.orders o ON TRY_CAST(r.order_id AS INT) = o.order_id
WHERE TRY_CAST(r.return_id AS INT) IS NOT NULL
  AND (o.order_date IS NULL OR TRY_CONVERT(DATE, r.return_date, 23) >= o.order_date);
GO

PRINT 'Bronze to Silver transformation complete.';
