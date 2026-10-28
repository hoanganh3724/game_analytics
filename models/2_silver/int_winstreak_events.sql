WITH streak_points AS (
    SELECT
        user_pseudo_id,
        player_id,
        ga_session_id,
        TO_TIMESTAMP(event_timestamp / 1000000) AS event_timestamp,
        TO_TIMESTAMP(event_timestamp / 1000000)::DATE AS event_date,
        'POINT_GAINED' AS winstreak_event_type,
        current_streak,
        points_gained,
        current_total_points,
        level_id,
        CAST(NULL AS INT) AS milestone_id,
        CAST(NULL AS BIGINT) AS coin_balance,
        country,
        device_operating_system,
        campaign
    FROM {{ ref('stg_winstreak_point_gained') }}
),

rewards_claimed AS (
    SELECT
        user_pseudo_id,
        player_id,
        ga_session_id,
        TO_TIMESTAMP(event_timestamp / 1000000) AS event_timestamp,
        TO_TIMESTAMP(event_timestamp / 1000000)::DATE AS event_date,
        'REWARD_CLAIMED' AS winstreak_event_type,
        CAST(NULL AS INT) AS current_streak,
        CAST(NULL AS INT) AS points_gained,
        CAST(NULL AS INT) AS current_total_points,
        CAST(NULL AS INT) AS level_id,
        milestone_id,
        coin_balance,
        country,
        device_operating_system,
        campaign
    FROM {{ ref('stg_winstreak_reward_claimed') }}
)

SELECT * FROM streak_points
UNION ALL
SELECT * FROM rewards_claimed