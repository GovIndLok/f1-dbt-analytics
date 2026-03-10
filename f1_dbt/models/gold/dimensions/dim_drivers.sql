{{  
  config(
    materialized = 'table',
    tags = ['dimension']
    )
}}

WITH soruce_drivers AS (
    SELECT * FROM {{ ref('silver_drivers')}}
),

latest_numbers AS (
    SELECT
        driverId,
        driverNumber as currentNumber,
        raceYear as lastRaceSeason
        FROM {{ ref('silver_driver_num') }}
        QUALIFY ROW_NUMBER() OVER (PARTITION BY driverId ORDER BY raceYear DESC) = 1
),

final AS (
    SELECT
        d.driverId as driver_id,
        d.driverRef as driver_ref,

        d.forename,
        d.surname,
        d.forename || ' ' || d.surname as fullname,
        d.nationality,
        d.dob,

        ln.currentNumber as current_number,
        ln.lastRaceSeason as last_race_season,

        CASE WHEN ln.lastRaceSeason = 2024 THEN TRUE
            ELSE FALSE
        END AS is_active

        FROM soruce_drivers d
        LEFT JOIN latest_numbers ln
            ON d.driverId = ln.driverId
)

SELECT * FROM final