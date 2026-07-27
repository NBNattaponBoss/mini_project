# Development Guidelines

# Personal Deposit Account Management System

## 1. Overview

This document defines the development guidelines for the **Personal Deposit Account Management System**.

The guidelines describe how the project should be implemented so that the codebase remains consistent with the project requirements, user flow, system architecture, database design, API specification, and UI/UX specification.

These guidelines are intended to guide both human developers and AI-assisted development tools.

---

## 2. Development Principles

The project must follow these core principles:

1. Keep the implementation aligned with the approved project scope.
2. Separate frontend, backend, and database responsibilities clearly.
3. Keep the code simple and maintainable.
4. Reuse existing components and logic whenever possible.
5. Avoid unnecessary complexity.
6. Use secure coding practices.
7. Keep naming and structure consistent across the project.
8. Ensure all changes remain synchronized with the documentation.

---

## 3. Scope Control

The system is a Mini Project, so implementation must stay within the approved scope.

### Allowed Features

* Login
* Logout
* Dashboard
* Deposit transaction management
* Withdrawal transaction management
* Transaction history
* Transaction filtering
* Monthly summary
* CRUD operations
* Authentication and authorization

### Not Allowed Unless Added Later

* Real bank integration
* Payment gateway integration
* Credit card management
* Loan management
* Investment management
* Cryptocurrency management
* Shared wallets
* Multi-user collaborative accounts
* AI financial advisor
* Email/SMS notifications

Developers must not add extra features without updating the requirements and all dependent documents.

---

## 4. Technology Rules

The project must use the following stack:

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

The technology stack must remain consistent across code, documentation, and configuration files.

---

## 5. Project Structure Rules

The project should be organized into clear folders to keep responsibilities separated.

### Recommended Folder Structure

```text id="a8w2rk"
personal-account-app/
├── docs/
├── frontend/
│   └── Flutter project
├── backend/
│   └── Node.js project
├── database/
│   └── database.sql
└── README.md
```

### Frontend Structure

```text id="b7n4sl"
frontend/
└── lib/
    ├── models/
    ├── screens/
    ├── services/
    ├── widgets/
    └── main.dart
```

### Backend Structure

