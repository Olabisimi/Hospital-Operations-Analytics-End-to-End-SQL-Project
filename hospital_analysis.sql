-- HOSPITAL DATASET PROJECT
-- 1️. Create Database
-- Creates a new database for the hospital dataset
CREATE DATABASE hospital_db;

-- ===============================================
-- 2️. Create Raw Tables
-- These tables store the original imported dataset
-- No constraints besides primary keys at this stage
-- ===============================================
-- Patients Table
CREATE TABLE patients_raw (
    patient_id TEXT PRIMARY KEY,
    name TEXT,
    age TEXT,
    gender TEXT,
    blood_group TEXT,
    genotype TEXT,
    phone TEXT,
    address TEXT,
    registration_date TEXT
);

-- Staff Table
CREATE TABLE staff_raw (
    staff_id TEXT PRIMARY KEY,
    name TEXT,
    role TEXT,
    specialty TEXT,
    phone TEXT
);

-- Appointments Table
CREATE TABLE appointments_raw (
    appointment_id TEXT PRIMARY KEY,
    patient_id TEXT,
    doctor_id TEXT,
    date TEXT,
    reason TEXT,
    status TEXT
);

-- Admissions Table
CREATE TABLE admissions_raw (
    admission_id TEXT PRIMARY KEY,
    patient_id TEXT,
    ward TEXT,
    admit_date TEXT,
    discharge_date TEXT,
    length_of_stay TEXT,
    status TEXT
);

-- Bills Table
CREATE TABLE bills_raw (
    bill_id TEXT PRIMARY KEY,
    patient_id TEXT,
    amount TEXT,
    payer TEXT,
    status TEXT,
    date TEXT
);

-- Labs Table
CREATE TABLE labs_raw (
    lab_id TEXT PRIMARY KEY,
    patient_id TEXT,
	doctor_id TEXT,
    test_name TEXT,
    result TEXT,
	status TEXT,
    test_date TEXT
);

-- Prescriptions Table
CREATE TABLE prescriptions_raw (
    prescription_id TEXT PRIMARY KEY,
    patient_id TEXT,
    drug TEXT,
    dosage TEXT,
    duration_days TEXT,
    date TEXT
);

-- Surgeries Table
CREATE TABLE surgeries_raw (
    surgery_id TEXT PRIMARY KEY,
    patient_id TEXT,
    procedure TEXT,
    surgeon_id TEXT,
    date TEXT,
    outcome TEXT
);

-- Emergencies Table
CREATE TABLE emergencies_raw (
    emergency_id TEXT PRIMARY KEY,
    patient_id TEXT,
    cause TEXT,
    triage_level TEXT,
    arrival_time TEXT,
    outcome TEXT
);

-- Inventory Table
CREATE TABLE inventory_raw (
    item_id TEXT PRIMARY KEY,
    item_name TEXT,
    category TEXT,
    quantity TEXT,
    unit_price TEXT,
    last_restock TEXT
);

-- ===============================================
-- 3️. Import CSV Data
-- Replace '/path/to/file.csv' with actual file paths
-- ===============================================

\COPY patients_raw FROM '/path/to/patients.csv' DELIMITER ',' CSV HEADER;
\COPY staff_raw FROM '/path/to/staff.csv' DELIMITER ',' CSV HEADER;
\COPY appointments_raw FROM '/path/to/appointments.csv' DELIMITER ',' CSV HEADER;
\COPY admissions_raw FROM '/path/to/admissions.csv' DELIMITER ',' CSV HEADER;
\COPY bills_raw FROM '/path/to/bills.csv' DELIMITER ',' CSV HEADER;
\COPY labs_raw FROM '/path/to/labs.csv' DELIMITER ',' CSV HEADER;
\COPY prescriptions_raw FROM '/path/to/prescriptions.csv' DELIMITER ',' CSV HEADER;
\COPY surgeries_raw FROM '/path/to/surgeries.csv' DELIMITER ',' CSV HEADER;
\COPY emergencies_raw FROM '/path/to/emergencies.csv' DELIMITER ',' CSV HEADER;
\COPY inventory_raw FROM '/path/to/inventory.csv' DELIMITER ',' CSV HEADER;

-- ===============================================
-- 4️.  Patients Table
-- Check missing values, duplicates, distinct text columns, phone audits etcs
-- ===============================================
SELECT * FROM patients_raw;
-- Trimming(removing leading and trailing spaces)
UPDATE patients_raw
SET name = TRIM(name),
    gender = TRIM(gender),
    blood_group = TRIM(blood_group),
    genotype = TRIM(genotype),
    phone = TRIM(phone),
    address = TRIM(address);
	
-- Duplicates
SELECT patient_id, COUNT(*) AS cnt
FROM patients_raw
GROUP BY patient_id
HAVING COUNT(*) > 1;

-- Distinct text values
SELECT DISTINCT gender FROM patients_raw;
SELECT DISTINCT blood_group FROM patients_raw;
SELECT DISTINCT genotype FROM patients_raw;

-- Missing values summary
SELECT COUNT(*) AS total_rows,
       SUM(CASE WHEN patient_id IS NULL OR patient_id = '' THEN 1 ELSE 0 END) AS patient_id_missing,
       SUM(CASE WHEN name IS NULL OR name = '' THEN 1 ELSE 0 END) AS name_missing,
       SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS age_missing,
       SUM(CASE WHEN gender IS NULL OR gender = '' THEN 1 ELSE 0 END) AS gender_missing,
       SUM(CASE WHEN blood_group IS NULL OR blood_group = '' THEN 1 ELSE 0 END) AS blood_group_missing,
       SUM(CASE WHEN genotype IS NULL OR genotype = '' THEN 1 ELSE 0 END) AS genotype_missing,
       SUM(CASE WHEN phone IS NULL OR phone = '' THEN 1 ELSE 0 END) AS phone_missing
FROM patients_raw;
-- No missing values
-- Stadardizing 
UPDATE patients_raw
SET gender = 'Male' WHERE LOWER(gender) IN ('m','male');
UPDATE patients_raw
SET gender = 'Female' WHERE LOWER(gender) IN ('f','female');
-- Phone column audit
-- Checking Length, non-digit, text, >10, distribution
SELECT phone, LENGTH(phone) AS phone_length FROM patients_raw ORDER BY phone_length DESC LIMIT 20;
SELECT phone FROM patients_raw WHERE phone ~ '\D' LIMIT 20;
SELECT phone FROM patients_raw WHERE phone ~ '[A-Za-z]' LIMIT 20;
SELECT phone, LENGTH(phone) AS phone_length
FROM patients_raw
WHERE LENGTH(REGEXP_REPLACE(phone, '\D','','g')) > 10 LIMIT 20;
SELECT LENGTH(REGEXP_REPLACE(phone, '\D','','g')) AS cleaned_length,
       COUNT(*) AS count
FROM patients_raw
GROUP BY LENGTH(REGEXP_REPLACE(phone, '\D','','g'))
ORDER BY cleaned_length DESC;

-- Phone cleaning updating
UPDATE patients_raw
SET phone = REGEXP_REPLACE(phone, '\D','','g');
UPDATE patients_raw
SET phone = SUBSTRING(phone FROM 2)
WHERE LENGTH(phone) = 11 AND phone LIKE '0%';

ALTER TABLE patients_raw ADD COLUMN phone_invalid BOOLEAN;
UPDATE patients_raw
SET phone_invalid = CASE WHEN LENGTH(phone) <> 10 THEN TRUE ELSE FALSE END;
SELECT * FROM patients_raw;

