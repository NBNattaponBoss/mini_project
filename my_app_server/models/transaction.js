const pool = require('../libs/db_pool');

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

exports.getDashboard = (userId) =>
  withConnection(async (connection) => {
    const totals = (
      await connection.query(summarySql, [userId])
    )[0];

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

exports.list = (userId, filters) =>
  withConnection(async (connection) => {
    const clauses = ['user_id = ?'];
    const values = [userId];

    if (filters.type) {
      clauses.push('type = ?');
      values.push(filters.type);
    }

    if (filters.month) {
      clauses.push(
        'MONTH(transaction_date) = ?',
      );
      values.push(filters.month);
    }

    if (filters.year) {
      clauses.push(
        'YEAR(transaction_date) = ?',
      );
      values.push(filters.year);
    }

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

    return exports.findById(
      userId,
      Number(result.insertId),
    );
  });

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