# 🚀 SQL to dbt Starter Pack Project

This repo demonstrates a portable data stack with synthetic data (https://syntheticdatagen.xyz/) processing using DuckDB and dbt transformations.

A portable data-stack with:
- Synthetic JSON marketing data processing
- DuckDB for OLAP storage  
- dbt for transformations (staging → intermediate → marts)
- Sequential Docker Compose workflow
- Complete marketing analytics models (attribution, campaign performance, visitor journey)
- **Advanced data contracts** with business logic constraints
- **Reusable macros** for touchpoint attribution and performance classification
- **Snapshots** for tracking campaign performance and visitor segment evolution
- **Column-level lineage visualization** with dbt-colibri

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

# Run snapshots for historical tracking:
dbt snapshot                    # Run all snapshots
dbt snapshot -s snap_campaign_performance  # Run specific snapshot

```

### 📊 Test Categories & Execution

See more on generic, singular, contracts and great expectations on this [README](dbt/tests/README.md)

### Visualization & Documentation
```sh
# Generate and serve dbt documentation
make dbt-docs       # Access at http://localhost:9000

# Generate and serve column lineage visualization
make dbt-colibri    # Access at http://localhost:8080
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

-- Query snapshot history
SELECT campaign_name, roas_tier, dbt_valid_from, dbt_valid_to
FROM snapshots.snap_campaign_performance
WHERE campaign_id = 'some-campaign-id'
ORDER BY dbt_valid_from;
```

## 🏗️ Advanced Features

### Data Contracts with Business Logic Constraints
- **Primary/Foreign Key constraints** for referential integrity
- **Check constraints** for business rules (budget > 1000, ROI >= -1, CTR between 0-1)
- **Named constraints** for better error messages
- **Automatic constraint validation** during model compilation

### Reusable Macros
- **`get_touchpoint_attribution()`** - Flexible first/last touch attribution logic
- **`classify_performance_tier()`** - Standardized tier classification (high/medium/low)
- **`classify_vs_target()`** - Compare actual vs target metrics
- **`safe_divide()`** - Division with null handling to prevent errors
- **`calculate_percentage_share()`** - Standardized percentage calculations

**Example macro usage:**
```sql
-- Performance tier classification
{{ classify_performance_tier(
    column_name='ads.ctr',
    tier_name='ctr_performance', 
    high_threshold=0.02,
    medium_threshold=0.01
) }}

-- Safe division 
{{ safe_divide('conversions.revenue', 'conversions.attributed_spend') }} as roas
```

### Column-level Lineage Visualization
- **dbt-colibri integration** - Interactive column lineage dashboard
- **Zero external dependencies** - Self-hosted static HTML visualization
- **Complete data flow visibility** - Track how columns transform through staging → intermediate → marts
- **Real-time updates** - Generated from latest dbt artifacts

**Access the lineage dashboard:**
```sh
make dbt-colibri    # Generates lineage and serves at http://localhost:8080
```

### Historical Snapshots
- **`snap_campaign_performance`** - Daily campaign metrics evolution (ROAS, conversion rates, budget utilization)
- **`snap_visitor_segments`** - Visitor segment transitions (prospect → customer → VIP)

**Query snapshot evolution:**
```sql
-- Campaign performance trends
SELECT campaign_name, roas_tier, budget_utilization_pct, dbt_valid_from
FROM snapshots.snap_campaign_performance  
WHERE campaign_id = 'campaign-123'
ORDER BY dbt_valid_from;

-- Visitor lifecycle progression  
SELECT visitor_frequency_segment, visitor_value_segment, lifecycle_stage, dbt_valid_from
FROM snapshots.snap_visitor_segments
WHERE visitor_id = 'visitor-456'
ORDER BY dbt_valid_from;
```

### Cleanup
```sh
make clean     # Remove containers and generated files
```

### 😎 [Follow me on Linkedin](https://www.linkedin.com/in/alejandro-aboy/)
- Get tips, learnings and tricks for your Data career!

### 📩 [Subscribe to The Pipe & The Line](https://thepipeandtheline.substack.com/?utm_source=github&utm_medium=referral)
- Join the Substack newsletter to get similar content to this one and more to improve your Data career!
