-- reviews with null values
SELECT COUNT(*) AS items_without_review
FROM warehouse.fact_order_items
WHERE review_score IS NULL;
WITH checks AS (
-- CHECK if row numbers match
  SELECT 'fact rows mismatch' AS check_name,
         ABS((SELECT COUNT(*) FROM cleaned.stg_order_items)
           - (SELECT COUNT(*) FROM warehouse.fact_order_items)) AS bad_rows
  UNION ALL
  SELECT 'dim_customers rows mismatch',
         ABS((SELECT COUNT(*) FROM cleaned.stg_customers)
           - (SELECT COUNT(*) FROM warehouse.dim_customers))
  UNION ALL
  SELECT 'dim_products rows mismatch',
         ABS((SELECT COUNT(*) FROM cleaned.stg_products)
           - (SELECT COUNT(*) FROM warehouse.dim_products))
  UNION ALL
  SELECT 'dim_sellers rows mismatch',
         ABS((SELECT COUNT(*) FROM cleaned.stg_sellers)
           - (SELECT COUNT(*) FROM warehouse.dim_sellers))
  UNION ALL
  SELECT 'dim_geolocation rows mismatch',
         ABS((SELECT COUNT(*) FROM cleaned.stg_geolocation)
           - (SELECT COUNT(*) FROM warehouse.dim_geolocation))
-- check no NULL keys in the fact table
  UNION ALL
  SELECT 'customer_key is NULL', COUNT(*)
  FROM warehouse.fact_order_items WHERE customer_key IS NULL
  UNION ALL
  SELECT 'product_key is NULL', COUNT(*)
  FROM warehouse.fact_order_items WHERE product_key IS NULL
  UNION ALL
  SELECT 'seller_key is NULL', COUNT(*)
  FROM warehouse.fact_order_items WHERE seller_key IS NULL
  UNION ALL
  SELECT 'purchase_date_key is NULL', COUNT(*)
  FROM warehouse.fact_order_items WHERE purchase_date_key IS NULL
  
-- check duplicates
  UNION ALL
  SELECT 'duplicate customer_id in dim_customers',
         (SELECT COUNT(*) FROM (
            SELECT customer_id FROM warehouse.dim_customers
            GROUP BY customer_id HAVING COUNT(*) > 1) d)
  UNION ALL
  SELECT 'duplicate product_id in dim_products',
         (SELECT COUNT(*) FROM (
            SELECT product_id FROM warehouse.dim_products
            GROUP BY product_id HAVING COUNT(*) > 1) d)
  UNION ALL
  SELECT 'duplicate seller_id in dim_sellers',
         (SELECT COUNT(*) FROM (
            SELECT seller_id FROM warehouse.dim_sellers
            GROUP BY seller_id HAVING COUNT(*) > 1) d)
  UNION ALL
  SELECT 'duplicate zip_code_prefix in dim_geolocation',
         (SELECT COUNT(*) FROM (
            SELECT zip_code_prefix FROM warehouse.dim_geolocation
            GROUP BY zip_code_prefix HAVING COUNT(*) > 1) d)
  UNION ALL
  SELECT 'duplicate (order_id, order_item_id) in fact',
         (SELECT COUNT(*) FROM (
            SELECT order_id, order_item_id FROM warehouse.fact_order_items
            GROUP BY order_id, order_item_id HAVING COUNT(*) > 1) d)

  -- check for illogical values
  UNION ALL
  SELECT 'price < 0', COUNT(*)
  FROM warehouse.fact_order_items WHERE price < 0
  UNION ALL
  SELECT 'freight_value < 0', COUNT(*)
  FROM warehouse.fact_order_items WHERE freight_value < 0
  UNION ALL
  SELECT 'review_score outside 1-5', COUNT(*)
  FROM warehouse.fact_order_items
  WHERE review_score IS NOT NULL AND review_score NOT BETWEEN 1 AND 5
  UNION ALL
  SELECT 'unknown order_status', COUNT(*)
  FROM warehouse.fact_order_items
  WHERE order_status IS NULL
     OR order_status NOT IN ('delivered','shipped','canceled','unavailable',
                             'invoiced','processing','created','approved')

  UNION ALL
  SELECT 'sum(price) differs from source',
         ROUND(ABS((SELECT COALESCE(SUM(price), 0) FROM cleaned.stg_order_items)
                 - (SELECT COALESCE(SUM(price), 0) FROM warehouse.fact_order_items)), 2)
  UNION ALL
  SELECT 'sum(freight_value) differs from source',
         ROUND(ABS((SELECT COALESCE(SUM(freight_value), 0) FROM cleaned.stg_order_items)
                 - (SELECT COALESCE(SUM(freight_value), 0) FROM warehouse.fact_order_items)), 2)
)
SELECT check_name,
       bad_rows,
       CASE WHEN bad_rows = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM checks;


