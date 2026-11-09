-- CareBridge bulk test data for Portfolio 2 (query optimisation)
-- WARNING: this empties every table first, including the Portfolio 1 sample rows.
-- All data is invented. setseed makes the "random" numbers repeatable.

SELECT setseed(0.42);

TRUNCATE branches, departments, doctors, patients, appointments, visits,
         diagnoses, drugs, prescriptions, lab_orders, payments
         RESTART IDENTITY CASCADE;

-- 1. Reference data ---------------------------------------------------
INSERT INTO branches (name, city, address, phone) VALUES
 ('CareBridge Ibadan Central','Ibadan','12 Ring Road','08000000001'),
 ('CareBridge Ogbomoso','Ogbomoso','5 Stadium Road','08000000002'),
 ('CareBridge Oyo Town','Oyo','21 Isokun Street','08000000003');

INSERT INTO departments (name) VALUES
 ('General Practice'),('Paediatrics'),('Internal Medicine'),
 ('Obstetrics and Gynaecology'),('Pharmacy'),('Laboratory');

-- 30 doctors, spread over the 3 branches and the first 4 departments
INSERT INTO doctors (branch_id, department_id, full_name, licence_number, email, phone)
SELECT 1 + (g % 3),
       1 + (g % 4),
       'Dr ' || (ARRAY['Adaeze','Tunde','Ngozi','Ibrahim','Funmi','Emeka','Hauwa','Segun','Blessing','Yusuf'])[1 + (g % 10)]
             || ' ' || (ARRAY['Okafor','Balogun','Adeyemi','Bello','Eze','Ogunleye','Musa','Nwosu','Afolabi','Olawale'])[1 + ((g / 10) % 10)],
       'MDCN-' || (1000 + g),
       'doctor' || g || '@carebridge.test',
       '0801' || lpad(g::text, 7, '0')
FROM generate_series(1, 30) AS g;

INSERT INTO drugs (name, strength, unit_price, stock_quantity)
SELECT d.name,
       (ARRAY['100mg','250mg','500mg','10mg','5mg'])[1 + floor(random() * 5)::int],
       round((50 + random() * 2950)::numeric, 2),
       200 + floor(random() * 1800)::int
FROM unnest(ARRAY['Paracetamol','Ibuprofen','Amoxicillin','Artemether/Lumefantrine','Metformin',
                  'Amlodipine','Lisinopril','Ciprofloxacin','Azithromycin','Omeprazole',
                  'Salbutamol inhaler','Loratadine','Vitamin C','Folic acid','Ferrous sulphate',
                  'Metronidazole','Co-trimoxazole','Diclofenac','Atorvastatin','Hydrochlorothiazide',
                  'Oral rehydration salts','Zinc sulphate','Cetirizine','Prednisolone','Fluconazole']) AS d(name);

-- 2. Patients: 20,000 -------------------------------------------------
INSERT INTO patients (first_name, last_name, date_of_birth, sex, phone, email, address, registered_at)
SELECT (ARRAY['Amina','Chidi','Bola','Kemi','Musa','Ifeoma','Tobi','Zainab','Emeka','Sade',
              'Uche','Hadiza','Femi','Nneka','Abdul','Yetunde','Chinedu','Rukky','Sola','Ngozi'])[1 + floor(random() * 20)::int],
       (ARRAY['Yusuf','Eze','Adebayo','Okonkwo','Bello','Ogunbanjo','Lawal','Nwachukwu','Salami','Ojo',
              'Ibrahim','Afolabi','Okoye','Balogun','Adeniyi','Danjuma','Olatunji','Agu','Abiola','Suleiman'])[1 + floor(random() * 20)::int],
       DATE '1940-01-01' + floor(random() * 30000)::int,
       CASE WHEN r < 0.52 THEN 'female' WHEN r < 0.99 THEN 'male' ELSE 'other' END,
       '0802' || lpad(g::text, 7, '0'),
       'patient' || g || '@example.test',
       (ARRAY['Bodija','Sango','Mokola','Agodi','Challenge','Ring Road','Iyaganku','Oluyole'])[1 + floor(random() * 8)::int] || ', Oyo State',
       TIMESTAMPTZ '2024-01-01 08:00+01' + random() * INTERVAL '660 days'
FROM (SELECT g, random() AS r FROM generate_series(1, 20000) AS g) AS s;

