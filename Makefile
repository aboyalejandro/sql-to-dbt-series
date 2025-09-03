# Check if docker-compose is available, otherwise use docker compose
DOCKER_COMPOSE := $(shell command -v docker-compose 2> /dev/null || echo "docker compose")

.PHONY: build run database dbt duckdb clean stop

# Build all containers
build:
	$(DOCKER_COMPOSE) build

# Run complete pipeline (database → dbt)
run:
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