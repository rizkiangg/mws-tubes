# Flutter HTTP Integration Setup

## Dependencies to Add

Update your `pubspec.yaml` file to include the `http` package for making HTTP requests to the Express backend:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Core dependencies (existing)
  provider: ^6.0.0
  shared_preferences: ^2.0.0
  hive: ^2.2.0
  hive_flutter: ^1.1.0
  intl: ^0.18.0
  
  # NEW: Add for Express backend communication
  http: ^1.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.0.0
  build_runner: ^2.3.0
```

Then run:
```bash
flutter pub get
```

## HTTP Service Integration

The `HttpClientService` has been created at:
```
lib/src/services/http_client.dart
```

This service handles:
- **JWT Token Management:** Automatically saves/loads tokens from SharedPreferences
- **Headers:** Adds Authorization header to all authenticated requests
- **Error Handling:** Consistent error messages and status code handling
- **API Calls:** All endpoints with proper serialization

## How to Update Existing Code

### Before (Using Hive):
```dart
void _loadOrders() {
  final orders = _orderRepository.getOrders();
  // ...
}
```

### After (Using HTTP):
```dart
void _loadOrders() async {
  try {
    final ordersList = await HttpClientService.getOrders();
    // Parse orders from API response
    // Update local state
  } catch (e) {
    // Handle error
  }
}
```

## Configuration

### Change Server Address

Edit `HttpClientService.baseUrl` based on environment:

```dart
// Local development
static const String baseUrl = 'http://localhost:5000/api';

// Production
static const String baseUrl = 'https://your-api.com/api';
```

## Provider Updates Example

```dart
class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _loading = false;
  
  Future<void> loadOrders() async {
    _loading = true;
    notifyListeners();
    
    try {
      final ordersList = await HttpClientService.getOrders();
      _orders = (ordersList as List)
          .map((json) => Order.fromJson(json))
          .toList();
    } catch (e) {
      // Handle error
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  
  Future<void> addOrder(String title, String description, double price) async {
    try {
      final result = await HttpClientService.createOrder(
        title: title,
        description: description,
        price: price,
      );
      // Handle result
    } catch (e) {
      rethrow;
    }
  }
}
```

## Pages to Update

1. **LoginPage** - Use `HttpClientService.login()`
2. **RegisterPage** - Use `HttpClientService.register()`
3. **OrderListPage** - Use `HttpClientService.getOrders()`
4. **OrderDetailPage** - Use `HttpClientService.getOrderById()`
5. **AdminDashboardPage** - Use `HttpClientService.getDashboardStats()`
6. **OrderHistoryPage** - Use `HttpClientService.getOrderHistory()`
7. **PricePage** - Use `HttpClientService.getPrices()`

## Offline Support

To support offline mode while migrating:

1. Keep Hive for local caching
2. Check internet connectivity before API calls
3. Fall back to Hive cache if offline
4. Sync when connection is restored

Example:
```dart
import 'package:connectivity_plus/connectivity_plus.dart';

final connectivity = Connectivity();

Future<List<Order>> getOrdersWithFallback() async {
  try {
    final result = await connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      // Use cached data from Hive
      return _orderRepository.getOrders();
    }
    
    // Fetch from API
    return await HttpClientService.getOrders();
  } catch (e) {
    // Fall back to Hive cache
    return _orderRepository.getOrders();
  }
}
```

## Testing

Test the HTTP service before integrating into providers:

```dart
void main() {
  test('Login should save token', () async {
    final result = await HttpClientService.login(
      email: 'test@example.com',
      password: 'password',
    );
    
    expect(result['token'], isNotEmpty);
  });
}
```

## Troubleshooting

### Common Issues

1. **"Failed to connect to server"**
   - Ensure Express server is running
   - Check `baseUrl` matches server address
   - Verify no firewall blocking port 5000

2. **"Authorization required"**
   - Ensure user is logged in
   - Check token is saved in SharedPreferences
   - Verify JWT_SECRET on server

3. **"CORS error"**
   - Express server has CORS enabled
   - If using different domain, update CORS origins in Express

4. **"Order not found" / 404**
   - Verify order ID is correct
   - Non-admin users can only see their own orders

## Next Steps

1. Install `http` package: `flutter pub get`
2. Review `HttpClientService` in `lib/src/services/http_client.dart`
3. Start Express backend: `cd server && npm start`
4. Update LoginPage to use `HttpClientService.login()`
5. Update other pages incrementally
6. Test each page thoroughly before moving to next

---

For detailed API documentation, see: [server/MIGRATION_GUIDE.md](../server/MIGRATION_GUIDE.md)
