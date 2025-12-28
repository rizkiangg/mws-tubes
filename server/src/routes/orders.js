const express = require('express');
const orderController = require('../controllers/orderController');
const { auth, adminOnly } = require('../middleware/auth');

const router = express.Router();

// Routes for authenticated users
router.post('/', auth, orderController.createOrder);
router.get('/', auth, orderController.getOrders);
router.get('/:id', auth, orderController.getOrderById);
router.get('/history/all', auth, orderController.getOrderHistory);

// Admin-only routes
router.put('/:id/status', auth, adminOnly, orderController.updateOrderStatus);
router.get('/stats/dashboard', auth, adminOnly, orderController.getStatistics);

module.exports = router;
