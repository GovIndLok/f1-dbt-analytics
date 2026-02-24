{{
  config(
    materialized = 'table',
    )
}}

WITH 
source_circuits AS (
    SELECT * FROM {{ ref('bronze_circuits') }}
),

deduplicate_circuits AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY circuitId 
    ) AS rowNum
    FROM source_circuits
),

cleaned_circuits AS (
    SELECT 
    circuitId,
    circuitRef,
    name,
    location,
    country,
    lat,
    lng,
    alt,
    url
    from deduplicate_circuits
    where rowNum = 1
),

casted_circuits AS (
    SELECT
    circuitId,
    circuitRef,
    name,
    location,
    country,
    CAST(lat AS DECIMAL(10, 7)) AS lat,
    CAST(lng AS DECIMAL(10, 7)) AS lng,
    CAST(alt AS INT) AS alt,
    url
    FROM cleaned_circuits
)

SELECT * FROM casted_circuits