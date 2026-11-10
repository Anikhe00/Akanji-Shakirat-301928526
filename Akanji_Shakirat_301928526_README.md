# Advanced Database Portfolio: CareBridge Clinics

**Module:** MIT 8103 Advanced Database Systems
**Student:** Shakirat Akanji, MSc Information Technology
**Student number:** 301928526
**Case study:** CareBridge Clinics, a simulated group of 3 private clinics in Oyo State, Nigeria. All data is invented. No real patient data is used.

## What this project is

One database problem, worked through five times. CareBridge needs to record patients, appointments, visits, diagnoses, prescriptions, lab orders, payments and drug stock. Each portfolio takes the same case study and looks at it from a different angle: design, speed, correctness under concurrency, a NoSQL alternative, and spreading the data across several servers.

The seeded database holds 20,000 patients and about 80,000 visits.

## The five portfolios

| # | Topic | What it shows | Folder |
|---|---|---|---|
| 1 | Database design | An 11-table PostgreSQL schema with primary and foreign keys, `CHECK` and `UNIQUE` rules, and seed data | [`portfolio-1-database-design/`](portfolio-1-database-design/) |
| 2 | Query optimisation | Slow queries analysed with `EXPLAIN ANALYZE` and fixed with indexes | [`portfolio-2-query-optimisation/`](portfolio-2-query-optimisation/) |
| 3 | Transactions and concurrency | Rollback, lost update and `SELECT ... FOR UPDATE`, isolation levels, concurrent double-booking | [`portfolio-3-transactions-concurrency/`](portfolio-3-transactions-concurrency/) |
| 4 | NoSQL (MongoDB) | 200 patients remodelled as documents, eight queries, indexing, and when a document database fits | [`portfolio-4-nosql/`](portfolio-4-nosql/) |
| 5 | Distributed and cloud | PostgreSQL primary-replica replication with failover, and a 3-node MongoDB Atlas replica set; sharding and CAP discussed | [`portfolio-5-distributed-cloud/`](portfolio-5-distributed-cloud/) |

The overall write-up is in [`Akanji_Shakirat_301928526_FinalSummary.md`](Akanji_Shakirat_301928526_FinalSummary.md). Each folder has its own README (`Akanji_Shakirat_301928526_P<n>_README.md`) with how to run it, the results, limitations, an AI-use declaration and references. Screenshots are in each folder's `evidence/` folder (Portfolio 3's demos are also saved as text output).

## Repository structure

Every file is named `Akanji_Shakirat_301928526_<Portfolio>_<Name>.<ext>`: last name, first name, student number, then the portfolio (P1 to P5) and what the file is. The two root documents have no portfolio part.

**Root files**

- `Akanji_Shakirat_301928526_README.md`: this file, the overview and how to navigate.
- `Akanji_Shakirat_301928526_FinalSummary.md`: the 2 to 3 page summary of all five portfolios, with the reflection, AI-use declaration and references.
- `docker-compose.yml`: starts PostgreSQL 16 and MongoDB 7 for Portfolios 1 to 4.

**Portfolio folders**

- [`portfolio-1-database-design`](portfolio-1-database-design/): ER design, schema, sample data, constraint tests, normalisation and evidence.
- [`portfolio-2-query-optimisation`](portfolio-2-query-optimisation/): test data generator, queries, execution plans before and after indexing, and performance analysis.
- [`portfolio-3-transactions-concurrency`](portfolio-3-transactions-concurrency/): commit, rollback, lost update, isolation levels and concurrent double booking.
- [`portfolio-4-nosql`](portfolio-4-nosql/): MongoDB document model, export from PostgreSQL, eight queries and suitability.
- [`portfolio-5-distributed-cloud`](portfolio-5-distributed-cloud/): PostgreSQL replication and failover, MongoDB Atlas replica set, sharding and CAP.

Each folder contains its own README (`Akanji_Shakirat_301928526_P<n>_README.md`) that lists every file in the folder, plus its scripts, the saved text output, and an `evidence/` subfolder with screenshots. Images whose name starts with `Rendered` are rendered from the saved text output and say so on the image. All other images are terminal screenshots.

**File tree** (every file in the repository):

