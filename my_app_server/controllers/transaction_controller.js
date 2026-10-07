// ==============================================================================
// Transaction Controller: ควบคุม Business Logic และการจัดการธุรกรรมฝาก/ถอน
// ==============================================================================

const transaction = require('../models/transaction');
const {
  validateTransaction,
  validatePeriod,
} = require('../utils/validation');

// แปลงค่า Parameter ID ให้เป็น Integer ที่มีค่ามากกว่า 0 หากไม่ถูกต้องจะคืนค่า null
const parseId = (value) =>
  Number.isInteger(Number(value)) &&
  Number(value) > 0
    ? Number(value)
    : null;

// ปรับรูปแบบข้อมูล Transaction ให้อยู่ในโครงสร้างและ Data Type ที่ถูกต้องก่อนบันทึก
const normalise = (body) => ({
  type: body.type,
  amount: Number(body.amount),
  transaction_date: body.transaction_date,
  description: body.description.trim(),
});

/**
 * Business Rule สำคัญ: canWithdraw()
 * ตรวจสอบก่อนบันทึกรายการถอนว่ายอดเงินคงเหลือเพียงพอหรือไม่
 * - หากเป็น 'deposit' จะผ่านเงื่อนไขเสมอ
 * - หากเป็น 'withdraw' จำนวนเงินที่ต้องการถอนต้อง <= ยอดเงินคงเหลือ ณ ปัจจุบัน
 * - กรณีแก้ไขรายการ (Edit Mode) จะส่ง excludedId เข้าไปด้วย เพื่อคำนวณยอดเงินคงเหลือ
 *   โดยยกเว้นรายการเดิมที่กำลังแก้ไข ป้องกันไม่ให้คำนวณยอดเงินซ้ำซ้อน
 * - วัตถุประสงค์: ป้องกันไม่ให้ Business Logic อนุญาตให้ยอดเงินคงเหลือของบัญชีติดลบ
 */
const canWithdraw = async (
  userId,
  item,
  excludedId,
) =>
  item.type !== 'withdraw' ||
  item.amount <=
      (await transaction.getBalanceExcluding(
        userId,
        excludedId,
      ));

/**
 * ดึงรายการธุรกรรมทั้งหมดของผู้ใช้ (พร้อม Filter: type, month, year)
 */
exports.list = async (req, res, next) => {
  try {
    const { type } = req.query;

    const month =
        req.query.month === undefined
            ? null
            : Number(req.query.month);

    const year =
        req.query.year === undefined
            ? null
            : Number(req.query.year);

    // ตรวจสอบความถูกต้องของ Query Parameter 'type'
    if (
      type &&
      !['deposit', 'withdraw'].includes(type)
    ) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed.',
      });
    }

    // ตรวจสอบความถูกต้องของ Query Parameter 'month' (1-12) และ 'year' (2000-2100)
    if (
      (month !== null &&
          (!Number.isInteger(month) ||
              month < 1 ||
              month > 12)) ||
      (year !== null &&
          (!Number.isInteger(year) ||
              year < 2000 ||
              year > 2100))
    ) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed.',
      });
    }

    // ดึงรายการธุรกรรมเฉพาะของ User ปัจจุบัน (req.user.userId จาก JWT)
    return res.json({
      success: true,
      message:
          'Transactions retrieved successfully.',
      data: await transaction.list(
        req.user.userId,
        {
          type,
          month,
          year,
        },
      ),
    });
  } catch (error) {
    return next(error);
  }
};

/**
 * ดึงรายละเอียดของรายการธุรกรรม 1 รายการตาม ID
 */
exports.detail = async (req, res, next) => {
  try {
    const item = await transaction.findById(
      req.user.userId,
      parseId(req.params.id),
    );

    return item
        ? res.json({
            success: true,
            message:
                'Transaction retrieved successfully.',
            data: item,
          })
        : res.status(404).json({
            success: false,
            message: 'Transaction not found.',
          });
  } catch (error) {
    return next(error);
  }
};

/**
 * สร้างรายการธุรกรรมใหม่ (Create Flow):
 * 1. ตรวจสอบความถูกต้องของข้อมูล (validateTransaction)
 * 2. ปรับโครงสร้างข้อมูล (normalise)
 * 3. ตรวจสอบกฎการเงิน: หากเป็นการถอน ต้องมียอดเงินคงเหลือเพียงพอ (canWithdraw)
 * 4. บันทึกลงฐานข้อมูลและส่งข้อมูลที่สร้างกลับไป
 */
