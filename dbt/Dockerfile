# Use the official dbt Docker image as a parent image
FROM python:3.10-slim

# Set the working directory to /app
WORKDIR /app

# Copy dbt path
COPY . ./dbt/

# Export ENV vars
ENV INPUT_FILES_PATH=${INPUT_FILES_PATH}
ENV DUCKDB_PATH=${DUCKDB_PATH}
ENV PYTHONDONTWRITEBYTECODE=1 

# Set the working directory to /dbt
WORKDIR /app/dbt

# Install system dependencies
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Install dependencies
RUN pip install --upgrade pip
RUN pip install dbt-duckdb
