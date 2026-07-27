# API Specification

# Personal Deposit Account Management System

## 1. Overview

This document defines the REST API specification for the **Personal Deposit Account Management System**.

The API is used by the Flutter mobile application to communicate with the Node.js + Express.js backend. The backend is responsible for authentication, authorization, validation, business rules, transaction processing, dashboard calculations, and monthly summary generation.

The API must remain consistent with the requirements, user flow, architecture, and database design documents.

---

## 2. API Design Principles

The API must follow these principles:

1. Use RESTful endpoint naming.
2. Use JSON request and response bodies.
3. Keep the frontend and backend separated.
4. Use JWT for protected endpoints.
5. Use secure password handling with bcrypt.
6. Validate all input on the backend.
7. Never trust `user_id` sent directly from the client.
8. Return consistent response structures.
9. Support the Mini Project scope only.
10. Calculate financial totals from transaction records.

---

## 3. Base URL

The API base URL should be:

```text id="z1k8dw"
http://localhost:3000/api
```

In production, the base URL can be changed according to the deployment environment, but it must remain consistent across Flutter configuration and backend routing.

---

## 4. Authentication Scheme

The API uses **JWT Bearer Token** authentication for protected endpoints.

### 4.1 Authorization Header

Protected requests must include:

```http id="h9q2la"
Authorization: Bearer <token>
```

### 4.2 Protected Resources

The following resources require authentication:

* Dashboard
* Transaction list
* Transaction detail
* Create transaction
* Update transaction
* Delete transaction
* Monthly summary

### 4.3 Session Handling

* Login is performed through the API.
* Logout is handled by clearing stored session data on the Flutter side.
* The backend does not need to store plaintext sessions for the current project scope.

---

## 5. Common Response Format

All API responses should follow a consistent structure.

### 5.1 Success Response

```json id="n4p7gx"
{
  "success": true,
  "message": "Operation completed successfully.",
  "data": {}
}
```

### 5.2 Error Response

```json id="p6k3rn"
{
  "success": false,
  "message": "Error message here.",
  "error": "Optional technical detail"
}
```

### 5.3 Validation Error Response

```json id="d3v9sb"
{
  "success": false,
  "message": "Validation failed.",
  "errors": [
    {
      "field": "amount",
      "message": "Amount must be greater than zero."
    }
  ]
}
```

---

## 6. Standard Data Models

## 6.1 User Model

```json id="o2x8ft"
{
  "id": 1,
  "username": "admin",
  "created_at": "2026-07-26T10:00:00.000Z"
}
```

The password field must never be returned in API responses.

---

## 6.2 Transaction Model

```json id="r6q1md"
{
  "id": 1,
  "user_id": 1,
  "type": "deposit",
  "amount": 10000.00,
  "transaction_date": "2026-07-01",
  "description": "Salary",
  "created_at": "2026-07-01T09:00:00.000Z"
}
```

### Field Rules

* `type` must be either `deposit` or `withdraw`
* `amount` must be numeric and greater than zero
* `transaction_date` must be a valid date
* `description` may be optional in storage, but the application may require it in validation
* `user_id` must come from the authenticated user, not from client trust

---

## 7. Endpoint Summary

| Method | Endpoint            | Description            | Auth Required |
| ------ | ------------------- | ---------------------- | ------------- |
| POST   | `/auth/login`       | Login user             | No            |
| GET    | `/dashboard`        | Get dashboard summary  | Yes           |
| GET    | `/transactions`     | Get transaction list   | Yes           |
| GET    | `/transactions/:id` | Get transaction detail | Yes           |
| POST   | `/transactions`     | Create transaction     | Yes           |
| PUT    | `/transactions/:id` | Update transaction     | Yes           |
| DELETE | `/transactions/:id` | Delete transaction     | Yes           |
| GET    | `/summary/monthly`  | Get monthly summary    | Yes           |

Logout is performed on the Flutter side by clearing local session data.

---

## 8. Authentication API

## 8.1 Login

### Endpoint

```http id="t8m5cl"
POST /api/auth/login
```

