# Testing

# Personal Deposit Account Management System

## 1. Overview

This document defines the testing plan for the **Personal Deposit Account Management System**.

The testing plan is designed to verify that the system works according to the approved requirements, user flow, architecture, database design, API specification, UI/UX specification, development guidelines, and implementation tasks.

The goal of testing is to confirm that the application behaves correctly, securely, and consistently across the Flutter frontend, Node.js backend, and MariaDB database.

---

## 2. Testing Objectives

The testing process must confirm that the system:

1. Allows users to log in successfully.
2. Rejects invalid login attempts.
3. Displays dashboard data correctly.
4. Supports deposit and withdrawal transactions.
5. Prevents withdrawals that exceed the available balance.
6. Supports edit and delete transaction operations.
7. Recalculates financial totals correctly after changes.
8. Supports filtering by transaction type, month, and year.
9. Displays monthly financial summaries correctly.
10. Protects user data through authentication and ownership checks.
11. Returns proper API responses and error messages.
12. Maintains data integrity in the database.
13. Works consistently between frontend and backend.

---

## 3. Testing Scope

The testing scope includes the following areas:

* Authentication
* Dashboard
* Transaction management
* Filtering
* Monthly summary
* Validation
* Authorization
* Database integrity
* API communication
* Flutter UI behavior
* End-to-end integration

The testing scope does **not** include out-of-scope features such as real banking integration, payment gateways, credit card management, or other features excluded in the project requirements.

---

## 4. Testing Levels

The system should be tested in multiple levels:

### 4.1 Frontend Testing

Testing the Flutter UI, form validation, navigation, loading states, error states, and user interaction behavior.

### 4.2 Backend Testing

Testing the Node.js API logic, authentication, validation, ownership checks, calculations, and response handling.

### 4.3 Database Testing

Testing table structure, foreign keys, data integrity, query results, and transaction record handling.

### 4.4 Integration Testing

Testing communication between Flutter, API, and MariaDB.

### 4.5 End-to-End Testing

Testing complete user flows from login to dashboard, transactions, summary, and logout.

---

## 5. Test Environment

The project should be tested in an environment that includes:

* Flutter application
* Node.js and Express.js backend
* MariaDB database
* HeidiSQL for database management
* Postman for API testing
* Android Studio emulator or physical device
* Visual Studio Code for development

---

## 6. Test Data

Testing should use sample data such as:

### 6.1 Sample User

* Username: `admin`
* Password: hashed password stored in the database

### 6.2 Sample Transactions

* Deposit transactions
* Withdrawal transactions
* Multiple dates across different months
* Records with different transaction types
* Records that allow balance and summary calculations

### 6.3 Test Conditions

* User with no transactions
* User with multiple deposits and withdrawals
* User with sufficient balance
* User with insufficient balance for withdrawal
* Invalid credentials
* Invalid or missing token
* Transactions owned by another user

---

## 7. Authentication Test Cases

## 7.1 Login Success

**Objective:** Verify that a user can log in with valid credentials.

**Precondition:** A valid user exists in the database.

**Steps:**

1. Open the Login screen.
2. Enter a valid username.
3. Enter a valid password.
4. Tap the Login button.

**Expected Result:**

* The system authenticates the user successfully.
* A JWT token is returned by the backend.
* Session data is stored on the device.
* The user is redirected to the Dashboard.

---

## 7.2 Login Failure - Invalid Credentials

**Objective:** Verify that the system rejects incorrect login information.

**Steps:**

1. Open the Login screen.
2. Enter an invalid username or password.
3. Tap the Login button.

**Expected Result:**

* The backend returns an authentication error.
* The user remains on the Login screen.
* An error message is displayed.

Expected message:

```text id="r3v2qn"
Invalid username or password.
```

---

## 7.3 Login Failure - Empty Username

**Objective:** Verify that the system validates required username input.

**Expected Result:**

* The form does not submit.
* A validation message is shown.

---

## 7.4 Login Failure - Empty Password

**Objective:** Verify that the system validates required password input.

**Expected Result:**

* The form does not submit.
* A validation message is shown.

---

## 7.5 Logout

**Objective:** Verify that the user can log out successfully.

**Steps:**

1. Log in successfully.
2. Tap the Logout action.
3. Confirm logout if required by the UI flow.

