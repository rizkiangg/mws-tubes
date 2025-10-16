import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';

class PriceListPage extends StatelessWidget {
  const PriceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);
    final prices = provider.getPriceList();

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Harga')),
      body: ListView.builder(
        itemCount: prices.length,
        itemBuilder: (context, i) {
          final p = prices[i];
          return ListTile(
            title: Text(p['name']),
            trailing: Text(p['price'].toStringAsFixed(0)),
          );
        },
      ),
    );
  }
}
