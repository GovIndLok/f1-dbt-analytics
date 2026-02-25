{{
  config(
    materialized = 'table',
    )
}}

WITH source_driver_standings AS (
    SELECT * FROM {{ ref('bronze_driver_standings') }}
),

deduplicate_driver_standings AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY driverStandingsId 
    ) AS rowNum
    FROM source_driver_standings
),

casted_driver_standings AS (
    SELECT
    driverStandingsId,
    raceId,
    driverId,
    CAST(points AS DECIMAL(3, 1)) AS points,
    position,
    wins                                         -- wins in season at that point in time
    FROM deduplicate_driver_standings
    WHERE rowNum = 1
)

SELECT * FROM casted_driver_standings