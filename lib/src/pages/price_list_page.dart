import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';

class PriceListPage extends StatefulWidget {
  const PriceListPage({super.key});

  @override
  State<PriceListPage> createState() => _PriceListPageState();
}

class _PriceListPageState extends State<PriceListPage> {
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
            subtitle: Text(
              'Rp ${(p['price'] as num).toDouble().toStringAsFixed(0)}',
            ),
            trailing: provider.isAdmin
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final nameController = TextEditingController(
                            text: p['name'],
                          );
                          final priceController = TextEditingController(
                            text: (p['price'] as num).toString(),
                          );
                          final messenger = ScaffoldMessenger.of(context);
                          final res = await showDialog<bool?>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Edit Harga'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nama',
                                    ),
                                  ),
                                  TextField(
                                    controller: priceController,
                                    decoration: const InputDecoration(
                                      labelText: 'Harga',
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Batal'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    final newName = nameController.text.trim();
                                    final newPrice =
                                        double.tryParse(priceController.text) ??
                                        0;
                                    provider.updatePrice(newName, newPrice);
                                    Navigator.pop(ctx, true);
                                  },
                                  child: const Text('Simpan'),
                                ),
                              ],
                            ),
                          );
                          if (!mounted) return;
                          if (res == true) {
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Harga diperbarui')),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          provider.removePrice(p['name']);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Harga dihapus')),
                          );
                        },
                      ),
                    ],
                  )
                : Text(
                    'Rp ${(p['price'] as num).toDouble().toStringAsFixed(0)}',
                  ),
          );
        },
      ),
      floatingActionButton: provider.isAdmin
          ? FloatingActionButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final nameController = TextEditingController();
                final priceController = TextEditingController();
                final res = await showDialog<bool?>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Tambah Harga'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'Nama'),
                        ),
                        TextField(
                          controller: priceController,
                          decoration: const InputDecoration(labelText: 'Harga'),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Batal'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          final price =
                              double.tryParse(priceController.text) ?? 0;
                          provider.addPrice(name, price);
                          Navigator.pop(ctx, true);
                        },
                        child: const Text('Tambah'),
                      ),
                    ],
                  ),
                );
                if (!mounted) return;
                if (res == true) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Harga ditambahkan')),
                  );
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
