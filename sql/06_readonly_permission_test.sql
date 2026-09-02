\set ON_ERROR_STOP on

SELECT
    current_database(),
    current_user;


SELECT
    has_database_privilege(
        current_user,
        'factory_copilot_db',
        'CONNECT'
    ) AS can_connect,

    has_schema_privilege(
        current_user,
        'app',
        'USAGE'
    ) AS can_use_schema,

    has_schema_privilege(
        current_user,
        'app',
        'CREATE'
    ) AS can_create_in_schema;

SELECT
    tablename,
    
    has_table_privilege(
        current_user,
        schemaname || '.' || tablename,
        'SELECT'
    ) AS can_select,

    has_table_privilege(
        current_user,
        schemaname || '.' || tablename,
        'INSERT'
    ) AS can_insert,

    has_table_privilege(
        current_user,
        schemaname || '.' || tablename,
        'UPDATE'
    ) AS can_update,

    has_table_privilege(
        current_user,
        schemaname || '.' || tablename,
        'DELETE'
    ) AS can_delete,

    has_table_privilege(
        current_user,
        schemaname || '.' || tablename,
        'TRUNCATE'
    ) AS can_truncate
FROM pg_tables
WHERE schemaname = 'app'
ORDER BY tablename;

SELECT COUNT(*) AS readable_order_rows
FROM app.orders;


\echo === Negative test: INSERT must fail ===
\set ON_ERROR_STOP off

BEGIN;

SAVEPOINT test_insert;

INSERT INTO app.production_log (
    production_date,
    stage,
    pieces_completed
)
VALUES (
    DATE '2999-01-01',
    'KNITTING',
    0
);

ROLLBACK TO SAVEPOINT test_insert;

ROLLBACK;

\set ON_ERROR_STOP on


\echo === Negative test: UPDATE must fail ===
\set ON_ERROR_STOP off

BEGIN;

SAVEPOINT test_update;

UPDATE app.orders
SET pieces = pieces
WHERE order_id = 'ORD-001';

ROLLBACK TO SAVEPOINT test_update;

ROLLBACK;

\set ON_ERROR_STOP on


\echo === Negative test: DELETE must fail ===
\set ON_ERROR_STOP off

BEGIN;

SAVEPOINT test_delete;

DELETE FROM app.orders
WHERE order_id = 'ORD-001';

ROLLBACK TO SAVEPOINT test_delete;

ROLLBACK;

\set ON_ERROR_STOP on


\echo === Negative test: TRUNCATE must fail ===
\set ON_ERROR_STOP off

BEGIN;

SAVEPOINT test_truncate;

TRUNCATE TABLE app.production_log;

ROLLBACK TO SAVEPOINT test_truncate;

ROLLBACK;

\set ON_ERROR_STOP on


\echo === Negative test: CREATE TABLE must fail ===
\set ON_ERROR_STOP off

BEGIN;

SAVEPOINT test_create;

CREATE TABLE app.agent_should_not_create (
    id integer
);

ROLLBACK TO SAVEPOINT test_create;

ROLLBACK;

\set ON_ERROR_STOP on


\echo === Negative test: DROP TABLE must fail ===
\set ON_ERROR_STOP off

BEGIN;

SAVEPOINT test_drop;

DROP TABLE app.orders;

ROLLBACK TO SAVEPOINT test_drop;

ROLLBACK;

\set ON_ERROR_STOP on


\echo === Final integrity check ===

SELECT 'orders' AS table_name, COUNT(*) AS row_count
FROM app.orders

UNION ALL

SELECT 'production_log', COUNT(*)
FROM app.production_log

UNION ALL

SELECT 'workshops', COUNT(*)
FROM app.workshops

ORDER BY table_name;