{{
  config(
    materialized = 'table',
    tags = ['gold', 'marts']
    )
}}

WITH source_drivers AS (
    SELECT * FROM {{ ref('dim_drivers') }}
),

race_years AS (
    SELECT race_id, year FROM {{ ref('dim_races') }}
),

race_results AS (
    SELECT 
        driver_id,
        rac.year,
        COUNT(race_id) as total_races,
        SUM(points) as total_points,
        AVG(start_position) as avg_start_position,
        AVG(finish_order) as avg_finish_order,
        AVG(points) as avg_points,
        AVG(fastest_lap_speed) as avg_fastest_lap_speed,
        SUM(CASE WHEN finish_order = 1 THEN 1 ELSE 0 END) as total_wins,
        SUM(CASE WHEN finish_order <= 3 THEN 1 ELSE 0 END) as total_podiums,
        SUM(CASE WHEN finish_order <= 10 THEN 1 ELSE 0 END) as total_points_finish,
        SUM(CASE WHEN start_position = 1 THEN 1 ELSE 0 END) as total_p1_starts,
        SUM(CASE WHEN finish_status_code = 'Finished' THEN 1 ELSE 0 END) / COUNT(*) as finish_rate
    FROM {{ ref('fct_results') }} res
    LEFT JOIN race_years rac
        ON res.race_id = rac.race_id
    GROUP BY driver_id, rac.year
),

qualifying AS (
    SELECT 
        driver_id,
        rac.year,
        AVG(qualifying_position) as avg_qualifying_position,
        SUM(CASE WHEN q3 IS NOT NULL THEN 1 ELSE 0 END) as total_q3_apperances
    FROM {{ ref('fct_qualifyings') }} qual
    LEFT JOIN race_years rac
        ON qual.race_id = rac.race_id
    GROUP BY driver_id, rac.year
),

final AS (
    SELECT
        driver.driver_id,
        driver.driver_ref,
        driver.forename,
        driver.surname,
        driver.nationality,
        driver.current_number,
        race.year,
        race.total_races,
        race.total_points,
        race.avg_start_position,
        race.avg_finish_order,
        race.avg_points,
        race.avg_fastest_lap_speed,
        race.total_wins,
        race.total_podiums,
        race.total_points_finish,
        race.total_p1_starts,
        race.finish_rate,
        qual.avg_qualifying_position,
        qual.total_q3_apperances
    FROM source_drivers driver
    LEFT JOIN race_results race
        ON driver.driver_id = race.driver_id
    LEFT JOIN qualifying qual
        ON driver.driver_id = qual.driver_id AND race.year = qual.year
)

SELECT * FROM final