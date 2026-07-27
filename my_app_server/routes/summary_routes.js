const router = require('express').Router();

const auth = require('../middleware/auth_middleware');
const controller = require('../controllers/transaction_controller');

router.get(
  '/monthly',
  auth,
  controller.monthly,
);

module.exports = router;