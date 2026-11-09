-- Portfolio 1: constraint tests.
-- Run AFTER the schema and the sample data are loaded. Every statement below
-- is meant to FAIL. Each error message proves that a rule from the schema works.
-- Nothing is changed, because a rejected statement writes nothing.
--
-- Run from the repository root:
--   docker exec -i carebridge-pg psql -U carebridge -d carebridge < portfolio-1-database-design/Akanji_Shakirat_301928526_P1_ConstraintTests.sql

\set ON_ERROR_STOP off
\set ECHO queries

\echo
\echo '=== Test 1: UNIQUE (doctor_id, scheduled_start): book Dr Okafor twice at 09:00 ==='
INSERT INTO appointments (patient_id, doctor_id, scheduled_start, scheduled_end)
VALUES (2, 1, '2026-10-20 09:00+01', '2026-10-20 09:30+01');

\echo
\echo '=== Test 2: CHECK on patients.sex: a value that is not female, male or other ==='
INSERT INTO patients (first_name, last_name, date_of_birth, sex)
VALUES ('Test', 'Patient', '1990-01-01', 'unknown');

\echo
\echo '=== Test 3: CHECK on drugs.stock_quantity: stock cannot go below 0 ==='
UPDATE drugs SET stock_quantity = -5 WHERE drug_id = 1;

\echo
\echo '=== Test 4: FOREIGN KEY: a payment for a visit that does not exist ==='
INSERT INTO payments (visit_id, amount, method) VALUES (999, 5000, 'cash');

\echo
\echo '=== Test 5: FOREIGN KEY: delete a patient who still has appointments ==='
DELETE FROM patients WHERE patient_id = 1;
