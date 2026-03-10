{{
  config(
    materialized = 'table',
    tags = ['gold', 'marts']
    )
}}

WITH source_constructors AS (
    SELECT * FROM {{ ref('dim_constructors') }}
),

race_years AS (
    SELECT race_id, year FROM {{ ref('dim_races') }}
),

race_results AS (
    SELECT 
        res.constructor_id,
        rac.year,
        SUM(res.points) as total_points,
        SUM(CASE WHEN res.finish_order = 1 THEN 1 ELSE 0 END) as total_wins,
        SUM(CASE WHEN res.finish_order <=3 THEN 1 ELSE 0 END) as total_podiums,
        SUM(CASE WHEN res.finish_status_code = 'Finished' THEN 1 ELSE 0 END) / COUNT(*) as finish_rate,
        MIN(res.finish_order) as best_finish,
        COUNT(CASE WHEN res.finish_order <= 2 THEN 1 END) as top2_count
    FROM {{ ref('fct_results') }} res
    LEFT JOIN race_years rac
        ON res.race_id = rac.race_id
    GROUP BY res.constructor_id, res.race_id,rac.year
),

race_stats AS (
    SELECT
        constructor_id,
        year,
        COUNT(DISTINCT race_id) as total_races,
        SUM(total_points) as total_points,
        SUM(total_wins) as total_wins,
        SUM(total_podiums) as total_podiums,
        AVG(finish_rate) as finish_rate,
        SUM(CASE WHEN best_finish = 1 AND top2_count = 2 THEN 1 ELSE 0 END) as total_1_2_finishes
    FROM race_results
    GROUP BY constructor_id, year
),

final AS (
    SELECT
        source.constructor_id,
        source.constructor_name,
        source.team_lineage_id,
        source.constructor_nationality,
        stats.year,
        stats.total_races,
        stats.total_points,
        stats.total_wins,
        stats.total_podiums,
        stats.finish_rate,
        stats.total_1_2_finishes
    FROM source_constructors source
    LEFT JOIN race_stats stats
        ON source.constructor_id = stats.constructor_id
)

SELECT * FROM final