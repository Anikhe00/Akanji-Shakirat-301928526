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

**File tree**

```text
.
├── .gitignore                                  # keeps .env and .DS_Store out of Git
├── Akanji_Shakirat_301928526_FinalSummary.md   # 2 to 3 page summary of all five portfolios
├── Akanji_Shakirat_301928526_README.md         # this file: overview and how to navigate
├── docker-compose.yml                          # PostgreSQL 16 and MongoDB 7 (Portfolios 1 to 4)
├── portfolio-1-database-design/                # ER design, schema, sample data, constraint tests, normalisation
├── portfolio-2-query-optimisation/             # data generator, queries, plans before and after indexing
├── portfolio-3-transactions-concurrency/       # rollback, lost update, isolation levels, double booking
├── portfolio-4-nosql/                          # MongoDB document model, export, eight queries
└── portfolio-5-distributed-cloud/              # replication and failover, Atlas replica set, sharding
```

Each portfolio folder is described in its own README (`Akanji_Shakirat_301928526_P<n>_README.md`), which lists every file in the folder.

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
