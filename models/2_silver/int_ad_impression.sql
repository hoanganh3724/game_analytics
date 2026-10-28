{{ config(materialized='table') }}

SELECT
    user_pseudo_id,
    CAST(TRY_CAST(ga_session_id AS DOUBLE) AS BIGINT) AS session_id,
    event_datetime AS impression_time,
    ad_platform,
    ad_source,
    ad_format,
    CAST(value AS DOUBLE) AS ad_revenue_usd,
    NULLIF(mobile_brand_name, '\N') AS mobile_brand
FROM {{ ref('stg_ad_impression') }}