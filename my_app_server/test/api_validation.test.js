const assert = require('node:assert/strict');

const {
  validateTransaction,
  validatePeriod,
} = require('../utils/validation');

assert.equal(
  validateTransaction({
    type: 'deposit',
    amount: 1,
    transaction_date: '2026-07-26',
    description: 'Salary',
  }),
  null,
);

assert.match(
  validateTransaction({
    type: 'withdraw',
    amount: 0,
    transaction_date: '2026-07-26',
    description: 'Food',
  }),
  /greater than zero/,
);

assert.match(
  validateTransaction({
    type: 'other',
    amount: 1,
    transaction_date: '2026-07-26',
    description: 'Test',
  }),
  /deposit or withdraw/,
);

assert.equal(
  validatePeriod(7, 2026),
  true,
);

assert.equal(
  validatePeriod(13, 2026),
  false,
);

console.log('Validation tests passed.');