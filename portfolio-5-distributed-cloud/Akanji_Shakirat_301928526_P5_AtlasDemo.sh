#!/usr/bin/env bash
# Portfolio 5: load the CareBridge patient documents into MongoDB Atlas and check the replica set.
# Run from the repo root:
#   bash portfolio-5-distributed-cloud/Akanji_Shakirat_301928526_P5_AtlasDemo.sh 2>&1 | tee portfolio-5-distributed-cloud/Akanji_Shakirat_301928526_P5_AtlasOutput.txt
# It asks for your Atlas connection string (hidden while you paste it). The string is never saved to a file.

cd "$(dirname "$0")"

if [ -z "$ATLAS_URI" ]; then
  read -r -s -p "Paste your Atlas connection string (it stays hidden), then press Enter: " ATLAS_URI
  echo
fi
export ATLAS_URI

if [ ! -f ../portfolio-4-nosql/Akanji_Shakirat_301928526_P4_Patients.jsonl ]; then
  echo "Cannot find portfolio-4-nosql/Akanji_Shakirat_301928526_P4_Patients.jsonl. Run the Portfolio 4 demo first."
  exit 1
fi

echo
echo "Step 1: importing 200 patient documents into Atlas..."
docker exec -i -e ATLAS_URI carebridge-mongo bash -c 'mongoimport --uri "$ATLAS_URI" --db carebridge --collection patients --drop' < ../portfolio-4-nosql/Akanji_Shakirat_301928526_P4_Patients.jsonl

echo
echo "Step 2: running the replica set checks on Atlas..."
docker cp Akanji_Shakirat_301928526_P5_AtlasChecks.js carebridge-mongo:/tmp/Akanji_Shakirat_301928526_P5_AtlasChecks.js
docker exec -e ATLAS_URI carebridge-mongo bash -c 'mongosh "$ATLAS_URI" --quiet --file /tmp/Akanji_Shakirat_301928526_P5_AtlasChecks.js'
