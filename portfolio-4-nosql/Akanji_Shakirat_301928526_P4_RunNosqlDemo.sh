#!/usr/bin/env bash
# Portfolio 4: export patient documents from PostgreSQL, import them into MongoDB, run queries.
# Run from the repo root:
#   bash portfolio-4-nosql/Akanji_Shakirat_301928526_P4_RunNosqlDemo.sh 2>&1 | tee portfolio-4-nosql/Akanji_Shakirat_301928526_P4_NosqlOutput.txt
set -e
cd "$(dirname "$0")"

echo "Step 1: exporting patient documents from PostgreSQL (can take up to a minute)..."
docker exec -i carebridge-pg psql -U carebridge -d carebridge -At < Akanji_Shakirat_301928526_P4_ExportPatients.sql > Akanji_Shakirat_301928526_P4_Patients.jsonl
echo "Exported $(wc -l < Akanji_Shakirat_301928526_P4_Patients.jsonl | tr -d ' ') documents to Akanji_Shakirat_301928526_P4_Patients.jsonl"

echo
echo "Step 2: importing into MongoDB..."
docker exec -i carebridge-mongo mongoimport --db carebridge --collection patients --drop < Akanji_Shakirat_301928526_P4_Patients.jsonl

echo
echo "Step 3: running the queries..."
docker cp Akanji_Shakirat_301928526_P4_Queries.js carebridge-mongo:/tmp/Akanji_Shakirat_301928526_P4_Queries.js
docker exec carebridge-mongo mongosh carebridge --quiet --file /tmp/Akanji_Shakirat_301928526_P4_Queries.js
