// ==============================================================================
// Unit Tests: ทดสอบฟังก์ชันตรวจสอบความถูกต้องของข้อมูล (Validation Logic Tests)
// ==============================================================================

const assert = require('node:assert/strict');

const {
  validateTransaction,
  validatePeriod,
} = require('../utils/validation');

// ทดสอบกรณีข้อมูล Transaction ถูกต้องครบถ้วน: ต้องคืนค่า null (ไม่มี Error)
assert.equal(
  validateTransaction({
    type: 'deposit',
    amount: 1,
    transaction_date: '2026-07-26',
    description: 'Salary',
  }),
  null,
);

// ทดสอบกรณีจำนวนเงินเป็น 0 หรือติดลบ: ต้องแจ้งเตือนว่าจำนวนเงินต้องมากกว่าศูนย์
assert.match(
  validateTransaction({
    type: 'withdraw',
    amount: 0,
    transaction_date: '2026-07-26',
    description: 'Food',
  }),
  /greater than zero/,
);

// ทดสอบกรณีประเภทรายการไม่ถูกต้อง (ไม่ใช่ deposit หรือ withdraw): ต้องแจ้งเตือน
assert.match(
  validateTransaction({
    type: 'other',
    amount: 1,
    transaction_date: '2026-07-26',
    description: 'Test',
  }),
  /deposit or withdraw/,
);

// ทดสอบกรณีช่วงเวลาถูกต้อง (เดือน 7, ปี 2026): ต้องคืนค่า true
assert.equal(
  validatePeriod(7, 2026),
  true,
);

// ทดสอบกรณีระบุเดือนเกิน 12 (เช่น เดือน 13): ต้องคืนค่า false
assert.equal(
  validatePeriod(13, 2026),
  false,
);

console.log('Validation tests passed.');