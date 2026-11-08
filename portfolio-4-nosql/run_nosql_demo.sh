#!/usr/bin/env bash
# Portfolio 4: export patient documents from PostgreSQL, import them into MongoDB, run queries.
# Run from the repo root:
#   bash portfolio-4-nosql/run_nosql_demo.sh 2>&1 | tee portfolio-4-nosql/nosql_output.txt
set -e
cd "$(dirname "$0")"

echo "Step 1: exporting patient documents from PostgreSQL (can take up to a minute)..."
docker exec -i carebridge-pg psql -U carebridge -d carebridge -At < export_patients.sql > patients.jsonl
echo "Exported $(wc -l < patients.jsonl | tr -d ' ') documents to patients.jsonl"

echo
echo "Step 2: importing into MongoDB..."
docker exec -i carebridge-mongo mongoimport --db carebridge --collection patients --drop < patients.jsonl

echo
echo "Step 3: running the queries..."
docker cp queries.js carebridge-mongo:/tmp/queries.js
docker exec carebridge-mongo mongosh carebridge --quiet --file /tmp/queries.js
