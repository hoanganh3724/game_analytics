{{ config(materialized='table') }}

WITH ranked_users AS (
    SELECT
        user_pseudo_id,
        player_id,
        country,
        city,
        device_operating_system,
        mobile_brand_name,
        mobile_model_name,
        app_version,
        campaign,
        media_source,
        start_timestamp,
        ROW_NUMBER() OVER (PARTITION BY user_pseudo_id ORDER BY start_timestamp ASC) as rn
    FROM {{ ref('int_level_gameplay') }}
)

SELECT
    user_pseudo_id,
    MAX(player_id) AS player_id,
    MIN(start_timestamp) AS first_seen_timestamp,
    MAX(country) AS geo_country,
    MAX(city) AS geo_city,
    MAX(device_operating_system) AS device_operating_system,
    MAX(mobile_brand_name) AS mobile_brand_name,
    MAX(mobile_model_name) AS mobile_model_name,
    MAX(app_version) AS app_version,
    MAX(campaign) AS acquisition_campaign,
    MAX(media_source) AS media_source
FROM ranked_users
WHERE rn = 1
GROUP BY user_pseudo_id