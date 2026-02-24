{{
  config(
    materialized = 'table',
    )
}}

WITH source_constructors AS (
    SELECT * FROM {{ ref('bronze_constructors') }}
),

WITH deduplicate_constructors AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY constructorId 
    ) AS rowNum
    FROM source_constructors
),

WITH cleaned_constructors AS (
    SELECT 
    constructorId,
    constructorRef,
    name,
    nationality,
    url
    FROM deduplicate_constructors
    WHERE rowNum = 1
)

SELECT * FROM cleaned_constructors