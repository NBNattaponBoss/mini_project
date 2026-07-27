const user = require('../models/user');
const jwt = require('../libs/jwt');

exports.login = async (req, res, next) => {
  try {
    const username = String(req.body.username || '').trim();
    const password = String(req.body.password || '');

    if (!username || !password) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed.',
        errors: [
          {
            field: !username ? 'username' : 'password',
            message: 'Username and password are required.',
          },
        ],
      });
    }

    const account = await user.findByUsername(username);

    if (!account || !(await user.verifyPassword(password, account.password))) {
      return res.status(401).json({
        success: false,
        message: 'Invalid username or password.',
      });
    }

    return res.json({
      success: true,
      message: 'Login successful.',
      data: {
        token: jwt.sign(account),
        user: {
          id: Number(account.id),
          username: account.username,
        },
      },
    });
  } catch (error) {
    return next(error);
  }
};

exports.register = async (req, res, next) => {
  try {
    const { fullname, username, password } = req.body;

    if (!fullname || !username || !password) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed.',
      });
    }

    const existing = await user.findByUsername(username);

    if (existing) {
      return res.status(409).json({
        success: false,
        message: 'Username already exists.',
      });
    }

    const id = await user.create({
      fullname,
      username,
      password,
    });

    return res.status(201).json({
      success: true,
      message: 'Register successful.',
      data: {
        id,
        username,
      },
    });
  } catch (error) {
    return next(error);
  }
};