**Expected Result:**

* Session data is cleared.
* The user is redirected to the Login screen.
* Protected screens can no longer be accessed without login.

---

## 8. Dashboard Test Cases

## 8.1 Load Dashboard Data

**Objective:** Verify that the dashboard displays the correct financial summary.

**Precondition:** The user is logged in and has transaction data.

**Expected Result:**

* Current balance is displayed correctly.
* Total deposit is displayed correctly.
* Total withdrawal is displayed correctly.
* Transaction count is displayed correctly.
* Recent transactions are displayed from newest to oldest.

---

## 8.2 Dashboard With No Transactions

**Objective:** Verify that the dashboard shows an empty state when no transactions exist.

**Expected Result:**

* The dashboard loads successfully.
* The summary values show zero or appropriate empty values.
* A friendly empty state is displayed for recent transactions.

---

## 8.3 Dashboard Unauthorized Access

**Objective:** Verify that protected dashboard data cannot be accessed without a valid token.

**Expected Result:**

* The backend returns unauthorized access.
* The user is redirected or blocked from viewing protected data.

Expected message:

```text id="w8k1vm"
Unauthorized access.
```

---

## 9. Deposit Transaction Test Cases

## 9.1 Create Deposit

**Objective:** Verify that a deposit transaction can be created successfully.

**Steps:**

1. Open the Add Transaction screen.
2. Select Deposit.
3. Enter a valid amount.
4. Select a valid date.
5. Enter a description.
6. Tap Save.

**Expected Result:**

* The deposit is saved in MariaDB.
* Current balance increases.
* Total deposit increases.
* Transaction count increases.
* Dashboard and transaction list refresh successfully.

---

## 9.2 Deposit Validation - Invalid Amount

**Objective:** Verify that the system rejects invalid deposit amounts.

**Expected Result:**

* Amount equal to zero or below is rejected.
* Validation message is shown.

Expected message:

```text id="z6n4kd"
Amount must be greater than zero.
```

---

## 9.3 Deposit Validation - Missing Required Fields

**Objective:** Verify that required fields are validated before submission.

**Expected Result:**

* The form does not submit.
* Missing fields are highlighted or show validation messages.

Expected message:

```text id="h2p7rd"
Please complete all required fields.
```

---

## 10. Withdrawal Transaction Test Cases

## 10.1 Create Withdrawal With Sufficient Balance

**Objective:** Verify that a withdrawal transaction can be created when the balance is sufficient.

**Precondition:** The current balance is greater than or equal to the withdrawal amount.

**Steps:**

1. Open the Add Transaction screen.
2. Select Withdrawal.
3. Enter a valid amount.
4. Select a valid date.
5. Enter a description.
6. Tap Save.

**Expected Result:**

* The withdrawal is saved in MariaDB.
* Current balance decreases.
* Total withdrawal increases.
* Transaction count increases.
* Dashboard and transaction list refresh successfully.

---

## 10.2 Withdrawal Validation - Insufficient Balance

**Objective:** Verify that the system blocks withdrawals that exceed the current balance.

**Precondition:** The withdrawal amount is greater than the available balance.

**Expected Result:**

* The backend rejects the request.
* The transaction is not saved.
* An error message is shown.

Expected message:

```text id="n8q4sd"
Insufficient balance for this withdrawal.
```

---

## 10.3 Withdrawal Validation - Invalid Amount

**Objective:** Verify that invalid withdrawal amounts are rejected.

**Expected Result:**

* Amount equal to zero or below is rejected.
* Validation message is shown.

---

## 11. Transaction List Test Cases

## 11.1 View Transaction List

**Objective:** Verify that the user can view their transaction history.

**Expected Result:**

* The user’s transactions are displayed.
* Records are sorted from newest to oldest.
* Each item shows type, amount, date, and description.

---

## 11.2 Filter by Transaction Type

**Objective:** Verify that the system filters records by transaction type.

**Filter Options:**

* All
* Deposit
* Withdrawal

**Expected Result:**

* Only matching records are displayed.
* The list updates correctly.

---

## 11.3 Filter by Month

**Objective:** Verify that the system filters records by month.

**Expected Result:**

* Only transactions for the selected month are shown.

---

