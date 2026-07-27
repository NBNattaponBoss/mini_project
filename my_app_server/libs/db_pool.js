const mariadb = require('mariadb');

module.exports = mariadb.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database:
      process.env.DB_NAME ||
      'personal_account',
  port: Number(
    process.env.DB_PORT || 3306,
  ),
  connectionLimit: 5,
});