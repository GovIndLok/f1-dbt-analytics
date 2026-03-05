{{
  config(
    materialized = 'table',
    tags = ['gold', 'fact']
    )
}}

WITH source_pit_stops AS (
    SELECT * FROM {{ ref('silver_pit_stops') }}
),

races AS (
    SELECT * FROM {{ ref('silver_races') }}
),

results AS (
    SELECT * FROM {{ ref('silver_results') }}
),

final AS (
    SELECT
        ps.raceId as race_id,
        ps.driverId as driver_id,

        ra.circuitId as circuit_id,
        res.constructorId as constructor_id,

        ps.stop,
        ps.lap,
        ps.time as pit_stop_time,
        ps.milliseconds as pit_stop_ms
    FROM source_pit_stops ps
    LEFT JOIN races ra
        ON ps.raceId = ra.raceId
    LEFT JOIN results res
        ON ps.raceId = res.raceId
        AND ps.driverId = res.driverId
)

SELECT * FROM final