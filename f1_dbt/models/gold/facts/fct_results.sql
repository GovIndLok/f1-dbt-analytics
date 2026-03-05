{{
  config(
    materialized = 'table',
    tags = ['gold', 'fact']
    )
}}

WITH source_results AS (
    SELECT * FROM {{ ref('silver_results') }}
),

races AS (
    SELECT * FROM {{ ref('silver_races') }}
),

status_seed AS (
    SELECT * FROM {{ ref('status') }}
),

final AS (
    SELECT
        s.resultId as result_id,
        s.raceId as race_id,
        s.driverId as driver_id,
        s.constructorId as constructor_id,

        r.circuitId as circuit_id,
        
        s.grid as start_position,
        s.finshPosition as finish_position,
        s.resultCode as finish_text_code,
        s.finishOrder as finish_order,
        s.points,
        s.laps as laps_completed,
        s.timeMilliseconds / 1000 as completion_time_sec,
        s.fastestLap as fastest_lap_num,
        s.fastestLapRank as fastest_lap_rank,
        s.fastestLapMilliseconds / 1000 as fastest_lap_time_sec,
        s.fastestLapSpeed as fastest_lap_speed,
        st.statusId as finish_status_id,
        st.status as finish_status_code

    FROM source_results s
    LEFT JOIN races r
        ON s.raceId = r.raceId
    LEFT JOIN status_seed st
        ON s.statusId = st.statusId
)

SELECT * FROM final