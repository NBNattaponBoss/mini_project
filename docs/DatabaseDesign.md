# Database Design

# Personal Deposit Account Management System

## 1. Overview

This document defines the database design for the **Personal Deposit Account Management System**.

The database is designed to support the following core functions:

* User authentication
* Deposit and withdrawal transaction storage
* Transaction history retrieval
* Dashboard calculations
* Transaction filtering by month, year, and type
* Monthly financial summaries
* Data ownership by authenticated user

The system uses **MariaDB** as the relational database management system.

---

## 2. Database Design Goals

The database design must:

1. Store user account data securely.
2. Store deposit and withdrawal transactions accurately.
3. Support one-to-many relationships between users and transactions.
4. Allow efficient retrieval of dashboard and summary data.
5. Support filtering by transaction type, month, and year.
6. Support automatic recalculation of financial totals from transaction records.
7. Prevent unauthorized data access through user ownership rules.
8. Remain simple and appropriate for a Mini Project.

---

## 3. Database Overview

The database contains two main tables:

* `users`
* `transactions`

```text id="3wls1r"
users
  │
  │ 1 : N
  ▼
transactions
```

The design intentionally keeps the schema simple so that the application can focus on authentication, transaction management, and financial summaries.

---

## 4. Database Name

The database name should be:

```text id="2k9xq7"
personal_account
```

If needed, the name may be adjusted to match the project naming convention, but it must remain consistent across the backend configuration, SQL scripts, and documentation.

---

## 5. Table: users

The `users` table stores user authentication information.

### 5.1 Purpose

This table is used to:

* Authenticate users during login
* Identify the owner of each transaction
* Store password hashes securely

### 5.2 Fields

| Field        | Data Type    | Constraints                           | Description                |
| ------------ | ------------ | ------------------------------------- | -------------------------- |
| `id`         | INT          | PRIMARY KEY, AUTO_INCREMENT, NOT NULL | Unique user identifier     |
| `username`   | VARCHAR(50)  | UNIQUE, NOT NULL                      | Login username             |
| `password`   | VARCHAR(255) | NOT NULL                              | Hashed password            |
| `created_at` | TIMESTAMP    | DEFAULT CURRENT_TIMESTAMP             | Account creation timestamp |

### 5.3 SQL Definition

```sql id="8n6s4m"
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 5.4 Design Notes

* The password must be stored as a **hashed value**, not plain text.
* The `username` field must be unique so that two users cannot share the same login name.
* The `id` field is used as the reference key for all transactions created by that user.

---

## 6. Table: transactions

The `transactions` table stores deposit and withdrawal records.

### 6.1 Purpose

This table is used to:

* Store deposit transactions
* Store withdrawal transactions
* Support dashboard calculations
* Support monthly summaries
* Support transaction filtering and history viewing
* Support editing and deleting transaction records

### 6.2 Fields

| Field              | Data Type                   | Constraints                           | Description                   |
| ------------------ | --------------------------- | ------------------------------------- | ----------------------------- |
| `id`               | INT                         | PRIMARY KEY, AUTO_INCREMENT, NOT NULL | Unique transaction identifier |
| `user_id`          | INT                         | FOREIGN KEY, NOT NULL                 | Owner of the transaction      |
| `type`             | ENUM('deposit', 'withdraw') | NOT NULL                              | Transaction type              |
| `amount`           | DECIMAL(12,2)               | NOT NULL                              | Transaction amount            |
| `transaction_date` | DATE                        | NOT NULL                              | Date of the transaction       |
| `description`      | VARCHAR(255)                | NULL                                  | Transaction details           |
| `created_at`       | TIMESTAMP                   | DEFAULT CURRENT_TIMESTAMP             | Record creation timestamp     |

### 6.3 SQL Definition

```sql id="7m8q2c"
CREATE TABLE transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    type ENUM('deposit', 'withdraw') NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    transaction_date DATE NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_transactions_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);
```

### 6.4 Design Notes

* `type` is restricted to `deposit` and `withdraw` only.
* `amount` uses `DECIMAL(12,2)` so that financial values can be stored accurately.
* `transaction_date` stores the business date of the transaction, not the record creation date.
* `description` is optional in the database design, but the application may require it according to validation rules.
* `user_id` links each transaction to its owner.

---

## 7. Relationship Design

The relationship between `users` and `transactions` is:

* One user can have many transactions.
* One transaction belongs to one user only.

```text id="b1rt5u"
users (1) ─────────────── (N) transactions
```

### Relationship Rules

* A transaction cannot exist without a valid user.
* Deleting a user will delete all related transactions because of `ON DELETE CASCADE`.
* A transaction must always be associated with the authenticated user who created it.

---

## 8. Primary Keys

### users

* Primary Key: `id`

### transactions

* Primary Key: `id`

Primary keys ensure that each record is uniquely identifiable.

---

## 9. Foreign Keys

### transactions.user_id → users.id

The `user_id` field in `transactions` is a foreign key that references `users.id`.

This ensures:

* Referential integrity
* Transaction ownership
* Prevention of orphan transaction records

```text id="9p7x2a"
transactions.user_id
        ↓
     users.id
