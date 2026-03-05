# Hospital-Operations-Analytics-End-to-End-SQL-Project
This project analyzes a hospital database using PostgreSQL to uncover operational, clinical, and performance insights.

**Executive Summary**
This project delivers a full-cycle SQL analytics solution for a hospital system, covering data modeling, data validation, exploratory analysis, and advanced performance metrics.
Using PostgreSQL, I transformed raw relational tables into actionable operational insights across patient flow, resource utilization, ward efficiency, and physician workload.

🗂️ 1. Data Architecture & Modeling
The database consists of 11 relational tables:
-- Patients
Admissions
Staff
Doctors(derived from staff)
Appointments
Labs
Prescriptions
Inventory
Emergency
Surgeries
Bills

Primary and foreign keys were implemented to enforce referential integrity and ensure proper relational modeling.
An Entity Relationship Diagram (ERD) was designed to validate table relationships and normalization structure.

 **2. Data Quality & Validation**
Before analysis, structured validation checks were performed:
✅ Duplicate Checks
Validated uniqueness of primary keys across core tables.
✅ Missing Value Analysis
Specialty field fully populated for Doctors.
Non-doctor roles correctly show NULL specialty (role-specific attribute).
No critical missing values in primary identifiers.
✅ Distinct & Integrity Verification
Total unique patients: 500
Total admissions: 500
One-to-one patient-admission mapping in this dataset.
These checks ensured analytical reliability before insight generation.

**3. Core Analytical Findings**
**Patient & Length of Stay Analysis**
-- Average Length of Stay (LOS): 15.86 days
Maximum LOS: 30 days
90th Percentile LOS: 28 days
Interpretation:
The top 10% of admissions exceed 28 days, indicating high-resource utilization cases that significantly impact bed capacity and operational efficiency.

**30-Day Readmission Analysis**
Using window functions (LAG):
Total readmissions within 30 days: 22
Readmission rate: 4.4%
Interpretation:
The readmission rate is relatively moderate but identifies a measurable segment requiring targeted follow-up protocols.

**Ward Performance**
Average LOS by Ward:
-- Maternity – 16.86 days
Surgery – 16.09 days
General – 15.74 days
ICU – 14.93 days
Interpretation:
Maternity and Surgery wards show higher-than-average stay durations, suggesting potential operational bottlenecks or case complexity.

**Doctor Workload Distribution**
Top doctor handled 7 admissions, with others closely following (5–4 admissions).
Interpretation:
Workload appears relatively balanced with no extreme case concentration.
 
**4. Advanced SQL Techniques Applied**
--Window functions (LAG for readmission analysis)
Ordered-set aggregate functions (PERCENTILE_CONT)
Cross-table joins
Aggregation & grouping
Ranking queries
Data validation queries
Referential integrity enforcement

**5. Business Implications**
Long-stay patients (>28 days) represent high operational cost drivers.
Ward-level LOS differences indicate resource allocation optimization opportunities.
Readmission monitoring can support quality-of-care improvements.
Balanced doctor workload reduces burnout risk.

**6. Strategic Recommendations**
Conduct root-cause analysis for long-stay patients.
Evaluate discharge processes in Maternity and Surgery wards.
Implement predictive monitoring for readmission risk.
Develop operational dashboards tracking LOS percentiles.

**Technical Stack**
PostgreSQL
SQL (Advanced Aggregations & Window Functions)
ER Modeling
Data Validation Techniques

**Project Value**
This project demonstrates:
Strong relational database modeling
Analytical SQL proficiency
Business-oriented interpretation of healthcare data
Ability to translate raw data into strategic recommendations
