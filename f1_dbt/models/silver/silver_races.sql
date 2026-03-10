{{
  config(
    materialized = 'table',
    )
}}

WITH source_races AS (
    SELECT * FROM {{ ref('bronze_races') }}
),

deduplicate_races AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY raceId 
        ORDER BY raceId
    ) AS rowNum
    FROM source_races
),

cleaned_races AS (
    SELECT 
    raceId,
    year,
    round,
    circuitId,
    name,
    CASE WHEN date RLIKE '^[0-9]' THEN date ELSE NULL END AS raceDate,
    CASE WHEN time RLIKE '^[0-9]' THEN time ELSE NULL END AS raceTime,
    TRY_TO_TIMESTAMP(
        CASE WHEN date RLIKE '^[0-9]' AND time RLIKE '^[0-9]'
             THEN date || ' ' || time
             ELSE NULL
        END,
        'yyyy-MM-dd HH:mm:ss'
    ) AS race_timestamp,
    url
    FROM deduplicate_races
    WHERE rowNum = 1
)

SELECT * FROM cleaned_races