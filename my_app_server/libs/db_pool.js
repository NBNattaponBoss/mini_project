// ==============================================================================
// โมดูลจัดการ Database Connection Pool ด้วย MariaDB Driver
// ==============================================================================
// Connection Pool คือ การสร้างและดูแลกลุ่มของ Database Connection เตรียมไว้ล่วงหน้า
// ช่วยลด Overhead และเวลาแฝง (Latency) ในการเปิด-ปิด TCP Connection ใหม่ทุกครั้งที่มี Request เข้ามา
// เมื่อต้องการใช้งานจะขอยืม Connection ผ่าน pool.getConnection() และคืนกลับด้วย connection.release()

const mariadb = require('mariadb');

module.exports = mariadb.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database:
      process.env.DB_NAME ||
      'personal_account',
  port: Number(
    process.env.DB_PORT || 3306,
  ),
  // กำหนดจำนวน Connection สูงสุดที่ Pool จะเปิดไว้พร้อมกัน (Concurrent Connections)
  // ช่วยควบคุมการใช้งานทรัพยากรของฐานข้อมูลไม่ให้สูงเกินไป
  connectionLimit: 5,
});