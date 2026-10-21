{{ config(materialized='table') }}

SELECT
    user_pseudo_id,
    CAST(ga_session_id AS VARCHAR) AS session_id,
    event_datetime AS impression_time,
    ad_platform,
    ad_source,
    ad_format,
    CAST(value AS DOUBLE) AS ad_revenue_usd,
    NULLIF(mobile_brand_name, '\N') AS mobile_brand
FROM {{ ref('stg_ad_impression') }}