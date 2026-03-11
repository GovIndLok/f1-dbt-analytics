{{
  config(
    materialized = 'table',
    tags = ['silver']
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
),

deduplicate_lap_times AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY raceId, driverId, lap ORDER BY raceId) AS row_num
    FROM casted_lap_times
)

SELECT
    raceId,
    driverId,
    lap,
    position,
    timeDisplay,
    milliseconds
FROM deduplicate_lap_times
WHERE row_num = 1