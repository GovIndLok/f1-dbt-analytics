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
        name AS circuitName,
        location AS circuitLocation,
        country,
        lat AS latitude,
        lng AS longitude,
        alt AS altitude,
        FROM source_circuits
)

SELECT * FROM final