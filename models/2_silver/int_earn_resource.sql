{{ config(materialized='table') }}

SELECT
    user_pseudo_id,
    CAST(TRY_CAST(ga_session_id AS DOUBLE) AS BIGINT) AS session_id,
    event_datetime AS earn_time,
    source AS resource_source,
    source_id,
    CAST(coin_total AS BIGINT) AS amount_earned
FROM {{ ref('stg_earn_resource') }}