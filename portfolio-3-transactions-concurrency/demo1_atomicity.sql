\set ECHO queries
\echo
\echo '=== A. Start a transaction, change the stock, look, then ROLLBACK ==='
BEGIN;
UPDATE drugs SET stock_quantity = stock_quantity - 6 WHERE name = 'Demo Artesunate';
SELECT name, stock_quantity FROM drugs WHERE name = 'Demo Artesunate';
ROLLBACK;
SELECT name, stock_quantity FROM drugs WHERE name = 'Demo Artesunate';

\echo
\echo '=== B. A successful dispense: both changes saved together with COMMIT ==='
BEGIN;
UPDATE prescriptions SET dispensed_at = now()
 WHERE quantity = 6 AND drug_id = (SELECT drug_id FROM drugs WHERE name = 'Demo Artesunate');
UPDATE drugs SET stock_quantity = stock_quantity - 6 WHERE name = 'Demo Artesunate';
COMMIT;
SELECT p.quantity, p.dispensed_at IS NOT NULL AS dispensed, d.stock_quantity AS stock_left
FROM prescriptions p JOIN drugs d ON d.drug_id = p.drug_id
WHERE d.name = 'Demo Artesunate' ORDER BY p.quantity;

\echo
\echo '=== C. A failing dispense: 8 units wanted but only 4 left. Nothing must be half-saved ==='
BEGIN;
UPDATE prescriptions SET dispensed_at = now()
 WHERE quantity = 8 AND drug_id = (SELECT drug_id FROM drugs WHERE name = 'Demo Artesunate');
SELECT p.quantity, p.dispensed_at IS NOT NULL AS dispensed
FROM prescriptions p JOIN drugs d ON d.drug_id = p.drug_id
WHERE d.name = 'Demo Artesunate' AND p.quantity = 8;
UPDATE drugs SET stock_quantity = stock_quantity - 8 WHERE name = 'Demo Artesunate';
SELECT 'this statement is ignored because the transaction has failed';
ROLLBACK;
SELECT p.quantity, p.dispensed_at IS NOT NULL AS dispensed, d.stock_quantity AS stock_left
FROM prescriptions p JOIN drugs d ON d.drug_id = p.drug_id
WHERE d.name = 'Demo Artesunate' ORDER BY p.quantity;
