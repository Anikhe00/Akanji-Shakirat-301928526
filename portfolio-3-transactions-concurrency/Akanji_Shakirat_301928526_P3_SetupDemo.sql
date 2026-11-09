-- Demo data for Portfolio 3. Safe to run again: it removes the demo rows first.
DELETE FROM prescriptions WHERE drug_id IN (SELECT drug_id FROM drugs WHERE name = 'Demo Artesunate');
DELETE FROM drugs WHERE name = 'Demo Artesunate';

INSERT INTO drugs (name, strength, unit_price, stock_quantity)
VALUES ('Demo Artesunate', '60mg', 1800.00, 10);

-- Two prescriptions on visit 1 for the demo drug: one for 6 units, one for 8 units
INSERT INTO prescriptions (visit_id, drug_id, dosage, duration_days, quantity)
SELECT 1, drug_id, '1 tablet twice daily', 3, 6 FROM drugs WHERE name = 'Demo Artesunate';
INSERT INTO prescriptions (visit_id, drug_id, dosage, duration_days, quantity)
SELECT 1, drug_id, '2 tablets twice daily', 4, 8 FROM drugs WHERE name = 'Demo Artesunate';
