-- Builds ONE JSON document per patient (first 200 patients), one document per line.
-- Each document embeds that patient's visits, and each visit embeds its doctor,
-- diagnoses, prescriptions, lab orders and payments, so a whole record is one read.
-- Dates use MongoDB extended JSON ({"$date": ...}) so mongoimport stores real dates.
SELECT jsonb_build_object(
  '_id',           p.patient_id,
  'first_name',    p.first_name,
  'last_name',     p.last_name,
  'sex',           p.sex,
  'phone',         p.phone,
  'address',       p.address,
  'date_of_birth', jsonb_build_object('$date', to_char(p.date_of_birth, 'YYYY-MM-DD"T"00:00:00"Z"')),
  'registered_at', jsonb_build_object('$date', to_char(p.registered_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"')),
  'visits', COALESCE((
    SELECT jsonb_agg(
      jsonb_build_object(
        'visit_id',   v.visit_id,
        'visit_date', jsonb_build_object('$date', to_char(v.visit_date AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"')),
        'notes',      v.notes,
        'doctor', (
          SELECT jsonb_build_object('doctor_id', d.doctor_id, 'name', d.full_name,
                                    'branch', b.name, 'city', b.city)
          FROM doctors d JOIN branches b ON b.branch_id = d.branch_id
          WHERE d.doctor_id = a.doctor_id),
        'diagnoses', COALESCE((
          SELECT jsonb_agg(jsonb_build_object('condition_name', dg.condition_name, 'icd_code', dg.icd_code))
          FROM diagnoses dg WHERE dg.visit_id = v.visit_id), '[]'::jsonb),
        'prescriptions', COALESCE((
          SELECT jsonb_agg(jsonb_build_object('drug', dr.name, 'strength', dr.strength,
                                              'dosage', pr.dosage, 'duration_days', pr.duration_days,
                                              'quantity', pr.quantity))
          FROM prescriptions pr JOIN drugs dr ON dr.drug_id = pr.drug_id
          WHERE pr.visit_id = v.visit_id), '[]'::jsonb),
        'lab_orders', COALESCE((
          SELECT jsonb_agg(jsonb_build_object('test_name', l.test_name, 'result', l.result_text))
          FROM lab_orders l WHERE l.visit_id = v.visit_id), '[]'::jsonb),
        'payments', COALESCE((
          SELECT jsonb_agg(jsonb_build_object('amount', pay.amount, 'method', pay.method))
          FROM payments pay WHERE pay.visit_id = v.visit_id), '[]'::jsonb)
      ) ORDER BY v.visit_date)
    FROM visits v
    JOIN appointments a ON a.appointment_id = v.appointment_id
    WHERE a.patient_id = p.patient_id), '[]'::jsonb)
)::text
FROM patients p
WHERE p.patient_id <= 200
ORDER BY p.patient_id;
