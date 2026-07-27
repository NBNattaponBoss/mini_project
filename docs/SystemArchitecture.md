# System Architecture

# Personal Deposit Account Management System

## 1. Overview

This document defines the system architecture of the **Personal Deposit Account Management System**.

The system is designed as a mobile application that follows a **three-tier architecture**:

1. **Frontend Mobile Application**
2. **Backend REST API**
3. **Relational Database**

The architecture is intended to support the project requirements and user flows defined in the project documentation, including authentication, dashboard display, transaction management, filtering, and monthly financial summary.

---

## 2. Architecture Goals

The system architecture must:

1. Separate the mobile frontend from backend business logic.
2. Keep database access inside the backend layer.
3. Support secure authentication using JWT and bcrypt.
4. Support CRUD operations for deposit and withdrawal transactions.
5. Recalculate financial totals automatically after data changes.
6. Allow the Flutter application to communicate with the backend through REST API calls.
7. Use MariaDB as the central relational database.
8. Maintain a clear and simple structure suitable for a Mini Project.

---

## 3. High-Level Architecture

```text
┌──────────────────────────────────────────────┐
│            Flutter Mobile Application        │
│                  Frontend                    │
│                                              │
│  - Login Screen                              │
│  - Dashboard                                 │
│  - Transaction List                          │
│  - Add / Edit Transaction                    │
│  - Monthly Summary                           │
│  - Logout                                    │
└──────────────────────┬───────────────────────┘
                       │ HTTP / JSON
                       ▼
┌──────────────────────────────────────────────┐
│            Node.js + Express.js API          │
│                  Backend                     │
│                                              │
│  - Authentication                            │
│  - Authorization                             │
│  - Business Rules                            │
│  - Transaction CRUD                          │
│  - Dashboard Data                            │
│  - Monthly Summary                           │
│  - Validation                                │
└──────────────────────┬───────────────────────┘
                       │ SQL
                       ▼
┌──────────────────────────────────────────────┐
│                    MariaDB                    │
│                  Database                    │
│                                              │
│  - users                                     │
│  - transactions                              │
└──────────────────────────────────────────────┘
```

---

## 4. Architecture Style

The system follows a **client-server architecture** with clear separation of responsibilities.

### 4.1 Client Layer

The client layer is the Flutter mobile application. It is responsible for:

* Rendering the user interface
* Collecting user input
* Displaying data received from the backend
* Handling local session state
* Sending API requests to the backend

### 4.2 Server Layer

The server layer is implemented using Node.js and Express.js. It is responsible for:

* Receiving API requests from Flutter
* Authenticating users
* Authorizing protected requests
* Validating input
* Applying business rules
* Reading and writing data in MariaDB
* Returning JSON responses

### 4.3 Data Layer

The data layer is MariaDB. It is responsible for:

* Storing user account data
* Storing deposit and withdrawal transactions
* Supporting queries for dashboard data
* Supporting queries for monthly summaries
* Supporting filtered transaction retrieval

---

## 5. Component Responsibilities

## 5.1 Flutter Mobile Application

The Flutter application is the presentation layer of the system.

Responsibilities:

* Login screen
* Dashboard screen
* Transaction list screen
* Add transaction screen
* Edit transaction screen
* Monthly summary screen
* Logout action
* Input validation before sending requests
* Displaying success and error messages
* Displaying financial summaries and transaction history

The Flutter application must not connect directly to MariaDB.

---

## 5.2 Node.js + Express.js Backend

The backend is the core processing layer of the system.

Responsibilities:

* Verify login credentials
* Issue JWT tokens after successful authentication
* Protect routes using authentication middleware
* Validate request payloads
* Enforce business rules
* Check transaction ownership
* Calculate totals and summaries
* Perform CRUD operations on transactions
* Return structured JSON responses

The backend acts as the only layer allowed to communicate with the database.

---

## 5.3 MariaDB Database

MariaDB is the central data storage layer.

Responsibilities:

* Store user credentials
* Store transaction records
* Support aggregation queries
* Support monthly filtering
* Support user-based data isolation

The database contains at least two tables:

* `users`
* `transactions`

---

## 6. Technology Mapping

The system uses the following technologies:

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

### Development and Testing Tools

* Visual Studio Code
* HeidiSQL
* Postman
* Android Studio
* Git
* GitHub

---

## 7. Layered Data Flow

The data flow of the system is:

```text
User
  ↓
Flutter Mobile Application
  ↓ HTTP / JSON
Node.js + Express.js API
  ↓ SQL
MariaDB
  ↓
Processed Result
  ↓ JSON Response
Flutter Mobile Application
  ↓
Updated UI
```

This flow must be followed for all protected operations, including login, dashboard loading, transaction creation, update, delete, filtering, and monthly summary display.

---

## 8. Authentication Architecture

Authentication is handled by the backend.

### Authentication Flow

```text
Flutter Login Screen
        ↓
POST /api/auth/login
        ↓
Node.js / Express.js
        ↓
Validate Username and Password
        ↓
Verify User in MariaDB
        ↓
Hash Comparison Using bcrypt
        ↓
Generate JWT Token
        ↓
Return Token and User Data
        ↓
Store Session Data in Flutter
```

### Authentication Rules

* Username and password are verified by the backend.
* Passwords must not be stored in plain text.
* JWT token is required for protected endpoints.
* Protected screens cannot be accessed without valid authentication.
* Logout clears stored session data on the device.

---

## 9. Authorization Architecture

Authorization is required for all user-specific operations.

The backend must verify that:

* The request contains a valid JWT token
* The authenticated user is identified correctly
* The user can only access their own transaction data
* The user cannot read, edit, or delete another user’s transaction records

