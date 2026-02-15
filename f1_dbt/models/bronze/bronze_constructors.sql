{{
    config(
    materialized = 'table',
    )
}}

-- dbt source: {{ source('source', 'constructors_csv') }}

SELECT * FROM read_files(
    '{{ "/Volumes/" ~ target.catalog ~ "/source/raw_file/constructors.csv" }}',
    format => 'csv',
    header => true,
    inferSchema => true
)