// ==============================================================================
// โมดูลจัดการ JSON Web Token (JWT) สำหรับระบบยืนยันตัวตน (Authentication)
// ==============================================================================
// JWT เป็น Stateless Authentication Token ทำให้ Server ไม่จำเป็นต้องเก็บ Session ในหน่วยความจำ
// ข้อมูลผู้ใช้ (Payload) ถูกเซ็นกำกับด้วย Secret Key และส่งไปเก็บไว้ที่ Client (Flutter)
// เมื่อ Client ยิง Request เข้ามา จะแนบ Token ในรูปแบบ Bearer Token มาใน Authorization Header

const jwt = require('jsonwebtoken');

// ดึง JWT Secret Key จาก Environment Variable สำหรับใช้ Sign และ Verify Token
const getSecret = () => process.env.JWT_SECRET || 'change-this-development-secret';

// สร้าง JWT Token โดยบรรจุ userId และ username ลงใน Payload กำหนดอายุการใช้งาน 1 วัน (1d)
exports.sign = (user) => jwt.sign({ userId: user.id, username: user.username }, getSecret(), { expiresIn: '1d' });

// ตรวจสอบความถูกต้องและความสมบูรณ์ของ Token ด้วย Secret Key หากหมดอายุหรือถูกปลอมแปลงจะ throw Exception
exports.verify = (token) => jwt.verify(token, getSecret());