-- Portfolio 3: SESSION B (terminal 2). Run the steps by hand, in the numbered order.
-- The steps of Session A are in Akanji_Shakirat_301928526_P3_SessionA.sql (terminal 1).
-- Alternate A -> B -> A -> B. Read the header of the Session A file first.

-- ======================================================================
-- PART 1: the lost update, fixed with SELECT ... FOR UPDATE
-- ======================================================================

-- STEP 2 (B): ask for the same row, with the lock. This WAITS: A holds the lock.
-- (The prompt does not come back. That is the demonstration. Go to step 3 in A.)
BEGIN;
SELECT name, stock_quantity FROM drugs WHERE name = 'Demo Artesunate' FOR UPDATE;

-- STEP 4 (B): the SELECT above has now returned, and shows stock 4, the value AFTER
-- A's dispensing. Dispense 4 and COMMIT. The final stock must be 0.
UPDATE drugs SET stock_quantity = stock_quantity - 4 WHERE name = 'Demo Artesunate';
COMMIT;
SELECT name, stock_quantity AS final_stock FROM drugs WHERE name = 'Demo Artesunate';

-- ======================================================================
-- PART 2: two receptionists book the same doctor at the same time
-- ======================================================================

-- STEP 6 (B): try to book the SAME doctor and time for another patient.
-- This WAITS, because A has inserted the row but has not committed.
BEGIN;
INSERT INTO appointments (patient_id, doctor_id, scheduled_start, scheduled_end, reason)
VALUES (2, 1, '2030-01-01 09:00+01', '2030-01-01 09:30+01', 'Session B');

-- STEP 8 (B): after A commits, the INSERT above fails with
--   ERROR: duplicate key value violates unique constraint "appointments_doctor_id_scheduled_start_key"
-- The transaction is now aborted, so end it:
ROLLBACK;
