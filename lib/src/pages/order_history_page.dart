import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';
import '../models/order.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<OrderProvider>(context);
    final List<Order> history = prov.history.reversed.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pesanan')),
      body: history.isEmpty
          ? const Center(child: Text('Belum ada riwayat.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: history.length,
              itemBuilder: (context, i) {
                final o = history[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(
                      Icons.history,
                      color: Color(0xFF0B57D0),
                    ),
                    title: Text('Pesanan #${o.id} - ${o.title}'),
                    subtitle: Text(
                      'Status: ${o.status.toString().split('.').last}',
                    ),
                    trailing: TextButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/detail',
                        arguments: o.id,
                      ),
                      child: const Text('Lihat Detail'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
