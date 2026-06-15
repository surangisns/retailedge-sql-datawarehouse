-- ============================================================
-- RetailEdge Analytics | PostgreSQL
-- Script 06: Transform Bronze → Silver
-- ============================================================

-- ── Customers ────────────────────────────────────────────────
TRUNCATE TABLE silver.customers;

INSERT INTO silver.customers (
    customer_id, first_name, last_name, full_name, email, phone,
    dob, gender, city, state, country, registration_date, customer_segment
)
SELECT
    customer_id::INT,
    INITCAP(TRIM(first_name)),
    INITCAP(TRIM(last_name)),
    INITCAP(TRIM(first_name)) || ' ' || INITCAP(TRIM(last_name)),
    LOWER(TRIM(email)),
    NULLIF(TRIM(phone), ''),
    CASE
        WHEN dob ~ '^\d{4}-\d{2}-\d{2}$' THEN TO_DATE(dob,'YYYY-MM-DD')
        WHEN dob ~ '^\d{2}/\d{2}/\d{4}$' THEN TO_DATE(dob,'DD/MM/YYYY')
        ELSE NULL
    END,
    CASE UPPER(TRIM(gender))
        WHEN 'M' THEN 'Male' WHEN 'MALE' THEN 'Male'
        WHEN 'F' THEN 'Female' WHEN 'FEMALE' THEN 'Female'
        ELSE 'Other'
    END,
    TRIM(city), TRIM(state),
    CASE WHEN UPPER(TRIM(country)) IN ('AU','AUS','AUSTRALIA') THEN 'Australia'
         WHEN TRIM(country) = '' OR country IS NULL THEN 'Australia'
         ELSE TRIM(country) END,
    CASE
        WHEN registration_date ~ '^\d{4}-\d{2}-\d{2}$' THEN TO_DATE(registration_date,'YYYY-MM-DD')
        WHEN registration_date ~ '^\d{2}/\d{2}/\d{4}$' THEN TO_DATE(registration_date,'DD/MM/YYYY')
        ELSE NULL
    END,
    LOWER(TRIM(customer_segment))
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY LOWER(TRIM(email)) ORDER BY customer_id::INT) AS rn
    FROM bronze.raw_customers
    WHERE customer_id IS NOT NULL AND email IS NOT NULL AND TRIM(email) != ''
) d WHERE rn = 1;

-- ── Products ─────────────────────────────────────────────────
TRUNCATE TABLE silver.products;

INSERT INTO silver.products (
    product_id, product_name, category, subcategory, brand,
    unit_cost, unit_price, weight_kg, is_active, launch_date
)
SELECT
    product_id::INT, TRIM(product_name), TRIM(category),
    NULLIF(TRIM(subcategory),''), TRIM(brand),
    ABS(unit_cost::NUMERIC(10,2)),
    ABS(unit_price::NUMERIC(10,2)),
    weight_kg::NUMERIC(6,2),
    CASE UPPER(TRIM(is_active)) WHEN 'Y' THEN TRUE WHEN 'YES' THEN TRUE WHEN '1' THEN TRUE ELSE FALSE END,
    CASE
        WHEN launch_date ~ '^\d{4}-\d{2}-\d{2}$' THEN TO_DATE(launch_date,'YYYY-MM-DD')
        WHEN launch_date ~ '^\d{2}/\d{2}/\d{4}$' THEN TO_DATE(launch_date,'DD/MM/YYYY')
        ELSE NULL
    END
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY product_id) rn
    FROM bronze.raw_products WHERE product_id IS NOT NULL
) d WHERE rn = 1;

-- ── Regions ──────────────────────────────────────────────────
TRUNCATE TABLE silver.regions;
INSERT INTO silver.regions (region_id, region_name, country, state, zone, manager_name)
SELECT DISTINCT region_id::INT, TRIM(region_name),
    CASE UPPER(TRIM(country)) WHEN 'AU' THEN 'Australia' WHEN 'AUS' THEN 'Australia'
        WHEN 'AUSTRALIA' THEN 'Australia' ELSE TRIM(country) END,
    NULLIF(TRIM(state),''), NULLIF(TRIM(zone),''), NULLIF(TRIM(manager_name),'')
