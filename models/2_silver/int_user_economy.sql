WITH earn AS (
    SELECT
        user_pseudo_id,
        player_id,
        ga_session_id,
        event_timestamp,
        event_date,
        'EARN' AS transaction_type,
        resource_source,
        source_id,
        amount,
        coin_balance,
        country,
        device_operating_system,
        campaign
    FROM {{ ref('stg_earn_resource') }}
),

spend AS (
    SELECT
        user_pseudo_id,
        player_id,
        ga_session_id,
        event_timestamp,
        event_date,
        'SPEND' AS transaction_type,
        resource_source,
        source_id,
        -1 * amount AS amount,
        coin_balance,
        country,
        device_operating_system,
        campaign
    FROM {{ ref('stg_spend_resource') }}
),

buy AS (
    SELECT
        user_pseudo_id,
        player_id,
        ga_session_id,
        event_timestamp,
        event_date,
        'BUY' AS transaction_type,
        resource_source,
        source_id,
        value AS amount,
        value_balance AS coin_balance,
        country,
        device_operating_system,
        campaign
    FROM {{ ref('stg_buy_resource') }}
)

SELECT * FROM earn
UNION ALL
SELECT * FROM spend
UNION ALL
SELECT * FROM buy