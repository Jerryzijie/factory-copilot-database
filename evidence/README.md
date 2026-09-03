# Acceptance Evidence

This folder is reserved for non-secret acceptance evidence prepared by the team.

## Evidence index

| File | Script | Acceptance coverage | Verified result |
|---|---|---|---|
| [`04_validate.txt`](04_validate.txt) | `sql/04_validate.sql` | Database creation, CSV import, field identifiers, totals and ownership | 120 orders, 360 production rows, 8 workshops; all tables owned by `factory_admin` |
| [`05_admin_permission_test.txt`](05_admin_permission_test.txt) | `sql/05_admin_permission_test.sql` | Administrator account and privileges | Connect, schema use/create, table CRUD, truncate and disposable-table create/drop all succeeded |
| [`06_readonly_permission_test.txt`](06_readonly_permission_test.txt) | `sql/06_readonly_permission_test.sql` | Agent read-only role | SELECT succeeded; INSERT, UPDATE, DELETE, TRUNCATE, CREATE and DROP were denied; final row counts were unchanged |

These outputs were generated on 3 September 2026 from a clean local reproduction of the repository scripts. Password prompts did not echo passwords, and the stored files have been checked for exposed credentials.

## Acceptance-criterion mapping

1. **Database, import and mapping:** `04_validate.txt` confirms the database identity, imported row counts, uniqueness, totals and table ownership. Field and PostgreSQL type mappings are documented in [`../docs/field_mapping.md`](../docs/field_mapping.md).
2. **Administrator and Agent roles:** `05_admin_permission_test.txt` proves administrator capabilities. `06_readonly_permission_test.txt` proves that `factory_agent` can read but cannot perform dangerous write or structure operations.
3. **Administrator and ordinary-user boundary:** [`../docs/database_guide.md`](../docs/database_guide.md) records the agreed boundary. `factory_admin` has full maintenance permissions, while `factory_user` inherits the shared read-only `factory_reader` role.

## Interpreting expected errors

The `permission denied` and `must be owner` messages in `06_readonly_permission_test.txt` are expected successful test outcomes. They demonstrate that the Agent cannot modify data or database structures. The final integrity query confirms that these rejected attempts did not alter the three project tables.

## Additional evidence guidance

Suggested evidence:

- database, schema and table creation results;
- CSV import and validation results from `04_validate.sql`;
- administrator permission results from `05_admin_permission_test.sql`;
- Agent read-only permission results from `06_readonly_permission_test.sql`;
- an evidence index that maps each file to the corresponding acceptance criterion.

Terminal outputs may be stored as text files, and screenshots may be included when useful. Do not include passwords, connection secrets or private environment files.
