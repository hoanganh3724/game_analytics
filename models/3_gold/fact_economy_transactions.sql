{{ config(materialized='table') }}

SELECT
    user_pseudo_id,
    player_id,
    ga_session_id,
    event_timestamp,
    event_date,
    transaction_type,
    resource_source,
    source_id,
    amount,
    coin_balance,
    campaign
FROM {{ ref('int_user_economy') }}