// ==============================================================================
// Transaction Model: จัดการการเข้าถึงข้อมูลธุรกรรมฝาก/ถอนในฐานข้อมูล
// ==============================================================================
// รับผิดชอบการติดต่อ Database, การ Execute คำสั่ง SQL, และการรวมยอด (Aggregation)

const pool = require('../libs/db_pool');

// แปลงค่าตัวเลข (id, user_id, amount) จาก Database Driver ให้เป็น JavaScript Number
// เพื่อป้องกันปัญหา Type Mismatch หรือ BigInt ใน JSON Response
const numbers = (row) => ({
  ...row,
  id: Number(row.id),
  ...(row.user_id === undefined
      ? {}
      : {
          user_id: Number(row.user_id),
        }),
  amount: Number(row.amount),
});

// SQL Template สำหรับคำนวณยอดรวมเงินฝาก, ยอดรวมเงินถอน และจำนวนรายการทั้งหมด
// - ใช้ Conditional Aggregation: SUM(CASE WHEN type = 'deposit' THEN amount ELSE 0 END)
//   เพื่อรวมยอดเงินฝากและเงินถอนใน Query เดียว ช่วยเพิ่มประสิทธิภาพ ไม่ต้องดึงทุกแถวมาคำนวณใน Node.js
// - ใช้ COALESCE(..., 0) เพื่อป้องกันค่า NULL กรณีที่ยังไม่มีรายการใดๆ ในระบบ
// - ตรวจสอบเงื่อนไข WHERE user_id = ? เพื่อคำนวณเฉพาะข้อมูลของเจ้าของบัญชีเท่านั้น
const summarySql = `
SELECT
  COALESCE(
    SUM(
      CASE
        WHEN type = 'deposit'
        THEN amount
        ELSE 0
      END
    ),
    0
  ) AS totalDeposit,
  COALESCE(
    SUM(
      CASE
        WHEN type = 'withdraw'
        THEN amount
        ELSE 0
      END
    ),
    0
  ) AS totalWithdraw,
  COUNT(*) AS transactionCount
FROM transactions
WHERE user_id = ?
`;

/**
 * Higher-order Function สำหรับจัดการ Connection Lifecycle ของ MariaDB Pool
 * - ยืม Connection จาก Pool
 * - ส่ง Connection ให้ Callback ทำงาน
 * - คืน Connection กลับสู่ Pool เสมอใน finally เพื่อป้องกัน Connection Leak
 */
async function withConnection(callback) {
  let connection;

  try {
    connection = await pool.getConnection();
    return await callback(connection);
  } finally {
    if (connection) {
      connection.release();
    }
  }
}

/**
 * ดึงข้อมูล Dashboard ของผู้ใช้: ยอดคงเหลือ, ยอดฝากรวม, ยอดถอนรวม และ 5 รายการล่าสุด
 * @param {number} userId - ID ของผู้ใช้ที่ Login อยู่ (ได้จาก JWT)
 */
exports.getDashboard = (userId) =>
  withConnection(async (connection) => {
    // 1. ดึงยอดรวมทางการเงินของ User
    const totals = (
      await connection.query(summarySql, [userId])
    )[0];

    // 2. ดึงรายการธุรกรรม 5 รายการล่าสุด เรียงจากวันที่ใหม่สุดมาเก่าสุด
    const recentTransactions =
      await connection.query(
        `SELECT
           id,
           type,
           amount,
           transaction_date,
           description,
           created_at
         FROM transactions
         WHERE user_id = ?
         ORDER BY transaction_date DESC, id DESC
         LIMIT 5`,
        [userId],
      );

    const totalDeposit = Number(
      totals.totalDeposit,
    );

    const totalWithdraw = Number(
      totals.totalWithdraw,
    );

    // 3. คำนวณยอดเงินคงเหลือสุทธิ (balance = totalDeposit - totalWithdraw)
    return {
      balance:
          totalDeposit - totalWithdraw,
      totalDeposit,
      totalWithdraw,
      transactionCount: Number(
        totals.transactionCount,
      ),
      recentTransactions:
          recentTransactions.map(numbers),
    };
  });

/**
 * ดึงรายการธุรกรรมทั้งหมดของผู้ใช้ พร้อมตัวกรอง (Filters: type, month, year)
 * @param {number} userId - ID ของผู้ใช้
 * @param {Object} filters - เงื่อนไขตัวกรอง { type, month, year }
 */
exports.list = (userId, filters) =>
  withConnection(async (connection) => {
    // กำหนดเงื่อนไขหลัก: ต้องเป็นข้อมูลของ User คนนี้เท่านั้น (User Ownership Security)
    const clauses = ['user_id = ?'];
    const values = [userId];

    // ตัวกรองประเภท: deposit หรือ withdraw
    if (filters.type) {
      clauses.push('type = ?');
      values.push(filters.type);
    }

    // ตัวกรองเดือน: สกัดจากฟังก์ชัน MONTH(transaction_date) ใน MySQL/MariaDB
    if (filters.month) {
      clauses.push(
        'MONTH(transaction_date) = ?',
      );
      values.push(filters.month);
    }

    // ตัวกรองปี: สกัดจากฟังก์ชัน YEAR(transaction_date) ใน MySQL/MariaDB
    if (filters.year) {
      clauses.push(
        'YEAR(transaction_date) = ?',
      );
      values.push(filters.year);
    }

    // ประกอบ SQL Dynamic Query พร้อมเรียงลำดับรายการตามวันที่ล่าสุด
    const rows = await connection.query(
      `SELECT
         id,
         type,
         amount,
         transaction_date,
         description,
         created_at
       FROM transactions
       WHERE ${clauses.join(' AND ')}
       ORDER BY transaction_date DESC, id DESC`,
      values,
    );

    return rows.map(numbers);
  });

