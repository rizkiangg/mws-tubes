// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';
import 'order_detail_page.dart';
import 'order_history_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<OrderProvider>(context);
    final orders = prov.orders;

    final totalOrders = orders.length;
    final menunggu = orders
        .where((o) => o.status == OrderStatus.menunggu)
        .length;
    final diproses = orders
        .where((o) => o.status == OrderStatus.diproses)
        .length;
    final selesai = orders.where((o) => o.status == OrderStatus.selesai).length;
    final totalRevenue = orders.fold<double>(0.0, (s, o) => s + (o.price));

    // show recent orders (including selesai) on the dashboard so admin can
    // review all orders created by customers
    final recent = orders.toList().reversed.take(6).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF0B57D0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Riwayat Pesanan',
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Total Pesanan',
                      // color: Colors.white,
                      value: '$totalOrders',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Pendapatan',
                      value: 'Rp ${totalRevenue.toStringAsFixed(0)}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Menunggu',
                      value: '$menunggu',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Diproses',
                      value: '$diproses',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Selesai',
                      value: '$selesai',
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Pesanan Terbaru',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (recent.isEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 12,
                  ),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.04),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'tidak ada pesanan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                ...recent.map(
                  (o) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(o.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rp ${o.price.toStringAsFixed(0)} • ${o.description}',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Owner: ${o.owner ?? '-'}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) async {
                          if (v == 'view') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrderDetailPage(orderId: o.id),
                              ),
                            );
                          } else if (v.startsWith('status:')) {
                            final s = v.split(':').last;
                            OrderStatus st = OrderStatus.menunggu;
                            if (s == 'diproses') st = OrderStatus.diproses;
                            if (s == 'selesai') st = OrderStatus.selesai;
                            prov.updateStatus(o.id, st);
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: Text('Lihat Detail'),
                          ),
                          const PopupMenuItem(
                            value: 'status:menunggu',
                            child: Text('Set Menunggu'),
                          ),
                          const PopupMenuItem(
                            value: 'status:diproses',
                            child: Text('Set Diproses'),
                          ),
                          const PopupMenuItem(
                            value: 'status:selesai',
                            child: Text('Set Selesai'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _StatCard({
    Key? key,
    required this.label,
    required this.value,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final base = color ?? const Color(0xFF0B57D0);

    final int alpha = (0.12 * 255).round();

    final int r = (base.r * 255).round() & 0xFF;
    final int g = (base.g * 255).round() & 0xFF;
    final int b = (base.b * 255).round() & 0xFF;
    final bg = Color.fromARGB(alpha, r, g, b);

    // final fg = Colors.black;
    final fg = ThemeData.estimateBrightnessForColor(base) == Brightness.dark
        ? const Color.fromARGB(255, 94, 94, 94)
        : Colors.black;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
