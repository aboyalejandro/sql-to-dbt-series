# 📊 Test Categories & Execution

### Generic Tests (Reusable)

Your custom tests in /tests/generic/: `dbt test --select test_type:generic`

- uuid_format - Applied to ID columns via YAML
- positive_numeric - Applied to budget/spend columns
- date_range - Applied to date columns
- percentage_bounds - Applied to CTR/bounce rate columns

### Singular Tests (Business Logic)

Your custom tests in /tests/singular/: `dbt test --select test_type:singular`

- test_campaign_date_logic.sql - Validates start_date ≤ end_date
- test_session_temporal_integrity.sql - Validates session timing
- test_marketing_metrics_calculation.sql - Validates CTR calculations
- test_referential_integrity.sql - Cross-table foreign key checks

### dbt-expectations Tests (Great Expectations)

Advanced tests from the dbt-expectations package: `dbt test --select package:metaplane_dbt_expectations`

- Column-level: regex matching, value ranges, data types
- Table-level: row counts, aggregation comparisons

### Data Contract Tests

Built into model compilation: `dbt run --select staging  # Contract validation happens during model creation`

- **Schema enforcement** (column names, data types)
- **Basic constraints** (not_null, unique, primary_key)
- **Business logic constraints** (check constraints with custom SQL)
- **Named constraints** for better error messages
- **Fails fast** if contract violations occur

**Advanced constraint examples:**
- `budget > 0` and `budget >= 1000` (minimum budget threshold)
- `roi >= -1` (reasonable ROI range)
- `ctr >= 0 AND ctr <= 1` (valid percentage range)
- `conversion_value >= 0` (non-negative financial values)

## ⚡ Test Execution Flow

During dbt build:

1. Contract Validation → Checks schema compliance during model compilation
2. Model Creation → Creates staging views with enforced contracts
3. Test Execution → Runs all configured tests (generic + singular + expectations)
4. Failure Handling → Stops pipeline if critical tests fail

Test Selection Examples:

### Run specific test types
dbt test --select test_type:generic
dbt test --select test_type:singular
dbt test --select test_name:uuid_format

### Run tests for specific models
dbt test --select stg_campaigns
dbt test --select staging

### Run tests with specific tags
dbt test --select tag:data_quality

🎯 When Tests Execute:

| Command   | Contract Check | Generic Tests | Singular Tests | dbt-expectations |
|-----------|----------------|---------------|----------------|------------------|
| dbt run   | ✅              | ❌             | ❌              | ❌                |
| dbt test  | ❌              | ✅             | ✅              | ✅                |
| dbt build | ✅              | ✅             | ✅              | ✅                |
| make run  | ✅              | ✅             | ✅              | ✅                |

Your comprehensive test suite provides 4-layer protection:
1. **Data contracts** prevent bad data from entering models with real-time constraint validation
2. **Custom generic tests** provide reusable validation logic across models  
3. **Singular tests** validate complex business logic and cross-table integrity
4. **dbt-expectations** provide advanced statistical and pattern validation

**Constraint vs Test Comparison:**

| Feature | Constraints | Tests |
|---------|-------------|-------|
| **Execution** | During model creation | After model creation |
| **Performance** | Database-level (fast) | Query-based (slower) |
| **Failure** | Stops model creation | Logs warnings/errors |
| **Use Case** | Data integrity rules | Business logic validation |
| **Examples** | `budget > 0`, `not_null` | Custom calculations, referential integrity |