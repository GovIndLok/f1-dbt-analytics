# f1_dbt — Formula 1 Analytics Pipeline

> **Platform:** Databricks · Unity Catalog
> **Tool:** dbt Core
> **Goal:** Process historical F1 race data (1950–2024) through a Medallion Architecture into analytics-ready dimensional models and data marts.

---

## Table of Contents

1. [Project Purpose](#1-project-purpose)
2. [Prerequisites & Setup](#2-prerequisites--setup)
3. [Project Structure](#3-project-structure)
4. [Running the Pipeline](#4-running-the-pipeline)
5. [Model Layers & Tags](#5-model-layers--tags)
6. [Seeds](#6-seeds)
7. [Snapshots](#7-snapshots)
8. [Testing](#8-testing)
9. [Variables Reference](#9-variables-reference)

---

## 1. Project Purpose

This dbt project powers an end-to-end F1 data pipeline on Databricks. Its purpose is to transform raw F1 CSV data — loaded into a Databricks Unity Catalog Volume — into clean, analytical models that answer questions like:

- Which constructors had the highest win rates in a given season?
- How did a driver's average qualifying position compare to their race finish?
- What is the pit stop efficiency trend for a team across a season?
- Which circuits produce the most retirements?

The data currently covers **1950 through 2024**. The pipeline is structured so that as the underlying dataset is updated, all downstream Silver and Gold models re-process automatically via `dbt run`.

---

## 2. Prerequisites & Setup

### Requirements

- Python ≥ 3.10 (managed via `uv`)
- dbt Core with `dbt-databricks` adapter
- A Databricks workspace with Unity Catalog enabled
- Access to the `f1_championship` catalog (or update variables to point to your catalog)

### dbt Profile

Create or update `~/.dbt/profiles.yml` with your Databricks connection:

```yaml
f1_dbt:
  target: dev
  outputs:
    dev:
      type: databricks
      catalog: f1_championship
      schema: silver            # default fallback schema (overridden per-layer by generate_schema_name macro)
      host: <your-databricks-host>
      http_path: <your-sql-warehouse-http-path>
      token: <your-access-token>
```

### Install Dependencies

```bash
# Install dbt packages (dbt_utils etc.)
dbt deps
```

---

## 3. Project Structure

```
f1_dbt/
├── models/
│   ├── bronze/         ← Raw ingestion models (13 tables)
│   │   ├── source.yml  ← External source definitions pointing to Volume paths
│   │   └── schema.yml  ← Bronze model tests
│   ├── silver/         ← Cleaned & enriched models (15 tables)
│   │   └── schema.yml
│   └── gold/
│       ├── dimensions/ ← Conformed dimension tables (dim_*)
│       ├── facts/      ← Grain-level fact tables (fct_*)
│       └── marts/      ← Aggregated season-level data marts (mart_*)
├── seeds/
│   ├── seed_constructor_lineage.csv   ← Team rebrand & succession reference data
│   └── status.csv                     ← Race finish status ID lookup
├── snapshots/
│   ├── constructor_lineage.yml        ← SCD2 on lineage seed
│   └── driver.yml                     ← SCD2 on driver nationality
├── macros/
│   └── generate_schema.sql            ← Overrides dbt schema naming to use schema name exactly
├── tests/                             ← Singular custom tests (if any)
└── dbt_project.yml
```

---

## 4. Running the Pipeline

### Full Run (all layers)

```bash
dbt run
```

### Run by layer

```bash
# Bronze only
dbt run --select bronze

# Silver only
dbt run --select silver

# Gold only
dbt run --select gold

# Dimensions only
dbt run --select tag:dimension

# Facts only
dbt run --select tag:fact

# Data marts only
dbt run --select tag:marts
```

### Run Seeds first (required before Silver)

`seed_constructor_lineage` is used in `silver_constructors`. Load it before running Silver models:

```bash
dbt seed
dbt run --select silver
```

### Run Snapshots

Snapshots should be run after seeds and after each data refresh to capture changes:

```bash
dbt snapshot
```

---

## 5. Model Layers & Tags

| Layer | Schema | Materialization | Tags |
|---|---|---|---|
| Bronze | `bronze` | `table` | — |
| Silver | `silver` | `table` | — |
| Gold — Dimensions | `gold` | `table` | `dimension` |
| Gold — Facts | `gold` | `table` | `gold`, `fact` |
| Gold — Marts | `gold` | `table` | `gold`, `marts` |

### Recommended Run Order

```
seeds → bronze → silver → gold (dims → facts → marts) → snapshots
```

dbt handles dependency resolution automatically via `ref()`. Running `dbt run` without `--select` will execute all models in the correct order.

---

## 6. Seeds

Seeds are loaded into the `reference` schema in the `f1_championship` catalog.

### `seed_constructor_lineage`

Reference table that maps F1 constructor identities across rebrands and successions. This is the backbone of the constructor lineage system used in `silver_constructors` and `dim_constructors`.

**Key columns:**

| Column | Description |
|---|---|
| `constructor_ref` | Matches the `constructorRef` field in bronze/silver |
| `team_lineage_id` | Groups rebrands of the same team under one ID |
| `root_team_name` | The original "brand" name for the lineage group |
| `lineage_sequence` | 1 = original name, 2 = first rebrand, etc. |
| `rebrand_year_start` | First season under this name |
| `rebrand_year_end` | Last season under this name (`NULL` = currently active) |
| `predecessor_lineage_id` | For succession teams: the lineage ID of the acquired entry |
| `succession_type` | `buyout` / `team_purchase` / `license_transfer` |
| `rebrand_notes` | Human-readable description of the change |

> `sauber` appears twice in this seed (original era 1993–2005, post-BMW era 2010–present). The `unique` test is intentionally omitted on `constructor_ref`.

### `status`

Maps `statusId` integers from race results CSVs to human-readable strings (e.g. `Finished`, `Engine`, `Accident`). Used in `fct_results` to populate `finish_status_code`.

To reload seeds:

```bash
dbt seed
# or to reload a specific seed:
dbt seed --select seed_constructor_lineage
```

---

## 7. Snapshots

Snapshots implement **SCD Type 2** tracking using dbt's `check` strategy. They capture the historical state of data before changes occur.

### `snapshot_constructor_lineage`

Tracks changes to `seed_constructor_lineage` over time. When a new rebrand or succession entry is added or corrected in the seed CSV, this snapshot preserves the state before the edit.

- **Unique key:** `constructor_ref` + `rebrand_year_start`
- **Tracked cols:** `team_lineage_id`, `root_team_name`, `lineage_sequence`, `rebrand_year_end`, `predecessor_lineage_id`, `succession_type`, `rebrand_notes`
- **Hard-delete detection:** enabled

### `snapshot_drivers`

Tracks nationality changes in the `bronze_drivers` table. A driver's nationality is determined by the racing licence country they hold, which can change.

- **Unique key:** `driver_id`
- **Tracked cols:** `nationality`

Run snapshots any time the source data or seeds are refreshed:

```bash
dbt snapshot
```

---

## 8. Testing

Tests are defined in `schema.yml` files at each layer. Run all tests:

```bash
dbt test
```

Run tests for a specific layer:

```bash
dbt test --select bronze
dbt test --select silver
dbt test --select gold
```

Run tests for a specific model:

```bash
dbt test --select silver_constructors
dbt test --select fct_results
```

### Severity Levels

- **`error`** — Test failure blocks the pipeline; used for primary key integrity, required fields, and star schema referential integrity
- **`warn`** — Non-blocking warning; used on foreign key nullability in Bronze where known source data gaps exist

---

## 9. Variables Reference

All configurable variables are set in `dbt_project.yml`:

| Variable | Default | Description |
|---|---|---|
| `catalog` | `f1_championship` | Unity Catalog name |
| `source_schema` | `source` | Schema where raw Volume paths are defined |
| `bronze_schema` | `bronze` | Target schema for Bronze models |
| `silver_schema` | `silver` | Target schema for Silver models |
| `gold_schema` | `gold` | Target schema for Gold models |
| `reference_schema` | `reference` | Target schema for dbt Seeds |
| `source_volume` | `raw_file` | Volume name containing raw CSVs |

Override variables at runtime:

```bash
dbt run --vars '{"catalog": "f1_dev", "bronze_schema": "bronze_dev"}'
```

---

*F1 Analytics Pipeline — dbt project documentation*
