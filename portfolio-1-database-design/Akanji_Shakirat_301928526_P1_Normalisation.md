# Portfolio 1: Normalisation Worked Example

Normalisation splits one wide table into related tables, so that each fact is stored once and cannot disagree with itself. This page follows one CareBridge visit through 1NF, 2NF and 3NF and ends at the tables in `Akanji_Shakirat_301928526_P1_Schema.sql`.

The rows use the sample data from `Akanji_Shakirat_301928526_P1_SampleData.sql`. Only the columns needed to explain each step are shown. The tables on this page are illustrative: they show the reasoning, not the contents of the database.

## Starting point: a visit sheet (not normalised)

A paper-style record that puts everything about a visit in one row:

| visit_id | patient | doctor | branch | branch_city | drugs prescribed |
| --- | --- | --- | --- | --- | --- |
| 1 | Amina Yusuf | Dr Adaeze Okafor | CareBridge Ibadan Central | Ibadan | Artemether/Lumefantrine x6 at 2500.00; Paracetamol x12 at 150.00 |

The last cell holds two drugs in one value. You cannot count how often a drug is prescribed, you cannot enforce that the drug exists, and a dosage has nowhere to go.

## 1NF: one value per cell

Each prescribed drug gets its own row. The key becomes **(visit_id, drug_id)**.

| visit_id | drug_id | drug_name | unit_price | quantity | patient | doctor | branch | branch_city |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 1 | Artemether/Lumefantrine | 2500.00 | 6 | Amina Yusuf | Dr Adaeze Okafor | CareBridge Ibadan Central | Ibadan |
| 1 | 2 | Paracetamol | 150.00 | 12 | Amina Yusuf | Dr Adaeze Okafor | CareBridge Ibadan Central | Ibadan |

This is in 1NF. The problem is repetition: the patient, doctor and branch are repeated for every drug on the visit.

## 2NF: every column depends on the whole key

2NF applies when the key has more than one column. Two kinds of column depend on only part of **(visit_id, drug_id)**:

- `drug_name` and `unit_price` depend only on **drug_id**. They move to a `drugs` table.
- `patient`, `doctor`, `branch` and `branch_city` depend only on **visit_id**. They move to a visit-level table.

**drugs** (key: drug_id)

| drug_id | name | unit_price |
| --- | --- | --- |
| 1 | Artemether/Lumefantrine | 2500.00 |
| 2 | Paracetamol | 150.00 |

**visit** (key: visit_id)

| visit_id | patient | doctor | branch | branch_city |
| --- | --- | --- | --- | --- |
| 1 | Amina Yusuf | Dr Adaeze Okafor | CareBridge Ibadan Central | Ibadan |

**prescriptions** (key: visit_id, drug_id)

| visit_id | drug_id | quantity |
| --- | --- | --- |
| 1 | 1 | 6 |
| 1 | 2 | 12 |

## 3NF: nothing depends on a non-key column

Inside the visit-level table some columns depend on another non-key column, not on `visit_id`:

- `branch_city` depends on the **branch**, not on the visit.
- `branch` depends on the **doctor** (each doctor works at one branch).
- `doctor` depends on the **appointment** that the visit belongs to.
- `patient` depends on the **appointment** too.

If the city of a branch were stored on every visit, changing it would mean updating thousands of visits, and some could be missed. Each fact moves to the table that it describes:

| Fact | Where it is stored | Linked by |
| --- | --- | --- |
| Branch name and city | `branches` | `doctors.branch_id` |
| Doctor name and licence | `doctors` | `appointments.doctor_id` |
| Patient details | `patients` | `appointments.patient_id` |
| Booking time and status | `appointments` | `visits.appointment_id` |
| The visit itself | `visits` | `prescriptions.visit_id` |

## Result

The final design has no repeated facts: `visits` holds only `appointment_id`, the date and the notes, and everything else is reached through foreign keys. This is why `prescriptions` has no `doctor_id` or `patient_id` column. They would copy facts that the visit already determines, and the two copies could disagree.

All 11 tables are in 3NF. Normalisation also keeps the rules working: a drug price lives in one place, so a price change cannot leave two different prices behind.
