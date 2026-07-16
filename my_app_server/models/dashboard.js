const pool = require('../libs/db_pool');

module.exports = {
  async getSummary(accountId) {
    let conn;
    try {
      conn = await pool.getConnection();
      const rows = await conn.query(`SELECT
        COALESCE(SUM(CASE WHEN transaction_type = 'deposit' THEN amount ELSE 0 END), 0) AS total_deposit,
        COALESCE(SUM(CASE WHEN transaction_type = 'withdrawal' THEN amount ELSE 0 END), 0) AS total_withdrawal,
        COUNT(*) AS transaction_count
        FROM transactions WHERE account_id = ?`, [accountId]);
      const item = rows[0];
      const deposit = Number(item.total_deposit);
      const withdrawal = Number(item.total_withdrawal);
      return { isError: false, data: { balance: deposit - withdrawal, total_deposit: deposit, total_withdrawal: withdrawal, transaction_count: Number(item.transaction_count) }, errorMessage: '' };
    } catch (error) {
      return { isError: true, data: '', errorMessage: error.message };
    } finally { if (conn) conn.release(); }
  },
};
