{{
  config(
    materialized = 'table',
    tags = ['silver']
    )
}}

WITH source_constructor_results AS (
    SELECT * FROM {{ ref('bronze_constructor_results') }}
),

deduplicate_constructor_results AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY constructorResultsId 
        ORDER BY constructorResultsId
    ) AS rowNum
    FROM source_constructor_results
),

cleaned_constructor_results AS (
    SELECT 
    constructorResultsId,
    raceId,
    constructorId,
    points,
    TRY_CAST(NULLIF(status, '\N') AS INT) AS status
    FROM deduplicate_constructor_results
    WHERE rowNum = 1
),

casted_constructor_results AS (
    SELECT
    constructorResultsId,
    raceId,
    constructorId,
    CAST(points AS DECIMAL(4, 1)) AS points,
    LEFT(CAST(status AS STRING), 3) AS status
    FROM cleaned_constructor_results
)

SELECT * FROM casted_constructor_results