-- ===============================================
-- 5. Staff Table 
-- Check missing values, duplicates, distinct text columns, phone audits
-- ===============================================
SELECT * FROM  staff_raw;
-- Trimming(removing leading and trailing spaces)
UPDATE staff_raw
SET 
	staff_id = TRIM(staff_id),
	name = TRIM(name),
    role = TRIM(role),
    specialty = TRIM(specialty),
    phone = TRIM(phone),
	hire_date = TRIM(hire_date);
	
-- Checking Duplicates	
SELECT staff_id, COUNT(*) AS cnt
FROM staff_raw
GROUP BY staff_id
HAVING COUNT(*) > 1;

--Checking unique values in text columns
SELECT DISTINCT role FROM staff_raw;
SELECT DISTINCT specialty FROM staff_raw;

-- Missing values, duplicates, distinct
SELECT COUNT(*) AS total_rows,
       SUM(CASE WHEN staff_id IS NULL OR staff_id = '' THEN 1 ELSE 0 END) AS staff_id_missing,
       SUM(CASE WHEN name IS NULL OR name = '' THEN 1 ELSE 0 END) AS name_missing,
       SUM(CASE WHEN role IS NULL OR role = '' THEN 1 ELSE 0 END) AS role_missing,
       SUM(CASE WHEN specialty IS NULL OR specialty = '' THEN 1 ELSE 0 END) AS specialty_missing,
       SUM(CASE WHEN phone IS NULL OR phone = '' THEN 1 ELSE 0 END) AS phone_missing
FROM staff_raw;
-- There is missing values in specialty column, to determine the percentage of missing values in the column
SELECT 
	COUNT(*) AS total_rows,
	SUM(
		CASE WHEN specialty IS NULL OR specialty = '' THEN 1 ELSE 0 END) AS specialty_missing_count,
		ROUND (100.0 * SUM(CASE WHEN specialty IS NULL OR specialty = '' THEN 1 ELSE 0 END) / COUNT(*), 2) AS specialty_missing_percentage
FROM staff_raw;

--Verifying cause of missingness in specialty column
-- Checking staff roles
SELECT role, count(*) FROM staff_raw GROUP BY role;
-- Checking specialty_missing_percentage for each staff role to be sure which role has missing values
SELECT
	role,
	COUNT(*) AS total,
	SUM(
		CASE WHEN specialty IS NULL OR specialty = '' THEN 1 ELSE 0 END) AS specialty_missing_count,
		ROUND (100.0 * SUM(CASE WHEN specialty IS NULL OR specialty = '' THEN 1 ELSE 0 END) / COUNT(*), 2) AS specialty_missing_percentage
FROM staff_raw
GROUP BY role;
-- ==============================================================
-- INSIGHT:
-- Only Doctors have 0 missing specialty values i.e only rows where role = 'Doctor' have a value in specialty column
-- The overall high missing percentage in specialty (81%) is due to non-doctor roles (e.g., nurses, admin etc) 
-- where specialty is not applicable.

-- This is not a data quality issue but a modelling issue.
-- During the data modelling stage:
-- 1. The staff table will store general employee information.
-- 2. A separate doctors table will be created.
-- 3. Only doctors will be inserted into the doctors table.
-- 4. The specialty column will be defined as NOT NULL in the doctors table.
-- This normalization removes structurally irrelevant NULL values
-- and enforces data integrity at the schema level.
-- ==============================================================

-- Phone audits
SELECT phone, LENGTH(phone) AS phone_length FROM staff_raw ORDER BY phone_length DESC LIMIT 20;
SELECT phone FROM staff_raw WHERE phone ~ '\D' LIMIT 20;
SELECT phone FROM staff_raw WHERE phone ~ '[A-Za-z]' LIMIT 20;
SELECT phone, LENGTH(phone) AS phone_length
FROM staff_raw
WHERE LENGTH(REGEXP_REPLACE(phone, '\D','','g')) > 10 LIMIT 20;
SELECT LENGTH(REGEXP_REPLACE(phone, '\D','','g')) AS cleaned_length,
       COUNT(*) AS count
FROM staff_raw
GROUP BY LENGTH(REGEXP_REPLACE(phone, '\D','','g'))
ORDER BY cleaned_length DESC;
-- Updating
UPDATE staff_raw
SET phone = REGEXP_REPLACE(phone, '\D','','g');
UPDATE staff_raw
SET phone = SUBSTRING(phone FROM 2)
WHERE LENGTH(phone) = 11 AND phone LIKE '0%';
--flags
ALTER TABLE staff_raw ADD COLUMN phone_invalid BOOLEAN;
UPDATE staff_raw
SET phone_invalid = CASE WHEN LENGTH(phone) <> 10 THEN TRUE ELSE FALSE END;
ALTER TABLE staff_raw ADD COLUMN specialty_missing BOOLEAN;
UPDATE staff_raw
SET specialty_missing = CASE WHEN specialty IS NULL OR specialty = '' THEN TRUE ELSE FALSE END;

-- ===============================================
-- 6. Appointments Table
-- ===============================================
SELECT * FROM appointments_raw;
-- Trimming(removing leading and trailing spaces)
UPDATE appointments_raw
SET 
	appointment_id = TRIM(appointment_id),
	patient_id = TRIM(patient_id),
	doctor_id = TRIM(doctor_id),
	date = TRIM(date),
	reason = TRIM(reason),
    status = TRIM(status);

-- Checking for duplicates
SELECT appointment_id, COUNT(*) AS cnt
FROM appointments_raw
GROUP BY appointment_id
HAVING COUNT(*) > 1;
-- Checking for distinct values in text column
SELECT DISTINCT status FROM appointments_raw;
SELECT DISTINCT reason FROM appointments_raw;
-- Checking for missing values
SELECT COUNT(*) AS total_rows,
       SUM(CASE WHEN appointment_id IS NULL OR appointment_id = '' THEN 1 ELSE 0 END) AS appointment_id_missing,
       SUM(CASE WHEN patient_id IS NULL THEN 1 ELSE 0 END) AS patient_id_missing,
       SUM(CASE WHEN doctor_id IS NULL THEN 1 ELSE 0 END) AS doctor_id_missing,
       SUM(CASE WHEN date IS NULL OR date = '' THEN 1 ELSE 0 END) AS date_missing,
       SUM(CASE WHEN reason IS NULL OR reason = '' THEN 1 ELSE 0 END) AS reason_missing,
       SUM(CASE WHEN status IS NULL OR status = '' THEN 1 ELSE 0 END) AS status_missing
FROM appointments_raw;
-- No missing value

-- ===============================================
-- 7. Admissions Table
-- ===============================================
SELECT * FROM admissions_raw
-- Checking duplicates
SELECT admission_id, COUNT(*) AS cnt
FROM admissions_raw
GROUP BY admission_id
HAVING COUNT(*) > 1;
-- Trimming extra spaces
UPDATE admissions_raw
SET 
	admission_id = TRIM(admission_id),
	patient_id = TRIM(patient_id),
	doctor_id = TRIM(patient_id),
	ward = TRIM(ward),
	admit_date = TRIM(admit_date),
    discharge_date = TRIM(discharge_date),
	length_of_stay = TRIM(length_of_stay),
    status = TRIM(status);
-- Checking for unique values in text columns
SELECT DISTINCT ward FROM admissions_raw;
SELECT DISTINCT status FROM admissions_raw;
-- checking for missing rows
SELECT COUNT(*) AS total_rows,
       SUM(CASE WHEN admission_id IS NULL OR admission_id = '' THEN 1 ELSE 0 END) AS admission_id_missing,
       SUM(CASE WHEN patient_id IS NULL THEN 1 ELSE 0 END) AS patient_id_missing,
	   SUM(CASE WHEN doctor_id IS NULL THEN 1 ELSE 0 END) AS doctor_id_missing,
       SUM(CASE WHEN ward IS NULL OR ward = '' THEN 1 ELSE 0 END) AS ward_missing,
       SUM(CASE WHEN admit_date IS NULL OR admit_date = '' THEN 1 ELSE 0 END) AS admit_date_missing,
       SUM(CASE WHEN discharge_date IS NULL OR discharge_date = '' THEN 1 ELSE 0 END) AS discharge_date_missing,
       SUM(CASE WHEN length_of_stay IS NULL THEN 1 ELSE 0 END) AS length_of_stay_missing,
       SUM(CASE WHEN status IS NULL OR status = '' THEN 1 ELSE 0 END) AS status_missing
