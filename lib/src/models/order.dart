enum OrderStatus { menunggu, diproses, selesai }

class Order {
  final String id;
  final String title;
  final String description;
  final double price;
  OrderStatus status;

  Order({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.status = OrderStatus.menunggu,
  });
}
