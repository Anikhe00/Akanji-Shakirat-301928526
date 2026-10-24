-- A patient's appointments, newest first (Q1, Q4)
CREATE INDEX idx_appointments_patient_start ON appointments (patient_id, scheduled_start DESC);

-- Foreign keys that PostgreSQL does not index automatically (Q1, Q4)
CREATE INDEX idx_diagnoses_visit ON diagnoses (visit_id);
CREATE INDEX idx_prescriptions_visit ON prescriptions (visit_id);

-- Partial index: only completed appointments (Q2)
CREATE INDEX idx_appointments_completed_start ON appointments (scheduled_start) WHERE status = 'completed';

-- Refresh statistics so the planner knows the new indexes exist
ANALYZE;
