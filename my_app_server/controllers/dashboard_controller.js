const transaction = require('../models/transaction');

exports.getDashboard = async (req, res, next) => {
  try {
    const data = await transaction.getDashboard(
      req.user.userId,
    );

    res.json({
      success: true,
      message: 'Dashboard data retrieved successfully.',
      data: data,
    });
  } catch (error) {
    next(error);
  }
};