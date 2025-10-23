import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<OrderProvider>(
              builder: (context, prov, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nama: ${prov.currentUser ?? 'Tamu'}'),
                    const SizedBox(height: 8),
                    Text('Role: ${prov.role ?? 'guest'}'),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () {}, child: const Text('Edit Profil')),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(
                context,
                '/orders',
                arguments: {'readOnly': true},
              ),
              child: const Text('Lihat Pesanan Saya'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/prices'),
              child: const Text('Daftar Harga'),
            ),
            const SizedBox(height: 16),
            const SizedBox.shrink(),
            const SizedBox(height: 12),
            Consumer<OrderProvider>(
              builder: (context, prov, _) {
                if (prov.currentUser == null) return const SizedBox.shrink();
                return ElevatedButton(
                  onPressed: () async {
                    await prov.logout();
                    if (!context.mounted) return;
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Logout'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
