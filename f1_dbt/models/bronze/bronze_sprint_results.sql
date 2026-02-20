{{
  config(
    materialized = 'table',
    )
}}

-- dbt source: {{ source('source', 'sprint_results_csv') }}

SELECT * FROM read_files(
    "/Volumes/{{ var('catalog') }}/{{ var('source_schema') }}/{{ var('source_volume') }}/sprint_results.csv",
    format => 'csv',
    header => true,
    inferSchema => true
)