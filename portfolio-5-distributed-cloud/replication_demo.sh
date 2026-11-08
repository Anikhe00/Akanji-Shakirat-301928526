#!/usr/bin/env bash
# Portfolio 5: PostgreSQL primary-replica replication, replication lag, and failover.
# Run from the repo root:
#   bash portfolio-5-distributed-cloud/replication_demo.sh 2>&1 | tee portfolio-5-distributed-cloud/replication_output.txt
# Every run starts from a clean slate (it deletes and recreates both containers).

cd "$(dirname "$0")"

COMPOSE=${COMPOSE:-"docker compose -f docker-compose.replication.yml --env-file ../.env"}
P=${P:-"docker exec -i carebridge-pg-primary psql -U carebridge -d carebridge"}
R=${R:-"docker exec -i carebridge-pg-replica psql -U carebridge -d carebridge"}
STOP_PRIMARY=${STOP_PRIMARY:-"docker stop carebridge-pg-primary"}
SCHEMA=${SCHEMA:-"../portfolio-1-database-design/schema.sql"}

section() { echo; echo "=============================================================="; echo "$1"; echo "=============================================================="; }
stock() { $1 -At -c "SELECT '$2: stock of the demo drug = ' || stock_quantity FROM drugs WHERE name = 'Replication Demo Drug'"; }

if [ -z "$SKIP_COMPOSE" ]; then
  section "SETUP: starting a fresh primary and replica"
  $COMPOSE down -v >/dev/null 2>&1
  $COMPOSE up -d
  echo "Waiting for the replica to start streaming from the primary..."
  for i in $(seq 1 90); do
    N=$($P -At -c "SELECT count(*) FROM pg_stat_replication WHERE state = 'streaming'" 2>/dev/null | tr -d '[:space:]')
    IN=$($R -At -c "SELECT pg_is_in_recovery()" 2>/dev/null | tr -d '[:space:]')
    [ "$N" = "1" ] && [ "$IN" = "t" ] && break
    sleep 2
  done
  echo "Replicas streaming from the primary: $N"
fi

section "1. Which server is which?"
$P -At -c "SELECT 'PRIMARY: pg_is_in_recovery = ' || pg_is_in_recovery()"
$R -At -c "SELECT 'REPLICA: pg_is_in_recovery = ' || pg_is_in_recovery() || '   (true means it is a standby that copies the primary)'"

section "2. Load the Portfolio 1 schema on the PRIMARY only, then read it on the REPLICA"
$P -q -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;" >/dev/null 2>&1
$P -q < "$SCHEMA" >/dev/null 2>&1
$P -q -c "INSERT INTO drugs (name, strength, unit_price, stock_quantity) VALUES ('Replication Demo Drug', '10mg', 500.00, 10);"
sleep 2
$P -At -c "SELECT 'PRIMARY: tables created = ' || count(*) FROM information_schema.tables WHERE table_schema = 'public'"
$R -At -c "SELECT 'REPLICA: tables it received = ' || count(*) FROM information_schema.tables WHERE table_schema = 'public'"
stock "$R" "REPLICA"

section "3. The replica is read-only: a write on the REPLICA is refused"
$R -c "UPDATE drugs SET stock_quantity = 0 WHERE name = 'Replication Demo Drug';" 2>&1

section "4. Replication lag: pause the replica, change the primary, compare"
$R -At -c "SELECT pg_wal_replay_pause()" >/dev/null
$P -q -c "UPDATE drugs SET stock_quantity = 8 WHERE name = 'Replication Demo Drug';"
sleep 3
stock "$P" "PRIMARY"
stock "$R" "REPLICA (paused, stale)"
$P -At -c "SELECT 'PRIMARY says the replica is ' || pg_wal_lsn_diff(sent_lsn, replay_lsn) || ' bytes behind' FROM pg_stat_replication"
echo "Now resume the replica..."
$R -At -c "SELECT pg_wal_replay_resume()" >/dev/null
sleep 2
stock "$R" "REPLICA (resumed)"
$P -At -c "SELECT 'PRIMARY says the replica is ' || pg_wal_lsn_diff(sent_lsn, replay_lsn) || ' bytes behind' FROM pg_stat_replication"

section "5. Failover: the primary dies, the replica is promoted"
$STOP_PRIMARY >/dev/null 2>&1
echo "The primary has been stopped."
sleep 2
$R -At -c "SELECT pg_promote()" | sed 's/^t$/Promotion requested: true/'
sleep 3
$R -At -c "SELECT 'Old REPLICA now: pg_is_in_recovery = ' || pg_is_in_recovery() || '   (false means it is a primary and accepts writes)'"
$R -q -c "UPDATE drugs SET stock_quantity = 5 WHERE name = 'Replication Demo Drug';"
stock "$R" "NEW PRIMARY (after write)"

echo
echo "Done. The old primary is stopped and was NOT rebuilt as a replica (see the README limitations)."