exports.create = async (req, res, next) => {
  try {
    // 1. Validation ตรวจสอบประเภท, จำนวนเงิน, วันที่ และรายละเอียด
    const invalid = validateTransaction(req.body);

    if (invalid) {
      return res.status(400).json({
        success: false,
        message: invalid,
      });
    }

    // 2. ปรับ format ข้อมูล
    const item = normalise(req.body);

    // 3. ตรวจสอบว่ายอดเงินคงเหลือเพียงพอสำหรับการถอนหรือไม่
    if (
      !(await canWithdraw(
        req.user.userId,
        item,
      ))
    ) {
      return res.status(400).json({
        success: false,
        message:
            'Insufficient balance for this withdrawal.',
      });
    }

    // 4. บันทึก Transaction ลง Database โดยผูกกับ req.user.userId
    return res.status(201).json({
      success: true,
      message:
          'Transaction created successfully.',
      data: await transaction.create(
        req.user.userId,
        item,
      ),
    });
  } catch (error) {
    return next(error);
  }
};

/**
 * แก้ไขรายการธุรกรรม (Update Flow):
 * 1. ตรวจสอบว่ามีรายการนี้อยู่จริงและเป็นของ User คนนี้หรือไม่
 * 2. ตรวจสอบความถูกต้องของข้อมูลใหม่ที่ส่งมา
 * 3. คำนวณยอดเงินคงเหลือโดยไม่รวมรายการเดิม และตรวจสอบว่าค่าใหม่ทำให้ยอดเงินติดลบหรือไม่
 * 4. อัปเดตข้อมูลลงฐานข้อมูล
 */
exports.update = async (req, res, next) => {
  try {
    const id = parseId(req.params.id);

    // ตรวจสอบความเป็นเจ้าของรายการ (User Ownership Check)
    if (
      !id ||
      !(await transaction.findById(
        req.user.userId,
        id,
      ))
    ) {
      return res.status(404).json({
        success: false,
        message: 'Transaction not found.',
      });
    }

    // ตรวจสอบความถูกต้องของ Field ต่างๆ
    const invalid = validateTransaction(req.body);

    if (invalid) {
      return res.status(400).json({
        success: false,
        message: invalid,
      });
    }

    const item = normalise(req.body);

    // ตรวจสอบยอดเงินคงเหลือ โดยยกเว้น Transaction ID ปัจจุบัน (id) ออกจากการคำนวณชั่วคราว
    if (
      !(await canWithdraw(
        req.user.userId,
        item,
        id,
      ))
    ) {
      return res.status(400).json({
        success: false,
        message:
            'The updated transaction would violate the balance rule.',
      });
    }

    // ดำเนินการ Update ในฐานข้อมูล
    return res.json({
      success: true,
      message:
          'Transaction updated successfully.',
      data: await transaction.update(
        req.user.userId,
        id,
        item,
      ),
    });
  } catch (error) {
    return next(error);
  }
};

/**
 * ลบรายการธุรกรรม (Delete Flow):
 * ตรวจสอบทั้ง Transaction ID และ User ID เพื่อให้ผู้ใช้สามารถลบเฉพาะรายการของตนเองเท่านั้น
 */
exports.remove = async (req, res, next) => {
  try {
    const deleted = await transaction.remove(
      req.user.userId,
      parseId(req.params.id),
    );

    return deleted
        ? res.json({
            success: true,
            message:
                'Transaction deleted successfully.',
          })
        : res.status(404).json({
            success: false,
            message: 'Transaction not found.',
          });
  } catch (error) {
    return next(error);
  }
};

/**
 * ดึงข้อมูลสรุปยอดรายเดือน (Monthly Summary):
 * รับ Parameter month และ year, ตรวจสอบความถูกต้อง แล้วคืนค่ายอดเงินฝาก, ยอดเงินถอน และยอดคงเหลือสุทธิ
 */
exports.monthly = async (req, res, next) => {
  try {
    const month = Number(req.query.month);
    const year = Number(req.query.year);

    // ตรวจสอบช่วงเดือน (1-12) และปี (2000-2100)
    if (!validatePeriod(month, year)) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed.',
      });
    }

    // ดึงข้อมูลสรุปจาก Model
    return res.json({
      success: true,
      message:
          'Monthly summary retrieved successfully.',
      data: await transaction.getMonthlySummary(
        req.user.userId,
        month,
        year,
      ),
    });
  } catch (error) {
    return next(error);
  }
};