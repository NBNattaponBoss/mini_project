# Project Requirements

# Personal Deposit Account Management System

## 1. Project Overview

**Project Name:** Personal Deposit Account Management System

**Project Type:** Mobile Application

**Project Purpose:**
A mobile application for managing personal deposit and withdrawal transactions. The system allows users to securely log in, record financial transactions, view their current balance, review transaction history, and analyze monthly financial summaries.

The application is designed as a Mini Project to demonstrate mobile application development, REST API integration, backend development, database management, authentication, CRUD operations, and financial data processing.

---

## 2. Project Objectives

The main objectives of this project are:

1. Develop a mobile application for managing personal financial transactions.
2. Allow users to record deposits and withdrawals.
3. Automatically calculate the current account balance.
4. Allow users to edit and delete transaction records.
5. Provide a dashboard showing financial information at a glance.
6. Provide monthly financial summaries.
7. Allow users to filter historical transactions by month and year.
8. Implement secure user authentication.
9. Demonstrate communication between a Flutter mobile application and a Node.js REST API.
10. Store and manage application data using MariaDB.

---

## 3. Target Users

The system is designed for individual users who want to:

* Track personal deposits and withdrawals.
* Monitor their current account balance.
* Review financial transaction history.
* Check monthly income and expenses.
* Manage financial records through a mobile device.

The initial version of the system supports personal use and does not include multi-user financial sharing or collaborative account management.

---

## 4. Technology Stack

### 4.1 Frontend

* **Flutter**
* **Dart**

Flutter is used to develop the mobile application interface and client-side functionality.

### 4.2 Backend

* **Node.js**
* **Express.js**

Node.js and Express.js are used to develop the RESTful API and backend business logic.

### 4.3 Database

* **MariaDB**

MariaDB is used as the relational database for storing user accounts and financial transaction records.

### 4.4 Development and Testing Tools

* **Visual Studio Code** — Source code editor
* **HeidiSQL** — MariaDB database management
* **Postman** — REST API testing
* **Git** — Version control
* **GitHub** — Source code repository
* **Android Studio** — Android SDK and emulator support

### 4.5 Backend Libraries

The backend may use the following libraries:

* `express` — REST API framework
* `mysql2` — MariaDB/MySQL database connection
* `bcrypt` — Password hashing
* `jsonwebtoken` — JWT authentication
* `cors` — Cross-Origin Resource Sharing
* `dotenv` — Environment variable management

### 4.6 Flutter Packages

The frontend may use the following packages:

* `http` — REST API communication
* `shared_preferences` — Local storage for authentication/session data
* `intl` — Date and number formatting
* `fl_chart` — Financial data visualization

---

# 5. System Scope

The system consists of the following major modules:

1. Authentication
2. Dashboard
3. Deposit Management
4. Withdrawal Management
5. Transaction Management
6. Monthly Financial Summary
7. Data Filtering
8. Logout

---

# 6. Functional Requirements

## 6.1 Authentication

### Login

The system must allow users to log in using:

* Username
* Password

The system must:

1. Receive the username and password from the mobile application.
2. Validate the submitted credentials.
3. Verify the user against the database.
4. Hash and verify passwords securely using bcrypt.
5. Generate a JWT token after successful authentication.
6. Return the authentication result to the Flutter application.
7. Prevent unauthorized users from accessing protected resources.

### Login Failure

If the username or password is incorrect, the system must:

* Reject the login request.
* Return an appropriate error response.
* Display an error message to the user.
* Keep the user on the Login screen.

### Logout

The system must allow users to log out.

After logout:

* The authentication/session information stored on the device must be cleared.
* The user must be redirected to the Login screen.
* Protected application pages must no longer be accessible without logging in again.

---

# 7. Dashboard Requirements

After successful login, the user must be able to access the Dashboard.

The Dashboard must display:

### 7.1 Current Balance

The current balance is calculated using:

