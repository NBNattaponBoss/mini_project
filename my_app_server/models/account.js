const crypto = require('crypto');
const pool = require('../libs/db_pool');

const hashPassword = (password) => crypto.createHash('sha256').update(password).digest('hex');

module.exports = {
  async register(fullName, username, password) {
    let conn;
    try {
      conn = await pool.getConnection();
      const exists = await conn.query('SELECT account_id FROM user_accounts WHERE account_username = ?', [username]);
      if (exists.length > 0) return { isError: true, errorMessage: 'ชื่อผู้ใช้นี้ถูกใช้แล้ว' };
      await conn.query('INSERT INTO user_accounts (full_name, account_username, account_password) VALUES (?, ?, ?)', [fullName, username, hashPassword(password)]);
      return { isError: false, data: '', errorMessage: '' };
    } catch (error) {
      console.error('Database error while registering:', error);
      return { isError: true, errorMessage: error.message };
    } finally { if (conn) conn.release(); }
  },

  async login(username, password) {
    let conn;
    try {
      conn = await pool.getConnection();
      const rows = await conn.query(
        'SELECT account_id, account_username, full_name FROM user_accounts WHERE BINARY account_username = ? AND account_password = ?',
        [username, hashPassword(password)],
      );
      if (rows.length === 0) return { isError: true, errorMessage: 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง' };
      return { isError: false, data: rows[0], errorMessage: '' };
    } catch (error) {
      console.error('Database error while logging in:', error);
      return { isError: true, errorMessage: error.message };
    } finally { if (conn) conn.release(); }
  },
};
