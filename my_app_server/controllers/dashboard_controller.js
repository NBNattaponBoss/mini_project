// ==============================================================================
// Dashboard Controller: จัดการข้อมูลภาพรวมทางการเงินสำหรับแสดงบนหน้าแรก
// ==============================================================================

const transaction = require('../models/transaction');

/**
 * ดึงข้อมูลภาพรวมการเงินของผู้ใช้ (Dashboard Summary):
 * 1. ดึง userId ของผู้ใช้จาก req.user.userId (ซึ่งถอดรหัสมาจาก JWT โดย Auth Middleware)
 * 2. เรียก transaction.getDashboard() เพื่อคำนวณยอดเงินคงเหลือ, เงินฝากรวม, เงินถอนรวม และ 5 รายการล่าสุด
 * 3. ส่งข้อมูลกลับไปยัง Flutter App ในรูปแบบ JSON มาตรฐาน
 */
exports.getDashboard = async (req, res, next) => {
  try {
    const data = await transaction.getDashboard(
      req.user.userId,
    );

    res.json({
      success: true,
      message: 'Dashboard data retrieved successfully.',
      data: data,
    });
  } catch (error) {
    next(error);
  }
};