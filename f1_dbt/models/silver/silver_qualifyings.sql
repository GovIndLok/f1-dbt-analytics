{{
  config(
    materialized = 'table',
    tags = ['silver']
    )
}}

WITH source_qualifyings AS (
    SELECT * FROM {{ ref('bronze_qualifyings') }}
),

deduplicate_qualifyings AS (
    SELECT *, 
    ROW_NUMBER() OVER (
        PARTITION BY raceId, driverId
        ORDER BY raceId, driverId
    ) AS rowNum
    FROM source_qualifyings
),

casted_qualifyings AS (
    SELECT
    qualifyId,
    raceId,
    driverId,
    constructorId,
    position,
    -- q1/q2/q3 stored as 'm:ss.mmm' — convert to total seconds as DOUBLE
    CASE 
        WHEN q1 RLIKE '^[0-9]' 
        THEN (TRY_CAST(SPLIT(q1, ':')[0] AS DOUBLE) * 60) + TRY_CAST(SPLIT(q1, ':')[1] AS DOUBLE)
        ELSE NULL 
    END AS q1_sec,
    CASE 
        WHEN q2 RLIKE '^[0-9]' 
        THEN (TRY_CAST(SPLIT(q2, ':')[0] AS DOUBLE) * 60) + TRY_CAST(SPLIT(q2, ':')[1] AS DOUBLE)
        ELSE NULL 
    END AS q2_sec,
    CASE 
        WHEN q3 RLIKE '^[0-9]' 
        THEN (TRY_CAST(SPLIT(q3, ':')[0] AS DOUBLE) * 60) + TRY_CAST(SPLIT(q3, ':')[1] AS DOUBLE)
        ELSE NULL 
    END AS q3_sec
    FROM deduplicate_qualifyings
    WHERE rowNum = 1
)

SELECT * FROM casted_qualifyings
