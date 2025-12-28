const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const notificationController = require('../controllers/notificationController');

// Get user notifications
router.get('/', auth, notificationController.getNotifications);

// Mark notification as read
router.put('/:notificationId/read', auth, notificationController.markAsRead);

// Mark all notifications as read
router.put('/read/all', auth, notificationController.markAllAsRead);

// Delete notification
router.delete('/:notificationId', auth, notificationController.deleteNotification);

module.exports = router;
