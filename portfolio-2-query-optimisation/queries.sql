\echo === Q1 patient history
SELECT a.appointment_id, a.scheduled_start, a.status, d.full_name AS doctor, dg.condition_name
FROM appointments a
JOIN doctors d ON d.doctor_id = a.doctor_id
LEFT JOIN visits v ON v.appointment_id = a.appointment_id
LEFT JOIN diagnoses dg ON dg.visit_id = v.visit_id
WHERE a.patient_id = 100
ORDER BY a.scheduled_start DESC;

\echo === Q2 doctor workload per branch, June 2025
SELECT b.name AS branch, d.full_name, count(*) AS completed
FROM appointments a
JOIN doctors d ON d.doctor_id = a.doctor_id
JOIN branches b ON b.branch_id = d.branch_id
WHERE a.status = 'completed'
  AND a.scheduled_start >= '2025-06-01' AND a.scheduled_start < '2025-07-01'
GROUP BY b.name, d.full_name
ORDER BY completed DESC
LIMIT 10;

\echo === Q3 ten most prescribed drugs
SELECT dr.name, count(*) AS times_prescribed, sum(p.quantity) AS total_quantity
FROM prescriptions p
JOIN drugs dr ON dr.drug_id = p.drug_id
GROUP BY dr.name
ORDER BY times_prescribed DESC
LIMIT 10;

\echo === Q4 everything one patient was prescribed
SELECT a.scheduled_start, dr.name AS drug, p.dosage, p.quantity
FROM appointments a
JOIN visits v ON v.appointment_id = a.appointment_id
JOIN prescriptions p ON p.visit_id = v.visit_id
JOIN drugs dr ON dr.drug_id = p.drug_id
WHERE a.patient_id = 100
ORDER BY a.scheduled_start DESC;

\echo === Q5 one doctor, one week
SELECT appointment_id, patient_id, scheduled_start, status
FROM appointments
WHERE doctor_id = 7 AND scheduled_start >= '2025-06-02' AND scheduled_start < '2025-06-09'
ORDER BY scheduled_start;
