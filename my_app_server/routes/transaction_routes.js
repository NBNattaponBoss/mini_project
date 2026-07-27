const router = require('express').Router();

const auth = require('../middleware/auth_middleware');
const controller = require('../controllers/transaction_controller');

router.use(auth);

router.get(
  '/',
  controller.list,
);

router.get(
  '/:id',
  controller.detail,
);

router.post(
  '/',
  controller.create,
);

router.put(
  '/:id',
  controller.update,
);

router.delete(
  '/:id',
  controller.remove,
);

module.exports = router;