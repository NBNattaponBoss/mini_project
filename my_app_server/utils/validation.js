// ==============================================================================
// Validation Utilities: ฟังก์ชันสำหรับตรวจสอบความถูกต้องของข้อมูล (Input Validation)
// ==============================================================================

/**
 * ตรวจสอบความถูกต้องของข้อมูลรายการธุรกรรมก่อนนำไปประมวลผล
 * @param {Object} body - ข้อมูลที่ส่งมาจาก Client { type, amount, transaction_date, description }
 * @returns {string|null} ข้อความ Error หากข้อมูลไม่ถูกต้อง หรือ null หากผ่านการตรวจสอบ
 */
exports.validateTransaction = (body) => {
  const {
    type,
    amount,
    transaction_date: date,
    description,
  } = body;

  // 1. ตรวจสอบประเภทรายการ (ต้องเป็น deposit หรือ withdraw เท่านั้น)
  if (
    !['deposit', 'withdraw'].includes(type)
  ) {
    return 'Transaction type must be deposit or withdraw.';
  }

  // 2. ตรวจสอบจำนวนเงิน (ต้องเป็นตัวเลขที่ถูกต้องและมีค่ามากกว่า 0)
  if (
    !Number.isFinite(Number(amount)) ||
    Number(amount) <= 0
  ) {
    return 'Amount must be greater than zero.';
  }

  // 3. ตรวจสอบวันที่ทำรายการ (ต้องเป็นวันที่ที่สามารถ Parse ได้ถูกต้อง)
  if (
    !date ||
    Number.isNaN(
      Date.parse(`${date}T00:00:00Z`),
    )
  ) {
    return 'Transaction date must be valid.';
  }

  // 4. ตรวจสอบรายละเอียด (ต้องเป็น String และไม่ว่างเปล่า)
  if (
    typeof description !== 'string' ||
    !description.trim()
  ) {
    return 'Please complete all required fields.';
  }

  // 5. ตรวจสอบความยาวรายละเอียด (ไม่เกิน 255 ตัวอักษร ตามขนาดคอลัมน์ในฐานข้อมูล)
  if (
    description.trim().length > 255
  ) {
    return 'Description must not exceed 255 characters.';
  }

  return null;
};

/**
 * ตรวจสอบความถูกต้องของช่วงเวลา (Month & Year) สำหรับรายงานสรุป
 * - month: ตัวเลขจำนวนเต็มระหว่าง 1 ถึง 12
 * - year: ตัวเลขจำนวนเต็มระหว่างปี ค.ศ. 2000 ถึง 2100
 */
exports.validatePeriod = (
  month,
  year,
) =>
  Number.isInteger(month) &&
  month >= 1 &&
  month <= 12 &&
  Number.isInteger(year) &&
  year >= 2000 &&
  year <= 2100;