{{ config(materialized='table') }}

SELECT
    user_pseudo_id,
    player_id,
    ga_session_id,
    event_timestamp,
    product_id,
    revenue_usd,
    campaign
FROM {{ ref('int_iap_monetization') }}