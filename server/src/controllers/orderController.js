const Order = require('../models/Order');
const User = require('../models/User');
const notificationController = require('./notificationController');

// Create new order
exports.createOrder = async (req, res) => {
  try {
    const { title, description, price } = req.body;
    const userId = req.user.id;
    const userUsername = req.user.username;

    const order = new Order({
      title,
      description,
      price,
      owner: userId,
      ownerUsername: userUsername,
      status: 'menunggu'
    });

    await order.save();
    res.status(201).json(order);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Get all orders (admin) or user's orders (regular user)
exports.getOrders = async (req, res) => {
  try {
    let query = {};
    
    // Non-admin users only see their own orders
    if (req.user.role !== 'admin') {
      query.owner = req.user.id;
    }

    const orders = await Order.find(query).populate('owner', 'username email name');
    res.json(orders);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Get order by ID (with permission check)
exports.getOrderById = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id).populate('owner', 'username email name');
    
    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    // Check authorization: admin or owner
    if (req.user.role !== 'admin' && order.owner._id.toString() !== req.user.id) {
      return res.status(403).json({ error: 'Access denied' });
    }

    res.json(order);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Update order status (admin only)
exports.updateOrderStatus = async (req, res) => {
  try {
    const { status } = req.body;
    
    if (!['menunggu', 'diproses', 'selesai'].includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    let updateData = { status };
    if (status === 'selesai') {
      updateData.completedAt = new Date();
    }

    const order = await Order.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true }
    ).populate('owner', 'username email name');

    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    // Create notification for order owner when status is 'selesai'
    if (status === 'selesai') {
      await notificationController.createNotification(
        order.owner._id,
        order._id,
        order.title,
        `Pesanan "${order.title}" Anda telah selesai! Silakan ambil di toko kami.`,
        'order_completed'
      );
    }

    res.json(order);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Get order history (completed orders)
exports.getOrderHistory = async (req, res) => {
  try {
    let query = { status: 'selesai' };
    
    // Non-admin users only see their own history
    if (req.user.role !== 'admin') {
      query.owner = req.user.id;
    }

    const history = await Order.find(query)
      .populate('owner', 'username email name')
      .sort({ completedAt: -1 });
    
    res.json(history);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Get order statistics (admin only)
exports.getStatistics = async (req, res) => {
  try {
    const totalOrders = await Order.countDocuments();
    const menunggu = await Order.countDocuments({ status: 'menunggu' });
    const diproses = await Order.countDocuments({ status: 'diproses' });
    const selesai = await Order.countDocuments({ status: 'selesai' });
    const totalRevenue = await Order.aggregate([
      { $group: { _id: null, total: { $sum: '$price' } } }
    ]);

    res.json({
      totalOrders,
      menunggu,
      diproses,
      selesai,
      totalRevenue: totalRevenue.length > 0 ? totalRevenue[0].total : 0
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
