// ==============================================================================
// Authentication Middleware: ตรวจสอบสิทธิ์การเข้าถึง API ด้วย JSON Web Token (JWT)
// ==============================================================================
// ขั้นตอนการทำงาน (Step-by-step Flow):
// 1. อ่าน Authorization Header จาก HTTP Request
// 2. ตรวจสอบว่า Header เริ่มต้นด้วย 'Bearer ' หรือไม่
// 3. สกัดเอาเฉพาะส่วน String ของ Token (ตัดคำว่า 'Bearer ' ออก 7 ตัวอักษรแรก)
// 4. ตรวจสอบความถูกต้องและลายเซ็นดิจิทัลของ JWT ผ่าน jwt.verify()
// 5. ดึงข้อมูลผู้ใช้ (userId, username) ที่อยู่ใน Payload
// 6. บันทึกข้อมูลลงใน req.user เพื่อให้ Controller ในลำดับถัดไปนำไปใช้งานอย่างปลอดภัย
//    (ตัวตนของผู้ใช้มาจาก JWT ที่ผ่านการ Sign โดย Server เสมอ ไม่ได้รับ userId จาก Client ตรงๆ)
// 7. เรียก next() เพื่อส่งต่อการทำงานไปยัง Controller ต่อไป
// 8. หาก Token ไม่ถูกต้อง, หมดอายุ หรือไม่มี Header จะส่ง 401 Unauthorized กลับทันที

const jwt = require('../libs/jwt');

module.exports = (req, res, next) => {
  // 1. อ่านค่า Authorization Header
  const header = req.headers.authorization || '';

  // 2. ตรวจสอบว่ามีรูปแบบ Bearer Token ถูกต้องหรือไม่
  if (!header.startsWith('Bearer ')) {
    return res.status(401).json({
      success: false,
      message: 'Unauthorized access.',
    });
  }

  try {
    // 3 & 4 & 5 & 6. สกัด Token, ตรวจสอบลายเซ็น และแนบ Payload ที่ถอดรหัสได้เข้ากับ req.user
    req.user = jwt.verify(
      header.substring(7),
    );

    // 7. ส่งต่อการทำงานไปยัง Middleware หรือ Controller ถัดไป
    return next();
  } catch (_) {
    // 8. กรณี Token ผิดพลาด, ปลอมแปลง หรือหมดอายุ ตอบกลับด้วย HTTP 401 Unauthorized
    return res.status(401).json({
      success: false,
      message: 'Unauthorized access.',
    });
  }
};