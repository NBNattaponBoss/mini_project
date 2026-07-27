# README

# Personal Deposit Account Management System

## 1. Project Overview

**Personal Deposit Account Management System** is a mobile application developed for managing personal deposit and withdrawal transactions.

The system allows a user to:

* Log in securely
* View dashboard financial summaries
* Add deposit transactions
* Add withdrawal transactions
* Edit and delete transactions
* Filter transaction history by type, month, and year
* View monthly financial summaries
* Log out securely

This project is built as a **Mini Project** using **Flutter**, **Node.js**, **Express.js**, and **MariaDB**.

---

## 2. Project Purpose

The purpose of this project is to demonstrate:

* Mobile application development
* REST API integration
* Backend development
* Database design and management
* Authentication and authorization
* CRUD operations
* Financial data calculation
* User interface design for financial tracking

---

## 3. Key Features

### Authentication

* Secure login with username and password
* JWT-based authentication
* Logout by clearing session data

### Dashboard

* Current balance
* Total deposit
* Total withdrawal
* Transaction count
* Recent transactions

### Transaction Management

* Add deposit transactions
* Add withdrawal transactions
* Edit transactions
* Delete transactions
* View transaction history

### Filtering

* Filter by transaction type
* Filter by month
* Filter by year

### Monthly Summary

* Monthly total deposit
* Monthly total withdrawal
* Monthly balance

---

## 4. Technology Stack

### Frontend

* Flutter
* Dart

### Backend

* Node.js
* Express.js

### Database

* MariaDB

### Authentication

* JWT
* bcrypt

### API Communication

* REST API
* JSON
* HTTP

### Development Tools

* Visual Studio Code
* HeidiSQL
* Postman
* Android Studio
* Git
* GitHub

---

## 5. System Architecture

The project follows a three-tier architecture:

```text id="m1z7qv"
Flutter Mobile Application
        ↓ HTTP / JSON
Node.js + Express.js REST API
        ↓ SQL
MariaDB Database
```

### Responsibilities

#### Flutter

* Display UI screens
* Collect user input
* Send API requests
* Show dashboard and transaction data

#### Node.js + Express.js

* Authenticate users
* Validate requests
* Enforce business rules
* Process transactions
* Calculate summaries
* Handle database operations

#### MariaDB

* Store users
* Store transactions
* Support filtering and summary queries

---

## 6. Database Overview

The database contains two main tables:

* `users`
* `transactions`

### Relationship

```text id="c8n2hd"
users (1) ─────────────── (N) transactions
```

### Main Table Purpose

#### users

Stores login information and password hashes.

#### transactions

Stores deposit and withdrawal records for each authenticated user.

---

## 7. API Overview

The backend provides RESTful API endpoints for:

* Login
* Dashboard data
* Transaction list
* Transaction detail
* Create transaction
* Update transaction
* Delete transaction
* Monthly summary

### Main Endpoints

* `POST /api/auth/login`
* `GET /api/dashboard`
* `GET /api/transactions`
* `GET /api/transactions/:id`
* `POST /api/transactions`
* `PUT /api/transactions/:id`
* `DELETE /api/transactions/:id`
* `GET /api/summary/monthly`

---

## 8. Project Structure

### Recommended Folder Structure

```text id="b9q4mf"
personal-account-app/
├── docs/
│   ├── 01_PROJECT_REQUIREMENTS.md
│   ├── 02_USER_FLOW.md
│   ├── 03_SYSTEM_ARCHITECTURE.md
│   ├── 04_DATABASE_DESIGN.md
│   ├── 05_API_SPECIFICATION.md
│   ├── 06_UI_UX_SPECIFICATION.md
│   ├── 07_DEVELOPMENT_GUIDELINES.md
│   ├── 08_TODO.md
│   ├── 09_TESTING.md
│   └── README.md
├── frontend/
│   └── Flutter project
├── backend/
│   └── Node.js project
└── database/
    └── database.sql
```

### Flutter Folder Structure

```text id="q6r1vt"
frontend/
└── lib/
    ├── models/
    ├── screens/
    ├── services/
    ├── widgets/
    └── main.dart
```

### Backend Folder Structure

```text id="p3k8yd"
backend/
├── config/
├── controllers/
├── middleware/
├── models/
├── routes/
├── utils/
├── .env
├── server.js
└── package.json
```

---

## 9. Database Design Summary

### `users`

| Field        | Type         | Description           |
| ------------ | ------------ | --------------------- |
| `id`         | INT          | Primary key           |
| `username`   | VARCHAR(50)  | Login username        |
| `password`   | VARCHAR(255) | Hashed password       |
| `created_at` | TIMESTAMP    | Account creation time |

