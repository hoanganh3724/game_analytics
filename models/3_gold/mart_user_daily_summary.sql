{{ config(materialized='table') }}

WITH daily_gameplay AS (
    SELECT
        user_pseudo_id,
        start_date AS activity_date,
        COUNT(1) AS total_levels_played,
        SUM(CASE WHEN status = 1 THEN 1 ELSE 0 END) AS levels_won,
        SUM(CASE WHEN status = 0 THEN 1 ELSE 0 END) AS levels_lost,
        SUM(duration_seconds) AS total_playtime_seconds,
        SUM(revive_count) AS total_revives_used
    FROM {{ ref('fact_gameplay_sessions') }}
    GROUP BY 1, 2
),

daily_ads AS (
    SELECT
        user_pseudo_id,
        event_date AS activity_date,
        COUNT(1) AS total_ad_impressions,
        SUM(revenue_usd) AS total_ad_revenue_usd
    FROM {{ ref('fact_ad_impressions') }}
    GROUP BY 1, 2
),

daily_iap AS (
    SELECT
        user_pseudo_id,
        event_date AS activity_date,
        COUNT(1) AS total_iap_transactions,
        SUM(revenue_usd) AS total_iap_revenue_usd
    FROM {{ ref('fact_iap_transactions') }}
    GROUP BY 1, 2
)

SELECT
    COALESCE(g.user_pseudo_id, a.user_pseudo_id, i.user_pseudo_id) AS user_pseudo_id,
    COALESCE(g.activity_date, a.activity_date, i.activity_date) AS activity_date,
    COALESCE(g.total_levels_played, 0) AS total_levels_played,
    COALESCE(g.levels_won, 0) AS levels_won,
    COALESCE(g.levels_lost, 0) AS levels_lost,
    COALESCE(g.total_playtime_seconds, 0) AS total_playtime_seconds,
    COALESCE(g.total_revives_used, 0) AS total_revives_used,
    COALESCE(a.total_ad_impressions, 0) AS total_ad_impressions,
    COALESCE(a.total_ad_revenue_usd, 0) AS total_ad_revenue_usd,
    COALESCE(i.total_iap_transactions, 0) AS total_iap_transactions,
    COALESCE(i.total_iap_revenue_usd, 0) AS total_iap_revenue_usd
FROM daily_gameplay g
FULL OUTER JOIN daily_ads a 
    ON g.user_pseudo_id = a.user_pseudo_id AND g.activity_date = a.activity_date
FULL OUTER JOIN daily_iap i 
    ON COALESCE(g.user_pseudo_id, a.user_pseudo_id) = i.user_pseudo_id 
   AND COALESCE(g.activity_date, a.activity_date) = i.activity_date