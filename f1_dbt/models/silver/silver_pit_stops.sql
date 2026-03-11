{{
  config(
    materialized = 'table',
    tags = ['silver']
    )
}}

WITH source_pit_stops AS (
    SELECT * FROM {{ ref('bronze_pit_stops') }}
),

deduplicate_pit_stops AS (
    SELECT *, 
    ROW_NUMBER() OVER (
        PARTITION BY raceId, driverId, stop
        ORDER BY raceId, driverId, stop
    ) AS rowNum
    FROM source_pit_stops
),

casted_pit_stops AS (
    SELECT
    raceId,
    driverId,
    stop,
    lap,
    time,
    CAST(milliseconds AS INT) AS milliseconds
    FROM deduplicate_pit_stops
    WHERE rowNum = 1
)

SELECT * FROM casted_pit_stops