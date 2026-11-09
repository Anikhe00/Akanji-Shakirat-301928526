-- Portfolio 1: join across six tables.
-- Shows that the patient and the doctor behind a prescription can be found
-- through foreign keys, without storing them twice in `prescriptions` (3NF).
--
-- Run from the repository root:
--   docker exec -i carebridge-pg psql -U carebridge -d carebridge < portfolio-1-database-design/Akanji_Shakirat_301928526_P1_JoinPrescriptions.sql

SELECT p.first_name || ' ' || p.last_name AS patient,
       doc.full_name                      AS doctor,
       d.name                             AS drug,
       pr.dosage,
       pr.quantity
FROM prescriptions pr
JOIN visits       v   ON v.visit_id        = pr.visit_id
JOIN appointments a   ON a.appointment_id  = v.appointment_id
JOIN patients     p   ON p.patient_id      = a.patient_id
JOIN doctors      doc ON doc.doctor_id     = a.doctor_id
JOIN drugs        d   ON d.drug_id         = pr.drug_id
ORDER BY pr.prescription_id;
