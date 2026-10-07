// ==============================================================================
// Authentication Controller: จัดการ Business Logic ของระบบสมาชิก (Login / Register)
// ==============================================================================

const user = require('../models/user');
const jwt = require('../libs/jwt');

/**
 * Controller สำหรับการเข้าสู่ระบบ (Login Flow):
 * 1. รับ username และ password จาก Request Body
 * 2. ตรวจสอบความถูกต้องของ Input (Validation)
 * 3. ค้นหาผู้ใช้ในฐานข้อมูลด้วย username (user.findByUsername)
 * 4. นำรหัสผ่านที่ส่งมาเปรียบเทียบกับ Hash ใน Database ด้วย bcrypt.compare()
 *    (Bcrypt ทำหน้าที่ Hash แบบทางเดียว ไม่ใช่การถอดรหัส Encryption)
 * 5. หากถูกต้อง จะสร้าง JWT Token ผ่าน jwt.sign() (Stateless Token)
 * 6. ส่ง JWT Token และข้อมูลผู้ใช้กลับไปให้ Flutter จัดเก็บใน SharedPreferences
 */
exports.login = async (req, res, next) => {
  try {
    const username = String(req.body.username || '').trim();
    const password = String(req.body.password || '');

    // ตรวจสอบว่ากรอกข้อมูลครบถ้วนหรือไม่
    if (!username || !password) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed.',
        errors: [
          {
            field: !username ? 'username' : 'password',
            message: 'Username and password are required.',
          },
        ],
      });
    }

    // ค้นหาบัญชีผู้ใช้ใน Database
    const account = await user.findByUsername(username);

    // ตรวจสอบว่าพบบัญชีหรือไม่ และรหัสผ่านตรงกับ Bcrypt Hash หรือไม่
    if (!account || !(await user.verifyPassword(password, account.password))) {
      return res.status(401).json({
        success: false,
        message: 'Invalid username or password.',
      });
    }

    // ออก JWT Token โดยบรรจุ userId และ username ลงใน Payload เพื่อให้ Client ใช้ยืนยันตัวตน
    return res.json({
      success: true,
      message: 'Login successful.',
      data: {
        token: jwt.sign(account),
        user: {
          id: Number(account.id),
          username: account.username,
        },
      },
    });
  } catch (error) {
    return next(error);
  }
};

/**
 * Controller สำหรับการสมัครสมาชิก (Register Flow):
 * 1. รับ fullname, username, password จาก Request Body
 * 2. ตรวจสอบความถูกต้องและความครบถ้วนของข้อมูล
 * 3. ตรวจสอบว่า username ซ้ำกับที่มีในระบบหรือไม่ (Unique Username Rule)
 * 4. เข้ารหัส password ด้วย bcrypt.hash() ก่อนบันทึกลง Database
 * 5. บันทึกข้อมูลผู้ใช้ใหม่ลงตาราง users (user.create)
 * 6. ตอบกลับ HTTP Status 201 Created พร้อม User ID ใหม่
 */
exports.register = async (req, res, next) => {
  try {
    const { fullname, username, password } = req.body;

    // ตรวจสอบความครบถ้วนของข้อมูล
    if (!fullname || !username || !password) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed.',
      });
    }

    // ตรวจสอบว่า Username ซ้ำหรือไม่
    const existing = await user.findByUsername(username);

    if (existing) {
      return res.status(409).json({
        success: false,
        message: 'Username already exists.',
      });
    }

    // บันทึกผู้ใช้ใหม่ลงฐานข้อมูล (รหัสผ่านจะถูก Bcrypt Hash ภายในฟังก์ชัน user.create)
    const id = await user.create({
      fullname,
      username,
      password,
    });

    return res.status(201).json({
      success: true,
      message: 'Register successful.',
      data: {
        id,
        username,
      },
    });
  } catch (error) {
    return next(error);
  }
};