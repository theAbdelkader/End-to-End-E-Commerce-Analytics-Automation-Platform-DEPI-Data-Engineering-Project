
-- Create staging schema
CREATE SCHEMA IF NOT EXISTS staging;

-- 1. Customers
CREATE TABLE IF NOT EXISTS staging.customers (
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix VARCHAR(10),
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

-- 2. Geolocation
CREATE TABLE IF NOT EXISTS staging.geolocation (
    geolocation_zip_code_prefix VARCHAR(10),
    geolocation_lat VARCHAR(50),
    geolocation_lng VARCHAR(50),
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(10)
);

-- 3. Products
CREATE TABLE IF NOT EXISTS staging.products (
    product_id VARCHAR(50),
    product_category_name VARCHAR(150),
    product_name_lenght VARCHAR(20),
    product_description_lenght VARCHAR(20),
    product_photos_qty VARCHAR(20),
    product_weight_g VARCHAR(30),
    product_length_cm VARCHAR(30),
    product_height_cm VARCHAR(30),
    product_width_cm VARCHAR(30)
);

-- 4. Category Translation
CREATE TABLE IF NOT EXISTS staging.category_translation (
    product_category_name VARCHAR(150),
    product_category_name_english VARCHAR(150)
);

-- 5. Sellers
CREATE TABLE IF NOT EXISTS staging.sellers (
    seller_id VARCHAR(50),
    seller_zip_code_prefix VARCHAR(10),
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);

-- 6. Orders
CREATE TABLE IF NOT EXISTS staging.orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp VARCHAR(50),
    order_approved_at VARCHAR(50),
    order_delivered_carrier_date VARCHAR(50),
    order_delivered_customer_date VARCHAR(50),
    order_estimated_delivery_date VARCHAR(50)
);

-- 7. Order Items
CREATE TABLE IF NOT EXISTS staging.order_items (
    order_id VARCHAR(50),
    order_item_id VARCHAR(20),
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date VARCHAR(50),
    price VARCHAR(30),
    freight_value VARCHAR(30)
);

-- 8. Order Payments
CREATE TABLE IF NOT EXISTS staging.order_payments (
    order_id VARCHAR(50),
    payment_sequential VARCHAR(20),
    payment_type VARCHAR(50),
    payment_installments VARCHAR(20),
    payment_value VARCHAR(30)
);

-- 9. Order Reviews
CREATE TABLE IF NOT EXISTS staging.order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score VARCHAR(20),
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date VARCHAR(50),
    review_answer_timestamp VARCHAR(50)
);
