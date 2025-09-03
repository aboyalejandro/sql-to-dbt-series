import duckdb
import os
import pandas as pd
import json
import logging
from pathlib import Path

# Set up logging
logging.basicConfig(level=logging.INFO)

# Define paths
SYNTHETIC_DATA_PATH = "/synthetic_data"
DUCKDB_FILE = os.environ.get("DUCKDB_PATH", "/database/sql_to_dbt_guide.duckdb")

# Ensure parent directory exists
os.makedirs(os.path.dirname(DUCKDB_FILE), exist_ok=True)

# Connect to DuckDB (creates file if it doesn't exist)
conn = duckdb.connect(database=DUCKDB_FILE)
logging.info(f"Connected to DuckDB at: {DUCKDB_FILE}")

# List of JSON files to load
json_files = ["campaigns.json", "ads.json", "sessions.json", "conversions.json", "journey_events.json"]

# Load each JSON file into DuckDB
for json_file in json_files:
    file_path = os.path.join(SYNTHETIC_DATA_PATH, json_file)
    table_name = json_file.replace('.json', '')
    
    if os.path.exists(file_path):
        logging.info(f"Loading {json_file} into table {table_name}")
        
        # Read JSON file
        with open(file_path, 'r') as f:
            data = json.load(f)
        
        # Convert to DataFrame
        df = pd.DataFrame(data)
        
        # Create table in DuckDB
        conn.execute(f"CREATE OR REPLACE TABLE {table_name} AS SELECT * FROM df")
        
        # Verify table creation
        count = conn.execute(f"SELECT COUNT(*) FROM {table_name}").fetchone()[0]
        logging.info(f"Created table {table_name} with {count} records")
    else:
        logging.warning(f"File not found: {file_path}")

# Verify tables were created
for json_file in json_files:
    table_name = json_file.replace('.json', '')
    try:
        count = conn.execute(f"SELECT COUNT(*) FROM {table_name}").fetchone()[0]
        logging.info(f"Table {table_name} verified with {count} records")
    except Exception as e:
        logging.error(f"Error verifying {table_name}: {e}")

conn.close()
logging.info(f"DuckDB file created at: {DUCKDB_FILE}")
