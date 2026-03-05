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
        raceId,
        circuitId, -- foreign key
        year,
        round,
        name AS raceName,
        date AS raceDate,
        time AS raceTime,
    FROM source_races
)

SELECT * FROM final