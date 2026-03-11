{{
  config(
    materialized = 'table',
    tags = ['bronze']
    )
}}

-- dbt source: {{ source('source', 'lap_times_csv') }}

SELECT * FROM read_files(
    "/Volumes/{{ var('catalog') }}/{{ var('source_schema') }}/{{ var('source_volume') }}/lap_times.csv",
    format => 'csv',
    header => true,
    inferSchema => true
)