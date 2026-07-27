# TODO

# Personal Deposit Account Management System

## 1. Overview

This document lists the development tasks for the **Personal Deposit Account Management System**.

The task list is organized in the same order as the project documentation and implementation flow so that the project remains consistent with the approved requirements, user flow, architecture, database design, API specification, UI/UX specification, and development guidelines.

---

## 2. Project Task Priorities

The project should be completed in the following order:

```text id="p5n2qv"
1. Review Requirements
2. Review User Flow
3. Review Architecture
4. Review Database Design
5. Review API Specification
6. Review UI/UX Specification
7. Follow Development Guidelines
8. Implement Database
9. Implement Backend
10. Test API
11. Implement Flutter UI
12. Integrate Flutter with API
13. Test End-to-End Flow
14. Prepare Final Documentation
```

---

## 3. Phase 1 — Documentation Review

### 3.1 Review Project Requirements

* [ ] Confirm project scope
* [ ] Confirm project name
* [ ] Confirm technology stack
* [ ] Confirm functional requirements
* [ ] Confirm non-functional requirements
* [ ] Confirm business rules
* [ ] Confirm out-of-scope features

### 3.2 Review User Flow

* [ ] Confirm login flow
* [ ] Confirm dashboard flow
* [ ] Confirm deposit flow
* [ ] Confirm withdrawal flow
* [ ] Confirm transaction list flow
* [ ] Confirm edit flow
* [ ] Confirm delete flow
* [ ] Confirm filter flow
* [ ] Confirm monthly summary flow
* [ ] Confirm logout flow

### 3.3 Review System Architecture

* [ ] Confirm Flutter frontend
* [ ] Confirm Node.js + Express.js backend
* [ ] Confirm MariaDB database
* [ ] Confirm REST API communication
* [ ] Confirm JWT authentication
* [ ] Confirm backend ownership of business logic

### 3.4 Review Database Design

* [ ] Confirm `users` table
* [ ] Confirm `transactions` table
* [ ] Confirm data types
* [ ] Confirm primary keys
* [ ] Confirm foreign keys
* [ ] Confirm indexes
* [ ] Confirm balance is calculated, not stored manually

### 3.5 Review API Specification

* [ ] Confirm login endpoint
* [ ] Confirm dashboard endpoint
* [ ] Confirm transaction endpoints
* [ ] Confirm monthly summary endpoint
* [ ] Confirm request and response formats
* [ ] Confirm authentication rules
* [ ] Confirm validation rules

### 3.6 Review UI/UX Specification

* [ ] Confirm login screen
* [ ] Confirm dashboard screen
* [ ] Confirm transaction list screen
* [ ] Confirm add transaction screen
* [ ] Confirm edit transaction screen
* [ ] Confirm monthly summary screen
* [ ] Confirm delete confirmation dialog
* [ ] Confirm loading, empty, success, and error states

### 3.7 Review Development Guidelines

* [ ] Confirm folder structure
* [ ] Confirm naming conventions
* [ ] Confirm security rules
* [ ] Confirm validation rules
* [ ] Confirm API integration rules
* [ ] Confirm database access rules

---

## 4. Phase 2 — Database Implementation

### 4.1 Set Up MariaDB

* [ ] Create project database
* [ ] Create required tables
* [ ] Add foreign key relationships
* [ ] Add indexes if needed
* [ ] Insert sample data for testing

### 4.2 Implement `users` Table

* [ ] Create `users` table
* [ ] Set `id` as primary key
* [ ] Set `username` as unique
* [ ] Store hashed passwords
* [ ] Add `created_at`

### 4.3 Implement `transactions` Table

* [ ] Create `transactions` table
* [ ] Set `id` as primary key
* [ ] Add `user_id` foreign key
* [ ] Restrict `type` to `deposit` and `withdraw`
* [ ] Store `amount` as `DECIMAL(12,2)`
* [ ] Store `transaction_date`
* [ ] Store `description`
* [ ] Add `created_at`

### 4.4 Test Database

* [ ] Insert test user
* [ ] Insert test transactions
* [ ] Verify foreign key behavior
* [ ] Verify sample queries
* [ ] Verify filtering by date and type
* [ ] Verify summary calculation support

---

## 5. Phase 3 — Backend Implementation

### 5.1 Set Up Node.js Project

* [ ] Initialize backend project
* [ ] Install required packages
* [ ] Configure `.env`
* [ ] Set up database connection
* [ ] Set up Express server
* [ ] Set up CORS configuration

### 5.2 Implement Project Structure

