{{ config(materialized='table') }}

SELECT 
    *,
    make_timestamp(CAST(event_timestamp AS BIGINT)) AS event_datetime
FROM {{ source('bronze_raw', 'level_start') }}