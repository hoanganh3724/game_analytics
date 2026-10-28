WITH source AS (
    SELECT * FROM {{ source('raw_game_data', 'winstreak_point_gained') }}
)

SELECT
    user_pseudo_id,
    player_id,
    'winstreak_point_gained' AS event_name,
    event_timestamp,
    event_date,
    advertising_id,
    vendor_id,
    appsflyer_id,
    time_zone_offset_seconds,
    country,
    city,
    platform AS device_operating_system,
    mobile_brand_name,
    mobile_model_name,
    operating_system_version,
    app_version,
    media_source,
    campaign,
    af_status,
    ab_test,
    TRY_CAST(ga_session_id AS BIGINT) AS ga_session_id,
    TRY_CAST(ga_session_number AS INT) AS ga_session_number,
    TRY_CAST(current_streak AS INT) AS current_streak,
    TRY_CAST(points_gained AS INT) AS points_gained,
    TRY_CAST(current_total_points AS INT) AS current_total_points,
    TRY_CAST(level_id AS INT) AS level_id
FROM source