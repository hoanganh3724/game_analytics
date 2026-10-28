WITH raw_ads AS (
    SELECT *
    FROM {{ ref('stg_ad_impression') }}
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY user_pseudo_id, event_timestamp 
        ORDER BY event_timestamp ASC
    )
)

SELECT
    user_pseudo_id,
    player_id,
    ga_session_id,
    ga_session_number,
    TO_TIMESTAMP(event_timestamp / 1000000) AS event_timestamp,
    TO_TIMESTAMP(event_timestamp / 1000000)::DATE AS event_date,
    ad_platform,
    ad_source,
    ad_format,
    ad_unit_name,
    ad_placement,
    revenue_usd,
    currency,
    country,
    city,
    device_operating_system,
    mobile_brand_name,
    mobile_model_name,
    campaign,
    media_source
FROM raw_ads