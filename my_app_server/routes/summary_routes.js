// ==============================================================================
// Summary Routes (/api/summary)
// ==============================================================================

const router = require('express').Router();

const auth = require('../middleware/auth_middleware');
const controller = require('../controllers/transaction_controller');

// GET /api/summary/monthly?month=X&year=Y
// สรุปยอดเงินฝาก, เงินถอน และคงเหลือสุทธิประจำเดือน
// Route นี้ต้องผ่าน JWT Authentication Middleware ก่อนเสมอ
router.get(
  '/monthly',
  auth,
  controller.monthly,
);

module.exports = router;