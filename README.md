# 🚀 Portable Data Stack with dbt and DuckDB! 

This repo demonstrates a portable data stack with synthetic data processing using DuckDB and dbt transformations.

A portable data-stack with:
- Synthetic JSON data processing
- DuckDB for OLAP storage
- dbt for transformations
- Sequential Docker Compose workflow

## 🙋🏻‍♂️ Pre-requisites
- Docker Desktop
- DuckDB to run local queries (optional)
- Copy .env.example to .env if you want to test locally

## 📝 Steps

### Run Complete Pipeline
```sh
make build    # Build all containers
make run      # Run database → dbt interactive command line
```

### Run Services Separately
```sh
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
dbt run --select staging
dbt run --select intermediate  
dbt run --select marts

# Run specific models:
dbt run --select stg_campaigns
dbt run --select campaign_performance

# Generate documentation:
dbt docs generate
```

### Query Data
```sh
make duckdb    # Open DuckDB CLI to query data
```

### Cleanup
```sh
make clean     # Remove containers and generated files
```

### Example DuckDB queries:
```sql
SHOW TABLES; 
SELECT * FROM campaigns LIMIT 5;
SELECT * FROM sessions LIMIT 5;
```

### 😎 [Follow me on Linkedin](https://www.linkedin.com/in/alejandro-aboy/)
- Get tips, learnings and tricks for your Data career!

### 📩 [Subscribe to The Pipe & The Line](https://thepipeandtheline.substack.com/?utm_source=github&utm_medium=referral)
- Join the Substack newsletter to get similar content to this one and more to improve your Data career!
