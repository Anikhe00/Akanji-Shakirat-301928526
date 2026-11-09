-- Portfolio 3: SESSION A (terminal 1). Run the steps by hand, in the numbered order.
-- The steps of Session B are in Akanji_Shakirat_301928526_P3_SessionB.sql (terminal 2).
-- Do NOT run both files from top to bottom one after the other: the point is to
-- alternate A -> B -> A -> B, so that the two sessions overlap in time.
--
-- Open a psql prompt in each terminal:
--   docker exec -it carebridge-pg psql -U carebridge -d carebridge
-- Before you start, in either terminal, reset the demo drug (stock = 10):
--   \i portfolio-3-transactions-concurrency/Akanji_Shakirat_301928526_P3_SetupDemo.sql
--   (or run it from outside: docker exec -i carebridge-pg psql -U carebridge -d carebridge < ... )

-- ======================================================================
-- PART 1: the lost update, fixed with SELECT ... FOR UPDATE
-- Stock is 10. A dispenses 6 and B dispenses 4, so the correct final stock is 0.
-- ======================================================================

-- STEP 1 (A): start a transaction and lock the row. It shows stock 10.
BEGIN;
SELECT name, stock_quantity FROM drugs WHERE name = 'Demo Artesunate' FOR UPDATE;

-- STEP 3 (A): while B is waiting, dispense 6 and COMMIT. This releases the lock.
UPDATE drugs SET stock_quantity = stock_quantity - 6 WHERE name = 'Demo Artesunate';
COMMIT;

-- ======================================================================
-- PART 2: two receptionists book the same doctor at the same time
-- (the UNIQUE (doctor_id, scheduled_start) rule from Portfolio 1)
-- ======================================================================

-- STEP 5 (A): start a booking for Doctor 1, 1 January 2030 at 09:00. Do NOT commit yet.
BEGIN;
INSERT INTO appointments (patient_id, doctor_id, scheduled_start, scheduled_end, reason)
VALUES (1, 1, '2030-01-01 09:00+01', '2030-01-01 09:30+01', 'Session A');

-- STEP 7 (A): commit the booking. B is still waiting, and now gets its error.
COMMIT;

-- STEP 9 (A): look at the result, then clean up the test booking.
SELECT count(*) AS bookings_for_that_slot FROM appointments
 WHERE doctor_id = 1 AND scheduled_start = '2030-01-01 09:00+01';
DELETE FROM appointments WHERE scheduled_start = '2030-01-01 09:00+01';
