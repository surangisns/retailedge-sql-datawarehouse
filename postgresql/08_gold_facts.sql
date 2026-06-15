-- ============================================================
-- RetailEdge Analytics | PostgreSQL
-- Script 08: Create and Load Gold Fact Tables
-- ============================================================

-- ── fact_sales ───────────────────────────────────────────────
DROP TABLE IF EXISTS gold.fact_sales CASCADE;
CREATE TABLE gold.fact_sales (
    sale_key            BIGSERIAL PRIMARY KEY,
    order_id            INT, item_id INT,
    date_key            INT REFERENCES gold.dim_date(date_key),
    customer_key        BIGINT REFERENCES gold.dim_customer(customer_key),
    product_key         BIGINT REFERENCES gold.dim_product(product_key),
    region_key          BIGINT REFERENCES gold.dim_region(region_key),
    channel_key         BIGINT REFERENCES gold.dim_sales_channel(channel_key),
    quantity_sold       INT, unit_price NUMERIC(10,2),
    discount_amount     NUMERIC(10,2), gross_sales_amount NUMERIC(10,2),
    net_sales_amount    NUMERIC(10,2), order_status VARCHAR(30),
    payment_method      VARCHAR(50), dwh_load_ts TIMESTAMP DEFAULT NOW()
);

INSERT INTO gold.fact_sales (
    order_id, item_id, date_key, customer_key, product_key,
    region_key, channel_key, quantity_sold, unit_price, discount_amount,
    gross_sales_amount, net_sales_amount, order_status, payment_method
)
SELECT
    o.order_id, oi.item_id,
    TO_CHAR(o.order_date,'YYYYMMDD')::INT,
    dc.customer_key, dp.product_key, dr.region_key, dsc.channel_key,
    oi.quantity, oi.unit_price, oi.discount_amount,
    oi.quantity * oi.unit_price,
    oi.line_total,
    o.order_status, o.payment_method
FROM silver.order_items oi
JOIN silver.orders          o   ON oi.order_id  = o.order_id
JOIN gold.dim_customer      dc  ON o.customer_id = dc.customer_id
JOIN gold.dim_product       dp  ON oi.product_id = dp.product_id
LEFT JOIN gold.dim_region       dr  ON o.region_id  = dr.region_id
LEFT JOIN gold.dim_sales_channel dsc ON o.channel_id = dsc.channel_id
WHERE o.order_date IS NOT NULL;

-- ── fact_returns ─────────────────────────────────────────────
DROP TABLE IF EXISTS gold.fact_returns CASCADE;
CREATE TABLE gold.fact_returns (
    return_key      BIGSERIAL PRIMARY KEY,
    return_id       INT, order_id INT,
    date_key        INT REFERENCES gold.dim_date(date_key),
    product_key     BIGINT REFERENCES gold.dim_product(product_key),
    return_reason   VARCHAR(300), refund_amount NUMERIC(10,2),
    return_status   VARCHAR(30), dwh_load_ts TIMESTAMP DEFAULT NOW()
);

INSERT INTO gold.fact_returns (return_id, order_id, date_key, product_key, return_reason, refund_amount, return_status)
SELECT r.return_id, r.order_id,
    TO_CHAR(r.return_date,'YYYYMMDD')::INT,
    dp.product_key,
    r.return_reason, r.refund_amount, r.return_status
FROM silver.returns r
JOIN gold.dim_product dp ON r.product_id = dp.product_id
WHERE r.return_date IS NOT NULL;