FROM admissions_raw;
-- There is missing values in discharge date column
-- Verifying the cause of missing values in discharge date(to see if the status are still admitted for all missing)
SELECT 
    COUNT(*) AS total_missing_discharge,
    SUM(CASE WHEN status = 'Still Admitted' THEN 1 ELSE 0 END) AS still_admitted_count,
    SUM(CASE WHEN status <> 'Still Admitted' OR status IS NULL THEN 1 ELSE 0 END) AS other_status_count
FROM admissions_raw
WHERE discharge_date IS NULL;
-- still_admitted_count = total_missing_discharge, hence this is structural missing and not data quality issue and as such will be left as it is 


-- ===============================================
-- 8. Bills Table 
-- ===============================================
SELECT * FROM bills_raw;
-- Trimming extra spaces
UPDATE bills_raw
SET 
	bill_id = TRIM(bill_id),
	patient_id = TRIM(patient_id),
	amount = TRIM(amount),
	payer = TRIM(payer),
	status = TRIM(status),
	date = TRIM(date);
-- Checking for unique values in text columns
SELECT DISTINCT payer FROM bills_raw;
SELECT DISTINCT status FROM bills_raw;

-- Checking duplicates
SELECT bill_id, COUNT(*) AS cnt
FROM bills_raw
GROUP BY bill_id
HAVING COUNT(*) > 1;
-- checking for missing rows
SELECT COUNT(*) AS total_rows,
       SUM(CASE WHEN bill_id IS NULL OR bill_id = '' THEN 1 ELSE 0 END) AS bill_id_missing,
       SUM(CASE WHEN patient_id IS NULL OR patient_id = '' THEN 1 ELSE 0 END) AS patient_id_missing,
	   SUM(CASE WHEN amount IS NULL OR amount = '' THEN 1 ELSE 0 END) AS amount_missing,
       SUM(CASE WHEN payer IS NULL OR payer = '' THEN 1 ELSE 0 END) AS payer_missing,
       SUM(CASE WHEN date IS NULL OR date = '' THEN 1 ELSE 0 END) AS date_missing,
       SUM(CASE WHEN status IS NULL OR status = '' THEN 1 ELSE 0 END) AS status_missing
FROM bills_raw;
-- No missing values

-- ===============================================
--9.  Labs Table 
-- ===============================================
SELECT * FROM labs_raw
-- Checking duplicates
SELECT lab_id, COUNT(*) AS cnt
FROM labs_raw
GROUP BY lab_id
HAVING COUNT(*) > 1;
-- Trimming extra spaces
UPDATE labs_raw
SET 
	lab_id = TRIM(lab_id),
	patient_id = TRIM(patient_id),
	doctor_id = TRIM(patient_id),
	test_name = TRIM(test_name),
	result = TRIM(result),
	status = TRIM(status),
	test_date = TRIM(test_date);
	
-- checking for missing rows
SELECT COUNT(*) AS total_rows,
       SUM(CASE WHEN lab_id IS NULL OR lab_id = '' THEN 1 ELSE 0 END) AS lab_id_missing,
       SUM(CASE WHEN patient_id IS NULL THEN 1 ELSE 0 END) AS patient_id_missing,
	   SUM(CASE WHEN doctor_id IS NULL THEN 1 ELSE 0 END) AS doctor_id_missing,
       SUM(CASE WHEN test_name IS NULL OR test_name = '' THEN 1 ELSE 0 END) AS test_name_missing,
       SUM(CASE WHEN test_date IS NULL OR test_date = '' THEN 1 ELSE 0 END) AS test_date_missing,
	   SUM(CASE WHEN result IS NULL OR result = '' THEN 1 ELSE 0 END) AS result_missing,
	   SUM(CASE WHEN status IS NULL OR status = '' THEN 1 ELSE 0 END) AS status_missing
FROM labs_raw;

-- There is missing values in result column, to determine the percentage of missing values in the column
SELECT 
	COUNT(*) AS total_rows,
	SUM(
		CASE WHEN result IS NULL OR result = '' THEN 1 ELSE 0 END) AS result_missing_count,
		ROUND (100.0 * SUM(CASE WHEN result IS NULL OR result = '' THEN 1 ELSE 0 END) / COUNT(*), 2) AS result_missing_percentage
FROM labs_raw;
-- Verifying if missing results are of pending status
SELECT 
    status,
    COUNT(*) AS total_rows,
    COUNT(result) AS non_null_results,
    COUNT(*) - COUNT(result) AS null_results
FROM labs_raw
GROUP BY status
ORDER BY status;
-- ==============================================================
-- INSIGHT:
-- Missing lab results exist because the Test results are not yet updated as they are of pending status.
-- ==============================================================
-- Checking for unique values in text columns
SELECT DISTINCT test_name FROM labs_raw;
SELECT DISTINCT result FROM labs_raw;
SELECT DISTINCT status FROM labs_raw;

-- ===============================================
--10.  Prescriptions Table Audit & Cleaning
-- ===============================================
SELECT * FROM prescriptions_raw
-- Trimming extra spaces
UPDATE prescriptions_raw
SET 
	prescription_id = TRIM(prescription_id),
	patient_id = TRIM(patient_id),
	doctor_id = TRIM(patient_id),
	dosage = TRIM(dosage),
	duration_days = TRIM(duration_days),
	date = TRIM(date),
	drug = TRIM(drug);
-- Checking duplicates
SELECT prescription_id, COUNT(*) AS cnt
FROM prescriptions_raw
GROUP BY prescription_id
HAVING COUNT(*) > 1;

-- checking for missing rows
SELECT COUNT(*) AS total_rows,
       SUM(CASE WHEN prescription_id IS NULL OR prescription_id = '' THEN 1 ELSE 0 END) AS prescription_id_missing,
       SUM(CASE WHEN patient_id IS NULL THEN 1 ELSE 0 END) AS patient_id_missing,
	   SUM(CASE WHEN doctor_id IS NULL THEN 1 ELSE 0 END) AS doctor_id_missing,
       SUM(CASE WHEN dosage IS NULL OR dosage = '' THEN 1 ELSE 0 END) AS dosage_missing,
	   SUM(CASE WHEN duration_days IS NULL OR duration_days = '' THEN 1 ELSE 0 END) AS duration_days_missing,
       SUM(CASE WHEN date IS NULL OR date = '' THEN 1 ELSE 0 END) AS date_missing,
	   SUM(CASE WHEN drug IS NULL OR drug = '' THEN 1 ELSE 0 END) AS drug_missing
FROM prescriptions_raw;
-- No missing values
-- Checking for unique values in text columns
SELECT DISTINCT drug FROM prescriptions_raw;


-- ===============================================
--11. Surgeries Table
-- ===============================================
SELECT * FROM surgeries_raw
-- Checking duplicates
SELECT surgery_id, COUNT(*) AS cnt
FROM surgeries_raw
GROUP BY surgery_id
HAVING COUNT(*) > 1;
-- Trimming extra spaces
UPDATE surgeries_raw
SET 
	surgery_id = TRIM(surgery_id),
	patient_id = TRIM(patient_id),
	surgeon_id = TRIM(surgeon_id),
	procedure = TRIM(procedure),
	date = TRIM(date),
	outcome = TRIM(outcome);
