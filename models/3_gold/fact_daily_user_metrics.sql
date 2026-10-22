{{ config(materialized='table') }}

WITH valid_users AS (
    -- Chỉ lấy danh sách người dùng hợp lệ đã có trong dim_user để đảm bảo toàn vẹn khóa ngoại
    SELECT user_pseudo_id 
    FROM {{ ref('dim_user_devices') }}
),

daily_gameplay AS (
    SELECT
        user_pseudo_id,
        CAST(start_time AS DATE) AS metric_date,
        COUNT(DISTINCT session_id) AS total_sessions,
        SUM(play_duration_seconds) AS total_playtime_seconds,
        SUM(CASE WHEN is_dropped_out THEN 1 ELSE 0 END) AS total_dropouts
    FROM {{ ref('int_level_gameplay') }}
    WHERE user_pseudo_id IS NOT NULL AND start_time IS NOT NULL
    GROUP BY user_pseudo_id, CAST(start_time AS DATE)
),

daily_iap AS (
    SELECT
        user_pseudo_id,
        CAST(purchase_time AS DATE) AS metric_date,
        COUNT(*) AS iap_count,
        SUM(revenue_usd) AS iap_revenue
    FROM {{ ref('int_in_app_purchase') }}
    WHERE user_pseudo_id IS NOT NULL AND purchase_time IS NOT NULL
    GROUP BY user_pseudo_id, CAST(purchase_time AS DATE)
),

daily_ads AS (
    SELECT
        user_pseudo_id,
        CAST(impression_time AS DATE) AS metric_date,
        COUNT(*) AS ad_impressions_count,
        SUM(ad_revenue_usd) AS ad_revenue
    FROM {{ ref('int_ad_impression') }}
    WHERE user_pseudo_id IS NOT NULL AND impression_time IS NOT NULL
    GROUP BY user_pseudo_id, CAST(impression_time AS DATE)
),

daily_eco AS (
    SELECT
        user_pseudo_id,
        CAST(transaction_time AS DATE) AS metric_date,
        SUM(CASE WHEN transaction_type = 'Earn' THEN amount ELSE 0 END) AS total_coins_earned,
        SUM(CASE WHEN transaction_type = 'Spend' THEN amount ELSE 0 END) AS total_coins_spent,
        SUM(CASE WHEN transaction_type = 'Buy' THEN amount ELSE 0 END) AS total_coins_bought
    FROM {{ ref('fact_economy_transactions') }}
    WHERE user_pseudo_id IS NOT NULL AND transaction_time IS NOT NULL
    GROUP BY user_pseudo_id, CAST(transaction_time AS DATE)
),

joined_metrics AS (
    SELECT
        COALESCE(g.user_pseudo_id, i.user_pseudo_id, a.user_pseudo_id, e.user_pseudo_id) AS user_pseudo_id,
        COALESCE(g.metric_date, i.metric_date, a.metric_date, e.metric_date) AS metric_date,
        COALESCE(g.total_sessions, 0) AS total_sessions,
        COALESCE(g.total_playtime_seconds, 0) AS total_playtime_seconds,
        COALESCE(g.total_dropouts, 0) AS total_dropouts,
        COALESCE(i.iap_count, 0) AS iap_count,
        COALESCE(i.iap_revenue, 0.0) AS iap_revenue,
        COALESCE(a.ad_impressions_count, 0) AS ad_impressions_count,
        COALESCE(a.ad_revenue, 0.0) AS ad_revenue,
        (COALESCE(i.iap_revenue, 0.0) + COALESCE(a.ad_revenue, 0.0)) AS total_revenue,
        COALESCE(e.total_coins_earned, 0) AS total_coins_earned,
        COALESCE(e.total_coins_spent, 0) AS total_coins_spent,
        COALESCE(e.total_coins_bought, 0) AS total_coins_bought
    FROM daily_gameplay g
    FULL OUTER JOIN daily_iap i 
        ON g.user_pseudo_id = i.user_pseudo_id AND g.metric_date = i.metric_date
    FULL OUTER JOIN daily_ads a 
        ON COALESCE(g.user_pseudo_id, i.user_pseudo_id) = a.user_pseudo_id 
       AND COALESCE(g.metric_date, i.metric_date) = a.metric_date
    FULL OUTER JOIN daily_eco e 
        ON COALESCE(g.user_pseudo_id, i.user_pseudo_id, a.user_pseudo_id) = e.user_pseudo_id 
       AND COALESCE(g.metric_date, i.metric_date, a.metric_date) = e.metric_date
)

SELECT j.*
FROM joined_metrics j
-- Lọc cứng triệt để để đảm bảo không bị dính NULL và loại bỏ hoàn toàn orphan user_id không nằm trong dim_users
INNER JOIN valid_users v ON j.user_pseudo_id = v.user_pseudo_id
WHERE j.user_pseudo_id IS NOT NULL 
  AND j.metric_date IS NOT NULL