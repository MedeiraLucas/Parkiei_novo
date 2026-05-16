const express = require('express');
const router = express.Router();

const parkingController = require('../controllers/parkingController');
const authMiddleware = require('../middlewares/authMiddleware');

router.get('/', parkingController.index);
router.post('/', authMiddleware, parkingController.create);

module.exports = router;
