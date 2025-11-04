enum OrderStatus { menunggu, diproses, selesai }

class Order {
  final String id;
  final String title;
  final String description;
  final double price;
  OrderStatus status;
  // owner: username or id of the user who created the order.
  // nullable for backwards compatibility with older saved orders.
  final String? owner;

  Order({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.status = OrderStatus.menunggu,
    this.owner,
  });
}
