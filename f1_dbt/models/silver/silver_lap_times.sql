{{
  config(
    materialized = 'table',
    )
}}

WITH source_lap_times AS (
    SELECT * FROM {{ ref('bronze_lap_times') }}
),

WITH deduplicate_lap_times AS (
    SELECT *, 
    ROW_NUMBER() OVER (
        PARTITION BY lapTimeId
    ) AS rowNum
    FROM source_lap_times
),

WITH casted_lap_times AS (
    SELECT
    raceId,
    driverId,
    lap,
    position
    CAST('00:' || NULLIF(NULLIF(time, '\N'), '') AS INTERVAL) AS time,
    CAST(milliseconds AS INT) AS milliseconds
    FROM deduplicate_lap_times
    WHERE rowNum = 1
)

SELECT * FROM casted_lap_times