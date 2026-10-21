{{ config(materialized='table') }}

SELECT
    user_pseudo_id,
    CAST(TRY_CAST(ga_session_id AS DOUBLE) AS BIGINT) AS session_id,
    event_datetime AS buy_time,
    source AS resource_source,
    source_id,
    CAST(rewarded_count AS BIGINT) AS amount_bought
FROM {{ ref('stg_buy_resource') }}