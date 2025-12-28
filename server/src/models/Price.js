const mongoose = require('mongoose');

const PriceSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  price: {
    type: Number,
    required: true,
    min: 0
  },
  unit: {
    type: String,
    default: 'pcs',
    enum: ['pcs', 'kg', 'meter', 'lusin']
  },
  defaultQty: {
    type: Number,
    default: 1.0,
    min: 0
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Price', PriceSchema);
