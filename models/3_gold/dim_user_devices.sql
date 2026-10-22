{{ config(
    materialized='table',
    schema='silver'
) }}

WITH user_first_seen AS (
    SELECT 
        user_pseudo_id, 
        MIN(start_time) AS first_seen_time,
        CAST(MIN(start_time) AS DATE) AS first_seen_date
    FROM {{ ref('int_level_gameplay') }} 
    GROUP BY user_pseudo_id
),

user_devices AS (
    SELECT 
        user_pseudo_id,
        MODE(mobile_brand) AS primary_device_brand,
        MODE(os_version) AS primary_os_version
    FROM {{ ref('int_in_app_purchase') }}
    WHERE mobile_brand IS NOT NULL
    GROUP BY user_pseudo_id
)

SELECT
    f.user_pseudo_id,
    f.first_seen_time,
    f.first_seen_date,
    COALESCE(d.primary_device_brand, 'Unknown') AS primary_device_brand,
    COALESCE(d.primary_os_version, 'Unknown') AS primary_os_version
FROM user_first_seen f
LEFT JOIN user_devices d ON f.user_pseudo_id = d.user_pseudo_id