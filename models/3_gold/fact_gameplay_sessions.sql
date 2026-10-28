{{ config(materialized='table') }}

SELECT
    user_pseudo_id,
    player_id,
    ga_session_id,
    level_id,
    level_index,
    attempt,
    start_timestamp,
    start_date,
    end_timestamp,
    end_date,
    status,
    duration_seconds,
    revive_count,
    booster_0,
    booster_1,
    booster_2,
    booster_3,
    unsolved_items,
    total_items,
    move_count,
    campaign,
    ab_test
FROM {{ ref('int_level_gameplay') }}