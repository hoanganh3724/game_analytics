{{ config(materialized='table') }}

SELECT
    user_pseudo_id,
    session_id,
    level_id,
    start_time,
    end_time,
    CAST(start_time AS DATE) AS session_date,
    play_duration_seconds,
    final_result,
    is_dropped_out
FROM {{ ref('int_level_gameplay') }}