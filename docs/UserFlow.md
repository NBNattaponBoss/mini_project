# User Flow

# Personal Deposit Account Management System

## 1. Overview

This document defines the user flows of the **Personal Deposit Account Management System**.

The user flow describes how an authenticated user interacts with the mobile application, including:

* Login
* Dashboard
* Deposit
* Withdrawal
* Transaction Management
* Transaction Filtering
* Monthly Financial Summary
* Logout

All flows must follow the requirements and business rules defined in `PROJECT_REQUIREMENTS.md`.

---

# 2. Overall Application Flow

The overall application flow is:

```text
Start Application
       │
       ▼
Check Authentication Status
       │
       ├── Not Authenticated
       │          │
       │          ▼
       │        Login
       │          │
       │          ▼
       │     Validate Credentials
       │          │
       │       ┌──┴──┐
       │       │     │
       │     Failed Success
       │       │     │
       │       ▼     ▼
       │    Show Error
       │             │
       │             ▼
       │         Dashboard
       │             │
       └─────────────┤
                     │
        ┌────────────┼─────────────┐
        │            │             │
        ▼            ▼             ▼
   Transactions   Monthly       Logout
                  Summary
        │
        ├── Add Transaction
        ├── View Transaction
        ├── Edit Transaction
        └── Delete Transaction
```

---

# 3. Authentication Flow

## 3.1 Application Start

When the application starts:

```text
Start Application
       │
       ▼
Check Authentication State
       │
   ┌───┴────┐
   │        │
Valid     Invalid /
Session   No Session
   │        │
   ▼        ▼
Dashboard  Login
```

If the user does not have a valid authentication session, the application must display the Login screen.

If the user has a valid authentication session, the application may navigate to the Dashboard.

---

# 4. Login Flow

## 4.1 Login Process

```text
Login Screen
     │
     ▼
Enter Username
     │
     ▼
Enter Password
     │
     ▼
Press Login
     │
     ▼
Validate Required Fields
     │
  ┌──┴───┐
  │      │
Invalid Valid
  │      │
  ▼      ▼
Show    Send Login
Error   Request
         │
         ▼
     Backend
         │
         ▼
   Verify Credentials
         │
      ┌──┴───┐
      │      │
    Failed Success
      │      │
      ▼      ▼
 Show Error Generate JWT
               │
               ▼
         Store Session
               │
               ▼
           Dashboard
```

## 4.2 Login Success

When authentication succeeds:

1. Backend verifies the username and password.
2. Backend generates a JWT token.
3. Flutter receives the token.
4. The application stores the required authentication/session information.
5. The user is redirected to the Dashboard.

## 4.3 Login Failure

When authentication fails:

```text
Invalid Username / Password
          │
          ▼
Backend Returns Error
          │
          ▼
Flutter Displays Error
          │
          ▼
Remain on Login Screen
```

The application must not navigate to protected pages.

---

# 5. Dashboard Flow

After successful authentication:

```text
Login Success
      │
      ▼
  Dashboard
      │
      ▼
Request Dashboard Data
      │
      ▼
Backend Validates JWT
      │
      ▼
Retrieve User Transactions
      │
      ▼
Calculate Financial Data
      │
      ▼
Return Dashboard Data
      │
      ▼
Display Dashboard
```

The Dashboard must display:

```text
Current Balance
Total Deposit
Total Withdrawal
Transaction Count
Recent Transactions
```

The current balance is calculated as:

```text
Current Balance
=
Total Deposits - Total Withdrawals
```

---

# 6. Dashboard Navigation Flow

From the Dashboard, the user can access:

```text
                    Dashboard
                        │
        ┌───────────────┼────────────────┐
        │               │                │
        ▼               ▼                ▼
 Transactions     Monthly Summary      Logout
        │
        ▼
Transaction List
```

The user may return to the Dashboard after completing transaction management or viewing the monthly summary.

---

# 7. Deposit Flow

## 7.1 Add Deposit

