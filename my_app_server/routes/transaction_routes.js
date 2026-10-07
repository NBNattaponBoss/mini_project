// ==============================================================================
// Transaction Routes (/api/transactions)
// ==============================================================================
// จัดการการทำงาน CRUD (Create, Read, Update, Delete) ของรายการเงินฝากและถอน

const router = require('express').Router();

const auth = require('../middleware/auth_middleware');
const controller = require('../controllers/transaction_controller');

// ติดตั้ง Auth Middleware ระดับ Router ทำให้ทุก Endpoint ด้านล่างต้องผ่าน JWT Authentication ทั้งหมด
router.use(auth);

// GET /api/transactions: ดึงรายการธุรกรรมทั้งหมด พร้อมรองรับ Filter (type, month, year)
router.get(
  '/',
  controller.list,
);

// GET /api/transactions/:id: ดึงรายละเอียดของรายการธุรกรรมตาม ID
router.get(
  '/:id',
  controller.detail,
);

// POST /api/transactions: บันทึกรายการเงินฝากหรือเงินถอนใหม่ (ตรวจสอบยอดคงเหลือก่อนถอน)
router.post(
  '/',
  controller.create,
);

// PUT /api/transactions/:id: แก้ไขข้อมูลรายการธุรกรรมเดิม
router.put(
  '/:id',
  controller.update,
);

// DELETE /api/transactions/:id: ลบรายการธุรกรรมตาม ID
router.delete(
  '/:id',
  controller.remove,
);

module.exports = router;