const Price = require('../models/Price');

// Get all prices
exports.getPrices = async (req, res) => {
  try {
    const prices = await Price.find().sort({ createdAt: -1 });
    res.json(prices);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Create price (admin only)
exports.createPrice = async (req, res) => {
  try {
    const { name, price, unit, defaultQty } = req.body;

    // Check if price already exists
    const existing = await Price.findOne({ name });
    if (existing) {
      return res.status(400).json({ error: 'Price entry already exists' });
    }

    const priceEntry = new Price({
      name,
      price,
      unit: unit || 'pcs',
      defaultQty: defaultQty || 1.0
    });

    await priceEntry.save();
    res.status(201).json(priceEntry);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Update price (admin only)
exports.updatePrice = async (req, res) => {
  try {
    const { price, unit, defaultQty } = req.body;

    const priceEntry = await Price.findByIdAndUpdate(
      req.params.id,
      {
        price,
        unit,
        defaultQty,
        updatedAt: new Date()
      },
      { new: true }
    );

    if (!priceEntry) {
      return res.status(404).json({ error: 'Price entry not found' });
    }

    res.json(priceEntry);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Delete price (admin only)
exports.deletePrice = async (req, res) => {
  try {
    const priceEntry = await Price.findByIdAndDelete(req.params.id);

    if (!priceEntry) {
      return res.status(404).json({ error: 'Price entry not found' });
    }

    res.json({ message: 'Price deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