### Purpose

Authenticates the user by username and password, then returns a JWT token if the credentials are valid.

### Request Body

```json id="v4q7nz"
{
  "username": "admin",
  "password": "123456"
}
```

### Validation Rules

* `username` must not be empty
* `password` must not be empty

### Success Response

```json id="y7r2cx"
{
  "success": true,
  "message": "Login successful.",
  "data": {
    "token": "jwt_token_here",
    "user": {
      "id": 1,
      "username": "admin"
    }
  }
}
```

### Failure Response: Invalid Credentials

```json id="c5j9qh"
{
  "success": false,
  "message": "Invalid username or password."
}
```

### Failure Response: Validation Error

```json id="b8w4sp"
{
  "success": false,
  "message": "Validation failed.",
  "errors": [
    {
      "field": "username",
      "message": "Username is required."
    },
    {
      "field": "password",
      "message": "Password is required."
    }
  ]
}
```

### Backend Rules

* Find the user by `username`
* Compare the password using `bcrypt`
* Return a JWT token if authentication succeeds
* Do not return the password hash
* Do not allow login without valid credentials

---

## 9. Dashboard API

## 9.1 Get Dashboard Summary

### Endpoint

```http id="q2n6av"
GET /api/dashboard
```

### Purpose

Returns the authenticated user’s summary data for the dashboard.

### Request Headers

```http id="m5t3sd"
Authorization: Bearer <token>
```

### Success Response

```json id="k8p1hr"
{
  "success": true,
  "message": "Dashboard data retrieved successfully.",
  "data": {
    "balance": 15500.00,
    "totalDeposit": 17000.00,
    "totalWithdraw": 1500.00,
    "transactionCount": 4,
    "recentTransactions": [
      {
        "id": 4,
        "type": "withdraw",
        "amount": 1000.00,
        "transaction_date": "2026-07-10",
        "description": "Transportation"
      },
      {
        "id": 3,
        "type": "deposit",
        "amount": 2000.00,
        "transaction_date": "2026-07-05",
        "description": "Bonus"
      }
    ]
  }
}
```

### Backend Rules

The backend must calculate:

* `balance = totalDeposit - totalWithdraw`
* `totalDeposit = SUM(all deposit transactions)`
* `totalWithdraw = SUM(all withdrawal transactions)`
* `transactionCount = COUNT(all user transactions)`

Recent transactions should be returned from newest to oldest.

---

## 10. Transaction APIs

## 10.1 Get Transaction List

### Endpoint

```http id="n6r4yt"
GET /api/transactions
```

### Purpose

Returns the authenticated user’s transaction history.

### Query Parameters

```text id="x3p7mn"
type
month
year
```

### Example

```http id="f2d8ka"
GET /api/transactions?type=deposit&month=7&year=2026
```

### Success Response

```json id="u1c9sd"
{
  "success": true,
  "message": "Transactions retrieved successfully.",
  "data": [
    {
      "id": 4,
      "type": "withdraw",
      "amount": 1000.00,
      "transaction_date": "2026-07-10",
      "description": "Transportation",
      "created_at": "2026-07-10T08:30:00.000Z"
    }
  ]
}
```

### Filter Rules

* `type` may be `deposit`, `withdraw`, or omitted for all
* `month` must be a valid month number if provided
* `year` must be a valid year if provided
* Results must belong only to the authenticated user
* Results should be sorted from newest to oldest

---

## 10.2 Get Transaction Detail

### Endpoint

```http id="l8q2hv"
GET /api/transactions/:id
```

### Purpose

Returns one transaction record belonging to the authenticated user.

### Success Response

```json id="r3m7kc"
{
  "success": true,
  "message": "Transaction retrieved successfully.",
  "data": {
    "id": 4,
    "type": "withdraw",
    "amount": 1000.00,
    "transaction_date": "2026-07-10",
    "description": "Transportation",
    "created_at": "2026-07-10T08:30:00.000Z"
  }
}
```

### Error Rules

