INSERT INTO branches (name, city, address, phone) VALUES
 ('CareBridge Ibadan Central','Ibadan','12 Ring Road','08000000001'),
 ('CareBridge Ogbomoso','Ogbomoso','5 Stadium Road','08000000002'),
 ('CareBridge Oyo Town','Oyo','21 Isokun Street','08000000003');

INSERT INTO departments (name) VALUES
 ('General Practice'),('Paediatrics'),('Pharmacy'),('Laboratory');

INSERT INTO doctors (branch_id, department_id, full_name, licence_number, email, phone) VALUES
 (1,1,'Dr Adaeze Okafor','MDCN-1001','adaeze@carebridge.test','08010000001'),
 (2,2,'Dr Tunde Balogun','MDCN-1002','tunde@carebridge.test','08010000002');

INSERT INTO patients (first_name, last_name, date_of_birth, sex, phone, email, address) VALUES
 ('Amina','Yusuf','1990-04-12','female','08020000001','amina@example.test','Bodija, Ibadan'),
 ('Chidi','Eze','1985-11-03','male','08020000002','chidi@example.test','Sango, Ibadan');

INSERT INTO appointments (patient_id, doctor_id, scheduled_start, scheduled_end, status, reason) VALUES
 (1,1,'2026-10-20 09:00+01','2026-10-20 09:30+01','completed','Fever and headache'),
 (2,1,'2026-10-20 10:00+01','2026-10-20 10:30+01','scheduled','Check-up');

INSERT INTO visits (appointment_id, notes) VALUES (1,'Fever for 3 days, no cough');
INSERT INTO diagnoses (visit_id, condition_name, icd_code) VALUES (1,'Malaria','B54');

INSERT INTO drugs (name, strength, unit_price, stock_quantity) VALUES
 ('Artemether/Lumefantrine','80/480mg',2500.00,100),
 ('Paracetamol','500mg',150.00,500);

INSERT INTO prescriptions (visit_id, drug_id, dosage, duration_days, quantity) VALUES
 (1,1,'1 tablet twice daily',3,6),
 (1,2,'2 tablets when needed',3,12);

INSERT INTO lab_orders (visit_id, test_name, result_text, resulted_at) VALUES
 (1,'Malaria parasite test','Positive', now());

INSERT INTO payments (visit_id, amount, method) VALUES (1,7500.00,'transfer');
