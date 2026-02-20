{{
  config(
    materialized = 'table',
    )
}}

-- dbt source: {{ source('source', 'pit_stops_csv') }}

SELECT * FROM read_files(
    "/Volumes/{{ var('catalog') }}/{{ var('source_schema') }}/{{ var('source_volume') }}/pit_stops.csv",
    format => 'csv',
    header => true,
    inferSchema => true
)