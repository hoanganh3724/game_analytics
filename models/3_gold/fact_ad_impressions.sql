{{ config(materialized='table') }}

SELECT
    user_pseudo_id,
    session_id,
    impression_time AS transaction_time,
    CAST(impression_time AS DATE) AS transaction_date,
    ad_platform,
    ad_source,
    ad_format,
    ad_revenue_usd,
    mobile_brand
FROM {{ ref('int_ad_impression') }}