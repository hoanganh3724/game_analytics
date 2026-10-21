{{ config(materialized='table') }}

WITH level_starts AS (
    SELECT
        user_pseudo_id,
        CAST(TRY_CAST(ga_session_id AS DOUBLE) AS BIGINT) AS session_id,
        CAST(level_index AS VARCHAR) AS level_id,
        event_datetime AS start_time,
        event_timestamp AS start_timestamp
    FROM {{ ref('stg_level_start') }}
),
level_ends AS (
    SELECT
        user_pseudo_id,
        CAST(TRY_CAST(ga_session_id AS DOUBLE) AS BIGINT) AS session_id,
        CAST(level_index AS VARCHAR) AS level_id,
        event_datetime AS end_time,
        event_timestamp AS end_timestamp
    FROM {{ ref('stg_level_end') }}
)
SELECT
    s.user_pseudo_id,
    s.session_id,
    s.level_id,
    s.start_time,
    e.end_time,
    DATEDIFF('second', s.start_time, e.end_time) AS play_duration_seconds,
    CASE 
        WHEN e.end_time IS NOT NULL THEN 'completed'
        ELSE 'dropped_out' 
    END AS final_result,
    CASE WHEN e.end_time IS NULL THEN TRUE ELSE FALSE END AS is_dropped_out
FROM level_starts s
LEFT JOIN level_ends e
    ON s.user_pseudo_id = e.user_pseudo_id
   AND s.session_id = e.session_id
   AND s.level_id = e.level_id
   AND e.end_timestamp >= s.start_timestamp