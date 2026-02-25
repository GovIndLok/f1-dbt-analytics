{{
  config(
    materialized = 'table',
    )
}}

WITH source_results AS (
    SELECT * FROM {{ ref('bronze_results') }}
),

WITH deduplicate_results AS (
    SELECT *, 
    ROW_NUMBER() OVER (
        PARTITION BY raceId, driverId
    ) AS rowNum
    FROM source_results
),

WITH casted_results AS (
    SELECT
    resultId,
    raceId,
    driverId,
    constructorId,
    number,
    grid,
    CAST(NULLIF(position, '\N') AS INT) AS finshPosition,
    CAST(NULLIF(positionText, '\N') AS STRING) AS resultCode,
    CAST(PositionOrder AS INT) AS finshOrder,
    CAST(NULLIF(points, '\N') AS DECIMAL(3,1)) AS points,
    laps,
    NULLIF(NULLIF(TRIM(time), '\N'), '') AS timeDisplay,
    CAST(NULLIF(milliseconds, '\N') AS INT) AS timeMilliseconds,
    CAST(NULLIF(fastestLap, '\N') AS INT) AS fastestLap,
    CAST(NULLIF(rank, '\N') AS INT) AS fastestLapRank,
    CAST(NULLIF(fastestLapTime, '\N') AS STRING) AS fastestLapTimeDisplay,
    
    -- Convert fastestLapTime to milliseconds
    CASE 
        WHEN fastestLapTime like '%:%' THEN
            (CAST(SPLIT_PART(fastestLapTime, ':', 1) AS INT) * 60 * 1000) +  -- min to msec
            (CAST(SPLIT_PART(fastestLapTime, ':', 2) AS INT) * 1000) +       -- sec to msec
            CAST(SPLIT_PART(fastestLapTime, '.', 2) AS INT)                  -- msec
        ELSE NULL
    END AS fastestLapTimeMilliseconds,
    
    CAST(NULLIF(fastestLapSpeed, '\N') AS DECIMAL(6,3)) AS fastestLapSpeed,
    statusId
    FROM deduplicate_results
    WHERE rowNum = 1
)

SELECT * FROM casted_results