{{
  config(
    materialized = 'table',
    tags = ['gold', 'fact']
    )
}}

WITH source_lap_times AS (
    SELECT * FROM {{ ref('silver_lap_times') }}
),

races AS (
    SELECT * FROM {{ ref('silver_races') }}
),

results AS (
    SELECT * FROM {{ ref('silver_results') }}
),

final AS (
    SELECT
        lt.raceId as race_id,
        lt.driverId as driver_id,

        ra.circuitId as circuit_id,
        res.constructorId as constructor_id,

        lt.lap,
        lt.position,
        lt.time as lap_time,
        lt.milliseconds as lap_ms
    FROM source_lap_times lt
    LEFT JOIN races ra
        ON lt.raceId = ra.raceId
    LEFT JOIN results res
        ON lt.raceId = res.raceId
        AND lt.driverId = res.driverId
)

SELECT * FROM final