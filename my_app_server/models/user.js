const bcrypt = require('bcryptjs');
const pool = require('../libs/db_pool');

exports.findByUsername = async (username) => {
  let connection;
  try {
    connection = await pool.getConnection();
    const rows = await connection.query(
      'SELECT id, username, password, created_at FROM users WHERE username = ? LIMIT 1',
      [username]
    );
    return rows[0] || null;
  } finally {
    if (connection) connection.release();
  }
};

exports.verifyPassword = (password, hash) => bcrypt.compare(password, hash);

exports.create = async ({ fullname, username, password }) => {
  let connection;

  try {
    connection = await pool.getConnection();

    const hash = await bcrypt.hash(password, 10);

    const result = await connection.query(
      `
      INSERT INTO users
      (fullname, username, password)
      VALUES (?, ?, ?)
      `,
      [fullname, username, hash]
    );

    return result.insertId;
  } finally {
    if (connection) connection.release();
  }
};