# Advanced Database Portfolio: CareBridge Clinics

**Module:** MIT 8103 Advanced Database Systems
**Student:** Shakirat Akanji, MSc Information Technology
**Case study:** CareBridge Clinics, a simulated group of 3 private clinics in Oyo State, Nigeria. All data is invented. No real patient data is used.

## What this project is

One database problem, worked through five times. CareBridge needs to record patients, appointments, visits, diagnoses, prescriptions, lab orders, payments and drug stock. Each portfolio takes the same case study and looks at it from a different angle: design, speed, correctness under concurrency, a NoSQL alternative, and spreading the data across several servers.

The seeded database holds 20,000 patients and about 80,000 visits.

## The five portfolios

| # | Topic | What it shows | Folder |
|---|---|---|---|
| 1 | Database design | An 11-table PostgreSQL schema with primary and foreign keys, `CHECK` and `UNIQUE` rules, and seed data | `portfolio-1-.../` |
| 2 | Query optimisation | Slow queries analysed with `EXPLAIN ANALYZE` and fixed with indexes | `portfolio-2-.../` |
| 3 | Transactions and concurrency | Rollback, lost update and `SELECT ... FOR UPDATE`, isolation levels, concurrent double-booking | `portfolio-3-transactions-concurrency/` |
| 4 | NoSQL (MongoDB) | 200 patients remodelled as documents, eight queries, indexing, and when a document database fits | `portfolio-4-nosql/` |
| 5 | Distributed and cloud | PostgreSQL primary-replica replication with failover, and a 3-node MongoDB Atlas replica set; sharding and CAP discussed | `portfolio-5-distributed-cloud/` |

Each folder has its own `README.md` with how to run it, the results, limitations, an AI-use declaration and references. Screenshots are in each folder's `evidence/` folder (Portfolio 3's demos are also saved as text output).

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
git clone https://github.com/Anikhe00/advanced-database-portfolio.git
cd advanced-database-portfolio
echo "PG_PASSWORD=choose-a-password" > .env
docker compose up -d
```

Then follow the "How to run" section in each portfolio's README. Portfolio 5's Atlas demo needs your own free Atlas cluster. Its script asks for the connection string and hides it, so the password is never saved.

## Security notes

- Passwords and connection strings are never committed. `.env` is ignored by Git.
- The Docker passwords are lab values, and MongoDB in Docker has no authentication. This is acceptable for simulated data only, not for real patient data.

## AI-use declaration

Claude (Anthropic) was used throughout to propose designs and demos, write scripts, help debug setup problems, and draft the READMEs from the output of scripts I ran. I ran everything myself, checked the results against what was written, and can explain each part. The full declaration, with what I corrected, is in the final documentation and at the end of each portfolio README.