## 11.4 Filter by Year

**Objective:** Verify that the system filters records by year.

**Expected Result:**

* Only transactions for the selected year are shown.

---

## 11.5 Filter Combination

**Objective:** Verify that combined filters work correctly.

**Example:**

* Month: July
* Year: 2026
* Type: Deposit

**Expected Result:**

* Only records matching all selected filters are displayed.

---

## 11.6 Empty Filter Result

**Objective:** Verify the empty state when filters return no records.

**Expected Result:**

* No data is shown.
* A friendly empty state is displayed.

---

## 12. Edit Transaction Test Cases

## 12.1 Edit Transaction Successfully

**Objective:** Verify that a user can edit their own transaction.

**Steps:**

1. Open the transaction list.
2. Select a transaction.
3. Tap Edit.
4. Modify type, amount, date, or description.
5. Tap Save.

**Expected Result:**

* The transaction is updated in the database.
* Financial totals are recalculated.
* Dashboard data is refreshed.
* Transaction list reflects the updated record.

---

## 12.2 Edit Transaction Ownership Check

**Objective:** Verify that a user cannot edit another user’s transaction.

**Expected Result:**

* The backend rejects the request.
* The transaction is not modified.
* Unauthorized access is prevented.

---

## 12.3 Edit Transaction Validation

**Objective:** Verify that invalid edits are rejected.

**Examples:**

* Empty required fields
* Invalid amount
* Invalid date
* Transaction type outside the allowed values

**Expected Result:**

* Validation errors are returned.
* The update is not saved.

---

## 13. Delete Transaction Test Cases

## 13.1 Delete Transaction Successfully

**Objective:** Verify that a user can delete their own transaction.

**Steps:**

1. Open the transaction list.
2. Select a transaction.
3. Tap Delete.
4. Confirm deletion in the dialog.

**Expected Result:**

* The transaction is removed from MariaDB.
* Financial totals are recalculated.
* Dashboard data is refreshed.
* Transaction list updates correctly.

---

## 13.2 Delete Transaction Cancel

**Objective:** Verify that canceling the delete dialog prevents deletion.

**Steps:**

1. Open the transaction list.
2. Select a transaction.
3. Tap Delete.
4. Choose Cancel.

**Expected Result:**

* The transaction remains unchanged.
* No backend delete request is completed.

---

## 13.3 Delete Transaction Ownership Check

**Objective:** Verify that a user cannot delete another user’s transaction.

**Expected Result:**

* The backend rejects the request.
* The transaction remains in the database.
* Unauthorized access is prevented.

---

## 14. Monthly Summary Test Cases

## 14.1 View Monthly Summary

**Objective:** Verify that monthly deposit, withdrawal, and balance data are displayed correctly.

**Steps:**

1. Open Monthly Summary.
2. Select a month.
3. Select a year.

**Expected Result:**

* Monthly deposit total is correct.
* Monthly withdrawal total is correct.
* Monthly balance is correct.

---

## 14.2 Monthly Summary with No Data

**Objective:** Verify that an empty state is shown when no transactions exist for the selected month and year.

**Expected Result:**

* The summary loads successfully.
* Values show zero or empty states appropriately.
* The UI remains understandable.

---

## 15. Calculation Test Cases

## 15.1 Current Balance Calculation

**Objective:** Verify that current balance is calculated from transaction records.

**Formula:**

```text id="c7m1pv"
Current Balance = Total Deposits - Total Withdrawals
```

**Expected Result:**

* The displayed balance matches the calculated value.

---

## 15.2 Monthly Balance Calculation

**Objective:** Verify that monthly balance is calculated correctly.

**Formula:**

```text id="u4q9mx"
Monthly Balance = Monthly Deposits - Monthly Withdrawals
```

**Expected Result:**

* The displayed monthly balance matches the calculated value.

---

## 15.3 Recalculation After Create, Update, Delete

**Objective:** Verify that financial values are recalculated after transaction changes.

**Expected Result:**

* Dashboard totals update correctly after create.
* Dashboard totals update correctly after update.
* Dashboard totals update correctly after delete.

---

## 16. Authorization Test Cases

## 16.1 Protected Endpoint Without Token

**Objective:** Verify that protected endpoints cannot be accessed without a token.