The user can create a new deposit transaction.

```text
Dashboard / Transaction List
           │
           ▼
  Add Transaction
           │
           ▼
 Select "Deposit"
           │
           ▼
 Enter Amount
           │
           ▼
 Select Transaction Date
           │
           ▼
 Enter Description
           │
           ▼
 Press Save
           │
           ▼
 Validate Input
           │
       ┌───┴────┐
       │        │
    Invalid    Valid
       │        │
       ▼        ▼
 Show Error   Send Request
                │
                ▼
             Backend
                │
                ▼
         Validate Request
                │
                ▼
          Verify User
                │
                ▼
        Save Transaction
                │
                ▼
       Recalculate Totals
                │
                ▼
        Return Success
                │
                ▼
        Update Application
                │
                ▼
       Show Updated Data
```

## 7.2 Deposit Business Rules

The deposit amount must:

* Be numeric.
* Be greater than zero.
* Be valid according to the requirements.

After a successful deposit:

```text
Total Deposit ↑
Current Balance ↑
Transaction Count ↑
```

---

# 8. Withdrawal Flow

## 8.1 Add Withdrawal

```text
Dashboard / Transaction List
           │
           ▼
  Add Transaction
           │
           ▼
 Select "Withdrawal"
           │
           ▼
 Enter Amount
           │
           ▼
 Select Transaction Date
           │
           ▼
 Enter Description
           │
           ▼
 Press Save
           │
           ▼
 Validate Input
           │
       ┌───┴────┐
       │        │
    Invalid    Valid
       │        │
       ▼        ▼
 Show Error   Check Balance
                   │
              ┌────┴────┐
              │         │
        Insufficient  Sufficient
              │         │
              ▼         ▼
          Show Error  Send Request
                           │
                           ▼
                        Backend
                           │
                           ▼
                    Validate Request
                           │
                           ▼
                      Verify User
                           │
                           ▼
                    Save Transaction
                           │
                           ▼
                  Recalculate Totals
                           │
                           ▼
                    Return Success
                           │
                           ▼
                    Update Application
```

## 8.2 Insufficient Balance Flow

The system must prevent the user from creating a withdrawal that exceeds the current balance.

```text
Withdrawal Amount
       │
       ▼
Compare with Current Balance
       │
   ┌───┴────┐
   │        │
Amount   Amount
≤ Balance > Balance
   │        │
   ▼        ▼
Continue  Reject
   │        │
   ▼        ▼
Save      Show Error
```

Error message:

```text
Insufficient balance for this withdrawal.
```

## 8.3 Withdrawal Business Rules

After a successful withdrawal:

```text
Total Withdrawal ↑
Current Balance ↓
Transaction Count ↑
```

---

# 9. Transaction List Flow

The user can view their transaction history.

```text
Dashboard
    │
    ▼
Transaction List
    │
    ▼
Request Transactions
    │
    ▼
Backend Validates JWT
    │
    ▼
Retrieve User's Transactions
    │
    ▼
Return Transaction Data
    │
    ▼
Display Transaction List
```

Each transaction should display:

```text
Transaction Type
Amount
Transaction Date
Description
```

Transactions should be displayed from newest to oldest.

---

# 10. Transaction Filtering Flow

The user can filter transactions by:

* Transaction Type
* Month
* Year

Available transaction types:

```text
All
Deposit
Withdrawal
```

Flow:

```text
Transaction List
       │
       ▼
Select Filter
       │
       ├── Transaction Type
       │
       ├── Month
       │
       └── Year
       │
       ▼
Apply Filter
       │
       ▼
Request / Process Filtered Data
       │
       ▼
Display Matching Transactions
```

Example:

```text
Month: July
Year: 2026
Type: Deposit
```

The application must display only transactions matching the selected criteria.

---

# 11. View Transaction Flow

The user can view transaction information from the transaction list.

