{{ config(materialized='table') }}

SELECT 
    user_pseudo_id, 
    session_id, 
    earn_time AS transaction_time, 
    CAST(earn_time AS DATE) AS transaction_date, 
    'Earn' AS transaction_type, 
    resource_source, 
    source_id, 
    amount_earned AS amount 
FROM {{ ref('int_earn_resource') }}
WHERE user_pseudo_id IS NOT NULL

UNION ALL

SELECT 
    user_pseudo_id, 
    session_id, 
    spend_time AS transaction_time, 
    CAST(spend_time AS DATE) AS transaction_date, 
    'Spend' AS transaction_type, 
    resource_source, 
    source_id, 
    amount_spent AS amount 
FROM {{ ref('int_spend_resource') }}
WHERE user_pseudo_id IS NOT NULL

UNION ALL

SELECT 
    user_pseudo_id, 
    session_id, 
    buy_time AS transaction_time, 
    CAST(buy_time AS DATE) AS transaction_date, 
    'Buy' AS transaction_type, 
    resource_source, 
    source_id, 
    amount_bought AS amount 
FROM {{ ref('int_buy_resource') }}
WHERE user_pseudo_id IS NOT NULL

UNION ALL

SELECT 
    user_pseudo_id, 
    session_id, 
    event_time AS transaction_time, 
    CAST(event_time AS DATE) AS transaction_date, 
    'Winstreak_Reward' AS transaction_type, 
    'winstreak' AS resource_source, 
    'reward' AS source_id, 
    reward_amount AS amount 
FROM {{ ref('int_winstreak_events') }} 
WHERE reward_amount IS NOT NULL 
  AND user_pseudo_id IS NOT NULL