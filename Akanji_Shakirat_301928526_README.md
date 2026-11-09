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

Every file name follows the pattern `Akanji_Shakirat_301928526_<Portfolio>_<Name>.<ext>` (last name, first name, student number, then the portfolio and what the file is). The tree below leaves out the `Akanji_Shakirat_301928526_` prefix to save space, so `P1_Schema.sql` is the file `Akanji_Shakirat_301928526_P1_Schema.sql`. The two root files have no portfolio part (`README.md`, `FinalSummary.md`).

```text
.
├── README.md                          this file: overview and how to navigate
├── FinalSummary.md                    the 2 to 3 page summary of all five portfolios
├── docker-compose.yml                 PostgreSQL 16 and MongoDB 7 for Portfolios 1 to 4
├── portfolio-1-database-design/
│   ├── P1_README.md                   design, keys, constraints, normalisation, testing
│   ├── P1_Schema.sql                  11 tables with keys and constraints
│   ├── P1_SampleData.sql              small data set used to test the rules
│   ├── P1_ConstraintTests.sql         five statements the database must reject
│   ├── P1_JoinPrescriptions.sql       six-table join (3NF check)
│   ├── P1_CarebridgeDesign.dbml       ER design source (dbdiagram.io)
│   ├── P1_ERDiagram.png               exported ER diagram
│   ├── P1_Normalisation.md            worked example: 1NF, 2NF, 3NF
│   ├── P1_Evidence.md                 index of the screenshots
│   └── evidence/                      terminal screenshots
├── portfolio-2-query-optimisation/
│   ├── P2_README.md                   method, results, performance analysis
│   ├── P2_SeedBulk.sql                generates about 500,000 rows of test data
│   ├── P2_ExplainQueries.sql          five queries with EXPLAIN (ANALYZE)
│   ├── P2_Indexes.sql                 the four indexes added
│   ├── P2_Queries.sql                 the same queries without EXPLAIN
│   ├── P2_PlansBefore.txt / P2_PlansAfter.txt   execution plans before and after
│   ├── P2_Results.txt, P2_IndexSizes.txt         query results and index sizes
│   └── evidence/                      before and after screenshots
├── portfolio-3-transactions-concurrency/
│   ├── P3_README.md                   four demos: rollback, lost update, isolation, double booking
│   ├── P3_SetupDemo.sql               resets the demo drug (re-runnable)
│   ├── P3_Demo1Atomicity.sql          Demo 1 (commit and rollback)
│   ├── P3_DemoConcurrency.sh          Demos 2 to 4, two sessions run together
│   ├── P3_SessionA.sql / P3_SessionB.sql   the same steps to run by hand in two terminals
│   ├── P3_Demo1Output.txt, P3_DemoConcurrencyOutput.txt   captured output
│   └── evidence/                      screenshots and rendered output
├── portfolio-4-nosql/
│   ├── P4_README.md                   document model, eight queries, when NoSQL fits
│   ├── P4_ExportPatients.sql          builds one JSON document per patient
│   ├── P4_Patients.jsonl              the exported documents (200 patients)
│   ├── P4_Queries.js                  eight mongosh queries
│   ├── P4_RunNosqlDemo.sh             runs export, import and queries
│   ├── P4_NosqlOutput.txt             captured output
│   └── evidence/                      terminal screenshots
└── portfolio-5-distributed-cloud/
    ├── P5_README.md                   replication, Atlas replica set, sharding, CAP
    ├── docker-compose.replication.yml PostgreSQL primary and replica
    ├── P5_InitPrimary.sql             creates the replication user
    ├── P5_ReplicationDemo.sh          lag and failover demo
    ├── P5_AtlasDemo.sh, P5_AtlasChecks.js   MongoDB Atlas import and checks
    ├── P5_ReplicationOutput.txt, P5_AtlasOutput.txt   captured output
    └── evidence/                      terminal screenshots
```

**How to review it.**

1. Read [`Akanji_Shakirat_301928526_FinalSummary.md`](Akanji_Shakirat_301928526_FinalSummary.md) for the whole project on a few pages.
2. Open each portfolio's `P<n>_README.md`. It lists the files in that folder, how to run them, the results, the limitations, the AI-use declaration and the references.
3. Check the evidence: the screenshots are in each folder's `evidence/` subfolder, and the full text output is saved next to the scripts in `.txt` files. Images whose name starts with `Rendered` are rendered from those saved text files and say so on the image. All other images are terminal screenshots.
4. To run the work yourself, follow "Getting started" below, then the "How to run" section in each portfolio README.

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
