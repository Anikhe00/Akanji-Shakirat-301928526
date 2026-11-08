#!/usr/bin/env bash
# Portfolio 3, Demos 2 to 4: two database sessions (A and B) running at the same time.
#
# Run from the repo root:
#   bash portfolio-3-transactions-concurrency/demo_concurrency.sh 2>&1 | tee portfolio-3-transactions-concurrency/demo_concurrency_output.txt
#
# Each demo starts session A and session B together. Every line printed starts with the
# time (HH:MM:SS.mmm), and the two sessions' lines are merged in time order, so you can
# read the output as a timeline of who did what, and when.

PSQL=${PSQL:-"docker exec -i carebridge-pg psql -U carebridge -d carebridge"}
T=$(mktemp -d)

reset_drug() {
  $PSQL -q >/dev/null <<'SQL'
DELETE FROM prescriptions WHERE drug_id IN (SELECT drug_id FROM drugs WHERE name = 'Demo Artesunate');
DELETE FROM drugs WHERE name = 'Demo Artesunate';
INSERT INTO drugs (name, strength, unit_price, stock_quantity) VALUES ('Demo Artesunate', '60mg', 1800.00, 10);
SQL
}

banner() {
  echo
  echo "=============================================================="
  echo "$1"
  echo "=============================================================="
}

# Runs $T/a.sql (session A) in the background and $T/b.sql (session B) in the foreground,
# then prints both sessions' lines merged in time order.
run_pair() {
  $PSQL -q -At < "$T/a.sql" > "$T/a.out" 2>&1 &
  PID=$!
  $PSQL -q -At < "$T/b.sql" > "$T/b.out" 2>&1
  wait $PID
  cat "$T/a.out" "$T/b.out" | sed 's/^NOTICE:  //' | grep -v '^$' | sort
}

stock_line() {
  $PSQL -At -c "SELECT 'FINAL stock = ' || stock_quantity FROM drugs WHERE name = 'Demo Artesunate'"
}

# ---------------------------------------------------------------- Demo 2, part 1
banner "DEMO 2, PART 1: lost update (no lock). Stock is 10. A dispenses 6, B dispenses 4. Correct final stock = 0"
reset_drug
cat > "$T/a.sql" <<'SQL'
\set ts 'to_char(clock_timestamp(),''HH24:MI:SS.MS'')'
BEGIN;
SELECT stock_quantity AS cur FROM drugs WHERE name='Demo Artesunate' \gset
SELECT :ts || '  A: reads stock = ' || :cur;
SELECT pg_sleep(3) \g /dev/null
UPDATE drugs SET stock_quantity = :cur - 6 WHERE name='Demo Artesunate';
COMMIT;
SELECT :ts || '  A: COMMIT done, A wrote ' || (:cur - 6);
SQL
cat > "$T/b.sql" <<'SQL'
\set ts 'to_char(clock_timestamp(),''HH24:MI:SS.MS'')'
SELECT pg_sleep(1) \g /dev/null
BEGIN;
SELECT stock_quantity AS cur FROM drugs WHERE name='Demo Artesunate' \gset
SELECT :ts || '  B: reads stock = ' || :cur;
SELECT pg_sleep(4) \g /dev/null
UPDATE drugs SET stock_quantity = :cur - 4 WHERE name='Demo Artesunate';
COMMIT;
SELECT :ts || '  B: COMMIT done, B wrote ' || (:cur - 4);
SQL
run_pair
stock_line
echo "-> B still used its old reading of 10, so A's dispensing of 6 was overwritten and lost."

# ---------------------------------------------------------------- Demo 2, part 2
banner "DEMO 2, PART 2: the fix, SELECT ... FOR UPDATE (row lock). Same task, correct final stock = 0"
reset_drug
cat > "$T/a.sql" <<'SQL'
\set ts 'to_char(clock_timestamp(),''HH24:MI:SS.MS'')'
BEGIN;
SELECT stock_quantity AS cur FROM drugs WHERE name='Demo Artesunate' FOR UPDATE \gset
SELECT :ts || '  A: reads stock = ' || :cur || ' and LOCKS the row';
SELECT pg_sleep(3) \g /dev/null
UPDATE drugs SET stock_quantity = :cur - 6 WHERE name='Demo Artesunate';
COMMIT;
SELECT :ts || '  A: COMMIT done, A wrote ' || (:cur - 6) || ' (lock released)';
SQL
cat > "$T/b.sql" <<'SQL'
\set ts 'to_char(clock_timestamp(),''HH24:MI:SS.MS'')'
SELECT pg_sleep(1) \g /dev/null
BEGIN;
SELECT :ts || '  B: asks for the row with FOR UPDATE (it must WAIT, A holds the lock)';
SELECT stock_quantity AS cur FROM drugs WHERE name='Demo Artesunate' FOR UPDATE \gset
SELECT :ts || '  B: finally got the row, stock = ' || :cur;
UPDATE drugs SET stock_quantity = :cur - 4 WHERE name='Demo Artesunate';
COMMIT;
SELECT :ts || '  B: COMMIT done, B wrote ' || (:cur - 4);
SQL
run_pair
stock_line
echo "-> B waited for A, then saw the latest value (4), so both dispensings counted."