```text
Current Balance = Total Deposits - Total Withdrawals
```

The system must calculate the balance automatically based on the user's transaction records.

### 7.2 Total Deposit

Display the total amount of all deposit transactions belonging to the authenticated user.

### 7.3 Total Withdrawal

Display the total amount of all withdrawal transactions belonging to the authenticated user.

### 7.4 Transaction Count

Display the total number of deposit and withdrawal transactions belonging to the authenticated user.

### 7.5 Recent Transactions

Display the user's latest transactions.

Each recent transaction should display:

* Transaction type
* Amount
* Transaction date
* Description

Recent transactions should be ordered from newest to oldest.

---

# 8. Deposit Requirements

The user must be able to create a deposit transaction.

A deposit transaction must contain:

* Transaction type
* Amount
* Transaction date
* Description

The system must validate that:

* The amount is greater than zero.
* The transaction date is valid.
* Required fields are not empty.

After successfully adding a deposit:

1. The transaction must be stored in MariaDB.
2. The current balance must be recalculated automatically.
3. The Dashboard must reflect the updated balance.
4. The deposit total must be updated.
5. The transaction count must be updated.

---

# 9. Withdrawal Requirements

The user must be able to create a withdrawal transaction.

A withdrawal transaction must contain:

* Transaction type
* Amount
* Transaction date
* Description

The system must validate that:

* The amount is greater than zero.
* The transaction date is valid.
* Required fields are not empty.
* The withdrawal amount does not exceed the available balance.

If the withdrawal amount is greater than the current balance:

```text
The system must reject the transaction.
```

The user must receive an appropriate error message.

After successfully adding a withdrawal:

1. The transaction must be stored in MariaDB.
2. The current balance must be recalculated automatically.
3. The Dashboard must reflect the updated balance.
4. The withdrawal total must be updated.
5. The transaction count must be updated.

---

# 10. Transaction Management Requirements

The system must provide complete CRUD functionality for financial transactions.

## 10.1 Create

Users can create:

* Deposit transactions
* Withdrawal transactions

Required information:

```text
Type
Amount
Transaction Date
Description
```

## 10.2 Read

Users can view their transaction history.

The transaction list must display:

* Transaction type
* Amount
* Transaction date
* Description

Transactions should be ordered by transaction date from newest to oldest.

## 10.3 Update

Users can edit their own transaction records.

The user must be able to modify:

* Transaction type
* Amount
* Transaction date
* Description

After an update:

* The transaction must be updated in the database.
* The current balance must be recalculated.
* Deposit totals must be recalculated.
* Withdrawal totals must be recalculated.
* Dashboard information must be updated.

If the edited transaction causes the account balance to become invalid, the system must reject the update.

## 10.4 Delete

Users can delete their own transaction records.

Before deleting a transaction, the application must display a confirmation dialog.

Example:

```text
Are you sure you want to delete this transaction?

[Cancel] [Delete]
```

After deletion:

* The transaction must be removed from the database.
* The current balance must be recalculated.
* Deposit totals must be recalculated.
* Withdrawal totals must be recalculated.
* Transaction count must be updated.

---

# 11. Transaction Filtering

The system must allow users to filter transaction records.

Users should be able to filter by:

* Transaction type
* Month
* Year

Transaction type options:

```text
All
Deposit
Withdrawal
```

Example:

```text
Month: July
Year: 2026
Type: Deposit
```

The system should display only transactions matching the selected filters.

---

# 12. Monthly Financial Summary

The system must provide a monthly financial summary.

Users must be able to select:

* Month
* Year

For the selected month and year, the system must display:

### 12.1 Monthly Total Deposit

The total amount deposited during the selected month.

### 12.2 Monthly Total Withdrawal

The total amount withdrawn during the selected month.

### 12.3 Monthly Balance

The monthly transaction balance is calculated as:

```text
Monthly Balance = Monthly Deposits - Monthly Withdrawals
```

