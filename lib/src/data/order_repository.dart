import '../models/order.dart';

class OrderRepository {
  final List<Order> _orders = [];

  // mutable price list managed by admin
  final List<Map<String, dynamic>> _prices = [
    {'name': 'Cuci Lipat', 'price': 15000.0},
    {'name': 'Setrika', 'price': 8000.0},
    {'name': 'Laundry Kiloan', 'price': 12000.0},
  ];

  List<Order> getAll() => List.unmodifiable(_orders);

  Order? getById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  void add(Order order) => _orders.add(order);

  void remove(String id) => _orders.removeWhere((o) => o.id == id);

  void updateStatus(String id, OrderStatus status) {
    final o = getById(id);
    if (o != null) o.status = status;
  }

  // Price list operations
  List<Map<String, dynamic>> getPriceList() => List.unmodifiable(_prices);

  void addPrice(String name, double price) {
    // if exists, update
    final idx = _prices.indexWhere((p) => p['name'] == name);
    if (idx >= 0) {
      _prices[idx]['price'] = price;
    } else {
      _prices.add({'name': name, 'price': price});
    }
  }

  void updatePrice(String name, double price) {
    final idx = _prices.indexWhere((p) => p['name'] == name);
    if (idx >= 0) _prices[idx]['price'] = price;
  }

  void removePrice(String name) {
    _prices.removeWhere((p) => p['name'] == name);
  }

  double? getPriceByName(String? name) {
    if (name == null) return null;
    try {
      final p = _prices.firstWhere((p) => p['name'] == name);
      return (p['price'] as num).toDouble();
    } catch (_) {
      return null;
    }
  }
}