* [ ] Create config folder
* [ ] Create routes folder
* [ ] Create controllers folder
* [ ] Create middleware folder
* [ ] Create models folder
* [ ] Create utils folder

### 5.3 Implement Authentication

* [ ] Create login route
* [ ] Validate username and password
* [ ] Check user credentials in database
* [ ] Hash and verify passwords using bcrypt
* [ ] Generate JWT token
* [ ] Return safe user data only
* [ ] Protect routes using JWT middleware

### 5.4 Implement Dashboard Logic

* [ ] Calculate total deposit
* [ ] Calculate total withdrawal
* [ ] Calculate current balance
* [ ] Count total transactions
* [ ] Retrieve recent transactions
* [ ] Return dashboard summary response

### 5.5 Implement Transaction CRUD

* [ ] Create transaction route
* [ ] Read transaction list route
* [ ] Read transaction detail route
* [ ] Update transaction route
* [ ] Delete transaction route
* [ ] Validate transaction ownership
* [ ] Apply business rules for deposits and withdrawals
* [ ] Recalculate totals after changes

### 5.6 Implement Filtering

* [ ] Filter by transaction type
* [ ] Filter by month
* [ ] Filter by year
* [ ] Support combined filtering
* [ ] Sort results from newest to oldest

### 5.7 Implement Monthly Summary

* [ ] Accept month and year query parameters
* [ ] Retrieve matching transactions
* [ ] Calculate monthly deposit total
* [ ] Calculate monthly withdrawal total
* [ ] Calculate monthly balance
* [ ] Return monthly summary response

### 5.8 Backend Validation and Security

* [ ] Validate all request payloads
* [ ] Prevent empty required fields
* [ ] Prevent invalid amount values
* [ ] Prevent withdrawal over balance
* [ ] Prevent unauthorized access
* [ ] Use parameterized SQL queries
* [ ] Avoid direct trust in client `user_id`

---

## 6. Phase 4 — API Testing

### 6.1 Test Authentication API

* [ ] Test login success
* [ ] Test login failure
* [ ] Test missing username
* [ ] Test missing password
* [ ] Test invalid token access

### 6.2 Test Dashboard API

* [ ] Test dashboard with valid token
* [ ] Test dashboard without token
* [ ] Test dashboard with invalid token

### 6.3 Test Transaction APIs

* [ ] Test create deposit
* [ ] Test create withdrawal
* [ ] Test withdrawal exceeding balance
* [ ] Test transaction list
* [ ] Test transaction detail
* [ ] Test update transaction
* [ ] Test delete transaction
* [ ] Test ownership protection

### 6.4 Test Filter and Summary APIs

* [ ] Test filter by type
* [ ] Test filter by month
* [ ] Test filter by year
* [ ] Test monthly summary retrieval
* [ ] Test empty month summary
* [ ] Test invalid query parameters

### 6.5 Document API Test Results

* [ ] Record tested endpoints
* [ ] Record expected results
* [ ] Record actual results
* [ ] Record fixes if needed

---

## 7. Phase 5 — Flutter Frontend Implementation

### 7.1 Set Up Flutter Project

* [ ] Initialize Flutter project
* [ ] Install required packages
* [ ] Configure project structure
* [ ] Set up theme and app styling
* [ ] Set up API base URL configuration

### 7.2 Implement Authentication Screens

* [ ] Build login screen
* [ ] Add username input
* [ ] Add password input
* [ ] Add login button
* [ ] Add validation messages
* [ ] Add loading indicator
* [ ] Add error handling
* [ ] Store session data after login

### 7.3 Implement Dashboard Screen

* [ ] Display current balance
* [ ] Display total deposit
* [ ] Display total withdrawal
* [ ] Display transaction count
* [ ] Display recent transactions
* [ ] Add navigation to transaction list
* [ ] Add navigation to monthly summary
* [ ] Add logout action

### 7.4 Implement Transaction Screens

* [ ] Build transaction list screen
* [ ] Build add transaction screen
* [ ] Build edit transaction screen
* [ ] Build delete confirmation dialog
* [ ] Add filter controls
* [ ] Add empty states
* [ ] Add loading states

### 7.5 Implement Monthly Summary Screen

* [ ] Add month selector
* [ ] Add year selector
* [ ] Display monthly deposit total
* [ ] Display monthly withdrawal total
* [ ] Display monthly balance
* [ ] Add optional chart if needed

### 7.6 Implement Reusable Widgets

* [ ] Create balance card widget
* [ ] Create summary card widget
* [ ] Create transaction card widget
* [ ] Create input field widget
* [ ] Create loading widget
* [ ] Create empty state widget
* [ ] Create confirmation dialog widget

