const jwt = require('../libs/jwt');

module.exports = (req, res, next) => {
  const header = req.headers.authorization || '';

  if (!header.startsWith('Bearer ')) {
    return res.status(401).json({
      success: false,
      message: 'Unauthorized access.',
    });
  }

  try {
    req.user = jwt.verify(
      header.substring(7),
    );

    return next();
  } catch (_) {
    return res.status(401).json({
      success: false,
      message: 'Unauthorized access.',
    });
  }
};