### `transactions`

| Field              | Type                        | Description          |
| ------------------ | --------------------------- | -------------------- |
| `id`               | INT                         | Primary key          |
| `user_id`          | INT                         | Foreign key to users |
| `type`             | ENUM('deposit', 'withdraw') | Transaction type     |
| `amount`           | DECIMAL(12,2)               | Transaction amount   |
| `transaction_date` | DATE                        | Transaction date     |
| `description`      | VARCHAR(255)                | Transaction detail   |
| `created_at`       | TIMESTAMP                   | Record creation time |

---

## 10. Core Business Rules

* A transaction must belong to one authenticated user.
* A transaction amount must be greater than zero.
* Deposit increases the balance.
* Withdrawal decreases the balance.
* Withdrawal must not exceed the available balance.
* Balance must be calculated from transaction records.
* Editing or deleting a transaction must recalculate totals.
* Protected data must only be accessible with valid authentication.
* Flutter must not connect directly to MariaDB.

---

## 11. Installation

## 11.1 Prerequisites

Make sure the following tools are installed:

* Flutter SDK
* Dart
* Node.js
* npm
* MariaDB
* HeidiSQL
* Visual Studio Code
* Android Studio
* Postman
* Git

---

## 11.2 Backend Setup

### 1. Install dependencies

```bash id="v8m4rl"
npm install
```

### 2. Configure environment variables

Create a `.env` file in the backend folder:

```env id="n5x7kc"
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=personal_account
DB_PORT=3306
JWT_SECRET=your_secret_key
PORT=3000
```

### 3. Start the backend server

```bash id="k1p9qx"
npm run dev
```

If no dev script is defined, use:

```bash id="z2v8hs"
node server.js
```

---

## 11.3 Flutter Setup

### 1. Install dependencies

```bash id="f4m6td"
flutter pub get
```

### 2. Run the Flutter app

```bash id="h7c2jp"
flutter run
```

---

## 12. How to Run the Project

### Step 1: Start MariaDB

Make sure MariaDB is running.

### Step 2: Open the database in HeidiSQL

* Create the database
* Create the tables
* Insert sample data if needed

### Step 3: Start the backend

Run the Node.js + Express.js server.

### Step 4: Start the Flutter application

Run the mobile application on an emulator or device.

### Step 5: Test the system

Use the application and verify:

* Login
* Dashboard
* Add deposit
* Add withdrawal
* Edit transaction
* Delete transaction
* Filter transaction history
* View monthly summary

---

## 13. API Testing

The backend can be tested using Postman.

### Suggested Tests

* Login success
* Login failure
* Get dashboard
* Create transaction
* Update transaction
* Delete transaction
* Filter transactions
* Get monthly summary
* Unauthorized access
* Insufficient balance

---

## 14. Testing Summary

The project was designed to support testing at multiple levels:

* Frontend testing
* Backend testing
* Database testing
* Integration testing
* End-to-end testing

Refer to `09_TESTING.md` for the full testing plan.

---

## 15. Screens in the Application

### Login Screen

For user authentication.

### Dashboard Screen

For displaying balance and financial summaries.

### Transaction List Screen

For displaying transaction history and filters.

### Add Transaction Screen

For creating deposit and withdrawal records.

### Edit Transaction Screen

For updating transaction records.

### Monthly Summary Screen

For displaying monthly deposit, withdrawal, and balance values.

---

## 16. Security Notes

* Passwords are stored as hashes using bcrypt.
* JWT is used to protect APIs.
* Sensitive data should be stored in `.env`.
* SQL queries should be parameterized.
* Users can only access their own transactions.
* Flutter must not bypass the backend.

---

## 17. Project Goals for Resume

This project can be used in a resume to demonstrate:

* Flutter mobile development
* Node.js and Express.js backend development
* MariaDB relational database design
* REST API integration
* Authentication and authorization
* CRUD operations
* Financial data calculation
* Full-stack application development

---

## 18. Final Notes

This project is intentionally designed to remain simple, consistent, and suitable for a Mini Project.

All documentation files should remain synchronized and should not conflict with one another.

If a requirement changes, the related documentation and implementation should be updated together.

---

## 19. Summary

**Personal Deposit Account Management System** is a mobile app for managing personal deposits and withdrawals with secure login, transaction tracking, dashboard summaries, and monthly financial reporting.

It is developed using:

* **Flutter** for the mobile frontend
* **Node.js + Express.js** for the backend API
* **MariaDB** for data storage
* **JWT + bcrypt** for authentication security

The project demonstrates a complete end-to-end workflow from user login to financial summary display.