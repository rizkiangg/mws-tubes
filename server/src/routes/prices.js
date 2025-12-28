const express = require('express');
const priceController = require('../controllers/priceController');
const { auth, adminOnly } = require('../middleware/auth');

const router = express.Router();

// Anyone can view prices
router.get('/', priceController.getPrices);

// Admin only for create, update, delete
router.post('/', auth, adminOnly, priceController.createPrice);
router.put('/:id', auth, adminOnly, priceController.updatePrice);
router.delete('/:id', auth, adminOnly, priceController.deletePrice);

module.exports = router;
