# Factory Copilot Database

## Overview

This repository contains a reproducible local PostgreSQL prototype for the Factory Copilot project. It creates the database roles, schema, tables and permissions; imports the current CSV data snapshot; and verifies both administrator and read-only access.

The three CSV files are current-stage learning and acceptance-test data. They are not permanent production files and may later be replaced, updated or supplemented with additional tables.

The database has been built and validated locally. It has not yet been deployed as a shared team database or connected to the project backend.

## Basic information

- Database management system: PostgreSQL
- SQL dialect: PostgreSQL
- Database: `factory_copilot_db`
- Schema: `app`
- PostgreSQL system administrator: `postgres`
- Project administrator: `factory_admin`
- Ordinary login user: `factory_user`
- Shared read-only permission role: `factory_reader`
- AI Agent login user: `factory_agent`

`factory_reader` is a `NOLOGIN` role. It stores shared read-only permissions. Both `factory_user` and `factory_agent` are login roles that inherit these permissions.

## Project structure

```text
SQLdb/
|-- data/
|   |-- orders.csv
|   |-- production_log.csv
|   `-- workshops.csv
|-- docs/
|   `-- field_mapping.md
|-- evidence/
|   `-- README.md
|-- sql/
|   |-- 01_roles_and_database.sql
|   |-- 02_schema_tables_permissions.sql
|   |-- 03_import.sql
|   |-- 04_validate.sql
|   |-- 05_admin_permission_test.sql
|   `-- 06_readonly_permission_test.sql
`-- README.md
```

## Prerequisites and command-line setup

These instructions use Windows PowerShell. Install PostgreSQL with the following components:

- PostgreSQL Database Server
- PostgreSQL command-line tools, including `psql`

During installation:

- keep or record the PostgreSQL port; this project uses the default port `5432`;
- create a local password for the PostgreSQL administrator `postgres`;
- do not record any database password in this repository.

Add the PostgreSQL `bin` directory to the Windows PATH environment variable. A typical path is:

```text
C:\Program Files\PostgreSQL\{version}\bin
```

The actual installation path may be different.

To add the directory to PATH on Windows:

1. Search for `Edit environment variables`.
2. Open `Environment Variables`.
3. Select `Path` under user variables.
4. Select `Edit`, then `New`.
5. Add the PostgreSQL `bin` directory.
6. Save the changes and reopen PowerShell.

Verify the command-line client:

```powershell
psql --version
```

Verify that the local PostgreSQL server is running:

```powershell
psql -X -h localhost -p 5432 -U postgres -d postgres -W
```

Password characters are not displayed while typing. A successful connection shows a prompt similar to:

```text
postgres=#
```

Exit `psql` with:

```text
\q
```

## Reproduce the database on another computer

Extract the project package, or download it from GitHub after the repository is available. Open PowerShell and change the working directory to the root of the extracted `SQLdb` folder:

```powershell
Set-Location "C:\path\to\SQLdb"
```

Replace the example path with the actual folder location. Run all commands below from this root directory because `03_import.sql` uses relative paths such as `data/orders.csv`.

### 1. Create the roles and database

Run `01_roles_and_database.sql` once on a fresh setup as the PostgreSQL system administrator `postgres`:

```powershell
psql -X -h localhost -p 5432 -U postgres -d postgres -W -f "sql/01_roles_and_database.sql"
```

The script creates:

- `factory_admin`: project database administrator;
- `factory_reader`: shared read-only role without login access;
- `factory_user`: ordinary login user that inherits `factory_reader`;
- `factory_agent`: AI Agent login user that inherits `factory_reader`;
- `factory_copilot_db`: project database owned by `factory_admin`.

The script asks you to create local passwords for `factory_admin`, `factory_user` and `factory_agent`. Do not store or share these passwords in the repository.

A successful setup should contain these key messages:

```text
CREATE ROLE
CREATE ROLE
CREATE ROLE
CREATE ROLE
GRANT ROLE
CREATE DATABASE
```

Password prompts for the three login roles are expected.

### 2. Create the schema, tables and permissions

Run `02_schema_tables_permissions.sql` once as `factory_admin`:

```powershell
psql -X -h localhost -p 5432 -U factory_admin -d factory_copilot_db -W -f "sql/02_schema_tables_permissions.sql"
```

This script creates the `app` schema, the three project tables, their constraints and the administrator/read-only permission structure.

A successful setup should confirm:

```text
current_database = factory_copilot_db
current_user     = factory_admin
BEGIN
CREATE SCHEMA
CREATE TABLE
CREATE TABLE
CREATE TABLE
COMMIT
```

Messages for `GRANT`, `REVOKE` and `ALTER DEFAULT PRIVILEGES` are also expected.

### 3. Import the CSV data

Run `03_import.sql` as `factory_admin` from the project root:

```powershell
psql -X -h localhost -p 5432 -U factory_admin -d factory_copilot_db -W -f "sql/03_import.sql"
```

The script replaces the current database snapshot with the three CSV files in `data/`. It does not append the CSV rows to the existing snapshot. If any import fails, the transaction is rolled back and the previous complete snapshot is preserved.

A successful import should contain:

```text
current_database = factory_copilot_db
current_user     = factory_admin
BEGIN
TRUNCATE TABLE
COPY 120
COPY 360
COPY 8
COMMIT
```

### 4. Validate the imported database

Run `04_validate.sql` as `factory_admin`:

```powershell
psql -X -h localhost -p 5432 -U factory_admin -d factory_copilot_db -W -f "sql/04_validate.sql"
```

The database name should be `factory_copilot_db`, and the current user should be `factory_admin`.

Expected `orders` results:

```text
row_count               = 120
unique_order_count      = 120
total_pieces            = 93500
missing_completed_dates = 34
missing_days_late       = 34
```

Expected `production_log` results:

```text
row_count        = 360
date_stage_pairs = 360
pieces_completed = 231595
```

Expected `workshops` results:

```text
row_count             = 8
distinct_workshop_ids = 8
total_daily_capacity  = 1600
active_workshops      = 7
missing_max_batch     = 7
```

Expected ownership:

```text
schemaname | tablename      | tableowner
-----------+----------------+--------------
app        | orders         | factory_admin
app        | production_log | factory_admin
app        | workshops      | factory_admin
```

Step 4 passes when all values match and all three tables are owned by `factory_admin`.

### 5. Test administrator permissions

Run `05_admin_permission_test.sql` as `factory_admin`:

```powershell
psql -X -h localhost -p 5432 -U factory_admin -d factory_copilot_db -W -f "sql/05_admin_permission_test.sql"
```

Expected identity and schema permissions:

```text
current_database     = factory_copilot_db
current_user         = factory_admin
can_connect          = t
can_use_schema       = t
can_create_in_schema = t
```

All three tables should return `t` for every tested permission:

```text
tablename      | select | insert | update | delete | truncate
---------------+--------+--------+--------+--------+---------
orders         | t      | t      | t      | t      | t
production_log | t      | t      | t      | t      | t
workshops      | t      | t      | t      | t      | t
```

The CRUD test should contain these successful results:

```text
CREATE TABLE
INSERT 0 1
probe_id = 1, note = original value
UPDATE 1
probe_id = 1, note = updated value
DELETE 1
rows_after_delete = 0
INSERT 0 1
TRUNCATE TABLE
rows_after_truncate = 0
DROP TABLE
ROLLBACK
probe_table_removed = t
```

`ROLLBACK` is expected. The test uses a disposable probe table and does not change the three project tables. Step 5 passes when all administrator operations succeed and `probe_table_removed` is `t`.

### 6. Test read-only permissions

Run `06_readonly_permission_test.sql` as `factory_agent`:

```powershell
psql -X -h localhost -p 5432 -U factory_agent -d factory_copilot_db -W -f "sql/06_readonly_permission_test.sql"
```

Expected identity and schema permissions:

```text
current_database     = factory_copilot_db
current_user         = factory_agent
can_connect          = t
can_use_schema       = t
can_create_in_schema = f
```

All three tables should be readable but not writable:

```text
tablename      | select | insert | update | delete | truncate
---------------+--------+--------+--------+--------+---------
orders         | t      | f      | f      | f      | f
production_log | t      | f      | f      | f      | f
workshops      | t      | f      | f      | f      | f
```

The positive read test should return:

```text
readable_order_rows = 120
```

The following errors are expected and prove that the Agent is read-only:

```text
INSERT:       permission denied for table production_log
UPDATE:       permission denied for table orders
DELETE:       permission denied for table orders
TRUNCATE:     permission denied for table production_log
CREATE TABLE: permission denied for schema app
DROP TABLE:   must be owner of table orders
```

The file name, line number and output language may vary. The permission error itself is the important result.

The final integrity check should return:

```text
table_name     | row_count
---------------+----------
orders         | 120
production_log | 360
workshops      | 8
```

Step 6 passes when `factory_agent` can read all three tables, all six dangerous operations are rejected and the final row counts remain unchanged.

## Rerunning the SQL files

- `01_roles_and_database.sql`: initial setup only; do not rerun it when the roles or database already exist.
- `02_schema_tables_permissions.sql`: initial construction only; do not rerun it when the `app` schema and tables already exist.
- `03_import.sql`: may be rerun to replace the current database snapshot with the CSV files in `data/`.
- `04_validate.sql`: safe to rerun.
- `05_admin_permission_test.sql`: safe to rerun.
- `06_readonly_permission_test.sql`: safe to rerun.

Do not delete existing roles, databases, schemas or tables only to resolve an `already exists` error without first confirming that the correct environment is being used.

## Documentation and acceptance evidence

The current field mapping is available in [docs/field_mapping.md](docs/field_mapping.md).

Additional database documentation should be stored in `docs/`. Acceptance outputs and supporting materials should be stored in `evidence/`. The teammate responsible for documentation and evidence can organise these files and add an evidence index.

The final materials should cover:

- field and PostgreSQL data-type mappings;
- table and field descriptions;
- role attributes and permission boundaries;
- database and import validation results;
- administrator permission results;
- Agent read-only permission results.

Do not include passwords in documentation, terminal output, screenshots or evidence files.

## Troubleshooting

- `psql is not recognized`: add the PostgreSQL `bin` directory to PATH and reopen PowerShell.
- `password authentication failed`: confirm the login role and enter the corresponding locally configured password.
- `data/orders.csv: No such file or directory`: run the import command from the project root.
- `role already exists` or `database already exists`: Step 1 has already been run; do not delete existing objects without confirming the target environment.
- Red underlines in a graphical SQL editor do not necessarily indicate invalid SQL when the file contains `psql` backslash commands.

## Security notes

- Never commit passwords or `.env` files.
- Do not send database passwords in screenshots or chat messages.
- Use `factory_admin` only for database maintenance.
- Use `factory_agent` for AI read-only access.
- The current database is a local prototype, not a shared production server.