```text
Transaction List
       │
       ▼
Select Transaction
       │
       ▼
Display Transaction Information
       │
       ├── Type
       ├── Amount
       ├── Transaction Date
       └── Description
```

---

# 12. Edit Transaction Flow

The user can edit their own transaction.

```text
Transaction List
       │
       ▼
Select Transaction
       │
       ▼
Press Edit
       │
       ▼
Edit Transaction Screen
       │
       ▼
Modify Information
       │
       ├── Type
       ├── Amount
       ├── Transaction Date
       └── Description
       │
       ▼
Press Save
       │
       ▼
Validate Input
       │
    ┌──┴───┐
    │      │
Invalid  Valid
    │      │
    ▼      ▼
Show Error
           │
           ▼
      Send Update Request
           │
           ▼
        Backend
           │
           ▼
      Verify JWT
           │
           ▼
   Verify Transaction Owner
           │
           ▼
    Validate Transaction
           │
           ▼
  Check Business Rules
           │
           ▼
    Update Database
           │
           ▼
 Recalculate Financial Data
           │
           ▼
    Return Success
           │
           ▼
    Refresh Transaction
           │
           ▼
    Refresh Dashboard
```

If the edited transaction causes an invalid account balance, the update must be rejected.

---

# 13. Delete Transaction Flow

The user can delete their own transaction.

```text
Transaction List
       │
       ▼
Select Transaction
       │
       ▼
Press Delete
       │
       ▼
Confirmation Dialog
       │
    ┌──┴────┐
    │       │
 Cancel   Confirm
    │       │
    ▼       ▼
Close    Send Delete
Dialog    Request
             │
             ▼
          Backend
             │
             ▼
        Verify JWT
             │
             ▼
     Verify Transaction Owner
             │
             ▼
       Delete Transaction
             │
             ▼
    Recalculate Financial Data
             │
             ▼
       Return Success
             │
             ▼
       Refresh Transaction
             │
             ▼
       Refresh Dashboard
```

Confirmation message:

```text
Are you sure you want to delete this transaction?

[Cancel] [Delete]
```

If the user selects **Cancel**, the transaction must not be deleted.

---

# 14. Monthly Financial Summary Flow

The user can view financial information by month and year.

```text
Dashboard
    │
    ▼
Monthly Summary
    │
    ▼
Select Month
    │
    ▼
Select Year
    │
    ▼
Request Monthly Summary
    │
    ▼
Backend Validates JWT
    │
    ▼
Retrieve Matching Transactions
    │
    ▼
Calculate Monthly Data
    │
    ▼
Return Summary
    │
    ▼
Display Monthly Summary
```

The Monthly Summary must display:

```text
Monthly Total Deposit
Monthly Total Withdrawal
Monthly Balance
```

The monthly balance is calculated as:

```text
Monthly Balance
=
Monthly Deposits - Monthly Withdrawals
```

---

# 15. Monthly Historical Data Flow

The user can view historical financial data by selecting different months and years.

```text
Monthly Summary
       │
       ▼
Select Month / Year
       │
       ▼
Load Selected Period
       │
       ▼
Calculate Summary
       │
       ▼
Display Results
       │
       ▼
User Changes Month / Year
       │
       └───────────────► Load New Period
```

The selected month and year determine the transaction period used for the monthly summary.

---

# 16. Logout Flow

The user can log out from the authenticated application.

```text
Dashboard
    │
    ▼
Press Logout
    │
    ▼
Clear Authentication / Session Data
    │
    ▼
Navigate to Login
    │
    ▼
Login Screen
```

After logout:

* Authentication/session information must be cleared.
* The user must return to the Login screen.
* Protected application resources must not be accessible without authentication.

---

# 17. Authentication and Authorization Flow

All protected operations must follow this general flow:

```text
Flutter Application
       │
       ▼
Send API Request
       │
       ▼
Include JWT Token
       │
       ▼
Node.js / Express.js
       │
       ▼
JWT Validation
       │
   ┌───┴────┐
   │        │
Invalid    Valid
   │        │
   ▼        ▼
Reject   Identify User
Request      │
             ▼
      Execute Operation
             │
             ▼
        Return Response
```

