import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'src/providers/order_provider.dart';
import 'src/pages/order_list_page.dart';
import 'src/pages/order_add_page.dart';
import 'src/pages/order_detail_page.dart';
import 'src/pages/user_page.dart';
import 'src/pages/price_list_page.dart';
import 'src/pages/root_page.dart';
import 'src/pages/login_page.dart';
import 'src/pages/register_page.dart';
import 'src/pages/order_history_page.dart';
import 'src/pages/order_status_page.dart';
import 'src/pages/profile_page.dart';
import 'src/pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Hive and open boxes before creating providers that rely on them
  await Hive.initFlutter();
  await Hive.openBox('orders');
  await Hive.openBox('prices');
  await Hive.openBox('history');

  final orderProvider = OrderProvider();
  await orderProvider.restoreSession();
  runApp(MyApp.withProvider(orderProvider: orderProvider));
}

class MyApp extends StatelessWidget {
  final OrderProvider? orderProvider;
  const MyApp({super.key}) : orderProvider = null;
  const MyApp.withProvider({
    super.key,
    required OrderProvider this.orderProvider,
  });

  @override
  Widget build(BuildContext context) {
    final providerValue = orderProvider ?? OrderProvider();
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: providerValue)],
      child: MaterialApp(
        title: 'Tugas Besar',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B57D0)),
          useMaterial3: true,
        ),
        initialRoute: providerValue.currentUser == null ? '/login' : '/',
        routes: {
          '/': (_) => const RootPage(),
          '/orders': (_) => const OrderListPage(),
          '/history': (_) => const OrderHistoryPage(),
          '/status': (_) => const OrderStatusPage(),
          '/add': (_) => const OrderAddPage(),
          '/user': (_) => const UserPage(),
          '/profile': (_) => const ProfilePage(),
          '/settings': (_) => const SettingsPage(),
          '/prices': (_) => const PriceListPage(),
          '/login': (_) => const LoginPage(),
          '/register': (_) => const RegisterPage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/detail') {
            final args = settings.arguments as String; // order id
            return MaterialPageRoute(
              builder: (_) => OrderDetailPage(orderId: args),
            );
          }

          if (settings.name == '/orders') {
            final args = settings.arguments;
            if (args is Map && args['readOnly'] == true) {
              return MaterialPageRoute(
                builder: (_) => const OrderListPage(readOnly: true),
              );
            }
            return MaterialPageRoute(builder: (_) => const OrderListPage());
          }

          return null;
        },
      ),
    );
  }
}
