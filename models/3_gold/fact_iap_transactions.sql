{{ config(materialized='table') }}

SELECT
    user_pseudo_id,
    session_id,
    purchase_time AS transaction_time,
    CAST(purchase_time AS DATE) AS transaction_date,
    product_id,
    revenue_usd,
    mobile_brand,
    os_version
FROM {{ ref('int_in_app_purchase') }}