-- checking for missing rows
SELECT COUNT(*) AS total_rows,
       SUM(CASE WHEN surgery_id IS NULL OR surgery_id = '' THEN 1 ELSE 0 END) AS surgery_id_missing,
       SUM(CASE WHEN patient_id IS NULL THEN 1 ELSE 0 END) AS patient_id_missing,
	   SUM(CASE WHEN surgeon_id IS NULL THEN 1 ELSE 0 END) AS surgeon_id_missing,
       SUM(CASE WHEN procedure IS NULL OR procedure = '' THEN 1 ELSE 0 END) AS procedure_missing,
       SUM(CASE WHEN date IS NULL OR date = '' THEN 1 ELSE 0 END) AS date_missing,
	   SUM(CASE WHEN outcome IS NULL OR outcome = '' THEN 1 ELSE 0 END) AS outcome_missing
FROM surgeries_raw;
-- No missing values

-- ===============================================
--12.  Emergencies Table
-- ===============================================
SELECT * FROM emergencies_raw
-- Trimming extra spaces
UPDATE emergencies_raw
SET 
	emergency_id = TRIM(emergency_id),
	patient_id = TRIM(patient_id),
	cause = TRIM(cause),
	triage_level = TRIM(triage_level),
	arrival_time = TRIM(arrival_time),
	outcome = TRIM(outcome);
-- Checking duplicates
SELECT emergency_id, COUNT(*) AS cnt
FROM emergencies_raw
GROUP BY emergency_id
HAVING COUNT(*) > 1;
-- Checking for unique values in text columns
SELECT DISTINCT triage_level FROM emergencies_raw;
SELECT DISTINCT outcome FROM emergencies_raw;
SELECT DISTINCT cause FROM emergencies_raw;

-- checking for missing rows
SELECT COUNT(*) AS total_rows,
       SUM(CASE WHEN emergency_id IS NULL OR emergency_id = '' THEN 1 ELSE 0 END) AS emergency_id_missing,
       SUM(CASE WHEN patient_id IS NULL THEN 1 ELSE 0 END) AS patient_id_missing,
	   SUM(CASE WHEN cause IS NULL THEN 1 ELSE 0 END) AS cause_missing,
       SUM(CASE WHEN triage_level IS NULL OR triage_level = '' THEN 1 ELSE 0 END) AS triage_level_missing,
       SUM(CASE WHEN arrival_time IS NULL OR arrival_time = '' THEN 1 ELSE 0 END) AS arrival_time_missing,
	   SUM(CASE WHEN outcome IS NULL OR outcome = '' THEN 1 ELSE 0 END) AS outcome_missing
FROM emergencies_raw;
-- No missing values

-- ===============================================
--13.  Inventory Table
-- ===============================================
SELECT * FROM inventory_raw
-- Trimming extra spaces
UPDATE inventory_raw
SET 
	item_id = TRIM(item_id),
	item_name = TRIM(item_name),
	category = TRIM(category),
	quantity = TRIM(quantity),
	unit_price = TRIM(unit_price),
	last_restock = TRIM(last_restock);

-- Checking duplicates
SELECT item_id, COUNT(*) AS cnt
FROM inventory_raw
GROUP BY item_id
HAVING COUNT(*) > 1;

-- Checking for unique values in text columns
SELECT DISTINCT item_name FROM inventory_raw;
SELECT DISTINCT category FROM inventory_raw;

-- checking for missing rows
SELECT COUNT(*) AS total_rows,
       SUM(CASE WHEN item_id IS NULL OR item_id = '' THEN 1 ELSE 0 END) AS item_id_missing,
       SUM(CASE WHEN item_name IS NULL OR item_name = '' THEN 1 ELSE 0 END) AS item_name_missing,
	   SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS category_missing,
       SUM(CASE WHEN quantity IS NULL OR quantity = '' THEN 1 ELSE 0 END) AS quantity_missing,
       SUM(CASE WHEN unit_price IS NULL OR unit_price = '' THEN 1 ELSE 0 END) AS unit_price_missing,
	   SUM(CASE WHEN last_restock IS NULL OR last_restock = '' THEN 1 ELSE 0 END) AS last_restock_missing
FROM inventory_raw;
-- No missing values


-- Structured relational database layer
-- Defining modelled tables
__ Patients
SELECT * FROM patients_raw;        
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    name TEXT NOT NULL,
    age INT CHECK (age > 0),
    gender TEXT CHECK (gender IN ('Male','Female')),
    blood_group TEXT,
    genotype TEXT,
    phone VARCHAR(18),
	phone_invalid BOOLEAN,
    address TEXT,
    registration_date DATE
);

-- Staff and normalized Doctors from staff
SELECT * FROM staff_raw;        
CREATE TABLE staff (
    staff_id INT PRIMARY KEY,
    name TEXT NOT NULL,
    role TEXT NOT NULL,
	phone VARCHAR(18),
	phone_invalid BOOLEAN,
	hire_date DATE);
CREATE TABLE doctors (
    staff_id INT PRIMARY KEY,specialty TEXT NOT NULL,
    CONSTRAINT fk_doctor_staff FOREIGN KEY (staff_id) REFERENCES staff(staff_id));
	
--Appointments
SELECT * FROM appointments_raw;        
CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    reason TEXT,
    status TEXT CHECK (status IN ('Completed','Missed','Cancelled','Pending')),
    CONSTRAINT fk_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    CONSTRAINT fk_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(staff_id)
);

--Admissions
SELECT * FROM admissions_raw ;        
CREATE TABLE admissions (
    admission_id INT PRIMARY KEY,
    patient_id INT NOT NULL,
	doctor_id INT NOT NULL,
    ward TEXT,
    admit_date DATE NOT NULL,
    discharge_date DATE,
    length_of_stay INT,
    status TEXT ,
    CONSTRAINT fk_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
	CONSTRAINT fk_doctor FOREIGN KEY (doctor_id) REFERENCES staff(staff_id)
);

-- Bills
SELECT* FROM bills_raw;        

CREATE TABLE bills (
    bill_id INT PRIMARY KEY,
    patient_id INT NOT NULL,
    amount NUMERIC(12,2),
    payer TEXT,
    status TEXT CHECK (status IN ('Paid','Pending','Partially Paid')),
    bill_date DATE NOT NULL,
    CONSTRAINT fk_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);


--Labs
SELECT * FROM labs_raw;
CREATE TABLE labs (
    lab_id INT PRIMARY KEY,
    patient_id INT NOT NULL,
	doctor_id INT NOT NULL,
	test_name TEXT NOT NULL,
    test_date DATE NOT NULL,
    result TEXT,
    status TEXT CHECK (status IN ('Pending','Completed')),
    CONSTRAINT fk_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    CONSTRAINT chk_result_status CHECK (
        (status = 'Completed' AND result IS NOT NULL)
        OR
        (status IN ('Pending') AND result IS NULL)));
	
--Prescriptions
SELECT * FROM prescriptions_raw;        
CREATE TABLE prescriptions (
    prescription_id INT PRIMARY KEY,
    patient_id INT NOT NULL,
	drug TEXT NOT NULL,
    dosage TEXT,
    duration_days INT,
    prescription_date DATE,
    CONSTRAINT fk_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);
--Surgery
SELECT * FROM surgeries_raw;        

CREATE TABLE surgeries (
    surgery_id INT PRIMARY KEY,
    patient_id INT NOT NULL,
    surgeon_id INT NOT NULL,
    procedure TEXT NOT NULL,
    surgery_date DATE,
    outcome TEXT CHECK (outcome IN ('Successful','Complications','Fatal')),
    CONSTRAINT fk_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    CONSTRAINT fk_surgeon FOREIGN KEY (surgeon_id) REFERENCES doctors(staff_id)
);