```text id="k3m9dq"
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

### Structure Rules

* Keep UI code inside Flutter screens and widgets.
* Keep API communication inside Flutter services.
* Keep backend request handling inside routes and controllers.
* Keep database query logic inside backend models or data-access functions.
* Keep shared helpers in utility files only when needed.

---

## 6. Naming Conventions

The project must use consistent naming conventions.

### 6.1 Flutter / Dart

Use `camelCase` for variables, functions, and methods.

Examples:

* `currentBalance`
* `transactionDate`
* `loadDashboardData()`

### 6.2 Node.js / JavaScript

Use `camelCase` for variables and functions.

Examples:

* `loginUser`
* `getMonthlySummary`
* `verifyToken`

### 6.3 Database

Use lowercase names with underscores.

Examples:

* `users`
* `transactions`
* `transaction_date`
* `created_at`

### 6.4 API Endpoints

Use lowercase resource names and RESTful paths.

Examples:

* `/api/auth/login`
* `/api/dashboard`
* `/api/transactions`
* `/api/summary/monthly`

### Naming Rules

* Do not use inconsistent names for the same concept.
* Use `transaction_date` in the database and API payloads.
* Use `deposit` and `withdraw` as transaction types.
* Keep field names synchronized across all layers.

---

## 7. Frontend Development Guidelines

## 7.1 Flutter Code Organization

The Flutter application should be divided into:

* screens
* widgets
* models
* services
* utilities

### Responsibilities

* `screens/` handles pages and layout.
* `widgets/` handles reusable UI components.
* `models/` handles data structures.
* `services/` handles API requests and business interaction.
* `utils/` handles helpers such as formatting and constants.

---

## 7.2 Flutter State Management

The project should use a simple and maintainable state management approach.

### Guidelines

* Keep state local when possible.
* Store session data such as token and user information securely in local storage.
* Refresh UI after API operations succeed.
* Do not place all logic inside widgets.
* Separate API calls from UI rendering.

A lightweight approach is acceptable for a Mini Project as long as the structure remains clear.

---

## 7.3 Flutter UI Rules

The Flutter UI must follow the UI/UX specification.

### Rules

* Use consistent colors and spacing.
* Keep screens mobile-friendly.
* Reuse transaction cards and summary cards.
* Show loading indicators during API requests.
* Show clear error messages for invalid input or failed requests.
* Show empty states when no data is available.
* Require confirmation before delete actions.

---

## 7.4 Flutter Validation Rules

The Flutter app may perform basic validation before sending requests.

### Required Client-Side Checks

* Username cannot be empty
* Password cannot be empty
* Amount must be greater than zero
* Transaction date must be selected
* Description must not be invalid or empty if required by the form

### Important Rule

Client-side validation is only a convenience.
The backend remains the final authority for validation and business rules.

---

## 7.5 Flutter API Integration Rules

Flutter must communicate with the backend only through REST API calls.

### Rules

* Do not connect Flutter directly to MariaDB.
* Use HTTP requests to call backend endpoints.
* Attach the JWT token to protected requests.
* Handle success and error responses properly.
* Refresh UI after create, update, and delete operations.

---

## 8. Backend Development Guidelines

## 8.1 Backend Code Organization

The backend should follow a layered structure.

### Recommended Layers

* Routes
* Controllers
* Middleware
* Models / Data access
* Utilities

### Responsibilities

* `routes/` defines API endpoints.
* `controllers/` process requests and build responses.
* `middleware/` handles authentication and authorization.
* `models/` handle database queries.
* `utils/` contains reusable helper logic.

---

## 8.2 Backend Business Logic Rules

The backend must enforce all important business rules.

### Rules

* Validate all incoming request data.
* Verify user credentials during login.
* Hash and compare passwords using bcrypt.
* Issue JWT tokens after successful login.
* Verify JWT tokens on protected routes.
* Determine the authenticated user from the token.
* Reject access to other users’ transactions.
* Prevent withdrawals that exceed the current balance.
* Recalculate totals after transaction create, update, or delete operations.

---

## 8.3 Backend Validation Rules

The backend must validate all incoming data even if the frontend already validated it.

### Validate

* Username
* Password
* Transaction type
* Amount
* Transaction date
* Description
* Month
* Year
* Transaction ownership

### Validation Principles

* Never trust client input blindly.
* Never trust `user_id` from the client for authorization.
* Return clear validation errors.
* Use consistent error messages.

---

## 8.4 Backend Security Rules

The backend must follow secure coding practices.

### Required Security Practices

* Store passwords as bcrypt hashes
* Use JWT for authentication
* Store secrets in environment variables
* Use parameterized SQL queries
* Prevent SQL injection
* Verify ownership before reading or modifying transaction data
* Protect all user-specific endpoints

### Forbidden Practices

* Do not store passwords in plain text
* Do not expose database credentials in source code
* Do not concatenate raw input into SQL statements
* Do not bypass middleware for protected routes

---

## 8.5 Backend Calculation Rules

The backend is responsible for calculating the financial data shown in the app.

### Calculations

* Total deposit
* Total withdrawal
* Current balance
* Transaction count
* Monthly deposit
* Monthly withdrawal
* Monthly balance

### Rules

* Balance must be calculated from transaction records.
* Monthly summary must be calculated from filtered transaction records.
* Do not rely on manually entered balance values.
* Recalculate totals whenever a transaction changes.

---

## 9. Database Development Guidelines

## 9.1 Database Rules

The database must remain aligned with `DATABASE_DESIGN.md`.

### Rules

* Use only the approved tables and fields.
* Keep `users` and `transactions` as the main tables.
* Keep foreign key relationships intact.
* Use the correct data types and constraints.
* Do not add summary tables unless the requirements change.

---

## 9.2 SQL Rules

### Required Practices

* Use `DECIMAL(12,2)` for financial amounts.
* Use `DATE` for transaction dates.
* Use `ENUM('deposit', 'withdraw')` for transaction type.
* Use foreign keys for ownership integrity.
* Use `ON DELETE CASCADE` only if it matches the documented design.
* Use indexes only when needed for performance.

### Forbidden Practices

* Do not store current balance as a manually editable database field.
* Do not store plaintext passwords.
* Do not create redundant tables for monthly summaries.
* Do not change field names without updating documentation.

---

## 10. API Development Guidelines

The backend API must remain consistent with `API_SPECIFICATION.md`.

### Rules

* Use RESTful endpoint naming.
* Use JSON for request and response bodies.
* Return consistent response structures.
* Return meaningful error messages.
* Protect sensitive endpoints using JWT.
* Keep request and response field names consistent with the frontend and database.

### Important Consistency Rules

* `transaction_date` must remain the transaction date field.
* `type` must remain `deposit` or `withdraw`.
* `amount` must remain numeric and positive.
* `description` must remain the descriptive field for transactions.
* `user_id` must come from authentication context, not client trust.

---

## 11. Authentication Guidelines

## 11.1 Login Implementation

* Verify credentials against the `users` table.
* Use bcrypt to compare passwords.
* Generate JWT after successful authentication.
* Return safe user information only.

## 11.2 Logout Implementation

* Logout is handled by clearing local session data in Flutter.
* Protected screens should become inaccessible after logout.
* If a server-side logout endpoint is added later, it must be documented first.

## 11.3 Session Storage

* Store authentication token securely on the client side.
* Do not expose the token unnecessarily.
* Clear token and user data on logout.

---

## 12. Transaction Handling Guidelines

The project must implement transaction handling consistently.

### Transaction Types

* `deposit`
* `withdraw`

### Transaction Rules

* Each transaction must belong to one authenticated user.
* Each transaction must have a valid amount and date.
* Withdrawals must not exceed the available balance.
* Editing a transaction must trigger recalculation.
* Deleting a transaction must trigger recalculation.

### Ownership Rules

* Users can only access their own transactions.
* Ownership must be checked on the backend.
* Never allow direct access to another user's records.

---

## 13. UI and API Synchronization Rules

The frontend and backend must remain synchronized.

### Synchronization Rules

* Every UI form field must match a backend request field.
* Every backend response field used by Flutter must be documented.
* Every screen in UI/UX must have a corresponding API flow.
* Every API endpoint must support a documented user flow.
* Every user flow must support a documented requirement.

---

## 14. Error Handling Guidelines

The project must show clear error handling in both frontend and backend.

### Frontend

* Show validation messages near fields.
* Show request failure messages clearly.
* Show loading states during API calls.
* Show empty states when no data exists.

### Backend

* Return meaningful error messages.
* Return proper HTTP status codes.
* Do not expose sensitive internal details.
* Keep error responses consistent.

### Common Error Situations

* Invalid login credentials
* Empty required fields
* Invalid amount
* Insufficient balance
* Unauthorized access
* Transaction not found
* Server error

---

## 15. Logging and Debugging Guidelines

### Development Logging

* Log important request and error details during development.
* Do not log sensitive information such as passwords or tokens.
* Use logging only for debugging and development visibility.

### Debugging Tools

* Use Postman to test API endpoints.
* Use HeidiSQL to inspect database data.
* Use Flutter DevTools or Android Studio tools to inspect UI issues.

---

## 16. Testing Guidelines

The project should be tested at each major layer.

### Backend Testing

* Login endpoint
* Dashboard endpoint
* Transaction CRUD endpoints
* Monthly summary endpoint
* Invalid token handling
* Ownership checks
* Insufficient balance checks

### Frontend Testing

* Login form validation
* Dashboard rendering
* Transaction form validation
* Filtering behavior
* Delete confirmation
* Empty state handling

### Database Testing

* Insert transactions
* Update transactions
* Delete transactions
* Foreign key integrity
* Query results for summaries and filters

---

## 17. Version Control Guidelines

### Git Rules

* Commit changes in meaningful steps.
* Keep commit messages clear.
* Avoid unrelated changes in the same commit.
* Keep documentation and code synchronized.

### GitHub Rules

* Use GitHub as the source repository.
* Keep code organized and readable.
* Include project documentation in the repository.
* Do not push broken or incomplete core logic without clear intent.

---

## 18. AI-Assisted Development Guidelines

When using AI to help generate or modify code, the AI must follow these rules:

1. Read the project documentation before making changes.
2. Do not invent new features outside the approved scope.
3. Keep all document references consistent.
4. Do not change database or API structure without updating related documentation.
5. Do not create duplicate logic when existing code can be reused.
6. Keep naming consistent across the project.
7. Preserve the user flow and UI structure already defined.
8. Keep code appropriate for a Mini Project.
9. Explain changes clearly when modifying code.
10. Avoid over-engineering.

---

## 19. Implementation Priority

Development should follow this order:

```text id="r4m2zp"
1. Requirements
   ↓
