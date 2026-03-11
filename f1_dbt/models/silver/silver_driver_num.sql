{{
  config(
    materialized = 'table',
    tags = ['silver']
    )
}}

WITH race_result as (
    SELECT
        result.driverId,
        race.year as raceYear,
        result.number as driverNumber,
        MIN(race.date) as firstDate,
        MAX(race.date) as lastDate,
        COUNT(DISTINCT result.raceId) as raceCount
    FROM {{ ref('bronze_results') }}  result
    JOIN {{ ref('bronze_races') }}  race
    on result.raceId = race.raceId
    WHERE result.number IS NOT NULL
    GROUP BY result.driverId, raceYear, driverNumber
)

SELECT 
    driverId,
    raceYear,
    driverNumber, 
    firstDate,
    lastDate,
    raceCount
FROM race_result
ORDER BY driverId, raceYear