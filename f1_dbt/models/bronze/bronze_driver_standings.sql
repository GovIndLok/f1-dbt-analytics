{{
  config(
    materialized = 'table',
    tags = ['bronze']
    )
}}

-- dbt source: {{ source('source', 'driver_standings_csv') }}

SELECT * FROM read_files(
    "/Volumes/{{ var('catalog') }}/{{ var('source_schema') }}/{{ var('source_volume') }}/driver_standings.csv",
    format => 'csv',
    header => true,
    inferSchema => true
)