2. User Flow
   ↓
3. System Architecture
   ↓
4. Database Design
   ↓
5. API Specification
   ↓
6. UI/UX Specification
   ↓
7. Development Guidelines
   ↓
8. TODO Plan
   ↓
9. Database Implementation
   ↓
10. Backend Implementation
   ↓
11. API Testing
   ↓
12. Flutter Implementation
   ↓
13. Integration Testing
   ↓
14. Final Documentation
```

The project should not jump to coding before the architecture and data model are clear.

---

## 20. Code Quality Guidelines

The codebase should be:

* Readable
* Maintainable
* Modular
* Secure
* Consistent
* Easy to debug
* Easy to extend within the project scope

### Good Practices

* Use meaningful names.
* Keep functions focused.
* Reuse components.
* Separate logic from UI.
* Keep SQL queries safe and readable.
* Keep API response structures consistent.

### Bad Practices

* Putting all logic into one file
* Using unclear variable names
* Hardcoding sensitive values
* Duplicating transaction logic
* Bypassing validation
* Mixing UI with database logic
* Expanding the system beyond scope

---

## 21. Documentation Sync Rules

Any code change that affects one part of the system must be reflected in the related documents.

### If You Change:

* Requirements → update all dependent documents
* Database → update `DATABASE_DESIGN.md` and related API docs
* API → update `API_SPECIFICATION.md` and any frontend references
* UI → update `UI_UX_SPECIFICATION.md` and any affected flow docs
* Development rules → update this document and implementation notes

The documentation must remain a single consistent system.

---

## 22. Final Development Statement

These guidelines ensure that the Personal Deposit Account Management System remains consistent, secure, maintainable, and appropriate for a Mini Project.

The project should be implemented with:

* Clear separation of concerns
* Consistent naming and structure
* Secure authentication
* Correct transaction handling
* Accurate financial calculations
* Clean Flutter UI
* Reliable Node.js backend
* Well-defined MariaDB schema

All future implementation work must follow these guidelines and remain aligned with the approved documentation.