-- Emergencies
SELECT * FROM emergencies_raw;        

CREATE TABLE emergencies (
    emergency_id INT PRIMARY KEY,
    patient_id INT NOT NULL,
    cause TEXT,
    triage_level TEXT CHECK (triage_level IN ('Red','Yellow','Green')),
    arrival_time TIMESTAMP,
    outcome TEXT CHECK (outcome IN ('Admitted','Treated & Discharged','Deceased')),
    CONSTRAINT fk_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);


--Inventory
SELECT * FROM inventory_raw;        

CREATE TABLE inventory (
    item_id INT PRIMARY KEY,
    item_name TEXT NOT NULL,
    category TEXT CHECK (category IN ('Drug','Lab Supply')),
    quantity INT,
    unit_price NUMERIC(10,2),
    last_restock DATE
);


-- Inserting data into the modelled tables
-- Insert cleaned patients
-- Insert all patients from raw table, casting types
INSERT INTO patients (
    patient_id, name, age, gender, blood_group, genotype, phone, phone_invalid, address, registration_date
)
SELECT
    patient_id::INT,
    name,
    age::INT,
    INITCAP(gender) AS gender,  -- converts 'male' -> 'Male', 'female' -> 'Female'
    blood_group,
    genotype,
    phone,
    phone_invalid::BOOLEAN,
    address,
    registration_date::DATE
FROM patients_raw;
SELECT * FROM patients

-- Insert all staff including phone, hire date, invalid phone flag
INSERT INTO staff (
    staff_id, name, role, phone, phone_invalid, hire_date
)
SELECT
    staff_id::INT,
    name,
    role,
    phone,
    phone_invalid::BOOLEAN,
    hire_date::DATE
FROM staff_raw;
SELECT * FROM staff;

-- Insert only doctors with specialties
INSERT INTO doctors (
    staff_id, specialty
)
SELECT
    staff_id::INT,
    specialty
FROM staff_raw
WHERE role = 'Doctor';
SELECT * FROM doctors;
-- Map appointment date from raw table
INSERT INTO appointments (
    appointment_id, patient_id, doctor_id, appointment_date, reason, status
)
SELECT
    appointment_id::INT,
    patient_id::INT,
    doctor_id::INT,
    date::DATE AS appointment_date,
    reason,
    status
FROM appointments_raw;
SELECT * FROM appointments;
-- Include doctor_id from raw
SELECT * FROM admissions;
INSERT INTO admissions (
    admission_id, patient_id, doctor_id, ward, admit_date, discharge_date, length_of_stay, status
)
SELECT
    admission_id::INT,
    patient_id::INT,
    doctor_id::INT,
    ward,
    admit_date::DATE,
    discharge_date::DATE,
    length_of_stay::INT,
    status
FROM admissions_raw;
-- Bills
INSERT INTO bills (
    bill_id, patient_id, amount, payer, status, bill_date
)
SELECT
    bill_id::INT,
    patient_id::INT,
    amount::NUMERIC,
    payer,
    status,
    date::DATE AS bill_date
FROM bills_raw;

-- Include doctor_id and derive status
INSERT INTO labs (
    lab_id,
    patient_id,
    doctor_id,
    test_name,
    test_date,
    result,
    status
)
SELECT
    lab_id::INT,
    patient_id::INT,
    doctor_id::INT,
    test_name,
    test_date::DATE,
    result,
    status
FROM labs_raw;
SELECT * FROM labs;
-- Include doctor_id
INSERT INTO prescriptions (
    prescription_id, patient_id,drug, dosage, duration_days, prescription_date
)
SELECT
    prescription_id::INT,
    patient_id::INT,
    drug,
    dosage,
    duration_days::INT,
    date::DATE AS prescription_date
FROM prescriptions_raw;

-- surgeon_id comes from doctor
INSERT INTO surgeries (
    surgery_id, patient_id, surgeon_id, procedure, surgery_date, outcome
)
SELECT
    surgery_id::INT,
    patient_id::INT,
    surgeon_id::INT,
    procedure,
    date::DATE AS surgery_date,
    outcome
FROM surgeries_raw;
SELECT * FROM surgeries;
-- Emergency
INSERT INTO emergencies (
    emergency_id, patient_id, cause, triage_level, arrival_time, outcome
)
SELECT
    emergency_id::INT,
    patient_id::INT,
    cause,
    triage_level,
    arrival_time::TIMESTAMP,
    outcome
FROM emergencies_raw;
SELECT * FROM emergencies;

--Inventory
INSERT INTO inventory (
    item_id, item_name, category, quantity, unit_price, last_restock
)
SELECT
    item_id::INT,
    item_name,
    category,
    quantity::INT,
    unit_price::NUMERIC,
    last_restock::DATE
FROM inventory_raw;
SELECT * FROM inventory;

-- Checking all models table
SELECT * FROM patients;
SELECT * FROM staff;
SELECT * FROM doctors;
SELECT * FROM appointments;
SELECT * FROM admissions;
SELECT * FROM bills;
SELECT * FROM labs;
SELECT * FROM surgeries;
SELECT * FROM emergencies;
SELECT * FROM prescriptions;
SELECT * FROM inventory;

--ANALYTICS
-- 1. Patient & Admission Insights 
-- Q1: How many patients are currently admitted vs. discharged?
SELECT * FROM admissions;
SELECT DISTINCT status FROM admissions
SELECT 
    CASE 
        WHEN discharge_date IS NULL THEN 'Still Admitted'  -- If discharge_date is null, patient is still admitted
        ELSE 'Discharged'                                      -- Otherwise, patient has been discharged
    END AS admission_status,
    COUNT(*) AS patient_count                                  -- Count number of patients in each category
FROM admissions
GROUP BY admission_status;                                     -- Group by admission status to get counts per category


--Q2: Which patients had the longest cumulative length of stay across multiple admissions?
SELECT 
    patient_id,                                                 -- Select the patient identifier
    SUM(length_of_stay) AS total_length_of_stay                 -- Sum length_of_stay across all admissions per patient
FROM admissions
GROUP BY patient_id                                            -- Group by patient to get cumulative stay
ORDER BY total_length_of_stay DESC                             -- Order descending to get patients with longest stay first
LIMIT 3;                                                      -- Limit to top 3 patients for quick insight


--Q3: Identify patients with readmissions within 30 days i.e did the patient come back within 30 days?
WITH patient_admissions AS (
    SELECT 
        patient_id,
        admit_date,
        discharge_date,
        LEAD(admit_date) OVER(PARTITION BY patient_id ORDER BY admit_date) AS next_admit_date
        -- Use LEAD to get the admit date of the next admission per patient
    FROM admissions
)
SELECT 
    patient_id,
    COUNT(*) AS readmission_count                                -- Count number of readmissions within 30 days
FROM patient_admissions
WHERE next_admit_date IS NOT NULL                               -- Only consider patients with a next admission
  AND next_admit_date - discharge_date <= 30                    -- Check if the next admission is within 30 days of discharge
GROUP BY patient_id
ORDER BY readmission_count DESC;


-- Q4: Determine the gap in days between consecutive admissions per patient
SELECT 
    patient_id,
    admit_date,
    discharge_date,
    LEAD(admit_date) OVER(PARTITION BY patient_id ORDER BY admit_date) - discharge_date AS gaps_before_readmission
    -- Calculate difference between current discharge and next admission date using LAG or LEAD
FROM admissions
ORDER BY patient_id, admit_date;
-- The query above shows some overlap
-- Detecting overlapping admissions
WITH next_admits AS (
    SELECT
        patient_id,
        admit_date,
        discharge_date,
        LEAD(admit_date) OVER (PARTITION BY patient_id ORDER BY admit_date) AS next_admit_date
    FROM admissions
)
SELECT *
FROM next_admits
WHERE discharge_date IS NULL
   OR next_admit_date < discharge_date
