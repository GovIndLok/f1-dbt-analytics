{{
  config(
    materialized = 'table',
    )
}}

WITH source_constructor_results AS (
    SELECT * FROM {{ ref('bronze_constructor_results') }}
),

WITH deduplicate_constructor_results AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY constructorResultId 
    ) AS rowNum
    FROM source_constructor_results
),

WITH cleaned_constructor_results AS (
    SELECT 
    constructorResultId,
    raceId,
    constructorId,
    points,
    TRY_CAST(NULLIF(status, '\N') AS INT) AS status
    FROM deduplicate_constructor_results
    WHERE rowNum = 1
),

casted_constructor_results AS (
    SELECT
    constructorResultId,
    raceId,
    constructorId,
    CAST(points AS DECIMAL(4, 1)) AS points,
    LEFT(CAST(status AS STRING), 3) AS status
    FROM cleaned_constructor_results
)

SELECT * FROM casted_constructor_results