/**
 * ค้นหารายละเอียดธุรกรรมตาม Transaction ID
 * ตรวจสอบทั้ง id และ user_id เพื่อป้องกันไม่ให้ผู้ใช้แอบดูข้อมูลของผู้อื่น (Data Isolation)
 */
exports.findById = (userId, id) =>
  withConnection(async (connection) => {
    const rows = await connection.query(
      `SELECT
         id,
         user_id,
         type,
         amount,
         transaction_date,
         description,
         created_at
       FROM transactions
       WHERE id = ?
         AND user_id = ?`,
      [id, userId],
    );

    return rows[0]
        ? numbers(rows[0])
        : null;
  });

/**
 * สร้างรายการธุรกรรมใหม่ (ฝากหรือถอน)
 * บันทึก userId ที่ได้จาก JWT ลงในตารางเสมอ เพื่อยืนยันความเป็นเจ้าของ
 */
exports.create = (userId, item) =>
  withConnection(async (connection) => {
    const result =
      await connection.query(
        `INSERT INTO transactions
           (
             user_id,
             type,
             amount,
             transaction_date,
             description
           )
         VALUES (?, ?, ?, ?, ?)`,
        [
          userId,
          item.type,
          item.amount,
          item.transaction_date,
          item.description,
        ],
      );

    // ดึงข้อมูลรายการที่เพิ่งสร้างขึ้นมาส่งกลับไปยัง Client
    return exports.findById(
      userId,
      Number(result.insertId),
    );
  });

/**
 * แก้ไขข้อมูลรายการธุรกรรม
 * บังคับเงื่อนไข WHERE id = ? AND user_id = ? เพื่อป้องกันการแก้ไขข้ามบัญชีของผู้ใช้อื่น
 */
exports.update = (userId, id, item) =>
  withConnection(async (connection) => {
    await connection.query(
      `UPDATE transactions
       SET
         type = ?,
         amount = ?,
         transaction_date = ?,
         description = ?
       WHERE id = ?
         AND user_id = ?`,
      [
        item.type,
        item.amount,
        item.transaction_date,
        item.description,
        id,
        userId,
      ],
    );

    return exports.findById(userId, id);
  });

/**
 * ลบรายการธุรกรรม
 * บังคับเงื่อนไข WHERE id = ? AND user_id = ? เพื่อความปลอดภัย
 */
exports.remove = (userId, id) =>
  withConnection(async (connection) => {
    const result =
      await connection.query(
        `DELETE FROM transactions
         WHERE id = ?
           AND user_id = ?`,
        [id, userId],
      );

    return result.affectedRows > 0;
  });

/**
 * คำนวณหายอดเงินคงเหลือโดยยกเว้นรายการที่ระบุ (excludedId)
 * สำคัญมากสำหรับกรณี 'แก้ไขรายการ' (Edit Transaction):
 * เพื่อคำนวณหายอดเงินคงเหลือ ณ ปัจจุบันโดยไม่นับรวมค่าเดิมของรายการที่กำลังแก้ไข
 * จากนั้นจึงนำค่าใหม่มาคำนวณทดสอบว่ายอดเงินคงเหลือจะติดลบหรือไม่
 * @param {number} userId - ID ของผู้ใช้
 * @param {number|null} excludedId - ID ของ Transaction ที่ต้องการยกเว้น (กรณีสร้างใหม่จะเป็น null)
 * @returns {Promise<number>} ยอดเงินคงเหลือที่คำนวณได้
 */
exports.getBalanceExcluding = (
  userId,
  excludedId,
) =>
  withConnection(async (connection) => {
    const clause = excludedId
        ? ' AND id != ?'
        : '';

    const args = excludedId
        ? [userId, excludedId]
        : [userId];

    const row = (
      await connection.query(
        `${summarySql}${clause}`,
        args,
      )
    )[0];

    return (
      Number(row.totalDeposit) -
      Number(row.totalWithdraw)
    );
  });

/**
 * สรุปยอดรวมเงินฝาก, เงินถอน และยอดคงเหลือ ประจำเดือนและปีที่ระบุ
 * ใช้ฟังก์ชัน MONTH() และ YEAR() ในการจัดกลุ่มช่วงเวลา
 */
exports.getMonthlySummary = (
  userId,
  month,
  year,
) =>
  withConnection(async (connection) => {
    const row = (
      await connection.query(
        `${summarySql}
         AND MONTH(transaction_date) = ?
         AND YEAR(transaction_date) = ?`,
        [userId, month, year],
      )
    )[0];

    const totalDeposit = Number(
      row.totalDeposit,
    );

    const totalWithdraw = Number(
      row.totalWithdraw,
    );

    return {
      month,
      year,
      totalDeposit,
      totalWithdraw,
      balance:
          totalDeposit - totalWithdraw,
    };
  });