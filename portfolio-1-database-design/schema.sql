-- CareBridge Clinics schema (PostgreSQL)
-- PRIMARY KEY = unique id of a row. NOT NULL = must have a value.
-- UNIQUE = no two rows may share the value. CHECK = a rule the value must obey.
-- REFERENCES = foreign key; the value must exist in the other table.

CREATE TABLE branches (
  branch_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- auto-numbered
  name       VARCHAR(100) NOT NULL UNIQUE,
  city       VARCHAR(60)  NOT NULL,
  address    VARCHAR(200),
  phone      VARCHAR(20)
);

CREATE TABLE departments (
  department_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name          VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE doctors (
  doctor_id      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  branch_id      INT NOT NULL REFERENCES branches(branch_id),
  department_id  INT NOT NULL REFERENCES departments(department_id),
  full_name      VARCHAR(120) NOT NULL,
  licence_number VARCHAR(40)  NOT NULL UNIQUE,
  email          VARCHAR(120) UNIQUE,
  phone          VARCHAR(20)
);

CREATE TABLE patients (
  patient_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  first_name    VARCHAR(60) NOT NULL,
  last_name     VARCHAR(60) NOT NULL,
  date_of_birth DATE NOT NULL CHECK (date_of_birth <= CURRENT_DATE),
  sex           VARCHAR(10) NOT NULL CHECK (sex IN ('female','male','other')),
  phone         VARCHAR(20),
  email         VARCHAR(120),
  address       VARCHAR(200),
  registered_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE appointments (
  appointment_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  patient_id      INT NOT NULL REFERENCES patients(patient_id),
  doctor_id       INT NOT NULL REFERENCES doctors(doctor_id),
  scheduled_start TIMESTAMPTZ NOT NULL,
  scheduled_end   TIMESTAMPTZ NOT NULL,
  status          VARCHAR(12) NOT NULL DEFAULT 'scheduled'
                  CHECK (status IN ('scheduled','completed','cancelled','no_show')),
  reason          VARCHAR(200),
  CHECK (scheduled_end > scheduled_start),
  UNIQUE (doctor_id, scheduled_start)  -- a doctor cannot be booked twice at the same time
);

CREATE TABLE visits (
  visit_id       INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  appointment_id INT NOT NULL UNIQUE REFERENCES appointments(appointment_id), -- one visit per appointment
  visit_date     TIMESTAMPTZ NOT NULL DEFAULT now(),
  notes          TEXT
);

CREATE TABLE diagnoses (
  diagnosis_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  visit_id       INT NOT NULL REFERENCES visits(visit_id),
  condition_name VARCHAR(150) NOT NULL,
  icd_code       VARCHAR(10)
);

CREATE TABLE drugs (
  drug_id        INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name           VARCHAR(120) NOT NULL UNIQUE,
  strength       VARCHAR(40),
  unit_price     NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0), -- NUMERIC for money, never FLOAT
  stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0) -- stock can never go negative
);

CREATE TABLE prescriptions (
  prescription_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  visit_id        INT NOT NULL REFERENCES visits(visit_id),
  drug_id         INT NOT NULL REFERENCES drugs(drug_id),
  dosage          VARCHAR(100) NOT NULL,
  duration_days   INT NOT NULL CHECK (duration_days > 0),
  quantity        INT NOT NULL CHECK (quantity > 0),
  dispensed_at    TIMESTAMPTZ  -- empty until the pharmacist hands the drug over
);

CREATE TABLE lab_orders (
  lab_order_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  visit_id     INT NOT NULL REFERENCES visits(visit_id),
  test_name    VARCHAR(120) NOT NULL,
  ordered_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  result_text  TEXT,
  resulted_at  TIMESTAMPTZ
);

CREATE TABLE payments (
  payment_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  visit_id   INT NOT NULL REFERENCES visits(visit_id),
  amount     NUMERIC(12,2) NOT NULL CHECK (amount > 0),
  method     VARCHAR(12) NOT NULL CHECK (method IN ('cash','card','transfer','insurance')),
  paid_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