**Expected Result:**

* The backend returns unauthorized access.
* The request is rejected.

---

## 16.2 Protected Endpoint With Invalid Token

**Objective:** Verify that invalid tokens are rejected.

**Expected Result:**

* The backend returns unauthorized access.
* The user is not allowed to continue.

---

## 16.3 Cross-User Data Access Prevention

**Objective:** Verify that a user cannot access another user’s transactions.

**Expected Result:**

* The backend checks ownership.
* The request is rejected if the transaction does not belong to the authenticated user.

---

## 17. Database Test Cases

## 17.1 users Table

**Objective:** Verify that the users table works correctly.

**Checks:**

* Primary key exists
* Username is unique
* Password is stored as a hash
* created_at is recorded

## 17.2 transactions Table

**Objective:** Verify that the transactions table works correctly.

**Checks:**

* Primary key exists
* Foreign key references users
* Type is restricted to deposit and withdraw
* Amount is stored correctly
* transaction_date is stored correctly
* Description is stored correctly

## 17.3 Foreign Key Integrity

**Objective:** Verify that transaction ownership is preserved.

**Expected Result:**

* Invalid user references are rejected.
* Related transactions follow the documented foreign key behavior.

---

## 18. UI Test Cases

## 18.1 Login Screen UI

**Objective:** Verify the login screen layout and feedback.

**Checks:**

* Username field is visible
* Password field is visible
* Login button is visible
* Error messages are visible
* Loading state is visible

## 18.2 Dashboard UI

**Objective:** Verify the dashboard layout.

**Checks:**

* Balance is displayed prominently
* Deposit, withdrawal, and count cards are visible
* Recent transactions are readable
* Logout action is available

## 18.3 Transaction UI

**Objective:** Verify transaction-related screens.

**Checks:**

* Add screen is usable
* Edit screen is pre-filled correctly
* Delete dialog appears before deletion
* Filters are visible and usable

## 18.4 Monthly Summary UI

**Objective:** Verify monthly summary layout.

**Checks:**

* Month selector is visible
* Year selector is visible
* Summary cards are displayed
* Optional chart does not reduce readability

---

## 19. Performance Test Cases

The application should also be checked for basic performance behavior.

### Checks

* Dashboard loads in a reasonable time
* API responses are returned without unnecessary delay
* Transaction list remains usable with normal project-sized data
* UI updates smoothly after create, update, and delete actions

---

## 20. Security Test Cases

The system should be tested for basic security behavior.

### Checks

* Passwords are not stored in plain text
* Protected APIs require valid tokens
* Sensitive database information is not exposed
* SQL queries use safe parameterized execution
* User ownership is enforced on protected resources

---

## 21. Test Case Table Summary

| Test Area        | Example Test                     |
| ---------------- | -------------------------------- |
| Authentication   | Valid login                      |
| Authentication   | Invalid login                    |
| Dashboard        | Summary display                  |
| Deposit          | Create deposit                   |
| Withdrawal       | Prevent overdraw                 |
| Transaction List | Filter records                   |
| Edit             | Update transaction               |
| Delete           | Confirm deletion                 |
| Monthly Summary  | View monthly totals              |
| Authorization    | Block foreign transaction access |
| Database         | Foreign key integrity            |
| Security         | Token protection                 |

---

## 22. Defect Handling

If a test fails, the issue should be recorded with:

* Test case name
* Expected result
* Actual result
* Error message
* Root cause
* Fix applied
* Retest result

This helps keep the project maintainable and aligned with the documentation.

---

## 23. Test Completion Criteria

Testing is considered complete when:

* Login works correctly
* Invalid login is rejected
* Dashboard displays correct totals
* Deposit and withdrawal transactions work
* Withdrawal over balance is blocked
* Edit and delete work correctly
* Filters work correctly
* Monthly summary is correct
* Unauthorized access is blocked
* Database relationships are valid
* Flutter and backend integration works reliably

---

## 24. Final Testing Statement

This testing plan ensures that the Personal Deposit Account Management System behaves correctly across all required modules.

The tests focus on:

* Correct functionality
* Data integrity
* Security
* User experience
* Frontend-backend integration
* Financial calculation accuracy

The testing results should confirm that the implementation matches the approved project documents and is ready for submission.