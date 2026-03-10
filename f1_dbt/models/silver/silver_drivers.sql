{{
  config(
    materialized = 'table',
    )
}}

WITH source_drivers AS (
    SELECT * FROM {{ ref('bronze_drivers') }}
),

deduplicate_drivers AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY driverId 
        ORDER BY driverId
    ) AS rowNum
    FROM source_drivers
),

cleaned_drivers AS (
    SELECT 
    driverId,
    driverRef,
    TRY_CAST(NULLIF(number, '\N') AS INT) AS number,
    TRY_CAST(NULLIF(code, '\N') AS STRING) AS code,
    forename,
    surname,
    dob,
    nationality,
    url
    FROM deduplicate_drivers
    WHERE rowNum = 1  --filtering early. Deduplicate
),

casted_drivers AS (
    SELECT
    driverId,
    driverRef,
    number,
    LEFT(CAST(code AS STRING), 3) AS code,
    forename,
    surname,
    CAST(dob AS DATE) AS dob,
    nationality,
    url
    FROM cleaned_drivers
),

final AS (
    SELECT *
    FROM casted_drivers
)

SELECT * FROM final