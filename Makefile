# Check if docker-compose is available, otherwise use docker compose
DOCKER_COMPOSE := $(shell command -v docker-compose 2> /dev/null || echo "docker compose")

.PHONY: extract build run database dbt duckdb clean stop

# Extract synthetic data from zip
extract:
	@echo "Extracting synthetic data..."
	@if [ -f synthetic_data/data.zip ]; then \
		cd synthetic_data && unzip -o data.zip && \
		echo "Data extracted successfully" && \
		rm data.zip && \
		echo "Zip file removed"; \
	else \
		echo "No data.zip found, skipping extraction"; \
	fi

# Build all containers
build:
	$(DOCKER_COMPOSE) build

# Run complete pipeline (extract → database → dbt)
run: extract
	$(DOCKER_COMPOSE) up --remove-orphans

# Run database service only
database:
	$(DOCKER_COMPOSE) up database --remove-orphans

# Run dbt service only
dbt:
	$(DOCKER_COMPOSE) run --rm dbt bash

# Open DuckDB CLI to query data
duckdb:
	@echo "Opening DuckDB CLI..."
	duckdb database/sql_to_dbt_guide.duckdb

# Stop all services
stop:
	$(DOCKER_COMPOSE) down --remove-orphans

# Clean up containers and generated files
clean:
	@echo "Removing all generated files..."
	$(DOCKER_COMPOSE) down --rmi all --volumes --remove-orphans
	rm -f database/*.duckdb
	rm -f .DS_Store