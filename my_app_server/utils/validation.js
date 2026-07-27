exports.validateTransaction = (body) => {
  const {
    type,
    amount,
    transaction_date: date,
    description,
  } = body;

  if (
    !['deposit', 'withdraw'].includes(type)
  ) {
    return 'Transaction type must be deposit or withdraw.';
  }

  if (
    !Number.isFinite(Number(amount)) ||
    Number(amount) <= 0
  ) {
    return 'Amount must be greater than zero.';
  }

  if (
    !date ||
    Number.isNaN(
      Date.parse(`${date}T00:00:00Z`),
    )
  ) {
    return 'Transaction date must be valid.';
  }

  if (
    typeof description !== 'string' ||
    !description.trim()
  ) {
    return 'Please complete all required fields.';
  }

  if (
    description.trim().length > 255
  ) {
    return 'Description must not exceed 255 characters.';
  }

  return null;
};

exports.validatePeriod = (
  month,
  year,
) =>
  Number.isInteger(month) &&
  month >= 1 &&
  month <= 12 &&
  Number.isInteger(year) &&
  year >= 2000 &&
  year <= 2100;