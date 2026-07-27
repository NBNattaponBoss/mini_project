const router = require('express').Router();

const auth = require('../middleware/auth_middleware');
const controller = require('../controllers/dashboard_controller');

router.get(
  '/',
  auth,
  controller.getDashboard,
);

module.exports = router;