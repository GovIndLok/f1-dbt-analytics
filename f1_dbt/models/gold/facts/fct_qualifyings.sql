{{
  config(
    materialized = 'table',
    tags = ['gold', 'fact']
    )
}}

WITH source_qualifyings AS (
    SELECT * FROM {{ ref('silver_qualifyings') }}
),

results AS (
    SELECT * FROM {{ ref('silver_results') }}
),

races AS (
    SELECT * FROM {{ ref('silver_races') }}
),

final AS (
    SELECT
        q.qualifyId as qualifying_id,
        q.raceId as race_id,
        q.driverId as driver_id,

        res.constructorId as constructor_id,
        ra.circuitId as circuit_id,

        q.position as qualifying_position,
        q.q1_sec,
        q.q2_sec,
        q.q3_sec
    FROM source_qualifyings q
    LEFT JOIN results res
        ON q.raceId = res.raceId
        AND q.driverId = res.driverId
    LEFT JOIN races ra
        ON q.raceId = ra.raceId
)

SELECT * FROM final