The system should allow users to view historical monthly data.

---

# 13. Balance Calculation Rules

The system must not rely on manually entered balance values.

The balance must be calculated from transaction records.

The primary calculation is:

```text
Current Balance
=
SUM(All Deposits)
-
SUM(All Withdrawals)
```

For monthly summary:

```text
Monthly Balance
=
SUM(Monthly Deposits)
-
SUM(Monthly Withdrawals)
```

Whenever a transaction is:

* Created
* Updated
* Deleted

The system must recalculate the relevant financial totals automatically.

---

# 14. Data Ownership and Security

Each transaction must belong to a specific authenticated user.

The system must ensure that:

* Users can only access their own transactions.
* Users cannot view another user's transactions.
* Users cannot edit another user's transactions.
* Users cannot delete another user's transactions.
* Users cannot access protected APIs without valid authentication.

The `user_id` associated with a transaction must be obtained from the authenticated user/session rather than trusted directly from client input.

---

# 15. Validation Requirements

The system must validate data on both the frontend and backend.

## Amount Validation

The amount must:

* Be numeric.
* Be greater than zero.
* Support decimal values.
* Not contain invalid characters.

## Date Validation

The transaction date must:

* Be a valid date.
* Follow the required date format.
* Not contain invalid date values.

## Description Validation

The description should:

* Not exceed the defined database field length.
* Accept normal text input.
* Be safely processed by the backend.

## Authentication Validation

The system must reject:

* Empty username.
* Empty password.
* Invalid credentials.
* Missing or invalid JWT tokens for protected endpoints.

---

# 16. Error Handling Requirements

The application must provide meaningful error messages.

Examples:

### Login

```text
Invalid username or password.
```

### Empty Required Field

```text
Please complete all required fields.
```

### Invalid Amount

```text
Amount must be greater than zero.
```

### Insufficient Balance

```text
Insufficient balance for this withdrawal.
```

### Unauthorized Access

```text
Unauthorized access.
```

### Server Error

```text
Something went wrong. Please try again later.
```

The backend should return appropriate HTTP status codes.

---

# 17. Non-Functional Requirements

## 17.1 Usability

The application should:

* Have a simple and intuitive interface.
* Clearly distinguish deposits and withdrawals.
* Provide clear navigation.
* Provide readable financial information.
* Provide confirmation before destructive actions.

## 17.2 Performance

The application should:

* Load dashboard information efficiently.
* Avoid unnecessary API requests.
* Handle normal transaction history without noticeable delays.

## 17.3 Security

The application must:

* Hash passwords using bcrypt.
* Use JWT for authentication.
* Store sensitive configuration in environment variables.
* Use parameterized SQL queries.
* Validate user input on the backend.
* Restrict data access based on authenticated user identity.

## 17.4 Maintainability

The codebase should:

* Follow a clear folder structure.
* Separate frontend UI from business logic.
* Separate backend routes, controllers, and database logic.
* Use reusable components.
* Use meaningful names for variables, functions, files, and database fields.
* Avoid unnecessary code duplication.

---

# 18. Main Application Screens

The Flutter application should contain at least the following screens:

## 18.1 Login Screen

Components:

* Username input
* Password input
* Login button
* Error message

## 18.2 Dashboard Screen

Components:

* Current balance card
* Total deposit
* Total withdrawal
* Transaction count
* Recent transactions
* Navigation to transaction management
* Navigation to monthly summary
* Logout option

## 18.3 Transaction List Screen

Components:

* Transaction list
* Transaction type filter
* Month filter
* Year filter
* Edit action
* Delete action
* Add transaction action

## 18.4 Add Transaction Screen

Components:

* Deposit/Withdrawal selector
* Amount input
* Date picker
* Description input
* Save button
* Validation messages

## 18.5 Edit Transaction Screen

Components:

