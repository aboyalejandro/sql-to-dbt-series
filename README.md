# 🚀 SQL to dbt Starter Pack Project

This repo demonstrates a portable data stack with synthetic data processing using DuckDB and dbt transformations.

A portable data-stack with:
- Synthetic JSON marketing data processing
- DuckDB for OLAP storage  
- dbt for transformations (staging → intermediate → marts)
- Sequential Docker Compose workflow
- Complete marketing analytics models (attribution, campaign performance, visitor journey)

## 🙋🏻‍♂️ Pre-requisites
- Docker Desktop
- Copy .env.example to .env if you want to test locally

## 📝 Steps

### Run Complete Pipeline
```sh
make build    # Build all containers
make run      # Extract data → database → dbt (full pipeline)
```

### Run Services Separately
```sh
make extract   # Extract synthetic data from data.zip
make database  # Process synthetic data → create DuckDB
```

### Interactive dbt Development
```sh
# Start interactive bash session in dbt container
make dbt

# Inside container - initial setup:
dbt deps          # Install packages
dbt debug         # Check connections

# Development commands:
dbt run           # Run all models
dbt test          # Run all tests
dbt build         # Run models + tests

# Reload after file changes:
dbt run --no-partial-parse    # Force full reparse of project

# Run specific layers:
dbt run --select staging      # Clean and standardize raw data
dbt run --select intermediate # Business logic and enrichment
dbt run --select marts        # Final aggregations for BI

# Run specific models (with upstream and downstream):
dbt run --select stg_campaigns
dbt run --select +stg_campaigns # Run all previous models before stg_campaigns
dbt run --select stg_campaigns+ # Run all subsequent models after stg_campaigns

```

### Query Data
```sh
make duckdb    # Open DuckDB CLI to query data
```

### Example DuckDB queries:
```sql
-- Show all available tables
SHOW TABLES; 

-- Raw data tables
SELECT * FROM campaigns LIMIT 5;
SELECT * FROM sessions LIMIT 5;
SELECT * FROM conversions LIMIT 5;

-- dbt-generated views
SELECT * FROM main_staging.stg_campaigns LIMIT 5;
SELECT * FROM main_intermediate.int_conversions LIMIT 5;
SELECT * FROM main_marts.campaign_performance LIMIT 5;

-- Marketing analytics queries
SELECT 
    campaign_name,
    total_conversions,
    total_revenue,
    roas,
    conversion_rate_pct
FROM main_marts.campaign_performance 
ORDER BY total_revenue DESC 
LIMIT 10;
```

### Cleanup
```sh
make clean     # Remove containers and generated files
```

### 😎 [Follow me on Linkedin](https://www.linkedin.com/in/alejandro-aboy/)
- Get tips, learnings and tricks for your Data career!

### 📩 [Subscribe to The Pipe & The Line](https://thepipeandtheline.substack.com/?utm_source=github&utm_medium=referral)
- Join the Substack newsletter to get similar content to this one and more to improve your Data career!
