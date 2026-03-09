{{
  config(
    materialized = 'table',
    tags = ['dimension']
    )
}}

WITH source_races AS (
    SELECT * FROM {{ ref('silver_races') }}
),

final AS (
    SELECT
        raceId as race_id,
        circuitId as circuit_id, -- foreign key
        year,
        round,
        name AS race_name,
        date AS race_date,
        time AS race_time,
    FROM source_races
)

SELECT * FROM final