ORDER BY patient_id, admit_date;
-- Add a flag column for the overlap admission
ALTER TABLE admissions
ADD COLUMN IF NOT EXISTS overlap_flag BOOLEAN DEFAULT FALSE;

--  Update the flag for overlapping admissions
WITH next_admits AS (
    SELECT
        patient_id,
        admit_date,
        discharge_date,
        LEAD(admit_date) OVER (PARTITION BY patient_id ORDER BY admit_date) AS next_admit_date
    FROM admissions
)
UPDATE admissions a
SET overlap_flag = TRUE
FROM next_admits t
WHERE a.patient_id = t.patient_id
  AND a.admit_date = t.admit_date
  AND (a.discharge_date IS NULL OR a.discharge_date >= t.next_admit_date);

SELECT * FROM admissions;
SELECT DISTINCT overlap_flag FROM admissions;
SELECT COUNT(overlap_flag) FROM admissions WHERE overlap_flag = 'True';



--Q5: Analyze average length of stay by ward and doctor
SELECT 
    ward,
    doctor_id,
    AVG(length_of_stay) AS avg_stay                             -- Average stay per ward per doctor
FROM admissions
GROUP BY ROLLUP(ward, doctor_id)                                -- Use ROLLUP to get subtotals by ward, by doctor, and overall total
ORDER BY ward, doctor_id;

--Q6: Track trends: admissions per month over multiple years
SELECT 
    EXTRACT(YEAR FROM admit_date) AS year,                      -- Extract the year from admit_date
    EXTRACT(MONTH FROM admit_date) AS month_num,-- Extract the month as number
	TO_CHAR(admit_date, 'Month') AS month_full_name,-- Extract the month as full name
	TO_CHAR(admit_date, 'Mon') AS month_abbr,-- Extract the month as abbr
	LEFT(TO_CHAR(admit_date, 'Mon'), 1) AS month_initial,-- Extract the month as initial
    COUNT(*) AS admissions_count                                 -- Count of admissions per month
FROM admissions
GROUP BY year, month_num, month_full_name, month_abbr, month_initial                                      -- Group by year and month
ORDER BY year, month_num;


--Q7: Find the age distribution of patients by ward type and highlight outliers
SELECT ward,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY age) AS q1,    -- 25th percentile
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY age) AS median, -- Median age
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY age) AS q3,    -- 75th percentile
    MAX(age) AS max_age, MIN(age) AS min_age
FROM patients
JOIN admissions USING (patient_id)                               -- Join to admissions to get ward info
GROUP BY ward
ORDER BY ward;

-- Flag age outliers per ward
WITH patient_ward AS (
    SELECT a.ward, p.patient_id, p.age
    FROM patients p
    JOIN admissions a
        ON p.patient_id = a.patient_id),
ward_stats AS (
    SELECT ward,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY age) AS q1,
        PERCENTILE_CONT(0.5)  WITHIN GROUP (ORDER BY age) AS median,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY age) AS q3
    FROM patient_ward
    GROUP BY ward)
SELECT pw.ward, pw.patient_id, pw.age, ws.q1, ws.median, ws.q3,
    CASE
        WHEN pw.age < ws.q1 - 1.5 * (ws.q3 - ws.q1) THEN 'Outlier Low'
        WHEN pw.age > ws.q3 + 1.5 * (ws.q3 - ws.q1) THEN 'Outlier High'
        ELSE 'Normal'
    END AS outlier_flag
FROM patient_ward pw
JOIN ward_stats ws
    ON pw.ward = ws.ward
ORDER BY pw.ward, pw.age;


--Q8: Identify patients without any lab tests or prescriptions
SELECT p.patient_id, p.name
FROM patients p
LEFT JOIN labs l ON p.patient_id = l.patient_id                 -- Left join to labs
LEFT JOIN prescriptions pr ON p.patient_id = pr.patient_id      -- Left join to prescriptions
WHERE l.lab_id IS NULL AND pr.prescription_id IS NULL;          -- Filter patients with no labs and no prescriptions


--Staff & Doctor Insights 
--Q1: Which doctors handle the highest number of admissions or lab tests?
SELECT * FROM doctors;
SELECT * FROM admissions;
SELECT * FROM staff;
SELECT * FROM labs;
SELECT 
    s.staff_id,
    s.name,
    COUNT(DISTINCT a.admission_id) AS total_admissions,          -- Count admissions per doctor
    COUNT(DISTINCT l.lab_id) AS total_lab_tests                  -- Count lab tests per doctor
FROM staff s
LEFT JOIN admissions a ON s.staff_id = a.doctor_id            -- Join to admissions table on doctor_id
LEFT JOIN labs l ON s.staff_id = l.doctor_id                  -- Join to labs table on doctor_id
WHERE s.role = 'Doctor'                                        -- Only consider staff who are doctors
GROUP BY s.staff_id, s.name
ORDER BY total_admissions DESC, total_lab_tests DESC
LIMIT 5;

--Q2: Identify doctors with no specialty assigned and analyze the roles they perform
SELECT s.staff_id, s.name, s.role, d.specialty
FROM staff s
LEFT JOIN doctors d ON s.staff_id = d.staff_id                -- Join to doctors table
WHERE d.specialty IS NULL;   -- Filter for missing specialty

--Q3: Compute the average number of patients per doctor per month
SELECT doctor_id,
    EXTRACT(YEAR FROM admit_date) AS year,
    EXTRACT(MONTH FROM admit_date) AS month,
    COUNT(DISTINCT patient_id) AS patient_count,                -- Number of unique patients per doctor per month
    AVG(COUNT(DISTINCT patient_id)) OVER (PARTITION BY doctor_id) AS avg_per_doctor-- Rolling average per doctor across all months
FROM admissions
GROUP BY doctor_id, year, month
ORDER BY doctor_id, year, month;

--Q4: Compare admissions handled by nurses vs. doctors
SELECT s.role,
    COUNT(*) AS total_admissions
FROM admissions a
JOIN staff s ON a.doctor_id = s.staff_id                       -- Join admissions to staff
WHERE s.role IN ('Doctor', 'Nurse')                            -- Only compare doctors and nurses
GROUP BY s.role;

--Q5: Identify doctors with the longest average patient stay
SELECT 
    doctor_id,
    AVG(length_of_stay) AS avg_length_of_stay                   -- Calculate average stay per doctor
FROM admissions
GROUP BY doctor_id
ORDER BY avg_length_of_stay DESC                               -- Rank doctors by longest average stay
LIMIT 3;                                                      -- Top 3


--Lab & Test Insights 
--Q1: Which lab tests have the highest percentage of abnormal results?
SELECT 
    test_name,
    COUNT(*) AS total_tests,
    SUM(CASE WHEN result = 'Abnormal' THEN 1 ELSE 0 END) AS abnormal_count,  -- Count abnormal results
    ROUND(SUM(CASE WHEN result = 'Abnormal' THEN 1 ELSE 0 END)::DECIMAL / COUNT(*) * 100, 2) AS abnormal_percent
FROM labs
GROUP BY test_name
ORDER BY abnormal_percent DESC;

--Q2: Identify patients with multiple abnormal lab results across different tests
SELECT 
    patient_id,
    COUNT(DISTINCT test_name) AS abnormal_tests_count           -- Count distinct tests with abnormal results
FROM labs
WHERE result = 'Abnormal'
GROUP BY patient_id
HAVING COUNT(DISTINCT test_name) > 1;                         -- Only patients with more than 1 abnormal test

--Q4: Determine which doctors order the most lab tests per patient
SELECT 
    doctor_id,
    patient_id,
    COUNT(*) AS lab_tests_count
