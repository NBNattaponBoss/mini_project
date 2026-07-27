const jwt = require('jsonwebtoken');

const getSecret = () => process.env.JWT_SECRET || 'change-this-development-secret';

exports.sign = (user) => jwt.sign({ userId: user.id, username: user.username }, getSecret(), { expiresIn: '1d' });
exports.verify = (token) => jwt.verify(token, getSecret());