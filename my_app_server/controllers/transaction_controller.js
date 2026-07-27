const transaction = require('../models/transaction');
const {
  validateTransaction,
  validatePeriod,
} = require('../utils/validation');

const parseId = (value) =>
  Number.isInteger(Number(value)) &&
  Number(value) > 0
    ? Number(value)
    : null;

const normalise = (body) => ({
  type: body.type,
  amount: Number(body.amount),
  transaction_date: body.transaction_date,
  description: body.description.trim(),
});

const canWithdraw = async (
  userId,
  item,
  excludedId,
) =>
  item.type !== 'withdraw' ||
  item.amount <=
      (await transaction.getBalanceExcluding(
        userId,
        excludedId,
      ));

exports.list = async (req, res, next) => {
  try {
    const { type } = req.query;

    const month =
        req.query.month === undefined
            ? null
            : Number(req.query.month);

    const year =
        req.query.year === undefined
            ? null
            : Number(req.query.year);

    if (
      type &&
      !['deposit', 'withdraw'].includes(type)
    ) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed.',
      });
    }

    if (
      (month !== null &&
          (!Number.isInteger(month) ||
              month < 1 ||
              month > 12)) ||
      (year !== null &&
          (!Number.isInteger(year) ||
              year < 2000 ||
              year > 2100))
    ) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed.',
      });
    }

    return res.json({
      success: true,
      message:
          'Transactions retrieved successfully.',
      data: await transaction.list(
        req.user.userId,
        {
          type,
          month,
          year,
        },
      ),
    });
  } catch (error) {
    return next(error);
  }
};

exports.detail = async (req, res, next) => {
  try {
    const item = await transaction.findById(
      req.user.userId,
      parseId(req.params.id),
    );

    return item
        ? res.json({
            success: true,
            message:
                'Transaction retrieved successfully.',
            data: item,
          })
        : res.status(404).json({
            success: false,
            message: 'Transaction not found.',
          });
  } catch (error) {
    return next(error);
  }
};

exports.create = async (req, res, next) => {
  try {
    const invalid = validateTransaction(req.body);

    if (invalid) {
      return res.status(400).json({
        success: false,
        message: invalid,
      });
    }

    const item = normalise(req.body);

    if (
      !(await canWithdraw(
        req.user.userId,
        item,
      ))
    ) {
      return res.status(400).json({
        success: false,
        message:
            'Insufficient balance for this withdrawal.',
      });
    }

    return res.status(201).json({
      success: true,
      message:
          'Transaction created successfully.',
      data: await transaction.create(
        req.user.userId,
        item,
      ),
    });
  } catch (error) {
    return next(error);
  }
};

exports.update = async (req, res, next) => {
  try {
    const id = parseId(req.params.id);

    if (
      !id ||
      !(await transaction.findById(
        req.user.userId,
        id,
      ))
    ) {
      return res.status(404).json({
        success: false,
        message: 'Transaction not found.',
      });
    }

    const invalid = validateTransaction(req.body);

    if (invalid) {
      return res.status(400).json({
        success: false,
        message: invalid,
      });
    }

    const item = normalise(req.body);

    if (
      !(await canWithdraw(
        req.user.userId,
        item,
        id,
      ))
    ) {
      return res.status(400).json({
        success: false,
        message:
            'The updated transaction would violate the balance rule.',
      });
    }

    return res.json({
      success: true,
      message:
          'Transaction updated successfully.',
      data: await transaction.update(
        req.user.userId,
        id,
        item,
      ),
    });
  } catch (error) {
    return next(error);
  }
};

exports.remove = async (req, res, next) => {
  try {
    const deleted = await transaction.remove(
      req.user.userId,
      parseId(req.params.id),
    );

    return deleted
        ? res.json({
            success: true,
            message:
                'Transaction deleted successfully.',
          })
        : res.status(404).json({
            success: false,
            message: 'Transaction not found.',
          });
  } catch (error) {
    return next(error);
  }
};

exports.monthly = async (req, res, next) => {
  try {
    const month = Number(req.query.month);
    const year = Number(req.query.year);

    if (!validatePeriod(month, year)) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed.',
      });
    }

    return res.json({
      success: true,
      message:
          'Monthly summary retrieved successfully.',
      data: await transaction.getMonthlySummary(
        req.user.userId,
        month,
        year,
      ),
    });
  } catch (error) {
    return next(error);
  }
};