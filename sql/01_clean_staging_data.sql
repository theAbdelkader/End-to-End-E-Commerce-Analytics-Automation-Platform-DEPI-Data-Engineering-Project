-- إنشاء اسكيما cleaned لو مش موجودة
CREATE SCHEMA IF NOT EXISTS cleaned;

-- 1. تنظيف جدول العملاء (Customers)
DROP TABLE IF EXISTS cleaned.stg_customers;
CREATE TABLE cleaned.stg_customers AS
SELECT 
    TRIM(customer_id) AS customer_id,
    TRIM(customer_unique_id) AS customer_unique_id,
    customer_zip_code_prefix::INT AS customer_zip_code_prefix,
    INITCAP(TRIM(customer_city)) AS customer_city,
    UPPER(TRIM(customer_state)) AS customer_state
FROM staging.customers;

-- 2. تنظيف وتجميع جدول العناوين وإزالة التكرار (Geolocation)
DROP TABLE IF EXISTS cleaned.stg_geolocation;
CREATE TABLE cleaned.stg_geolocation AS
SELECT 
    geolocation_zip_code_prefix::INT AS zip_code_prefix,
    ROUND(AVG(geolocation_lat::NUMERIC), 6) AS latitude,
    ROUND(AVG(geolocation_lng::NUMERIC), 6) AS longitude,
    UPPER(TRIM(MODE() WITHIN GROUP (ORDER BY geolocation_city))) AS city,
    UPPER(TRIM(MODE() WITHIN GROUP (ORDER BY geolocation_state))) AS state
FROM staging.geolocation
WHERE geolocation_zip_code_prefix IS NOT NULL
GROUP BY geolocation_zip_code_prefix;

-- 3. تنظيف جدول المنتجات ودمج ترجمة الأقسام (Products)
DROP TABLE IF EXISTS cleaned.stg_products;
CREATE TABLE cleaned.stg_products AS
SELECT 
    TRIM(p.product_id) AS product_id,
    COALESCE(NULLIF(TRIM(p.product_category_name), ''), 'unknown') AS product_category_name_pt,
    COALESCE(NULLIF(TRIM(t.product_category_name_english), ''), 'unknown') AS product_category_name_en,
    COALESCE(p.product_name_lenght::INT, 0) AS product_name_length,
    COALESCE(p.product_description_lenght::INT, 0) AS product_description_length,
    COALESCE(p.product_photos_qty::INT, 0) AS product_photos_qty,
    COALESCE(p.product_weight_g::NUMERIC, 0.0) AS product_weight_g,
    COALESCE(p.product_length_cm::NUMERIC, 0.0) AS product_length_cm,
    COALESCE(p.product_height_cm::NUMERIC, 0.0) AS product_height_cm,
    COALESCE(p.product_width_cm::NUMERIC, 0.0) AS product_width_cm
FROM staging.products p
LEFT JOIN staging.category_translation t 
       ON TRIM(p.product_category_name) = TRIM(t.product_category_name);

-- 4. تنظيف جدول البائعين (Sellers)
DROP TABLE IF EXISTS cleaned.stg_sellers;
CREATE TABLE cleaned.stg_sellers AS
SELECT 
    TRIM(seller_id) AS seller_id,
    seller_zip_code_prefix::INT AS seller_zip_code_prefix,
    INITCAP(TRIM(seller_city)) AS seller_city,
    UPPER(TRIM(seller_state)) AS seller_state
FROM staging.sellers;

-- 5. تنظيف جدول الطلبات وتحويل التواريخ (Orders)
DROP TABLE IF EXISTS cleaned.stg_orders;
CREATE TABLE cleaned.stg_orders AS
SELECT 
    TRIM(order_id) AS order_id,
    TRIM(customer_id) AS customer_id,
    LOWER(TRIM(order_status)) AS order_status,
    order_purchase_timestamp::TIMESTAMP AS order_purchase_timestamp,
    order_approved_at::TIMESTAMP AS order_approved_at,
    order_delivered_carrier_date::TIMESTAMP AS order_delivered_carrier_date,
    order_delivered_customer_date::TIMESTAMP AS order_delivered_customer_date,
    order_estimated_delivery_date::TIMESTAMP AS order_estimated_delivery_date
FROM staging.orders;

-- 6. تنظيف جدول عناصر الطلب والأسعار (Order Items)
DROP TABLE IF EXISTS cleaned.stg_order_items;
CREATE TABLE cleaned.stg_order_items AS
SELECT 
    TRIM(order_id) AS order_id,
    order_item_id::INT AS order_item_id,
    TRIM(product_id) AS product_id,
    TRIM(seller_id) AS seller_id,
    shipping_limit_date::TIMESTAMP AS shipping_limit_date,
    GREATEST(price::NUMERIC(10,2), 0.00) AS price,
    GREATEST(freight_value::NUMERIC(10,2), 0.00) AS freight_value
FROM staging.order_items;

-- 7. تنظيف جدول الدفع والمبالغ (Order Payments)
DROP TABLE IF EXISTS cleaned.stg_order_payments;
CREATE TABLE cleaned.stg_order_payments AS
SELECT 
    TRIM(order_id) AS order_id,
    payment_sequential::INT AS payment_sequential,
    LOWER(TRIM(payment_type)) AS payment_type,
    payment_installments::INT AS payment_installments,
    GREATEST(payment_value::NUMERIC(10,2), 0.00) AS payment_value
FROM staging.order_payments;

-- 8. تنظيف جدول التقييمات والتعليقات المفقودة (Order Reviews)
DROP TABLE IF EXISTS cleaned.stg_order_reviews;
CREATE TABLE cleaned.stg_order_reviews AS
SELECT 
    TRIM(review_id) AS review_id,
    TRIM(order_id) AS order_id,
    review_score::INT AS review_score,
    COALESCE(NULLIF(TRIM(review_comment_title), ''), 'No Title') AS review_comment_title,
    COALESCE(NULLIF(TRIM(review_comment_message), ''), 'No Message') AS review_comment_message,
    review_creation_date::TIMESTAMP AS review_creation_date,
    review_answer_timestamp::TIMESTAMP AS review_answer_timestamp
FROM staging.order_reviews;