# ---------------------------------------------------------------- Demo 3
for LEVEL in "READ COMMITTED" "REPEATABLE READ"; do
  banner "DEMO 3: isolation level $LEVEL. A reads stock twice in one transaction; B dispenses 3 in between"
  reset_drug
  cat > "$T/a.sql" <<'SQL'
\set ts 'to_char(clock_timestamp(),''HH24:MI:SS.MS'')'
BEGIN ISOLATION LEVEL LEVELNAME;
SELECT stock_quantity AS first_read FROM drugs WHERE name='Demo Artesunate' \gset
SELECT :ts || '  A: FIRST read  = ' || :first_read;
SELECT pg_sleep(3) \g /dev/null
SELECT stock_quantity AS second_read FROM drugs WHERE name='Demo Artesunate' \gset
SELECT :ts || '  A: SECOND read = ' || :second_read;
COMMIT;
SQL
  sed -i.bak "s/LEVELNAME/$LEVEL/" "$T/a.sql"
  cat > "$T/b.sql" <<'SQL'
\set ts 'to_char(clock_timestamp(),''HH24:MI:SS.MS'')'
SELECT pg_sleep(1) \g /dev/null
UPDATE drugs SET stock_quantity = stock_quantity - 3 WHERE name='Demo Artesunate';
SELECT :ts || '  B: dispensed 3 and committed (stock is now 7 for everyone new)';
SQL
  run_pair
done
echo "-> READ COMMITTED: A's second read changed (7). REPEATABLE READ: A kept its snapshot (10)."

# ---------------------------------------------------------------- Demo 4
banner "DEMO 4: two receptionists book Doctor 1 at the same time slot (UNIQUE rule from Portfolio 1)"
$PSQL -q >/dev/null <<'SQL'
DELETE FROM appointments WHERE scheduled_start = '2030-01-01 09:00+01';
SQL
cat > "$T/a.sql" <<'SQL'
\set ts 'to_char(clock_timestamp(),''HH24:MI:SS.MS'')'
BEGIN;
INSERT INTO appointments (patient_id, doctor_id, scheduled_start, scheduled_end, reason)
VALUES (1, 1, '2030-01-01 09:00+01', '2030-01-01 09:30+01', 'Session A');
SELECT :ts || '  A: inserted the booking (not committed yet)';
SELECT pg_sleep(3) \g /dev/null
COMMIT;
SELECT :ts || '  A: COMMIT done, the booking is now permanent';
SQL
cat > "$T/b.sql" <<'SQL'
\set ts 'to_char(clock_timestamp(),''HH24:MI:SS.MS'')'
SELECT pg_sleep(1) \g /dev/null
BEGIN;
SELECT :ts || '  B: tries to insert the SAME doctor and time (it must WAIT for A)';
DO $$
BEGIN
  INSERT INTO appointments (patient_id, doctor_id, scheduled_start, scheduled_end, reason)
  VALUES (2, 1, '2030-01-01 09:00+01', '2030-01-01 09:30+01', 'Session B');
  RAISE NOTICE '% B: insert succeeded', to_char(clock_timestamp(),'HH24:MI:SS.MS');
EXCEPTION WHEN unique_violation THEN
  RAISE NOTICE '%  B: REJECTED -> %', to_char(clock_timestamp(),'HH24:MI:SS.MS'), SQLERRM;
END $$;
ROLLBACK;
SQL
run_pair
$PSQL -At -c "SELECT 'FINAL bookings for Doctor 1 at that time = ' || count(*) FROM appointments WHERE doctor_id = 1 AND scheduled_start = '2030-01-01 09:00+01'"
echo "-> B waited, then the database refused the double booking. Exactly one booking exists."
$PSQL -q >/dev/null <<'SQL'
DELETE FROM appointments WHERE scheduled_start = '2030-01-01 09:00+01';
SQL

rm -rf "$T"
echo
echo "All demos finished."
