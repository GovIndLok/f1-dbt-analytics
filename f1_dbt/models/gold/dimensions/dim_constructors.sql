{{
  config(
    materialized = 'table',
    tags = ['dimension']
    )
}}

WITH source_constructors AS (
    SELECT * FROM {{ ref('silver_constructors') }}
),

final AS (
    SELECT
        constructorId as constructor_id,
        constructorRef as constructor_ref,
        constructorName as constructor_name,
        nationality as constructor_nationality,
        wikipediaUrl as constructor_url,
        root_team_name,
        team_lineage_id,
        is_rebrand,
        is_successor_team,
        is_current_name
    FROM source_constructors
)

SELECT * FROM final