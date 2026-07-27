require('dotenv').config();

const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/auth_routes');
const dashboardRoutes = require('./routes/dashboard_routes');
const transactionRoutes = require('./routes/transaction_routes');
const summaryRoutes = require('./routes/summary_routes');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/transactions', transactionRoutes);
app.use('/api/summary', summaryRoutes);

app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint not found.',
  });
});

app.use((error, req, res, next) => {
  // eslint-disable-line no-unused-vars

  console.error(
    'Unexpected server error:',
    error.message,
  );

  res.status(500).json({
    success: false,
    message:
        'Something went wrong. Please try again later.',
  });
});

const port = Number(
  process.env.PORT || 3000,
);

app.listen(port, () => {
  console.log(
    `API server listening on port ${port}`,
  );
});