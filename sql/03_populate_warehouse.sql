-- 1. تعبئة جدول التواريخ تلقائياً للفترة من 2016 إلى 2018
INSERT INTO warehouse.dim_date (
        date_key,
        full_date,
        year,
        quarter,
        month,
        month_name,
        day,
        day_of_week,
        day_name
    )
SELECT TO_CHAR(d, 'YYYYMMDD')::INT AS date_key,
    d::DATE AS full_date,
    EXTRACT(
        YEAR
        FROM d
    )::INT AS year,
    EXTRACT(
        QUARTER
        FROM d
    )::INT AS quarter,
    EXTRACT(
        MONTH
        FROM d
    )::INT AS month,
    TRIM(TO_CHAR(d, 'Month')) AS month_name,
    EXTRACT(
        DAY
        FROM d
    )::INT AS day,
    EXTRACT(
        ISODOW
        FROM d
    )::INT AS day_of_week,
    TRIM(TO_CHAR(d, 'Day')) AS day_name
FROM generate_series(
        '2016-01-01'::DATE,
        '2018-12-31'::DATE,
        '1 day'::INTERVAL
    ) d;
-- 2. نقل العملاء إلى dim_customers
INSERT INTO warehouse.dim_customers (
        customer_id,
        customer_unique_id,
        zip_code_prefix,
        city,
        state
    )
SELECT customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM cleaned.stg_customers;
-- 3. نقل المنتجات إلى dim_products
INSERT INTO warehouse.dim_products (
        product_id,
        category_name_pt,
        category_name_en,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm
    )
SELECT product_id,
    product_category_name_pt,
    product_category_name_en,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM cleaned.stg_products;
-- 4. نقل البائعين إلى dim_sellers
INSERT INTO warehouse.dim_sellers (seller_id, zip_code_prefix, city, state)
SELECT seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM cleaned.stg_sellers;
-- 5. نقل الجغرافيا إلى dim_geolocation
INSERT INTO warehouse.dim_geolocation (
        zip_code_prefix,
        latitude,
        longitude,
        city,
        state
    )
SELECT zip_code_prefix,
    latitude,
    longitude,
    city,
    state
FROM cleaned.stg_geolocation;
-- 6. ملء جدول الحقائق (fact_order_items) بربط المفاتيح البديلة (Surrogate Keys)
INSERT INTO warehouse.fact_order_items (
        order_id,
        order_item_id,
        customer_key,
        product_key,
        seller_key,
        purchase_date_key,
        order_status,
        price,
        freight_value,
        payment_value,
        review_score
    )
SELECT oi.order_id,
    oi.order_item_id,
    c.customer_key,
    p.product_key,
    s.seller_key,
    TO_CHAR(o.order_purchase_timestamp, 'YYYYMMDD')::INT AS purchase_date_key,
    o.order_status,
    oi.price,
    oi.freight_value,
    COALESCE(pay.payment_value, 0.00) AS payment_value,
    COALESCE(r.review_score, 0) AS review_score
FROM cleaned.stg_order_items oi
    JOIN cleaned.stg_orders o ON oi.order_id = o.order_id
    LEFT JOIN warehouse.dim_customers c ON o.customer_id = c.customer_id
    LEFT JOIN warehouse.dim_products p ON oi.product_id = p.product_id
    LEFT JOIN warehouse.dim_sellers s ON oi.seller_id = s.seller_id
    LEFT JOIN (
        SELECT order_id,
            SUM(payment_value) AS payment_value
        FROM cleaned.stg_order_payments
        GROUP BY order_id
    ) pay ON oi.order_id = pay.order_id
    LEFT JOIN (
        SELECT order_id,
            AVG(review_score)::INT AS review_score
        FROM cleaned.stg_order_reviews
        GROUP BY order_id
    ) r ON oi.order_id = r.order_id;