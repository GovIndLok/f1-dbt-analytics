{{
  config(
    materialized = 'table',
    tags = ['bronze']
    )
}}  

-- dbt source: {{ source('source', 'constructor_results_csv') }}

SELECT * FROM read_files(
    "/Volumes/{{ var('catalog') }}/{{ var('source_schema') }}/{{ var('source_volume') }}/constructor_results.csv",
    format => 'csv',
    header => true,
    inferSchema => true
)