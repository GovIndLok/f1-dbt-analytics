{{
  config(
    materialized = 'table',
    tags = ['dimension']
    )
}}

WITH source_circuits AS (
    SELECT * FROM {{ ref('silver_circuits') }}
),

final AS (
    SELECT
        circuitId,
        circuitRef,
        name AS circuit_name,
        location AS circuit_location,
        country,
        lat AS latitude,
        lng AS longitude,
        alt AS altitude
        FROM source_circuits
)

SELECT * FROM final