# E-Commerce Database Management System

## Project Overview

This project shows the design and the implementation of a relational database structure for a fictional e-commerce company. The schema is normalized to the Third Normal Form (3NF) and implemented in MySQL.

The design focuses on data integrity, scalable architecture, and strict adherence to **GDRP Compliance** with 'Privacy by Design' principles by separating analytical data from Personally Identifiable Information (PII).

## Entity Relationship Diagram (ERD)



## Techical Highlights

### 1. GDPR & Data Privacy

To support compliance with EU data regulations (GDPR), user data is vertically partitioned:

* **`customers / `employees`:** These parent tables hold anonymous, non-identifiable data (IDs, location keys, timstamps) permanently for analytics and reporting.
* **`customers_pii`/ `employees_pii`:** These child tables contain sensitive data (Names, Emails, Address, Phone Numbers).
* **Right to be Forgotten:** Stored procedures (`customer_offboarding`, `employee_offboarding`) allow for the systematic deletion of PII while preserving the transactional history required for business intelligence.

### 2. Database Integrity

* **Constraints:** Extensive use of `FOREIGN KEY`, `UNIQUE`, and `CHECK` constraints to prevent invalid data entry (for example preventing negative inventory or invalid ratings).
* **Computed Columns:** Utilization of `GENERATED ALWAYS AS` for derived attributes like order line totals to ensure consistency.

### 3. Automation & Logic

* **Stored Procedures:** Transactional procedures handle complex inserts across multiple tables and manage data deletion workflows (for example `new_employee`).
* **Triggers:** A `BEFORE INSERT` trigger (in `validate_return_quantity`) acts as a safeguard to ensure returned items do not exceed the original order quantity.

## Key SQL Features Used

* **DDL:** Table creation, Vertical Partitioning, Indexing (via Keys).
* **Logic:** Stored Procedures, Triggers, Transactions, (`COMMIT` / `ROLLBACK`).
* **Typing:** `DECIMAL` for financial accuracy, `DATETIME`, `BOOLEAN`.

## Future Implementations

* Implementation of role-based access control for different users (for example HR and Sales).
* Creation of a View layer to simplify joins for different reporting tools.
