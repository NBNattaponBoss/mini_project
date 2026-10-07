// ==============================================================================
// Dashboard Routes (/api/dashboard)
// ==============================================================================

const router = require('express').Router();

const auth = require('../middleware/auth_middleware');
const controller = require('../controllers/dashboard_controller');

// GET /api/dashboard
// ดึงข้อมูลสรุปภาพรวมทางการเงินและ 5 รายการล่าสุดของผู้ใช้
// Route นี้ต้องผ่าน JWT Authentication Middleware ก่อนเสมอ
router.get(
  '/',
  auth,
  controller.getDashboard,
);

module.exports = router;