FROM bronze.raw_regions WHERE region_id IS NOT NULL;

-- ── Sales Channels ───────────────────────────────────────────
TRUNCATE TABLE silver.sales_channels;
INSERT INTO silver.sales_channels (channel_id, channel_name, channel_type, commission_pct, is_active)
SELECT channel_id::INT, TRIM(channel_name), LOWER(TRIM(channel_type)),
    CASE WHEN commission_pct::NUMERIC > 100 THEN NULL ELSE commission_pct::NUMERIC(5,2) END,
    CASE UPPER(TRIM(is_active)) WHEN 'Y' THEN TRUE WHEN 'YES' THEN TRUE WHEN '1' THEN TRUE ELSE FALSE END
FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY channel_id ORDER BY channel_id) rn FROM bronze.raw_sales_channels WHERE channel_id IS NOT NULL) d WHERE rn = 1;

-- ── Orders ───────────────────────────────────────────────────
TRUNCATE TABLE silver.orders;
INSERT INTO silver.orders (order_id, customer_id, order_date, order_status, channel_id, region_id, shipping_date, delivery_date, discount_pct, payment_method)
SELECT o.order_id::INT, o.customer_id::INT,
    TO_DATE(o.order_date,'YYYY-MM-DD'),
    LOWER(TRIM(o.order_status)), o.channel::INT, NULLIF(o.region_id,'')::INT,
    TO_DATE(o.shipping_date,'YYYY-MM-DD'),
    CASE WHEN TO_DATE(o.delivery_date,'YYYY-MM-DD') < TO_DATE(o.shipping_date,'YYYY-MM-DD')
         THEN NULL ELSE TO_DATE(o.delivery_date,'YYYY-MM-DD') END,
    CASE WHEN o.discount_pct::NUMERIC > 100 THEN NULL ELSE o.discount_pct::NUMERIC(5,2) END,
    LOWER(TRIM(o.payment_method))
FROM bronze.raw_orders o
JOIN silver.customers c ON o.customer_id::INT = c.customer_id
WHERE o.order_id IS NOT NULL;

-- ── Order Items ──────────────────────────────────────────────
TRUNCATE TABLE silver.order_items;
INSERT INTO silver.order_items (item_id, order_id, product_id, quantity, unit_price, discount_amount, line_total)
SELECT item_id::INT, order_id::INT, product_id::INT,
    ABS(quantity::INT),
    unit_price::NUMERIC(10,2),
    discount_amount::NUMERIC(10,2),
    ABS(quantity::INT) * unit_price::NUMERIC(10,2) - discount_amount::NUMERIC(10,2)
FROM bronze.raw_order_items
WHERE item_id IS NOT NULL
  AND order_id::INT IN (SELECT order_id FROM silver.orders)
  AND product_id IS NOT NULL AND product_id != ''
  AND product_id::INT IN (SELECT product_id FROM silver.products);

-- ── Returns ──────────────────────────────────────────────────
TRUNCATE TABLE silver.returns;
INSERT INTO silver.returns (return_id, order_id, product_id, return_date, return_reason, refund_amount, return_status)
SELECT r.return_id::INT, NULLIF(r.order_id,'')::INT, r.product_id::INT,
    TO_DATE(r.return_date,'YYYY-MM-DD'),
    TRIM(r.return_reason), r.refund_amount::NUMERIC(10,2), LOWER(TRIM(r.return_status))
FROM bronze.raw_returns r
LEFT JOIN silver.orders o ON r.order_id::INT = o.order_id
WHERE r.return_id IS NOT NULL
  AND (o.order_date IS NULL OR TO_DATE(r.return_date,'YYYY-MM-DD') >= o.order_date);