FROM labs
GROUP BY doctor_id, patient_id
ORDER BY lab_tests_count DESC;

--Q5: Find lab tests most frequently pending and analyze by doctor or ward
SELECT * FROM labs
SELECT 
    test_name,
    doctor_id,
    COUNT(*) AS pending_count
FROM labs
WHERE result IS NULL OR result = 'Pending'                      -- Include missing or pending results
GROUP BY test_name, doctor_id
ORDER BY pending_count DESC;


-- Prescription & Medication Insights – Queries with Comments
--Q1: Identify medications prescribed together frequently (co-occurrence)
SELECT * FROM prescriptions;
SELECT 
    p1.drug AS med1,
    p2.drug AS med2,
    COUNT(*) AS co_occurrence_count
FROM prescriptions p1
JOIN prescriptions p2 
    ON p1.patient_id = p2.patient_id
   AND p1.prescription_id = p2.prescription_id
   AND p1.drug < p2.drug        -- Avoid duplicate pairs
GROUP BY p1.drug, p2.drug
ORDER BY co_occurrence_count DESC;

--Q2: Find patients who are over-prescribed or have overlapping prescriptions
SELECT 
    patient_id,
    COUNT(*) AS prescription_count
FROM prescriptions
GROUP BY patient_id
HAVING COUNT(*) > 5;                                           -- Arbitrary threshold for over-prescription

--Q3: Determine doctors with highest prescription volume and compare with outcomes
SELECT * FROM admissions;
SELECT * FROM prescriptions;
SELECT 
    doctor_id,
    COUNT(*) AS prescription_count,
    AVG(a.length_of_stay) AS avg_patient_stay                     -- Join to admissions for outcome
FROM prescriptions p
JOIN admissions a ON p.patient_id = a.patient_id
GROUP BY doctor_id
ORDER BY prescription_count DESC;

--Q4: Track trends in prescription frequency over time
SELECT 
    EXTRACT(YEAR FROM prescription_date) AS year,
    EXTRACT(MONTH FROM prescription_date) AS month,
    COUNT(*) AS prescriptions_count
FROM prescriptions
GROUP BY year, month
ORDER BY year, month;

--Q5: Identify prescriptions given without an associated lab test
SELECT * FROM labs;
SELECT 
    p.patient_id,
    p.drug,
    p.prescription_id
FROM prescriptions p
LEFT JOIN labs l 
    ON p.patient_id = l.patient_id
WHERE l.lab_id IS NULL;      -- No lab for this prescription


--Cross-Table & Complex Metrics – Queries with Comments
--Q1: Correlate lab results with length of stay
SELECT 
    l.patient_id,
    AVG(a.length_of_stay) AS avg_stay
FROM labs l
JOIN admissions a ON l.patient_id = a.patient_id
WHERE l.result = 'Abnormal'                                    -- Only abnormal lab results
GROUP BY l.patient_id
ORDER BY avg_stay DESC;

--Q2: Identify patients admitted by multiple doctors
SELECT 
    patient_id,
    COUNT(DISTINCT doctor_id) AS doctor_count
FROM admissions
GROUP BY patient_id
HAVING COUNT(DISTINCT doctor_id) > 1;

--Q3: Determine which wards have higher rates of pending lab results
SELECT 
    a.ward,
    COUNT(*) FILTER (WHERE l.result IS NULL OR l.result = 'Pending') AS pending_count,
    COUNT(l.lab_id) AS total_tests,
    ROUND(COUNT(*) FILTER (WHERE l.result IS NULL OR l.result = 'Pending')::DECIMAL / COUNT(l.lab_id) * 100, 2) AS pending_percent
FROM admissions a
JOIN labs l ON a.patient_id = l.patient_id
GROUP BY a.ward
ORDER BY pending_percent DESC;

--Q4: Analyze doctor performance: admissions handled vs. abnormal lab outcomes
SELECT 
    d.staff_id AS doctor_id,
    COUNT(DISTINCT a.admission_id) AS admissions_count,
    SUM(CASE WHEN l.result = 'Abnormal' THEN 1 ELSE 0 END) AS abnormal_labs_count
FROM staff d
LEFT JOIN admissions a ON d.staff_id = a.doctor_id
LEFT JOIN labs l ON a.patient_id = l.patient_id
WHERE d.role = 'Doctor'
GROUP BY d.staff_id
ORDER BY admissions_count DESC;


--Time-Series & Trend Analysis
--Q1: Which months or weekdays have the highest admissions, lab tests, or prescriptions?
-- Admissions per month and weekday
SELECT 
    EXTRACT(YEAR FROM admit_date) AS year,
    EXTRACT(MONTH FROM admit_date) AS month,
    EXTRACT(DOW FROM admit_date) AS weekday,                   -- 0=Sunday, 6=Saturday
    COUNT(*) AS admissions_count
FROM admissions
GROUP BY year, month, weekday
ORDER BY admissions_count DESC;

--Q2: Track patient admission trends by age group over years
SELECT 
    CASE 
        WHEN age < 20 THEN '<20'
        WHEN age BETWEEN 20 AND 39 THEN '20-39'
        WHEN age BETWEEN 40 AND 59 THEN '40-59'
        ELSE '60+' 
    END AS age_group,
    EXTRACT(YEAR FROM admit_date) AS year,
    COUNT(*) AS admissions_count
FROM patients p
JOIN admissions a ON p.patient_id = a.patient_id
GROUP BY age_group, year
ORDER BY year, age_group;

--Q3: Identify seasonal spikes in abnormal lab results
SELECT 
    EXTRACT(MONTH FROM test_date) AS month,
    COUNT(*) AS abnormal_count
FROM labs
WHERE result = 'Abnormal'
GROUP BY month
ORDER BY abnormal_count DESC;

--Q4: Analyze time between admission and first lab test per patient
SELECT 
    a.patient_id,
    MIN(l.test_date) - a.admit_date AS days_to_first_lab      -- Difference between admission and first lab
FROM admissions a
JOIN labs l ON a.patient_id = l.patient_id
GROUP BY a.patient_id, a.admit_date
ORDER BY days_to_first_lab;

--Q5: Determine average discharge delay by ward or doctor
SELECT 
    ward,
    doctor_id,
    AVG(discharge_date - admit_date) AS avg_length_of_stay    -- Average length of stay
FROM admissions
GROUP BY ward, doctor_id
ORDER BY avg_length_of_stay DESC;

--Quality & Data Integrity Checks 
--Q1: Identify doctor IDs in labs or prescriptions that don’t exist in staff table
-- Labs
SELECT DISTINCT l.doctor_id
FROM labs l
LEFT JOIN staff s ON l.doctor_id = s.staff_id
WHERE s.staff_id IS NULL;

--Q2: Detect patients with overlapping admissions
SELECT a1.patient_id, a1.admit_date AS admit1, a1.discharge_date AS discharge1,
       a2.admit_date AS admit2, a2.discharge_date AS discharge2
FROM admissions a1
JOIN admissions a2 
  ON a1.patient_id = a2.patient_id
 AND a1.admission_id < a2.admission_id                        -- Avoid self-join duplicates
WHERE a1.discharge_date >= a2.admit_date                     -- Overlap condition
ORDER BY a1.patient_id;

--Q3: Find lab tests with inconsistent statuses or missing results
SELECT *
FROM labs
WHERE result IS NULL OR result NOT IN ('Normal', 'Abnormal', 'Pending');  -- Check for missing or invalid statuses

--Q4: Detect anomalies in length_of_stay
SELECT *
FROM admissions
WHERE length_of_stay < 0                                      -- Negative stay
   OR length_of_stay > 365;                                    -- Unusually long stay

