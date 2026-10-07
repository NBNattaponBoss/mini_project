// โหลด Environment Variables จากไฟล์ .env เข้าสู่ process.env
require('dotenv').config();

const express = require('express');
const cors = require('cors');

// นำเข้า Routing Modules แยกตามหน้าที่การทำงาน (Separation of Concerns)
const authRoutes = require('./routes/auth_routes');
const dashboardRoutes = require('./routes/dashboard_routes');
const transactionRoutes = require('./routes/transaction_routes');
const summaryRoutes = require('./routes/summary_routes');

// สร้าง Express Application Instance
const app = express();

// เปิดใช้งาน CORS (Cross-Origin Resource Sharing) เพื่ออนุญาต Cross-Origin HTTP Requests
// โดยเฉพาะกรณีที่ Client ทำงานผ่าน Browser หรืออุปกรณ์อื่น และอยู่คนละ Origin กับ API Server
app.use(cors());

// เปิดใช้งาน JSON Body Parser เพื่อให้ Express สามารถอ่านและแปลงข้อมูล JSON
// ที่ส่งมาจาก Client (เช่น Flutter App) เข้าสู่ req.body ได้โดยอัตโนมัติ
app.use(express.json());

// ติดตั้ง (Mount) Route Handlers ไปยัง Base URL Path ที่เกี่ยวข้อง
app.use('/api/auth', authRoutes);                 // ระบบยืนยันตัวตน (Login, Register)
app.use('/api/dashboard', dashboardRoutes);       // ข้อมูลภาพรวมและสรุปหน้าแรก
app.use('/api/transactions', transactionRoutes);   // จัดการธุรกรรมฝาก/ถอน (CRUD)
app.use('/api/summary', summaryRoutes);           // สรุปยอดรายเดือน/รายปี

// 404 Handler: จัดการ Request ที่เรียก Endpoint ที่ไม่มีอยู่ในระบบ
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint not found.',
  });
});

// Centralized Global Error Handler Middleware
// รับ Error ทั้งหมดที่ถูกส่งต่อมาจาก Controller ผ่าน next(error)
// ป้องกันไม่ให้ Server ล่มเมื่อเกิด Exception และส่ง Response มาตรฐานกลับไปยัง Client
app.use((error, req, res, next) => {
  // eslint-disable-line no-unused-vars

  console.error(
    'Unexpected server error:',
    error.message,
  );

  res.status(500).json({
    success: false,
    message:
        'Something went wrong. Please try again later.',
  });
});

// กำหนดหมายเลข Port จาก Environment Variable หรือค่าเริ่มต้น 3000
const port = Number(
  process.env.PORT || 3000,
);

// เริ่มต้นเปิด Server ให้รอรับ Request
app.listen(port, () => {
  console.log(
    `API server listening on port ${port}`,
  );
});