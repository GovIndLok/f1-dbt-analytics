{{
  config(
    materialized = 'table',
    )
}}

WITH source_qualifyings AS (
    SELECT * FROM {{ ref('bronze_qualifyings') }}
),

WITH deduplicate_qualifyings AS (
    SELECT *, 
    ROW_NUMBER() OVER (
        PARTITION BY raceId, driverId
    ) AS rowNum
    FROM source_qualifyings
),

WITH casted_qualifyings AS (
    SELECT
        qualifyId,
        raceId,
        driverId,
        position,
        CAST('00:' || NULLIF(NULLIF(q1, '\N'), '') AS INTERVAL) AS q1,
        CAST('00:' || NULLIF(NULLIF(q2, '\N'), '') AS INTERVAL) AS q2,
        CAST('00:' || NULLIF(NULLIF(q3, '\N'), '') AS INTERVAL) AS q3
    FROM deduplicate_qualifyings
    WHERE rowNum = 1
)

SELECT * FROM casted_qualifyings