* Transaction type
* Amount
* Date
* Description
* Save button
* Validation messages

## 18.6 Monthly Summary Screen

Components:

* Month selector
* Year selector
* Monthly deposit total
* Monthly withdrawal total
* Monthly balance
* Optional financial chart

---

# 19. Data Model Overview

The initial database should contain at least two main tables:

```text
users
    |
    | 1:N
    |
transactions
```

## users

Stores user authentication information.

Main fields:

```text
id
username
password
created_at
```

## transactions

Stores deposit and withdrawal records.

Main fields:

```text
id
user_id
type
amount
transaction_date
description
created_at
```

The `user_id` field in `transactions` references the `id` field in `users`.

---

# 20. Core Business Rules

The following rules must always be followed:

### Rule 1 — User Isolation

A user can only access transactions belonging to their own account.

### Rule 2 — Positive Amount

Every transaction amount must be greater than zero.

### Rule 3 — Deposit

A deposit increases the account balance.

```text
Balance = Balance + Deposit
```

### Rule 4 — Withdrawal

A withdrawal decreases the account balance.

```text
Balance = Balance - Withdrawal
```

### Rule 5 — Insufficient Balance

A withdrawal must not be allowed when:

```text
Withdrawal Amount > Current Balance
```

### Rule 6 — Automatic Recalculation

The balance must always be calculated from transaction records.

### Rule 7 — Update Recalculation

Editing a transaction must cause the system to recalculate the affected totals.

### Rule 8 — Delete Recalculation

Deleting a transaction must cause the system to recalculate the affected totals.

### Rule 9 — Authentication

Protected resources require a valid authentication token.

### Rule 10 — Transaction Ownership

The backend must verify transaction ownership before reading, editing, or deleting a transaction.

---

# 21. Project Constraints

The initial version of the project will have the following limitations:

* The application is designed primarily for personal financial management.
* The system does not process real bank transactions.
* The system does not connect to real banking APIs.
* The system does not perform real money transfers.
* The system does not integrate with payment gateways.
* The system does not include bank account synchronization.
* The system does not include multi-user shared accounts.
* MariaDB is used as the primary database.
* The backend is implemented using Node.js and Express.js.
* The mobile application is implemented using Flutter.

---

# 22. Out of Scope

The following features are not required for the initial Mini Project:

* Real bank integration
* Online payment
* Credit card management
* Loan management
* Investment management
* Cryptocurrency management
* Bank statement import
* Email notifications
* SMS notifications
* Social features
* Shared wallets
* Multi-currency financial accounts
* Advanced financial forecasting
* AI financial advisor

These features should not be implemented unless explicitly requested later.

---

# 23. Expected System Flow

The overall system flow should follow this structure:

```text
User
 |
 v
Flutter Mobile Application
 |
 | HTTP / JSON
 v
Node.js + Express.js REST API
 |
 | Authentication / Business Logic
 |
 v
MariaDB
 |
 v
Transaction Data
 |
 v
Backend Calculation
 |
 v
Flutter Dashboard / Summary
```

Authentication flow:

```text
User
 |
 v
Login Screen
 |
 v
POST /api/auth/login
 |
 v
Node.js
 |
 v
Verify User
 |
 +---- Invalid ----> Error Response
 |
 +---- Valid ------> JWT Token
                       |
                       v
                 Flutter Application
                       |
                       v
                    Dashboard
```

Transaction flow:

```text
User
 |
 v
Create / Edit / Delete Transaction
 |
 v
Flutter
 |
 v
REST API
 |
 v
Authentication Check
 |
 v
Validate Request
 |
 v
Check User Ownership
 |
 v
MariaDB
 |
 v
Recalculate Financial Data
 |
 v
Return Response
 |
 v
Update Flutter UI
```

---

# 24. Definition of Done

The Mini Project will be considered complete when:

