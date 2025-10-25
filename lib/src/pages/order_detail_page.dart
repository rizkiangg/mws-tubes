import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;
  final bool readOnly;
  const OrderDetailPage({
    super.key,
    required this.orderId,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);
    final order = provider.getById(orderId);
    // effective readOnly: page-level readOnly OR not an admin
    final effectiveReadOnly = readOnly || !provider.isAdmin;

    if (order == null) {
      return Scaffold(body: Center(child: Text('Pesanan tidak ditemukan')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Info Pesanan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nama: ${order.title}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Deskripsi: ${order.description}'),
            const SizedBox(height: 8),
            Text('Harga: ${order.price.toStringAsFixed(0)}'),
            const SizedBox(height: 16),
            const Text('Status:'),
            Wrap(
              spacing: 8,
              children: OrderStatus.values.map((s) {
                final label = s.toString().split('.').last;
                final selected = s == order.status;
                return ChoiceChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: effectiveReadOnly
                      ? null
                      : (_) => provider.updateStatus(order.id, s),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (!effectiveReadOnly)
              ElevatedButton(
                onPressed: () {
                  provider.removeOrder(order.id);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Hapus Pesanan'),
              ),
          ],
        ),
      ),
    );
  }
}
