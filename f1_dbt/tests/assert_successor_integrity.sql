-- Test: assert_successor_integrity
-- Successor teams (is_successor_team = TRUE) must always have both:
--   - a non-null predecessor_lineage_id
--   - a non-null succession_type
-- Any row violating this rule is returned; zero rows = test passes.

SELECT
    constructor_id,
    constructor_ref,
    constructor_name,
    is_successor_team,
    predecessor_lineage_id,
    succession_type
FROM {{ ref('silver_constructors') }}
WHERE
    is_successor_team = TRUE
    AND (
        predecessor_lineage_id IS NULL
        OR succession_type IS NULL
    )
