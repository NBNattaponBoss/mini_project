// ==============================================================================
// User Model: จัดการการเข้าถึงข้อมูลผู้ใช้งาน (Users) ในฐานข้อมูล
// ==============================================================================
// รับผิดชอบการติดต่อ Database, การ Query SQL และการแฮชรหัสผ่านด้วย Bcrypt

const bcrypt = require('bcryptjs');
const pool = require('../libs/db_pool');

/**
 * ค้นหาข้อมูลผู้ใช้ด้วย Username สำหรับการ Login หรือตรวจสอบความซ้ำซ้อนตอน Register
 * @param {string} username - ชื่อผู้ใช้ที่ต้องการค้นหา
 * @returns {Promise<Object|null>} ข้อมูลผู้ใช้ หรือ null หากไม่พบ
 */
exports.findByUsername = async (username) => {
  let connection;
  try {
    // ขอ Connection จาก Pool เพื่อใช้ Execute คำสั่ง SQL
    connection = await pool.getConnection();
    const rows = await connection.query(
      'SELECT id, username, password, created_at FROM users WHERE username = ? LIMIT 1',
      [username]
    );
    return rows[0] || null;
  } finally {
    // คืน Connection กลับเข้าสู่ Pool เสมอในบล็อก finally แม้จะเกิด Exception
    // เพื่อป้องกันปัญหา Connection Leak ในระบบ
    if (connection) connection.release();
  }
};

/**
 * ตรวจสอบความถูกต้องของรหัสผ่าน โดยนำ Plaintext Password มาเทียบกับ Bcrypt Hash ใน Database
 * หมายเหตุ: Bcrypt เป็น Password Hashing (ทางเดียว) ไม่ใช่การเข้ารหัส (Encryption)
 */
exports.verifyPassword = (password, hash) => bcrypt.compare(password, hash);

/**
 * สร้างบัญชีผู้ใช้งานใหม่ลงในฐานข้อมูล
 * @param {Object} userData - ข้อมูลผู้ใช้ { fullname, username, password }
 * @returns {Promise<number>} ID ของผู้ใช้ที่เพิ่งสร้างขึ้น
 */
exports.create = async ({ fullname, username, password }) => {
  let connection;

  try {
    connection = await pool.getConnection();

    // ทำการ Hash รหัสผ่านด้วย Bcrypt โดยใช้ Salt Rounds = 10 เพื่อความปลอดภัย
    const hash = await bcrypt.hash(password, 10);

    const result = await connection.query(
      `
      INSERT INTO users
      (fullname, username, password)
      VALUES (?, ?, ?)
      `,
      [fullname, username, hash]
    );

    // MariaDB Driver อาจคืนค่า insertId เป็น BigInt ใน JavaScript
    // ซึ่ง JSON Serialization ไม่รองรับ BigInt โดยตรง (จะเกิด TypeError)
    // จึงต้องแปลงเป็น Number ก่อนส่งค่ากลับไปยัง Controller/Response
    return Number(result.insertId);
  } finally {
    if (connection) connection.release();
  }
};