* Return `404` if the transaction does not exist
* Return `403` or `404` if the transaction does not belong to the authenticated user
* Return `401` if the token is missing or invalid

---

## 10.3 Create Transaction

### Endpoint

```http id="w9v4qa"
POST /api/transactions
```

### Purpose

Creates a deposit or withdrawal transaction.

### Request Body

```json id="k1f8jm"
{
  "type": "deposit",
  "amount": 2000,
  "transaction_date": "2026-07-26",
  "description": "Salary"
}
```

### Validation Rules

* `type` is required
* `amount` is required and must be greater than zero
* `transaction_date` is required and must be valid
* `description` must be present if required by the UI rules
* `type` must be either `deposit` or `withdraw`

### Additional Withdrawal Rule

If `type = withdraw`, the amount must not exceed the current available balance.

### Success Response

```json id="p4q6xs"
{
  "success": true,
  "message": "Transaction created successfully.",
  "data": {
    "id": 5,
    "user_id": 1,
    "type": "deposit",
    "amount": 2000.00,
    "transaction_date": "2026-07-26",
    "description": "Salary",
    "created_at": "2026-07-26T12:00:00.000Z"
  }
}
```

### Error Response: Insufficient Balance

```json id="m2s8jt"
{
  "success": false,
  "message": "Insufficient balance for this withdrawal."
}
```

### Backend Rules

* The `user_id` must come from the authenticated token
* The backend must save the transaction in MariaDB
* The backend must recalculate dashboard totals after insert

---

## 10.4 Update Transaction

### Endpoint

```http id="a7r1pd"
PUT /api/transactions/:id
```

### Purpose

Updates an existing transaction belonging to the authenticated user.

### Request Body

```json id="h4d9ms"
{
  "type": "withdraw",
  "amount": 700,
  "transaction_date": "2026-07-26",
  "description": "Food and drinks"
}
```

### Validation Rules

* Same validation rules as create
* The transaction must belong to the authenticated user
* The updated data must still satisfy all business rules

### Success Response

```json id="z6t3cq"
{
  "success": true,
  "message": "Transaction updated successfully.",
  "data": {
    "id": 5,
    "user_id": 1,
    "type": "withdraw",
    "amount": 700.00,
    "transaction_date": "2026-07-26",
    "description": "Food and drinks",
    "created_at": "2026-07-26T12:00:00.000Z"
  }
}
```

### Error Response: Invalid Balance After Update

```json id="r9x2nb"
{
  "success": false,
  "message": "The updated transaction would violate the balance rule."
}
```

### Backend Rules

* Verify ownership before update
* Recalculate totals after update
* Reject updates that violate the balance rule

---

## 10.5 Delete Transaction

### Endpoint

```http id="c4j7lw"
DELETE /api/transactions/:id
```

### Purpose

Deletes a transaction belonging to the authenticated user.

### Success Response

```json id="t5n8vz"
{
  "success": true,
  "message": "Transaction deleted successfully."
}
```

### Backend Rules

* Verify ownership before delete
* Recalculate totals after delete
* Remove only the authenticated user’s transaction record

### Frontend Rule

The Flutter app must display a confirmation dialog before sending the delete request.

---

## 11. Monthly Summary API

## 11.1 Get Monthly Summary

### Endpoint

```http id="d8m3pq"
GET /api/summary/monthly
```

### Purpose

Returns the authenticated user’s financial summary for a selected month and year.

### Query Parameters

```text id="f7v1ke"
month
year
```

### Example

```http id="n2h5xr"
GET /api/summary/monthly?month=7&year=2026
```

### Success Response

```json id="q1c6bz"
{
  "success": true,
  "message": "Monthly summary retrieved successfully.",
  "data": {
    "month": 7,
    "year": 2026,
    "totalDeposit": 17000.00,
    "totalWithdraw": 1500.00,
    "balance": 15500.00
  }
}
```

### Backend Rules

* Filter transactions by authenticated user
* Filter records by month and year
* Sum deposits and withdrawals separately
* Compute monthly balance as `monthlyDeposit - monthlyWithdraw`

