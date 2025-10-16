import '../models/order.dart';

class OrderRepository {
  final List<Order> _orders = [];

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

  List<Map<String, dynamic>> getPriceList() {
    // simple static price list
    return [
      {'name': 'Produk A', 'price': 10000.0},
      {'name': 'Produk B', 'price': 20000.0},
      {'name': 'Produk C', 'price': 30000.0},
    ];
  }
}
