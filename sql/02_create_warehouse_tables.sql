-- إنشاء اسكيما الـ warehouse
CREATE SCHEMA IF NOT EXISTS warehouse;
-- مسح الجداول لو كانت موجودة مسبقاً لاعادة البناء
DROP TABLE IF EXISTS warehouse.fact_order_items;
DROP TABLE IF EXISTS warehouse.dim_customers;
DROP TABLE IF EXISTS warehouse.dim_products;
DROP TABLE IF EXISTS warehouse.dim_sellers;
DROP TABLE IF EXISTS warehouse.dim_geolocation;
DROP TABLE IF EXISTS warehouse.dim_date;
-- 1. جدول أبعاد العملاء
CREATE TABLE warehouse.dim_customers (
    customer_key SERIAL PRIMARY KEY,
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    zip_code_prefix INT,
    city VARCHAR(100),
    state VARCHAR(10)
);
-- 2. جدول أبعاد المنتجات
CREATE TABLE warehouse.dim_products (
    product_key SERIAL PRIMARY KEY,
    product_id VARCHAR(50),
    category_name_pt VARCHAR(100),
    category_name_en VARCHAR(100),
    product_weight_g NUMERIC,
    product_length_cm NUMERIC,
    product_height_cm NUMERIC,
    product_width_cm NUMERIC
);
-- 3. جدول أبعاد البائعين
CREATE TABLE warehouse.dim_sellers (
    seller_key SERIAL PRIMARY KEY,
    seller_id VARCHAR(50),
    zip_code_prefix INT,
    city VARCHAR(100),
    state VARCHAR(10)
);
-- 4. جدول أبعاد الجغرافيا
CREATE TABLE warehouse.dim_geolocation (
    geo_key SERIAL PRIMARY KEY,
    zip_code_prefix INT UNIQUE,
    latitude NUMERIC(10, 6),
    longitude NUMERIC(10, 6),
    city VARCHAR(100),
    state VARCHAR(10)
);
-- 5. جدول التواريخ للتحليل الزمني
CREATE TABLE warehouse.dim_date (
    date_key INT PRIMARY KEY,
    -- YYYYMMDD
    full_date DATE,
    year INT,
    quarter INT,
    month INT,
    month_name VARCHAR(20),
    day INT,
    day_of_week INT,
    day_name VARCHAR(20)
);
-- 6. جدول الحقائق المحوري (Fact Table)
CREATE TABLE warehouse.fact_order_items (
    fact_id BIGSERIAL PRIMARY KEY,
    order_id VARCHAR(50),
    order_item_id INT,
    customer_key INT REFERENCES warehouse.dim_customers(customer_key),
    product_key INT REFERENCES warehouse.dim_products(product_key),
    seller_key INT REFERENCES warehouse.dim_sellers(seller_key),
    purchase_date_key INT REFERENCES warehouse.dim_date(date_key),
    order_status VARCHAR(20),
    price NUMERIC(10, 2),
    freight_value NUMERIC(10, 2),
    payment_value NUMERIC(10, 2),
    review_score INT
);