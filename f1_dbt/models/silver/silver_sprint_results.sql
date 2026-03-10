{{
  config(
    materialized = 'table',
    )
}}

WITH source_sprint_results AS (
    SELECT * FROM {{ ref('bronze_sprint_results') }}
),

deduplicate_sprint_results AS (
    SELECT *, 
    ROW_NUMBER() OVER (
        PARTITION BY raceId, driverId
        ORDER BY raceId, driverId
    ) AS rowNum
    FROM source_sprint_results
),

casted_sprint_results AS (
    SELECT
    resultId,
    raceId,
    driverId,
    constructorId,
    number,
    grid,
    TRY_CAST(position AS INT) AS finshPosition,
    NULLIF(positionText, '\N') AS resultCode,
    CAST(PositionOrder AS INT) AS finshOrder,
    TRY_CAST(points AS DECIMAL(3,1)) AS points,
    laps,
    CASE WHEN time RLIKE '^[+]?[0-9]' THEN time ELSE NULL END AS timeDisplay,
    TRY_CAST(milliseconds AS INT) AS timeMilliseconds,
    TRY_CAST(fastestLap AS INT) AS fastestLap,
    NULLIF(fastestLapTime, '\N') AS fastestLapTimeDisplay,
    
    -- Convert fastestLapTime to milliseconds
    CASE 
        WHEN fastestLapTime like '%:%' THEN
            (TRY_CAST(SPLIT_PART(fastestLapTime, ':', 1) AS INT) * 60 * 1000) +  -- min to msec
            (TRY_CAST(SPLIT_PART(fastestLapTime, ':', 2) AS INT) * 1000) +       -- sec to msec
            (TRY_CAST(SPLIT_PART(fastestLapTime, '.', 2) AS INT))                -- msec
        ELSE NULL
    END AS fastestLapTimeMilliseconds,
    
    statusId
    FROM deduplicate_sprint_results
    WHERE rowNum = 1
)

SELECT * FROM casted_sprint_results