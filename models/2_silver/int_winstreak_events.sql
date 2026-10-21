{{ config(materialized='table') }}

WITH points AS (
    SELECT
        user_pseudo_id,
        CAST(TRY_CAST(ga_session_id AS DOUBLE) AS BIGINT) AS session_id,
        event_datetime AS event_time,
        event_timestamp,
        points_gained
    FROM {{ ref('stg_winstreak_point_gained') }}
),
rewards AS (
    SELECT
        user_pseudo_id,
        CAST(TRY_CAST(ga_session_id AS DOUBLE) AS BIGINT) AS session_id,
        event_timestamp,
        rewarded_count AS reward_amount
    FROM {{ ref('stg_winstreak_reward_claimed') }}
)
SELECT
    p.user_pseudo_id,
    p.session_id,
    p.event_time,
    p.points_gained,
    r.reward_amount
FROM points p
FULL OUTER JOIN rewards r
    ON p.user_pseudo_id = r.user_pseudo_id
   AND p.session_id = r.session_id
   AND p.event_timestamp = r.event_timestamp