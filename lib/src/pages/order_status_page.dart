import 'package:flutter/material.dart';

class OrderStatusPage extends StatelessWidget {
  const OrderStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Status Pesanan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Filter berdasarkan status:'),
            SizedBox(height: 12),
            Chip(label: Text('Menunggu')),
            SizedBox(height: 8),
            Chip(label: Text('Diproses')),
            SizedBox(height: 8),
            Chip(label: Text('Selesai')),
          ],
        ),
      ),
    );
  }
}