-- 3. Appointments: 100,000 --------------------------------------------
-- Doctor = 1 + g % 30; slot number = g / 30; 8 hourly slots a day per doctor.
-- That makes every (doctor, start time) pair unique, as the table demands.
-- Patient ids are skewed (power of random) so some patients visit often.
INSERT INTO appointments (patient_id, doctor_id, scheduled_start, scheduled_end, status, reason)
SELECT patient_id, doctor_id, start_time, start_time + INTERVAL '30 minutes',
       CASE WHEN r < 0.80 THEN 'completed' WHEN r < 0.90 THEN 'cancelled' ELSE 'no_show' END,
       reason
FROM (
  SELECT 1 + floor(20000 * power(random(), 2))::int AS patient_id,
         1 + (g % 30) AS doctor_id,
         TIMESTAMPTZ '2025-01-06 08:00+01'
           + ((g / 30) / 8) * INTERVAL '1 day'
           + ((g / 30) % 8) * INTERVAL '1 hour' AS start_time,
         random() AS r,
         (ARRAY['Fever','Headache','Check-up','Cough','Stomach pain','Follow-up','Blood pressure check','Skin rash'])[1 + floor(random() * 8)::int] AS reason
  FROM generate_series(0, 99999) AS g
) AS s;

-- 4. Visits: one per completed appointment ------------------------------
INSERT INTO visits (appointment_id, visit_date, notes)
SELECT appointment_id, scheduled_start + INTERVAL '5 minutes', 'Routine consultation'
FROM appointments
WHERE status = 'completed';

-- 5. Diagnoses: one per visit, plus a second for about 20% of visits ------
INSERT INTO diagnoses (visit_id, condition_name, icd_code)
SELECT visit_id,
       (ARRAY['Malaria','Hypertension','Type 2 diabetes','Typhoid fever','Upper respiratory infection',
              'Gastroenteritis','Urinary tract infection','Asthma','Anaemia','Skin infection'])[idx],
       (ARRAY['B54','I10','E11','A01.0','J06.9','A09','N39.0','J45','D64.9','L08.9'])[idx]
FROM (SELECT visit_id, 1 + floor(random() * 10)::int AS idx FROM visits) AS s;

INSERT INTO diagnoses (visit_id, condition_name, icd_code)
SELECT visit_id,
       (ARRAY['Malaria','Hypertension','Type 2 diabetes','Typhoid fever','Upper respiratory infection',
              'Gastroenteritis','Urinary tract infection','Asthma','Anaemia','Skin infection'])[idx],
       (ARRAY['B54','I10','E11','A01.0','J06.9','A09','N39.0','J45','D64.9','L08.9'])[idx]
FROM (SELECT visit_id, 1 + floor(random() * 10)::int AS idx FROM visits WHERE random() < 0.2) AS s;

-- 6. Prescriptions: 1 to 3 per visit (about 70%, 35%, 12% chance each) ------
-- The random number r is drawn inside a subquery so each (visit, n) pair
-- gets its own dice roll.
INSERT INTO prescriptions (visit_id, drug_id, dosage, duration_days, quantity, dispensed_at)
SELECT visit_id,
       1 + floor(random() * 25)::int,
       (ARRAY['1 tablet twice daily','2 tablets three times daily','1 tablet at night','5ml twice daily'])[1 + floor(random() * 4)::int],
       3 + floor(random() * 12)::int,
       6 + floor(random() * 30)::int,
       visit_date + INTERVAL '30 minutes'
FROM (
  SELECT v.visit_id, v.visit_date, n, random() AS r
  FROM visits v
  CROSS JOIN generate_series(1, 3) AS n
) AS s
WHERE r < CASE n WHEN 1 THEN 0.70 WHEN 2 THEN 0.35 ELSE 0.12 END;

-- 7. Lab orders: about 30% of visits ----------------------------------------
INSERT INTO lab_orders (visit_id, test_name, ordered_at, result_text, resulted_at)
SELECT visit_id,
       (ARRAY['Malaria parasite test','Full blood count','Blood glucose','Urinalysis','Widal test','Lipid profile','Liver function test','Hepatitis B screen'])[1 + floor(random() * 8)::int],
       visit_date,
       (ARRAY['Normal','Abnormal','Positive','Negative'])[1 + floor(random() * 4)::int],
       visit_date + INTERVAL '2 hours'
FROM visits
WHERE random() < 0.30;

-- 8. Payments: one per visit ---------------------------------------------------
INSERT INTO payments (visit_id, amount, method, paid_at)
SELECT visit_id,
       3000 + floor(random() * 40)::int * 250,
       (ARRAY['cash','card','transfer','insurance'])[1 + floor(random() * 4)::int],
       visit_date + INTERVAL '1 hour'
FROM visits;

-- 9. Refresh the planner's statistics -----------------------------------------
ANALYZE;