---

## 8. Phase 6 — Flutter and API Integration

### 8.1 Implement API Services

* [ ] Create auth service
* [ ] Create dashboard service
* [ ] Create transaction service
* [ ] Create summary service
* [ ] Handle headers and token attachment
* [ ] Handle success and error responses

### 8.2 Connect Login Flow

* [ ] Send login request to backend
* [ ] Receive JWT token
* [ ] Store session data securely
* [ ] Navigate to dashboard on success
* [ ] Show error message on failure

### 8.3 Connect Dashboard Flow

* [ ] Load dashboard data from API
* [ ] Display balance and summaries
* [ ] Display recent transactions
* [ ] Refresh data after transaction changes

### 8.4 Connect Transaction Flow

* [ ] Load transaction list from API
* [ ] Send create request
* [ ] Send update request
* [ ] Send delete request
* [ ] Refresh list after changes
* [ ] Recalculate displayed totals

### 8.5 Connect Monthly Summary Flow

* [ ] Load monthly summary from API
* [ ] Update summary when month or year changes
* [ ] Display filtered financial data

### 8.6 Handle Logout

* [ ] Clear stored token
* [ ] Clear stored user data
* [ ] Navigate back to login screen
* [ ] Prevent access to protected pages after logout

---

## 9. Phase 7 — Validation and Error Handling

### 9.1 Frontend Validation

* [ ] Validate empty username
* [ ] Validate empty password
* [ ] Validate empty amount
* [ ] Validate invalid amount
* [ ] Validate missing date
* [ ] Validate required description if needed

### 9.2 Backend Validation

* [ ] Validate login request
* [ ] Validate transaction type
* [ ] Validate amount greater than zero
* [ ] Validate transaction date
* [ ] Validate ownership
* [ ] Validate balance rule for withdrawals

### 9.3 Error Messages

* [ ] Invalid username or password
* [ ] Please complete all required fields
* [ ] Amount must be greater than zero
* [ ] Insufficient balance for this withdrawal
* [ ] Unauthorized access
* [ ] Transaction not found
* [ ] Something went wrong

---

## 10. Phase 8 — Testing

### 10.1 Unit Testing

* [ ] Test validation logic
* [ ] Test calculation logic
* [ ] Test helper functions
* [ ] Test service functions if needed

### 10.2 Integration Testing

* [ ] Test Flutter to backend communication
* [ ] Test backend to database communication
* [ ] Test authentication flow
* [ ] Test CRUD flow
* [ ] Test monthly summary flow

### 10.3 End-to-End Testing

* [ ] Login successfully
* [ ] View dashboard
* [ ] Add deposit
* [ ] Add withdrawal
* [ ] Edit transaction
* [ ] Delete transaction
* [ ] Filter transactions
* [ ] View monthly summary
* [ ] Logout successfully

### 10.4 Regression Testing

* [ ] Recheck login after changes
* [ ] Recheck dashboard after changes
* [ ] Recheck balance calculation after changes
* [ ] Recheck ownership protection after changes

---

## 11. Phase 9 — Documentation and Final Preparation

### 11.1 Final Documentation

* [ ] Update `README.md`
* [ ] Update screenshots if needed
* [ ] Update installation steps
* [ ] Update setup instructions
* [ ] Update API usage notes
* [ ] Update database notes

### 11.2 Portfolio Preparation

* [ ] Prepare project description for resume
* [ ] Prepare short feature summary
* [ ] Prepare technology stack summary
* [ ] Prepare GitHub project description

### 11.3 Final Review

* [ ] Verify all documents are consistent
* [ ] Verify implementation matches requirements
* [ ] Verify no out-of-scope features were added
* [ ] Verify the app is ready for submission

---

## 12. Suggested Implementation Order

```text id="v6n3xd"
1. Review documents
2. Set up MariaDB
3. Create database tables
4. Build Node.js backend
5. Test backend APIs in Postman
6. Build Flutter UI
7. Connect Flutter to API
8. Test all user flows
9. Fix issues
10. Update README and final docs
```

---

## 13. Task Completion Rule

A task should only be marked complete when:

* It works according to the requirements
* It matches the approved architecture
* It does not conflict with any other document
* It has been tested successfully

---

## 14. Final TODO Statement

This TODO list is intentionally aligned with the full project documentation.

It ensures that development follows the approved sequence:

* Requirements
* User Flow
* Architecture
* Database
* API
* UI/UX
* Development Guidelines
* Implementation
* Testing
* Final Documentation

The project should be developed in a controlled and consistent way so that all components remain synchronized.