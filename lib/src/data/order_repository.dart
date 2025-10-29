import 'package:hive/hive.dart';

import '../models/order.dart';

class OrderRepository {
  // Note: boxes are opened in main.dart before the repository/provider is created
  Box get _ordersBox => Hive.box('orders');
  Box get _pricesBox => Hive.box('prices');

  OrderRepository() {
    // ensure default prices exist
    final existing = _pricesBox.get('list');
    if (existing == null) {
      // default price list with unit information
      final initial = [
        {'name': 'Setrika', 'price': 3500.0, 'unit': 'pcs', 'default_qty': 1.0},
        {
          'name': 'Cuci Setrika',
          'price': 5000.0,
          'unit': 'kg',
          'default_qty': 1.0,
        },
        {
          'name': 'Laundry Kiloan',
          'price': 5000.0,
          'unit': 'kg',
          'default_qty': 1.0,
        },
        {
          'name': 'Gorden Kecil',
          'price': 10000.0,
          'unit': 'pcs',
          'default_qty': 1.0,
        },
        {
          'name': 'Gorden Sedang-Besar',
          'price': 15000.0,
          'unit': 'pcs',
          'default_qty': 1.0,
        },
        {
          'name': 'Selimut Kecil',
          'price': 10000.0,
          'unit': 'pcs',
          'default_qty': 1.0,
        },
        {
          'name': 'Selimut Sedang',
          'price': 15000.0,
          'unit': 'pcs',
          'default_qty': 1.0,
        },
        {
          'name': 'Bed Cover Set',
          'price': 20000.0,
          'unit': 'pcs',
          'default_qty': 1.0,
        },
        {
          'name': 'Bed Cover Set Besar',
          'price': 25000.0,
          'unit': 'pcs',
          'default_qty': 1.0,
        },
        // keep a few common services
        {
          'name': 'Cuci Lipat',
          'price': 5000.0,
          'unit': 'kg',
          'default_qty': 1.0,
        },
        {
          'name': 'Baby Care Laundry',
          'price': 8000.0,
          'unit': 'pcs',
          'default_qty': 1.0,
        },
      ];
      _pricesBox.put('list', initial);
    }
  }

  List<Order> getAll() {
    final values = _ordersBox.values;
    return values
        .map((e) {
          try {
            final Map<String, dynamic> m = Map<String, dynamic>.from(e as Map);
            return _orderFromMap(m);
          } catch (_) {
            return null;
          }
        })
        .whereType<Order>()
        .toList(growable: false);
  }

  Order? getById(String id) {
    final v = _ordersBox.get(id);
    if (v == null) return null;
    try {
      return _orderFromMap(Map<String, dynamic>.from(v as Map));
    } catch (_) {
      return null;
    }
  }

  void add(Order order) {
    _ordersBox.put(order.id, _orderToMap(order));
  }

  void remove(String id) => _ordersBox.delete(id);

  void updateStatus(String id, OrderStatus status) {
    final o = getById(id);
    if (o != null) {
      o.status = status;
      _ordersBox.put(id, _orderToMap(o));
    }
  }

  // Price list operations
  List<Map<String, dynamic>> getPriceList() {
    final list = _pricesBox.get('list');
    if (list == null) return <Map<String, dynamic>>[];
    try {
      final l = List<Map<String, dynamic>>.from(
        (list as List).map((e) => Map<String, dynamic>.from(e as Map)),
      );
      return List.unmodifiable(l);
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  void _savePriceList(List<Map<String, dynamic>> list) {
    _pricesBox.put('list', list);
  }

  void addPrice(
    String name,
    double price, {
    String unit = 'pcs',
    double defaultQty = 1.0,
  }) {
    final list = getPriceList().toList();
    final idx = list.indexWhere((p) => p['name'] == name);
    if (idx >= 0) {
      list[idx]['price'] = price;
      list[idx]['unit'] = unit;
      list[idx]['default_qty'] = defaultQty;
    } else {
      list.add({
        'name': name,
        'price': price,
        'unit': unit,
        'default_qty': defaultQty,
      });
    }
    _savePriceList(list);
  }

  void updatePrice(
    String name,
    double price, {
    String? unit,
    double? defaultQty,
  }) {
    final list = getPriceList().toList();
    final idx = list.indexWhere((p) => p['name'] == name);
    if (idx >= 0) {
      list[idx]['price'] = price;
      if (unit != null) list[idx]['unit'] = unit;
      if (defaultQty != null) list[idx]['default_qty'] = defaultQty;
      _savePriceList(list);
    }
  }

  void removePrice(String name) {
    final list = getPriceList().toList();
    list.removeWhere((p) => p['name'] == name);
    _savePriceList(list);
  }

  double? getPriceByName(String? name) {
    if (name == null) return null;
    try {
      final p = getPriceList().firstWhere((p) => p['name'] == name);
      return (p['price'] as num).toDouble();
    } catch (_) {
      return null;
    }
  }

  /// Return default quantity configured for a price (or 1.0 if absent)
  double? getDefaultQuantity(String? name) {
    if (name == null) return null;
    try {
      final p = getPriceList().firstWhere((p) => p['name'] == name);
      final v = p['default_qty'];
      if (v == null) return 1.0;
      return (v as num).toDouble();
    } catch (_) {
      return null;
    }
  }

  /// Return unit for the price entry (e.g., 'kg' or 'pcs') or null if unknown
  String? getUnitByName(String? name) {
    if (name == null) return null;
    try {
      final p = getPriceList().firstWhere((p) => p['name'] == name);
      return (p['unit'] as String?) ?? 'pcs';
    } catch (_) {
      return null;
    }
  }

  /// Compute total price given a service name and quantity. For kg, quantity
  /// can be decimal; for pcs, quantity is multiplied as integer/decimal.
  double? computePrice(String? name, double quantity) {
    final base = getPriceByName(name);
    if (base == null) return null;
    return base * (quantity <= 0 ? 1 : quantity);
  }

  // Helpers to map Order <-> Map for persistent storage without adapters
  Map<String, dynamic> _orderToMap(Order o) => {
    'id': o.id,
    'title': o.title,
    'description': o.description,
    'price': o.price,
    'status': o.status.name,
  };

  Order _orderFromMap(Map<String, dynamic> m) => Order(
    id: m['id'] as String,
    title: m['title'] as String,
    description: m['description'] as String,
    price: (m['price'] as num).toDouble(),
    status: _statusFromString(m['status'] as String?),
  );

  OrderStatus _statusFromString(String? s) {
    switch (s) {
      case 'diproses':
        return OrderStatus.diproses;
      case 'selesai':
        return OrderStatus.selesai;
      case 'menunggu':
      default:
        return OrderStatus.menunggu;
    }
  }
}
