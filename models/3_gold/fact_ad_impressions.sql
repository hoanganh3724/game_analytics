{{ config(materialized='table') }}

SELECT
    user_pseudo_id,
    player_id,
    ga_session_id,
    event_timestamp,
    ad_platform,
    ad_source,
    ad_format,
    ad_unit_name,
    ad_placement,
    revenue_usd,
    currency,
    campaign
FROM {{ ref('int_ad_monetization') }}