* [ ] User can log in successfully.
* [ ] User can log out successfully.
* [ ] Unauthorized users cannot access protected resources.
* [ ] Dashboard displays current balance.
* [ ] Dashboard displays total deposits.
* [ ] Dashboard displays total withdrawals.
* [ ] Dashboard displays transaction count.
* [ ] Dashboard displays recent transactions.
* [ ] User can add a deposit.
* [ ] User can add a withdrawal.
* [ ] System prevents withdrawal exceeding available balance.
* [ ] User can view transaction history.
* [ ] User can edit transactions.
* [ ] User can delete transactions.
* [ ] System asks for confirmation before deletion.
* [ ] Balance recalculates after creating a transaction.
* [ ] Balance recalculates after editing a transaction.
* [ ] Balance recalculates after deleting a transaction.
* [ ] User can filter transactions by type.
* [ ] User can filter transactions by month.
* [ ] User can filter transactions by year.
* [ ] User can view monthly deposit totals.
* [ ] User can view monthly withdrawal totals.
* [ ] User can view monthly balance.
* [ ] User data is isolated from other users.
* [ ] Passwords are securely hashed.
* [ ] API authentication is implemented.
* [ ] REST APIs have been tested using Postman.
* [ ] Database has been tested using MariaDB/HeidiSQL.
* [ ] Flutter application successfully communicates with the Node.js backend.

---

# 25. Development Priority

Development should follow this order:

```text
1. Requirements
      ↓
2. User Flow
      ↓
3. System Architecture
      ↓
4. Database Design
      ↓
5. Database Implementation
      ↓
6. API Specification
      ↓
7. Backend Development
      ↓
8. API Testing with Postman
      ↓
9. UI/UX Implementation
      ↓
10. Flutter Development
      ↓
11. Flutter + API Integration
      ↓
12. System Testing
      ↓
13. Final Documentation
```

The project should not skip the design and specification stages without explicit approval.

---

# 26. Important Instructions for AI Development

When developing this project, AI assistants must follow these rules:

1. Read and follow all project documentation before modifying or creating code.
2. Do not introduce features outside the defined project scope without explicit approval.
3. Do not change the database schema without updating `DATABASE_DESIGN.md`.
4. Do not change API endpoints or request/response structures without updating `API_SPECIFICATION.md`.
5. Do not change the system architecture without explicit approval.
6. Do not create duplicate functionality when an existing component or service can be reused.
7. Keep frontend and backend responsibilities separated.
8. Never connect Flutter directly to MariaDB.
9. Flutter must communicate with MariaDB through the Node.js REST API.
10. Never store plaintext passwords.
11. Never expose database credentials in source code.
12. Never trust `user_id` supplied directly by the client for authorization.
13. Always validate input on the backend.
14. Use parameterized SQL queries.
15. Preserve existing working functionality when adding new features.
16. If a requested change conflicts with the requirements, explain the conflict before implementing it.
17. When modifying code, explain which files are changed and why.
18. Keep the implementation appropriate for a Mini Project and avoid unnecessary over-engineering.

---

# 27. Final Technology Summary

```text
Frontend:
Flutter + Dart

Backend:
Node.js + Express.js

Database:
MariaDB

Authentication:
JWT + bcrypt

API:
RESTful API + JSON

API Testing:
Postman

Database Management:
HeidiSQL

Development:
Visual Studio Code + Android Studio

Version Control:
Git + GitHub
```

---

# 28. Project Success Criteria

The project should demonstrate the following technical capabilities:

* Mobile application development with Flutter.
* REST API development with Node.js and Express.js.
* Relational database design with MariaDB.
* Authentication and authorization.
* Secure password handling.
* CRUD operations.
* API integration.
* Financial data calculation.
* Data filtering and aggregation.
* Monthly financial reporting.
* Frontend and backend separation.
* Database management.
* API testing.
* Version control.

The final system should provide a functional, maintainable, and user-friendly mobile application for personal deposit and withdrawal management.