```

---

## 10. Index Strategy

To improve query performance, the following indexes are recommended.

### 10.1 Default Indexes

* Primary key indexes on `users.id` and `transactions.id`
* Unique index on `users.username`

### 10.2 Additional Indexes

The following index may be added for faster filtering and summary queries:

```sql id="4v2l9n"
CREATE INDEX idx_transactions_user_date
ON transactions (user_id, transaction_date);
```

This index helps with:

* Listing transactions by user
* Filtering transactions by month and year
* Generating monthly summaries
* Sorting transactions by date

### 10.3 Optional Type Index

If needed, an additional index may be created for filtering by transaction type:

```sql id="0xq1mf"
CREATE INDEX idx_transactions_user_type
ON transactions (user_id, type);
```

This is optional and should only be added if it improves query performance in the implementation.

---

## 11. Data Types and Constraints

### 11.1 Username

* Type: `VARCHAR(50)`
* Must not be empty
* Must be unique

### 11.2 Password

* Type: `VARCHAR(255)`
* Must store hashed password only
* Must not store plain text

### 11.3 Amount

* Type: `DECIMAL(12,2)`
* Must be greater than zero
* Must support decimal values

### 11.4 Transaction Date

* Type: `DATE`
* Must be a valid date
* Must support month and year filtering

### 11.5 Transaction Type

* Type: `ENUM('deposit', 'withdraw')`
* Must only allow deposit or withdraw

### 11.6 Description

* Type: `VARCHAR(255)`
* May be optional in the database
* Should store human-readable transaction details

---

## 12. Data Storage Rules

The database must follow these rules:

1. Store only structured relational data.
2. Store password hashes, not plain text passwords.
3. Store transaction records with an owning `user_id`.
4. Do not store current balance as a manually edited value.
5. Calculate balance from transaction data in the backend.
6. Keep transaction history intact unless a record is intentionally deleted.
7. Use foreign keys to preserve referential integrity.

---

## 13. Balance Storage Rule

The system must **not** store the current balance as a separate editable field in the database.

The balance must be calculated using transaction data:

```text id="q4n8zv"
Current Balance = Total Deposits - Total Withdrawals
```

This rule ensures that the balance remains consistent when transactions are created, updated, or deleted.

The same principle applies to monthly summaries.

---

## 14. Monthly Summary Data Rule

The monthly summary is not stored as a separate table.

Instead, it is calculated from the transactions table by filtering records using:

* `transaction_date`
* `type`
* `user_id`

Example calculations:

```text id="l8v2pc"
Monthly Deposit = SUM(type = 'deposit')
Monthly Withdrawal = SUM(type = 'withdraw')
Monthly Balance = Monthly Deposit - Monthly Withdrawal
```

This design keeps the database simple and avoids redundant summary storage.

---

## 15. Query Support Requirements

The schema must support the following common queries:

### 15.1 Login Query

* Find a user by `username`

### 15.2 Dashboard Query

* Retrieve all transactions for a user
* Sum deposit amounts
* Sum withdrawal amounts
* Count total transactions
* Retrieve recent transactions

### 15.3 Transaction List Query

* Retrieve transactions by `user_id`
* Sort transactions by `transaction_date` descending
* Filter by `type`
* Filter by month and year

### 15.4 Monthly Summary Query

* Filter transactions by `user_id`
* Filter by month and year
* Sum by `type`

---

## 16. Normalization

The database is designed to be simple and normalized enough for the project scope.

### Normalization Principles Applied

* User data is stored only in `users`
* Transaction data is stored only in `transactions`
* Repeated financial records are not duplicated in multiple tables
* Transaction ownership is handled through foreign keys

This structure reduces redundancy and makes maintenance easier.

---

## 17. Example Data

### users

| id | username | password        | created_at          |
| -: | -------- | --------------- | ------------------- |
|  1 | admin    | hashed_password | 2026-07-26 10:00:00 |

### transactions

| id | user_id | type     |   amount | transaction_date | description | created_at          |
| -: | ------: | -------- | -------: | ---------------- | ----------- | ------------------- |
|  1 |       1 | deposit  | 10000.00 | 2026-07-01       | Salary      | 2026-07-01 09:00:00 |
|  2 |       1 | withdraw |   500.00 | 2026-07-02       | Lunch       | 2026-07-02 12:00:00 |
|  3 |       1 | deposit  |  2000.00 | 2026-07-05       | Bonus       | 2026-07-05 08:30:00 |

---

## 18. Data Integrity Rules

The database must enforce the following integrity rules:

1. `username` must be unique.
2. `password` must not be null.
3. `user_id` must reference a valid user.
4. `type` must be either `deposit` or `withdraw`.
5. `amount` must be stored as a numeric financial value.
6. `transaction_date` must be required.
7. Transaction records must be deleted automatically if the parent user is deleted.

---

## 19. Security Considerations

The database design must support secure handling of data.

### Security Principles

* Never store plain text passwords.
* Use foreign keys to prevent invalid references.
* Use parameterized SQL queries in the backend.
* Keep database credentials in environment variables.
* Do not expose direct database access to the Flutter application.

The database itself is only one part of security; the backend must enforce authentication and authorization.

---

## 20. Recommended SQL Script Structure

The SQL script for the project should be organized in the following order:

```text id="x9k7rl"
1. Create database
2. Select database
3. Create users table
4. Create transactions table
5. Create indexes
6. Insert sample user
7. Insert sample transactions
8. Verify data
```

Example structure:

```sql id="r5t1nv"
CREATE DATABASE personal_account;
USE personal_account;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    type ENUM('deposit', 'withdraw') NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    transaction_date DATE NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_transactions_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);
```

---

## 21. Architecture Compatibility

This database design is compatible with the architecture defined in `SYSTEM_ARCHITECTURE.md` because:

* Flutter communicates with the backend through REST API.
* Node.js handles business logic and database access.
* MariaDB stores users and transactions.
* The backend calculates dashboard and summary totals from transaction data.

No part of the Flutter application should bypass the backend to query the database directly.

---

## 22. Database Scope Boundaries

The database design is intentionally limited to the needs of the Mini Project.

### Included

* User authentication data
* Deposit and withdrawal transactions
* Ownership via `user_id`
* Query support for dashboard and summaries

### Not Included

* Bank account synchronization
* Real banking transactions
* Payment gateway data
* Credit card data
* Loan data
* Investment data
* Shared wallet tables
* Multi-user collaborative account tables

These features are outside the current project scope.

---

## 23. Database Design Summary

The database design uses a minimal relational structure with two main tables:

* `users`
* `transactions`

The design supports:

* Secure authentication
* User-specific transaction management
* Dashboard calculations
* Monthly summaries
* Transaction filtering
* Data integrity through foreign keys

This structure is sufficient for the project requirements and keeps the implementation appropriate for a Mini Project.

---

## 24. Design Completion Criteria

The database design is considered complete when it supports all of the following:

* User login data
* Password hashing
* Transaction storage
* Deposit and withdrawal types
* User ownership of records
* Transaction history queries
* Dashboard totals
* Monthly summaries
* Filtering by month, year, and type
* Referential integrity
* Secure backend access

This design must remain synchronized with the requirements and architecture documents.