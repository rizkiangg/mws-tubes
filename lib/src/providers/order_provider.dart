import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../data/order_repository.dart';
import '../models/order.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repo = OrderRepository();
  List<Order> get orders {
    final all = _repo.getAll();
    if (isAdmin) return all;
    // non-admin: return only orders owned by current user
    if (_currentUser == null) return <Order>[];
    return all.where((o) => o.owner == _currentUser).toList(growable: false);
  }

  // Authentication/session state
  String? _currentUser;
  String? _role; // 'admin' or 'user'

  String? get currentUser => _currentUser;
  String? get role => _role;
  bool get isAdmin => _role == 'admin';

  // Simple hard-coded authentication for demo
  // In production, replace with proper auth backend
  Future<bool> login(String username, String password) async {
    // demo credentials
    if (username == 'admin' && password == 'admin123') {
      _currentUser = 'admin';
      _role = 'admin';
    } else if (username == 'user' && password == 'user123') {
      _currentUser = 'user';
      _role = 'user';
    } else {
      // check registered users in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users');
      if (usersJson != null) {
        try {
          final Map<String, dynamic> users = jsonDecode(usersJson);
          if (users.containsKey(username)) {
            final u = users[username] as Map<String, dynamic>;
            if (u['password'] == password) {
              _currentUser = username;
              _role = u['role'] ?? 'user';
            } else {
              return false;
            }
          } else {
            return false;
          }
        } catch (_) {
          return false;
        }
      } else {
        return false;
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUser', _currentUser!);
    await prefs.setString('role', _role!);
    notifyListeners();
    return true;
  }

  /// Register a new user and persist in SharedPreferences.
  /// Returns true on success, false if username already exists or error.
  Future<bool> registerUser({
    required String username,
    required String password,
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');
    Map<String, dynamic> users = {};
    if (usersJson != null) {
      try {
        users = jsonDecode(usersJson) as Map<String, dynamic>;
      } catch (_) {
        users = {};
      }
    }
    if (users.containsKey(username)) return false;
    users[username] = {
      'password': password,
      'name': name,
      'email': email,
      'role': 'user',
    };
    await prefs.setString('users', jsonEncode(users));
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    _role = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
    await prefs.remove('role');
    notifyListeners();
  }

  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('currentUser');
    final r = prefs.getString('role');
    if (user != null && r != null) {
      _currentUser = user;
      _role = r;
      notifyListeners();
    }
  }

  /// Create a new order and return its id.
  String addOrder({
    required String title,
    required String description,
    required double price,
  }) {
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      price: price,
      // attach owner if available
      owner: _currentUser,
    );
    _repo.add(order);
    notifyListeners();
    return order.id;
  }

  void removeOrder(String id) {
    _repo.remove(id);
    notifyListeners();
  }

  void updateStatus(String id, OrderStatus status) {
    // Only allow status updates when logged in as admin
    if (!isAdmin) return;
    _repo.updateStatus(id, status);
    notifyListeners();
  }

  /// Return completed orders history
  List<Order> get history {
    final all = _repo.getHistory();
    if (isAdmin) return all;
    if (_currentUser == null) return <Order>[];
    return all.where((o) => o.owner == _currentUser).toList(growable: false);
  }

  Order? getById(String id) => _repo.getById(id);

  List<Map<String, dynamic>> getPriceList() => _repo.getPriceList();
  void addPrice(
    String name,
    double price, {
    String unit = 'pcs',
    double defaultQty = 1.0,
  }) {
    _repo.addPrice(name, price, unit: unit, defaultQty: defaultQty);
    notifyListeners();
  }

  void updatePrice(
    String name,
    double price, {
    String? unit,
    double? defaultQty,
  }) {
    _repo.updatePrice(name, price, unit: unit, defaultQty: defaultQty);
    notifyListeners();
  }

  void removePrice(String name) {
    _repo.removePrice(name);
    notifyListeners();
  }

  double? getPriceByName(String? name) => _repo.getPriceByName(name);
  double? getDefaultQuantity(String? name) => _repo.getDefaultQuantity(name);
  String? getUnitByName(String? name) => _repo.getUnitByName(name);

  double? getComputedPrice(String? name, double quantity) =>
      _repo.computePrice(name, quantity);
}