```text
.
├── .gitignore                                  # keeps .env and .DS_Store out of Git
├── Akanji_Shakirat_301928526_FinalSummary.md   # 2 to 3 page summary of all five portfolios
├── Akanji_Shakirat_301928526_README.md         # this file: overview and how to navigate
├── docker-compose.yml                          # PostgreSQL 16 and MongoDB 7 (Portfolios 1 to 4)
├── portfolio-1-database-design/
│   ├── Akanji_Shakirat_301928526_P1_CarebridgeDesign.dbml   # ER design source (dbdiagram.io)
│   ├── Akanji_Shakirat_301928526_P1_ConstraintTests.sql     # five statements the database must reject
│   ├── Akanji_Shakirat_301928526_P1_ERDiagram.png           # exported ER diagram
│   ├── Akanji_Shakirat_301928526_P1_Evidence.md             # index of the screenshots
│   ├── Akanji_Shakirat_301928526_P1_JoinPrescriptions.sql   # six-table join (3NF check)
│   ├── Akanji_Shakirat_301928526_P1_Normalisation.md        # worked example: 1NF, 2NF, 3NF
│   ├── Akanji_Shakirat_301928526_P1_README.md               # design, keys, constraints, normalisation, testing
│   ├── Akanji_Shakirat_301928526_P1_SampleData.sql          # small data set used to test the rules
│   ├── Akanji_Shakirat_301928526_P1_Schema.sql              # 11 tables with keys and constraints
│   └── evidence/
│       ├── Akanji_Shakirat_301928526_P1_ConstraintDeletePatientWithAppointment.png
│       ├── Akanji_Shakirat_301928526_P1_ConstraintDoubleBooking.png
│       ├── Akanji_Shakirat_301928526_P1_ConstraintNegativeDrugStock.png
│       ├── Akanji_Shakirat_301928526_P1_ConstraintPaymentForInvalidVisit.png
│       ├── Akanji_Shakirat_301928526_P1_ConstraintWrongSexValue.png
│       └── Akanji_Shakirat_301928526_P1_JoinPrescriptions.png
├── portfolio-2-query-optimisation/
│   ├── Akanji_Shakirat_301928526_P2_ExplainQueries.sql   # five queries with EXPLAIN (ANALYZE)
│   ├── Akanji_Shakirat_301928526_P2_Indexes.sql          # the four indexes added
│   ├── Akanji_Shakirat_301928526_P2_IndexSizes.txt       # disk size of the new indexes
│   ├── Akanji_Shakirat_301928526_P2_PlansAfter.txt       # execution plans after indexing
│   ├── Akanji_Shakirat_301928526_P2_PlansBefore.txt      # execution plans before indexing
│   ├── Akanji_Shakirat_301928526_P2_Queries.sql          # the same queries without EXPLAIN
│   ├── Akanji_Shakirat_301928526_P2_README.md            # method, results, performance analysis
│   ├── Akanji_Shakirat_301928526_P2_Results.txt          # query results
│   ├── Akanji_Shakirat_301928526_P2_SeedBulk.sql         # generates about 500,000 rows of test data
│   └── evidence/
│       ├── Akanji_Shakirat_301928526_P2_AfterIndex.png
│       ├── Akanji_Shakirat_301928526_P2_BeforeIndex.png
│       └── Akanji_Shakirat_301928526_P2_RenderedQ1Results.png
├── portfolio-3-transactions-concurrency/
│   ├── Akanji_Shakirat_301928526_P3_Demo1Atomicity.sql          # Demo 1: commit and rollback
│   ├── Akanji_Shakirat_301928526_P3_Demo1Output.txt             # captured output of Demo 1
│   ├── Akanji_Shakirat_301928526_P3_DemoConcurrency.sh          # Demos 2 to 4, two sessions run together
│   ├── Akanji_Shakirat_301928526_P3_DemoConcurrencyOutput.txt   # captured output of Demos 2 to 4
│   ├── Akanji_Shakirat_301928526_P3_README.md                   # rollback, lost update, isolation, double booking
│   ├── Akanji_Shakirat_301928526_P3_SessionA.sql                # session A steps, to run by hand
│   ├── Akanji_Shakirat_301928526_P3_SessionB.sql                # session B steps, second terminal
│   ├── Akanji_Shakirat_301928526_P3_SetupDemo.sql               # resets the demo drug (re-runnable)
│   └── evidence/
│       ├── Akanji_Shakirat_301928526_P3_DemoConcurrencyOutput.png
│       └── Akanji_Shakirat_301928526_P3_RenderedDemo1Atomicity.png
├── portfolio-4-nosql/
│   ├── Akanji_Shakirat_301928526_P4_ExportPatients.sql   # builds one JSON document per patient
│   ├── Akanji_Shakirat_301928526_P4_NosqlOutput.txt      # captured output
│   ├── Akanji_Shakirat_301928526_P4_Patients.jsonl       # exported documents (200 patients)
│   ├── Akanji_Shakirat_301928526_P4_Queries.js           # eight mongosh queries
│   ├── Akanji_Shakirat_301928526_P4_README.md            # document model, eight queries, when NoSQL fits
│   ├── Akanji_Shakirat_301928526_P4_RunNosqlDemo.sh      # runs export, import and queries
│   └── evidence/
│       ├── Akanji_Shakirat_301928526_P4_ContainersRunning.png
│       ├── Akanji_Shakirat_301928526_P4_ExportImportQ1Q2.png
│       ├── Akanji_Shakirat_301928526_P4_Q2Q3.png
│       ├── Akanji_Shakirat_301928526_P4_Q4Q5.png
│       └── Akanji_Shakirat_301928526_P4_Q6Q7Q8.png
└── portfolio-5-distributed-cloud/
    ├── Akanji_Shakirat_301928526_P5_AtlasChecks.js          # mongosh checks run against Atlas
    ├── Akanji_Shakirat_301928526_P5_AtlasDemo.sh            # Atlas import and checks
    ├── Akanji_Shakirat_301928526_P5_AtlasOutput.txt         # captured output of the Atlas run
    ├── Akanji_Shakirat_301928526_P5_InitPrimary.sql         # creates the replication user
    ├── Akanji_Shakirat_301928526_P5_README.md               # replication, Atlas replica set, sharding, CAP
    ├── Akanji_Shakirat_301928526_P5_ReplicationDemo.sh      # lag and failover demo
    ├── Akanji_Shakirat_301928526_P5_ReplicationOutput.txt   # captured output of the replication demo
    ├── docker-compose.replication.yml                       # PostgreSQL primary and replica (Portfolio 5)
    └── evidence/
        ├── Akanji_Shakirat_301928526_P5_AtlasCluster.png
        ├── Akanji_Shakirat_301928526_P5_AtlasImportChecks.png
        ├── Akanji_Shakirat_301928526_P5_ReplicationLagFailover.png
        └── Akanji_Shakirat_301928526_P5_ReplicationSetup.png
```