Protected operations include:

* Dashboard
* Transaction List
* Create Transaction
* Edit Transaction
* Delete Transaction
* Monthly Summary

---

# 18. Transaction Ownership Flow

Every transaction belongs to an authenticated user.

When accessing a transaction:

```text
User Request
     │
     ▼
JWT Validation
     │
     ▼
Identify Authenticated User
     │
     ▼
Find Requested Transaction
     │
     ▼
Check Transaction Ownership
     │
   ┌─┴──┐
   │    │
 Own  Not Own
   │    │
   ▼    ▼
Allow  Reject
Access Access
```

A user must not be able to:

* View another user's transaction.
* Edit another user's transaction.
* Delete another user's transaction.

The backend must determine the authenticated user's identity from the validated JWT rather than trusting a `user_id` supplied directly by the client.

---

# 19. Error Flow

All major operations must handle validation and server errors.

General flow:

```text
User Action
    │
    ▼
Validate Input
    │
 ┌──┴────┐
 │       │
Invalid Valid
 │       │
 ▼       ▼
Show    Send API
Error   Request
          │
          ▼
       Backend
          │
          ▼
       Validate
          │
       ┌──┴────┐
       │       │
      Error   Success
       │       │
       ▼       ▼
 Return Error Execute Operation
       │       │
       ▼       ▼
 Flutter UI   Success Response
       │
       ▼
 Display Message
```

Examples of errors:

```text
Invalid username or password.
Please complete all required fields.
Amount must be greater than zero.
Insufficient balance for this withdrawal.
Unauthorized access.
Something went wrong. Please try again later.
```

---

# 20. Complete User Journey

The complete normal user journey is:

```text
                    Start
                      │
                      ▼
              Authentication Check
                      │
                 ┌────┴─────┐
                 │          │
            No Session   Valid Session
                 │          │
                 ▼          │
               Login        │
                 │          │
                 ▼          │
          Validate Login    │
                 │          │
                 ▼          │
            Login Success ──┘
                 │
                 ▼
              Dashboard
                 │
       ┌─────────┼──────────────┐
       │         │              │
       ▼         ▼              ▼
 Transactions  Monthly        Logout
       │        Summary          │
       │                         ▼
       │                       Login
       │
 ┌─────┼───────────┐
 │     │           │
 ▼     ▼           ▼
Add   Edit       Delete
 │     │           │
 ▼     ▼           ▼
Validate & Process Transaction
       │
       ▼
Recalculate Financial Data
       │
       ▼
Refresh Dashboard / Transaction List
       │
       ▼
      User
```

---

# 21. Core Transaction Flow

All transaction operations must follow the same general pattern:

```text
User Action
    │
    ▼
Flutter UI
    │
    ▼
Input Validation
    │
    ▼
REST API Request
    │
    ▼
JWT Authentication
    │
    ▼
User Authorization
    │
    ▼
Backend Validation
    │
    ▼
Business Rule Validation
    │
    ▼
MariaDB Operation
    │
    ▼
Recalculate Financial Data
    │
    ▼
API Response
    │
    ▼
Flutter Updates UI
```

This pattern applies to:

* Create Transaction
* Update Transaction
* Delete Transaction

---

# 22. Financial Calculation Flow

Financial information must be derived from transaction records.

```text
Transaction Records
       │
       ├── Deposit Transactions
       │          │
       │          ▼
       │    Sum Deposit Amounts
       │
       └── Withdrawal Transactions
                  │
                  ▼
          Sum Withdrawal Amounts
                  │
                  ▼
       Calculate Financial Data
                  │
                  ▼
Current Balance = Total Deposits - Total Withdrawals
```

For monthly data:

