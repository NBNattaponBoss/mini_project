-- ==============================================================================
-- โครงสร้างฐานข้อมูลสำหรับระบบบันทึกรายรับ-รายจ่ายส่วนบุคคล (Personal Account)
-- รองรับระบบสมาชิก (Users) และรายการธุรกรรมฝาก/ถอน (Transactions)
-- ==============================================================================

-- สร้าง Database หากยังไม่มี โดยกำหนด charset เป็น utf8mb4 เพื่อรองรับภาษาไทยและ emoji ได้สมบูรณ์
CREATE DATABASE IF NOT EXISTS personal_account
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE personal_account;

-- ------------------------------------------------------------------------------
-- ตาราง users: เก็บข้อมูลบัญชีผู้ใช้งานระบบ
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
  id INT NOT NULL AUTO_INCREMENT,
  fullname VARCHAR(100) NOT NULL,
  username VARCHAR(50) NOT NULL,
  -- รหัสผ่านจะถูกเก็บเป็น Bcrypt Hash (ความยาว 60 ตัวอักษร) เสมอ ไม่เก็บรหัสผ่านจริง (Plaintext)
  password VARCHAR(255) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  -- กำหนด UNIQUE KEY เพื่อป้องกันการสมัครชื่อผู้ใช้ (username) ซ้ำกันในระบบ
  UNIQUE KEY uq_username (username)
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- ตาราง transactions: เก็บรายการฝากเงินและถอนเงินของแต่ละผู้ใช้
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS transactions (
  id INT NOT NULL AUTO_INCREMENT,
  -- user_id ทำหน้าที่เป็น Foreign Key อ้างอิงไปยัง users(id)
  user_id INT NOT NULL,
  -- กำหนดประเภทรายการผ่าน ENUM: 'deposit' (ฝาก) หรือ 'withdraw' (ถอน)
  type ENUM('deposit', 'withdraw') NOT NULL,
  -- วันที่ทำรายการธุรกรรม (ใช้สำหรับคำนวณสรุปยอดรายเดือน/รายปี)
  transaction_date DATE NOT NULL,
  -- จำนวนเงิน ใช้ DECIMAL(12,2) เพื่อความแม่นยำทางการเงิน ป้องกันปัญหา Floating Point Precision
  amount DECIMAL(12,2) NOT NULL,
  description VARCHAR(255) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  -- สร้าง Index เพื่อเพิ่มประสิทธิภาพการค้นหาและเรียงลำดับรายการของแต่ละ User ตามวันที่
  KEY idx_transactions_user_date (user_id, transaction_date DESC),
  -- ผูก Foreign Key กับตาราง users โดยถ้าลบ User ข้อมูลรายการทั้งหมดของ User นั้นจะถูกลบอัตโนมัติ (CASCADE)
  CONSTRAINT fk_transactions_user FOREIGN KEY (user_id)
    REFERENCES users(id) ON DELETE CASCADE,
  -- ตรวจสอบในระดับฐานข้อมูลว่าจำนวนเงินต้องมากกว่า 0 เสมอ
  CONSTRAINT chk_transaction_amount CHECK (amount > 0)
) ENGINE=InnoDB;

