{{
  config(
    materialized = 'table',
    )
}}

WITH source_pit_stops AS (
    SELECT * FROM {{ ref('bronze_pit_stops') }}
),

WITH deduplicate_pit_stops AS (
    SELECT *, 
    ROW_NUMBER() OVER (
        PARTITION BY raceId, driverId, stop
    ) AS rowNum
    FROM source_pit_stops
),

WITH casted_pit_stops AS (
    SELECT
    raceId,
    driverId,
    stop,
    CAST(milliseconds AS INT) AS milliseconds,
    CAST('00:' || NULLIF(NULLIF(time, '\N'), '') AS INTERVAL) AS time
    FROM deduplicate_pit_stops
    WHERE rowNum = 1
)

SELECT * FROM casted_pit_stops