import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';

class OrderListPage extends StatelessWidget {
  const OrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);
    final orders = provider.orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pesanan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/user'),
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () => Navigator.pushNamed(context, '/prices'),
          ),
        ],
      ),
      body: orders.isEmpty
          ? const Center(child: Text('Belum ada pesanan'))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, i) {
                final o = orders[i];
                return ListTile(
                  title: Text(o.title),
                  subtitle: Text(
                    '${o.price.toStringAsFixed(0)} - ${o.status.name}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => provider.removeOrder(o.id),
                  ),
                  onTap: () =>
                      Navigator.pushNamed(context, '/detail', arguments: o.id),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