**How to review it.** Read the final summary first. Then open each portfolio README for how to run it, the results and the limitations, and check the `evidence/` folder. To run the work yourself, follow "Getting started" below.

## Main findings

- **Rules belong in the database.** Constraints from Portfolio 1 (`CHECK (stock_quantity >= 0)`, `UNIQUE (doctor_id, scheduled_start)`) were what stopped bad stock and double bookings in Portfolio 3, even with two users at once.
- **Concurrency needs locks.** Without a lock, two nurses dispensing from the same stock left 6 instead of 0. With `FOR UPDATE` the result was correct.
- **Indexes change the plan.** A collection scan of 200 documents became an index lookup of 1 document in MongoDB, the same idea as the SQL indexes in Portfolio 2.
- **Use both databases.** PostgreSQL stays the system of record for appointments, billing and stock. MongoDB holds the patient-record view for fast reads.
- **Replicas can be stale.** A paused replica returned stock 10 while the primary showed 8. Stock and payments must read from the primary; reports can use replicas.

## Tools

PostgreSQL 16, MongoDB 7, MongoDB Atlas (free M0 cluster), Docker and Docker Compose, `psql`, `mongosh`, Git and GitHub.

## Getting started

Requirements: Docker Desktop and Git.

```bash
git clone https://github.com/Anikhe00/Akanji-Shakirat-301928526.git
cd Akanji-Shakirat-301928526
echo "PG_PASSWORD=choose-a-password" > .env
docker compose up -d
```

Then follow the "How to run" section in each portfolio's README. Portfolio 5's Atlas demo needs your own free Atlas cluster. Its script asks for the connection string and hides it, so the password is never saved.

## Security notes

- Passwords and connection strings are never committed. `.env` is ignored by Git.
- The Docker passwords are lab values, and MongoDB in Docker has no authentication. This is acceptable for simulated data only, not for real patient data.

## AI-use declaration

Claude (Anthropic) was used throughout to propose designs and demos, write scripts, help debug setup problems, and draft the READMEs from the output of scripts I ran. I ran everything myself, checked the results against what was written, and can explain each part. The full declaration is in [`Akanji_Shakirat_301928526_FinalSummary.md`](Akanji_Shakirat_301928526_FinalSummary.md) and at the end of each portfolio README.
