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
        season_number as currentNumber,
        season as lastRaceSeason,
        FROM {{ ref('silver_driver_num') }}
        QUALIFY ROW_NUMBER() OVER (PARTITION BY driverId ORDER BY season DESC) = 1
),

final AS (
    SELECT
        d.driverId,
        d.driverRef,

        d.forename,
        d.surname,
        d.forename || ' ' || d.surname as fullname,
        d.nationality,
        d.dob,

        ln.currentNumber,
        ln.lastRaceSeason,

        CASE ln.lastRaceSeason = 2024 THEN TRUE
            ELSE FALSE
        END AS isActive

        FROM soruce_drivers d
        LEFT JOIN latest_numbers ln
            ON d.driverId = ln.driverId
)

SELECT * FROM final