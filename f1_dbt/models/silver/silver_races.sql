{{
  config(
    materialized = 'table',
    )
}}

WITH source_races AS (
    SELECT * FROM {{ ref('bronze_races') }}
),

WITH deduplicate_races AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY raceId 
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
    TRY_CAST(NULLIF(date, '\N') AS DATE) AS date,
    TRY_CAST(NULLIF(time, '\N') AS TIME) AS time,
    url
    FROM deduplicate_races
    WHERE rowNum = 1
)

SELECT * FROM cleaned_races