--Q5: Compare phone number formats or invalid entries
SELECT patient_id, phone
FROM patients
WHERE LENGTH(phone) != 10                                      -- Check for invalid length
   OR phone !~ '^[0-9]+$';   -- Check for non-digit characters

--Advanced SQL Techniques 
--Q1: Rank doctors by number of abnormal lab results
SELECT 
    doctor_id,
    COUNT(*) AS abnormal_count,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS rank_abnormal    -- Rank doctors by abnormal lab count
FROM labs
WHERE result = 'Abnormal'
GROUP BY doctor_id
ORDER BY rank_abnormal;

--Q2: Recursive CTE to trace multi-admission chains
WITH RECURSIVE admission_chain AS (
    SELECT patient_id, admission_id, admit_date, discharge_date, 1 AS chain_level
    FROM admissions
    WHERE admit_date IS NOT NULL
    UNION ALL
    SELECT a.patient_id, a.admission_id, a.admit_date, a.discharge_date, ac.chain_level + 1
    FROM admissions a
    JOIN admission_chain ac ON a.patient_id = ac.patient_id
    WHERE a.admit_date > ac.admit_date)
SELECT * FROM admission_chain
ORDER BY patient_id, chain_level;

--Q3: Multi-level aggregation using ROLLUP
SELECT 
    ward,
    doctor_id,
    EXTRACT(MONTH FROM admit_date) AS month,
    AVG(length_of_stay) AS avg_stay
FROM admissions
GROUP BY ROLLUP(ward, doctor_id, month)                       -- Aggregation with subtotals
ORDER BY ward, doctor_id, month;

--Q4: Identify patients with length_of_stay above 90th percentile
SELECT *
FROM admissions
WHERE length_of_stay > (
    SELECT PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY length_of_stay)
    FROM admissions
);




-- =========================================
-- POWER BI DASHBOARD PRODUCTION VIEWS
-- =========================================
--PAGE 1 – Executive Overview (Views Structure)
--Total Admissions Used for → KPI Card
CREATE VIEW vw_total_admissions AS
SELECT 
    COUNT(*) AS total_admissions
FROM admissions;

--Current Admissions Used for → KPI Card
CREATE VIEW vw_current_admissions AS
SELECT 
    COUNT(*) AS current_admissions
FROM admissions
WHERE discharge_date IS NULL;

--Average Length of Stay Used for → KPI Card
CREATE VIEW vw_avg_length_of_stay AS
SELECT 
    ROUND(AVG(length_of_stay), 2) AS avg_length_of_stay
FROM admissions;

--Readmission Rate (30 Days) Used for → KPI Card
CREATE VIEW vw_readmission_rate AS
WITH readmission_cte AS (
    SELECT 
        patient_id,
        discharge_date,
        LEAD(admit_date) OVER (
            PARTITION BY patient_id 
            ORDER BY admit_date
        ) AS next_admit_date
    FROM admissions
)
SELECT 
    ROUND(
        COUNT(*) FILTER (
            WHERE next_admit_date IS NOT NULL 
            AND next_admit_date - discharge_date <= 30
        )::DECIMAL 
        / COUNT(*) * 100,
    2) AS readmission_rate_percent
FROM readmission_cte;

--Abnormal Labs Used for → KPI Card
CREATE VIEW vw_abnormal_lab_percent AS
SELECT 
    ROUND(
        SUM(CASE WHEN result = 'Abnormal' THEN 1 ELSE 0 END)::DECIMAL 
        / COUNT(*) * 100,
    2) AS abnormal_lab_percent
FROM labs;

-- PAGE 1 CHART VIEWS
--Admissions by Month (Line Chart)
CREATE VIEW vw_admissions_monthly AS
SELECT 
    EXTRACT(YEAR FROM admit_date) AS year,
    EXTRACT(MONTH FROM admit_date) AS month,
    COUNT(*) AS admissions_count
FROM admissions
GROUP BY year, month
ORDER BY year, month;

--Admissions by Ward (Bar Chart)
CREATE VIEW vw_admissions_by_ward AS
SELECT 
    ward,
    COUNT(*) AS admissions_count
FROM admissions
GROUP BY ward
ORDER BY admissions_count DESC;

--Abnormal Lab % by Ward Used for → Bar Chart

CREATE VIEW vw_abnormal_by_ward AS
SELECT 
    a.ward,
    ROUND(
        SUM(CASE WHEN l.result = 'Abnormal' THEN 1 ELSE 0 END)::DECIMAL 
        / COUNT(l.lab_id) * 100,
    2) AS abnormal_percent
FROM admissions a
JOIN labs l ON a.patient_id = l.patient_id
GROUP BY a.ward
ORDER BY abnormal_percent DESC;



-- PAGE 2 – Operational Deep Dive (Views Structure)
--PAGE 2 KPIs
--Total Doctors
CREATE VIEW vw_total_doctors AS
SELECT 
    COUNT(*) AS total_doctors
FROM staff
WHERE role = 'Doctor';
--Avg Patients Per Doctor
CREATE VIEW vw_avg_patients_per_doctor AS
SELECT 
    ROUND(
        COUNT(DISTINCT patient_id)::DECIMAL 
        / COUNT(DISTINCT doctor_id),
    2) AS avg_patients_per_doctor
FROM admissions;
--Total Pending Labs
CREATE VIEW vw_total_pending_labs AS
SELECT 
    COUNT(*) AS total_pending_labs
FROM labs
WHERE result IS NULL 
   OR result = 'Pending';
--Avg Lab Turnaround Time
CREATE VIEW vw_avg_lab_turnaround AS
SELECT 
    ROUND(
        AVG(result_date - test_date),
    2) AS avg_turnaround_days
FROM labs
WHERE result_date IS NOT NULL;
--Total Prescriptions
CREATE VIEW vw_total_prescriptions AS
SELECT 
    COUNT(*) AS total_prescriptions
FROM prescriptions;

--PAGE 2 CHART VIEWS
--Doctor Performance Ranking Used for → Ranking Bar Chart
CREATE VIEW vw_doctor_ranking AS
SELECT 
    doctor_id,
    COUNT(*) AS admissions_handled,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS doctor_rank
FROM admissions
GROUP BY doctor_id;

--Pending Labs by Ward
CREATE VIEW vw_pending_by_ward AS
SELECT 
    a.ward,
    COUNT(*) AS pending_count
FROM admissions a
JOIN labs l ON a.patient_id = l.patient_id
WHERE l.result IS NULL 
   OR l.result = 'Pending'
GROUP BY a.ward
ORDER BY pending_count DESC;

--Lab Turnaround Time Trend
CREATE VIEW vw_lab_turnaround_trend AS
SELECT 
    EXTRACT(YEAR FROM test_date) AS year,
    EXTRACT(MONTH FROM test_date) AS month,
    ROUND(AVG(result_date - test_date), 2) AS avg_turnaround_days
FROM labs
WHERE result_date IS NOT NULL
GROUP BY year, month
ORDER BY year, month;

--Prescription Volume by Doctor
CREATE VIEW vw_prescription_by_doctor AS
SELECT 
    doctor_id,
    COUNT(*) AS prescription_count
FROM prescriptions
GROUP BY doctor_id
ORDER BY prescription_count DESC;

--Age Group Admission Trend
CREATE VIEW vw_age_group_trend AS
SELECT 
    CASE 
        WHEN p.age < 20 THEN '<20'
        WHEN p.age BETWEEN 20 AND 39 THEN '20-39'
        WHEN p.age BETWEEN 40 AND 59 THEN '40-59'
        ELSE '60+'
    END AS age_group,
    EXTRACT(YEAR FROM a.admit_date) AS year,
    COUNT(*) AS admissions_count
FROM patients p
JOIN admissions a ON p.patient_id = a.patient_id
GROUP BY age_group, year
ORDER BY year, age_group;











