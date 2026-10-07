// ==============================================================================
// Authentication Routes (/api/auth)
// ==============================================================================
// จัดการ Endpoint สำหรับระบบสมาชิก เป็น Public Route ที่ไม่ต้องผ่าน JWT Authentication

const router = require('express').Router();
const controller = require('../controllers/auth_controller');

// POST /api/auth/login: เข้าสู่ระบบ ตรวจสอบ username/password และออก JWT Token
router.post('/login', controller.login);

// POST /api/auth/register: สมัครสมาชิกใหม่ แฮชรหัสผ่าน และบันทึกลง Database
router.post('/register', controller.register);

module.exports = router;