Authorization is enforced in middleware and controller logic before database access occurs.

---

## 10. Transaction Processing Architecture

All transaction operations follow the same backend pattern:

```text
Flutter UI
  ↓
API Request
  ↓
Authentication Check
  ↓
Validation Check
  ↓
Ownership Check
  ↓
Database Operation
  ↓
Recalculate Totals
  ↓
JSON Response
  ↓
Refresh Flutter UI
```

This pattern applies to:

* Add deposit
* Add withdrawal
* Edit transaction
* Delete transaction
* View transaction list
* Filter transaction records
* Load monthly summary

---

## 11. Business Logic Placement

Business logic must be placed in the backend, not in the Flutter UI layer.

Examples of business logic:

* Rejecting empty fields
* Rejecting invalid amount values
* Preventing withdrawals that exceed the balance
* Recalculating current balance
* Calculating total deposits
* Calculating total withdrawals
* Calculating monthly balance
* Sorting transaction records from newest to oldest
* Checking transaction ownership

Flutter may perform basic form validation, but the backend must remain the source of truth for all critical rules.

---

## 12. Database Access Strategy

The backend should use parameterized SQL queries to communicate with MariaDB.

Database access rules:

1. Flutter must never query MariaDB directly.
2. Backend routes must never bypass authentication for protected operations.
3. User identity must come from the validated session or JWT token.
4. `user_id` must not be trusted directly from client input.
5. Insert, update, and delete operations must be followed by recalculation of relevant totals.

---

## 13. Recommended Backend Structure

The Node.js backend should be organized into clear folders to keep the project maintainable.

```text
backend/
├── config/
│   └── database.js
├── controllers/
│   ├── auth.controller.js
│   ├── dashboard.controller.js
│   └── transaction.controller.js
├── middleware/
│   └── auth.middleware.js
├── models/
│   ├── user.model.js
│   └── transaction.model.js
├── routes/
│   ├── auth.routes.js
│   ├── dashboard.routes.js
│   └── transaction.routes.js
├── utils/
│   └── helpers.js
├── .env
├── server.js
└── package.json
```

### Folder Responsibilities

* `config/` — database connection and app configuration
* `controllers/` — request handling and response logic
* `middleware/` — authentication and request protection
* `models/` — database query functions
* `routes/` — API endpoint definitions
* `utils/` — reusable helper functions

---

## 14. Recommended Flutter Structure

The Flutter app should also be organized clearly.

```text
frontend/
├── lib/
│   ├── models/
│   │   ├── user.dart
│   │   └── transaction.dart
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── home_screen.dart
│   │   ├── transaction_list_screen.dart
│   │   ├── add_transaction_screen.dart
│   │   ├── edit_transaction_screen.dart
│   │   └── monthly_summary_screen.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   └── transaction_service.dart
│   ├── widgets/
│   │   ├── balance_card.dart
│   │   ├── transaction_card.dart
│   │   └── summary_card.dart
│   └── main.dart
```

### Folder Responsibilities

* `models/` — data structures
* `screens/` — UI pages
* `services/` — API communication and logic
* `widgets/` — reusable UI components

---

## 15. Database Structure Summary

The database design is simple and centered on the authenticated user.

```text
users
  └── 1 to many ── transactions
```

### `users`

Stores login credentials and account identity.

### `transactions`

Stores deposit and withdrawal records for each user.

The architecture assumes that all financial summaries are calculated from transaction records rather than stored as manually edited balance values.

---

## 16. Security Architecture

The system must include the following security practices:

* Password hashing with bcrypt
* JWT authentication
* Protected API routes
* Input validation on backend
* Parameterized SQL queries
* Environment variables for sensitive configuration
* User ownership checks before transaction access

This ensures that the project remains suitable for a secure mini project implementation.

---

## 17. API Architecture Summary

The REST API provides the communication bridge between Flutter and MariaDB.

Main API groups:

* Authentication API
* Dashboard API
* Transaction API
* Monthly Summary API

The API returns JSON responses for all operations.

Typical endpoints include:

* Login
* Dashboard data retrieval
* Transaction list retrieval
* Transaction create, update, and delete
* Monthly summary retrieval

---

## 18. Architecture Constraints

The system must follow these constraints:

1. Flutter must communicate only through the REST API.
2. MariaDB must be accessed only by Node.js.
3. Authentication must be enforced on protected endpoints.
4. Business rules must not rely only on the mobile app.
5. Transaction ownership must be checked on the backend.
6. The architecture must remain simple and appropriate for a Mini Project.

---

## 19. Expected Runtime Sequence

A typical runtime sequence is:

```text
Open App
  ↓
Check session
  ↓
Login or go to Dashboard
  ↓
Load data through API
  ↓
Backend validates request
  ↓
Backend reads/writes MariaDB
  ↓
Backend recalculates totals
  ↓
Flutter updates the screen
```

This sequence applies to all user interactions in the application.

---

## 20. Architecture Completion Criteria

The architecture is considered complete when it supports all required modules:

* Authentication
* Dashboard
* Deposit management
* Withdrawal management
* Transaction management
* Monthly financial summary
* Data filtering
* Logout

It must also support the required technology stack:

* Flutter
* Dart
* Node.js
* Express.js
* MariaDB
* JWT
* bcrypt

---

## 21. Final Architecture Statement

This project uses a **Flutter frontend**, a **Node.js + Express.js backend**, and a **MariaDB database** in a three-tier architecture.

The frontend is responsible for presentation and user interaction, the backend is responsible for authentication, business rules, and API processing, and the database is responsible for persistent storage of user and transaction data.

The system must keep these layers separated to maintain clarity, security, and consistency across the entire Mini Project.