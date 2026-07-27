# Personal Deposit Account Management System

Flutter mobile client and Node.js/Express API for tracking personal deposits and withdrawals. The implementation follows the specifications in [`docs`](docs/README.md).

## Prerequisites

- Flutter SDK and an Android emulator/device
- Node.js
- MariaDB (configured manually in HeidiSQL)

## Database setup

Create the `personal_account` database and the `users` and `transactions` tables exactly as specified in [`docs/DatabaseDesign.md`](docs/DatabaseDesign.md). The application does not create or modify your database automatically.

Passwords in `users.password` must be bcrypt hashes. You can generate one after installing server packages:

```powershell
node -e "console.log(require('bcryptjs').hashSync('123456', 10))"
```

## Start the API

```powershell
cd my_app_server
Copy-Item .env.example .env
npm install
npm start
```

Set the MariaDB credentials and a secure `JWT_SECRET` in `.env` before starting.

## Start Flutter

```powershell
cd my_app
flutter pub get
flutter run
```

The default API URL targets the Android emulator host (`10.0.2.2`). For a different device or host, pass `--dart-define=API_BASE_URL=http://<host>:3000/api` to `flutter run`.

## Checks

Run backend validation tests with `npm test` from `my_app_server`, and use [`my_app_server/test.http`](my_app_server/test.http) to test the database-backed endpoints after MariaDB is ready.