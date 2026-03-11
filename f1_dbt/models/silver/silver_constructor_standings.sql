{{
  config(
    materialized = 'table',
    tags = ['silver']
    )
}}

WITH source_constructor_standings AS (
    SELECT * FROM {{ ref('bronze_constructor_standings') }}
),

deduplicate_constructor_standings AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY constructorStandingsId 
        ORDER BY constructorStandingsId
    ) AS rowNum
    FROM source_constructor_standings
),

casted_constructor_standings AS (
    SELECT 
    constructorStandingsId,
    raceId,
    constructorId,
    CAST(points AS DECIMAL(5,1)) AS points,
    position,
    wins
    FROM deduplicate_constructor_standings
    WHERE rowNum = 1
)

SELECT * FROM casted_constructor_standings