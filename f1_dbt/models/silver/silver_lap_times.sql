{{
  config(
    materialized = 'table',
    )
}}

WITH source_lap_times AS (
    SELECT * FROM {{ ref('bronze_lap_times') }}
),

casted_lap_times AS (
    SELECT
    raceId,
    driverId,
    lap,
    position,
    CASE WHEN time RLIKE '^[0-9]' THEN time ELSE NULL END AS timeDisplay,
    TRY_CAST(milliseconds AS INT) AS milliseconds
    FROM source_lap_times
)

SELECT * FROM casted_lap_times