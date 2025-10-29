import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'order_list_page.dart';
import 'order_history_page.dart';
import 'profile_page.dart';
import 'price_list_page.dart';
import 'admin_dashboard.dart';
import '../providers/order_provider.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  @override
  void initState() {
    super.initState();
  }

  int _index = 0;

  void _onTap(int idx) => setState(() => _index = idx);

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<OrderProvider>(context);
    final bool isAdmin = prov.isAdmin;

    final pages = isAdmin
        ? <Widget>[
            const AdminDashboardPage(),
            const OrderListPage(),
            const PriceListPage(),
            const ProfilePage(),
          ]
        : <Widget>[
            const HomePage(),
            const OrderListPage(),
            const OrderHistoryPage(),
            const ProfilePage(),
          ];

    final items = isAdmin
        ? const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'Pesanan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.price_check),
              label: 'Harga',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ]
        : const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'Pesanan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        items: items,
      ),
    );
  }
}
