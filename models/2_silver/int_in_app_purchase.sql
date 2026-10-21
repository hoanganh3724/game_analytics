{{ config(materialized='table') }}

SELECT
    user_pseudo_id,
    CAST(TRY_CAST(ga_session_id AS DOUBLE) AS BIGINT) AS session_id,
    event_datetime AS purchase_time,
    product_id,
    CAST(event_value_in_usd AS DOUBLE) AS revenue_usd,
    NULLIF(mobile_brand_name, '\N') AS mobile_brand,
    NULLIF(operating_system_version, '\N') AS os_version
FROM {{ ref('stg_in_app_purchase') }}