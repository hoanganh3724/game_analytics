WITH start_events AS (
    SELECT *
    FROM {{ ref('stg_level_start') }}
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY user_pseudo_id, event_timestamp 
        ORDER BY event_timestamp ASC
    )
),

end_events AS (
    SELECT *
    FROM {{ ref('stg_level_end') }}
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY user_pseudo_id, event_timestamp 
        ORDER BY event_timestamp ASC
    )
)

SELECT
    s.user_pseudo_id,
    s.player_id,
    s.ga_session_id,
    s.ga_session_number,
    s.level_id,
    s.level_index,
    s.attempt,
    s.event_timestamp AS start_timestamp,
    s.event_date AS start_date,
    e.event_timestamp AS end_timestamp,
    e.event_date AS end_date,
    e.status,
    e.duration_seconds,
    COALESCE(e.revive_count, 0) AS revive_count,
    COALESCE(e.booster_0, 0) AS booster_0,
    COALESCE(e.booster_1, 0) AS booster_1,
    COALESCE(e.booster_2, 0) AS booster_2,
    COALESCE(e.booster_3, 0) AS booster_3,
    e.unsolved_items,
    e.total_items,
    e.move_count,
    s.country,
    s.city,
    s.device_operating_system,
    s.mobile_brand_name,
    s.mobile_model_name,
    s.app_version,
    s.campaign,
    s.media_source,
    s.ab_test
FROM start_events s
LEFT JOIN end_events e
    ON s.user_pseudo_id = e.user_pseudo_id
   AND s.level_id = e.level_id
   AND s.level_index = e.level_index
   AND s.attempt = e.attempt
   AND e.event_timestamp >= s.event_timestamp