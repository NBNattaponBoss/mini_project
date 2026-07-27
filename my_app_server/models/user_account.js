const pool = require('../libs/db_pool');

module.exports = {
  async getUserAccountById(accountId) {
    let conn;

    try {
      conn = await pool.getConnection();

      const rows = await conn.query(
        `SELECT
            account_id,
            account_username,
            full_name
         FROM user_accounts
         WHERE account_id = ?`,
        [accountId],
      );

      return {
        isError: false,
        data: rows,
        errorMessage: '',
      };
    } catch (error) {
      return {
        isError: true,
        data: '',
        errorMessage: error.message,
      };
    } finally {
      if (conn) {
        conn.release();
      }
    }
  },
};