import 'package:flutter/foundation.dart';
import '../data/order_repository.dart';
import '../models/order.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repo = OrderRepository();
  List<Order> get orders => _repo.getAll();

  void addOrder({
    required String title,
    required String description,
    required double price,
  }) {
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      price: price,
    );
    _repo.add(order);
    notifyListeners();
  }

  void removeOrder(String id) {
    _repo.remove(id);
    notifyListeners();
  }

  void updateStatus(String id, OrderStatus status) {
    _repo.updateStatus(id, status);
    notifyListeners();
  }

  Order? getById(String id) => _repo.getById(id);

  List<Map<String, dynamic>> getPriceList() => _repo.getPriceList();
}
