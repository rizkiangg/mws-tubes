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
      return Scaffold(
        appBar: AppBar(
          title: const Text('Info Pesanan'),
          backgroundColor: const Color(0xFF0B57D0),
        ),
        body: const Center(child: Text('Pesanan tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Pesanan'),
        backgroundColor: const Color(0xFF0B57D0),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.04),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(order.description),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // show Indonesian Rupiah symbol
                        Text(
                          'Rp',
                          style: TextStyle(
                            color: const Color(0xFF0B57D0),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          order.price.toStringAsFixed(0),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Status',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: OrderStatus.values.map((s) {
                        final label = s.toString().split('.').last;
                        final selected = s == order.status;
                        return ChoiceChip(
                          label: Text(
                            label,
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.black,
                            ),
                          ),
                          selected: selected,
                          selectedColor: const Color(0xFF0B57D0),
                          backgroundColor: const Color(0xFFF6F8FB),
                          onSelected: effectiveReadOnly
                              ? null
                              : (_) => provider.updateStatus(order.id, s),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (!effectiveReadOnly)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // capture navigator before awaiting to avoid using BuildContext
                      final navigator = Navigator.of(context);
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Konfirmasi'),
                          content: const Text('Hapus pesanan ini?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text(
                                'Hapus',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        provider.removeOrder(order.id);
                        navigator.pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Hapus Pesanan'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