```text
Selected Month + Year
          │
          ▼
Filter Transactions
          │
          ├── Monthly Deposits
          │
          └── Monthly Withdrawals
                    │
                    ▼
          Calculate Monthly Balance
                    │
                    ▼
Monthly Balance
=
Monthly Deposits - Monthly Withdrawals
```

---

# 23. Data Refresh Flow

After any successful transaction modification:

```text
Transaction Created / Updated / Deleted
                 │
                 ▼
        Backend Operation Success
                 │
                 ▼
       Financial Data Recalculation
                 │
                 ▼
          API Success Response
                 │
                 ▼
          Flutter Refresh Data
                 │
        ┌────────┴────────┐
        │                 │
        ▼                 ▼
Transaction List       Dashboard
        │                 │
        └────────┬────────┘
                 ▼
           Updated Data
```

The application must ensure that the displayed financial information reflects the latest transaction data.

---

# 24. User Flow Rules

The following rules must be maintained throughout the application:

1. Users must authenticate before accessing protected resources.
2. Users can only access their own transaction records.
3. A transaction amount must be greater than zero.
4. A withdrawal cannot exceed the current available balance.
5. Deposit transactions increase the current balance.
6. Withdrawal transactions decrease the current balance.
7. Creating a transaction must update financial totals.
8. Editing a transaction must recalculate financial totals.
9. Deleting a transaction must recalculate financial totals.
10. Delete operations require user confirmation.
11. Monthly summaries are based on the selected month and year.
12. Dashboard financial data must reflect the user's current transaction records.
13. Logout must clear the authentication/session state and return the user to Login.
14. Flutter must communicate with the backend through the REST API rather than accessing MariaDB directly.
15. The backend is responsible for authentication, authorization, validation, business rules, and database operations.

---

# 25. Mapping to Project Requirements

This user flow directly supports the requirements defined in `PROJECT_REQUIREMENTS.md`.

| Requirement                   | User Flow                                   |
| ----------------------------- | ------------------------------------------- |
| Login                         | Login Flow                                  |
| Logout                        | Logout Flow                                 |
| Current Balance               | Dashboard Flow / Financial Calculation Flow |
| Total Deposit                 | Dashboard Flow                              |
| Total Withdrawal              | Dashboard Flow                              |
| Transaction Count             | Dashboard Flow                              |
| Recent Transactions           | Dashboard Flow                              |
| Add Deposit                   | Deposit Flow                                |
| Add Withdrawal                | Withdrawal Flow                             |
| Edit Transaction              | Edit Transaction Flow                       |
| Delete Transaction            | Delete Transaction Flow                     |
| Transaction History           | Transaction List Flow                       |
| Filter by Type                | Transaction Filtering Flow                  |
| Filter by Month               | Transaction Filtering Flow                  |
| Filter by Year                | Transaction Filtering Flow                  |
| Monthly Deposit               | Monthly Financial Summary Flow              |
| Monthly Withdrawal            | Monthly Financial Summary Flow              |
| Monthly Balance               | Monthly Financial Summary Flow              |
| User Data Isolation           | Transaction Ownership Flow                  |
| JWT Authentication            | Authentication and Authorization Flow       |
| Automatic Balance Calculation | Financial Calculation Flow                  |

---

# 26. Flow Completion Criteria

The User Flow is considered complete when the following flows are supported:

```text
[x] Application Start
[x] Authentication Check
[x] Login
[x] Login Failure
[x] Login Success
[x] Dashboard
[x] Add Deposit
[x] Add Withdrawal
[x] Insufficient Balance Handling
[x] View Transactions
[x] Filter Transactions
[x] Edit Transaction
[x] Delete Transaction
[x] Delete Confirmation
[x] Monthly Financial Summary
[x] Historical Monthly Data
[x] Logout
[x] Authentication / Authorization
[x] Transaction Ownership
[x] Error Handling
[x] Financial Recalculation
[x] Data Refresh
```

This document must remain synchronized with `PROJECT_REQUIREMENTS.md`.

If the requirements are changed in the future, all affected user flows must be reviewed and updated accordingly.