---

## 12. Error Handling Rules

The API must return clear and meaningful errors.

### 12.1 Common HTTP Status Codes

| Status Code | Meaning              |
| ----------- | -------------------- |
| `200`       | Success              |
| `201`       | Resource created     |
| `400`       | Invalid request data |
| `401`       | Unauthorized         |
| `403`       | Forbidden            |
| `404`       | Not found            |
| `500`       | Server error         |

### 12.2 Common Error Messages

```json id="v2k9hm"
{
  "success": false,
  "message": "Invalid username or password."
}
```

```json id="x8p1rk"
{
  "success": false,
  "message": "Please complete all required fields."
}
```

```json id="j3n6fb"
{
  "success": false,
  "message": "Amount must be greater than zero."
}
```

```json id="s5m2dq"
{
  "success": false,
  "message": "Unauthorized access."
}
```

```json id="y9t4cw"
{
  "success": false,
  "message": "Something went wrong. Please try again later."
}
```

---

## 13. Validation Rules by Field

## 13.1 Username

* Required
* Must not be empty

## 13.2 Password

* Required
* Must not be empty

## 13.3 Type

* Required
* Must be `deposit` or `withdraw`

## 13.4 Amount

* Required
* Numeric
* Greater than zero
* Decimal values allowed

## 13.5 Transaction Date

* Required
* Must be a valid date
* Must support month/year filtering

## 13.6 Description

* Optional in storage if needed
* May be required by the UI/validation rules
* Must fit within the database field length

---

## 14. Security Rules

The API must enforce the following security rules:

1. Passwords must be hashed with bcrypt.
2. JWT tokens must be required for protected endpoints.
3. Sensitive database credentials must be stored in environment variables.
4. SQL queries must be parameterized.
5. `user_id` must be derived from the authenticated session/token.
6. Users must not access other users’ transactions.
7. Invalid or missing tokens must block access.

---

## 15. Data Flow Summary

The API supports the following system flow:

```text id="q5l8vd"
Flutter App
  ↓ HTTP / JSON
Node.js + Express.js API
  ↓ Authentication / Validation / Business Rules
MariaDB
  ↓ Query Results
Node.js + Express.js API
  ↓ JSON Response
Flutter App
```

This flow applies to:

* Login
* Dashboard loading
* Transaction CRUD
* Filtering
* Monthly summary

---

## 16. Consistency with Database Design

This API specification matches the database design by using:

* `users.id`
* `users.username`
* `users.password`
* `transactions.id`
* `transactions.user_id`
* `transactions.type`
* `transactions.amount`
* `transactions.transaction_date`
* `transactions.description`
* `transactions.created_at`

The API does not introduce database fields outside the approved schema.

---

## 17. Logout Handling

The current project scope defines logout as clearing session information on the Flutter side and returning the user to the Login screen.

If a backend logout endpoint is added later, it must be documented and aligned with the same authentication design.

For the current version, no dedicated server-side logout endpoint is required.

---

## 18. API Testing Scope

The API should be tested using Postman for:

* Login success and failure
* Dashboard retrieval
* Transaction creation
* Transaction update
* Transaction delete
* Transaction filtering
* Monthly summary retrieval
* Invalid token handling
* Ownership validation
* Insufficient balance handling

---

## 19. Endpoint Completion Criteria

This API specification is complete when it supports all required project features:

* Authentication
* Dashboard summary
* Transaction creation
* Transaction retrieval
* Transaction update
* Transaction deletion
* Transaction filtering
* Monthly summary

It must also enforce:

* JWT authentication
* bcrypt password verification
* ownership checks
* validation rules
* financial recalculation
* consistent JSON responses

---

## 20. Final API Summary

The API layer acts as the bridge between the Flutter frontend and the MariaDB database.

Its responsibilities are:

* Authenticate users
* Protect user data
* Process transactions
* Enforce business rules
* Return dashboard and summary data
* Support the entire mobile application workflow

The API must remain consistent with the project requirements, user flow, architecture, and database design documents.