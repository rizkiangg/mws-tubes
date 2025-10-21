import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/providers/order_provider.dart';
import 'src/pages/order_list_page.dart';
import 'src/pages/order_add_page.dart';
import 'src/pages/order_detail_page.dart';
import 'src/pages/user_page.dart';
import 'src/pages/price_list_page.dart';
import 'src/pages/home_page.dart';
import 'src/pages/login_page.dart';
import 'src/pages/register_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => OrderProvider())],
      child: MaterialApp(
        title: 'Tugas Besar',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const HomePage(),
          '/orders': (_) => const OrderListPage(),
          '/add': (_) => const OrderAddPage(),
          '/user': (_) => const UserPage(),
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
          return null;
        },
      ),
    );
  }
}
