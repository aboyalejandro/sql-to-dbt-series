# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Avoid __pycache__
ENV PYTHONDONTWRITEBYTECODE=1

# Install required packages
RUN pip install --no-cache-dir duckdb pandas

# Copy database processing script
COPY sources.py .

# Create output directory
RUN mkdir -p /database

# Set environment variable for DuckDB path
ENV DUCKDB_PATH="/database/sql_to_dbt_guide.duckdb"

# Command to run the script
CMD ["python", "sources.py"]