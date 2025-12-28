import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HttpClientService {
  static const String baseUrl = 'http://localhost:5000/api';
  static const String _tokenKey = 'jwt_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<void> _saveUserData(String userId, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_usernameKey, username);
  }

  static Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
  }

  static Future<Map<String, String>> _getHeaders({
    bool requireAuth = true,
  }) async {
    final headers = {'Content-Type': 'application/json'};
    if (requireAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // ===== Auth Endpoints =====

  /// Register a new user
  /// Returns: {message, user: {id, username, email, name, role}}
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  /// Login user with email and password
  /// Returns: {message, token, user: {id, username, email, name, role}}
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        final user = data['user'];
        await _saveUserData(user['id'], user['username']);
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  /// Logout user (clears local token)
  static Future<void> logout() async {
    await _clearToken();
    await _clearUserData();
  }

  /// Get current user profile
  /// Requires: Authorization header
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get profile');
      }
    } catch (e) {
      throw Exception('Profile error: $e');
    }
  }

  // ===== Order Endpoints =====

  /// Create a new order
  /// Requires: Authorization header
  /// Returns: {message, order: {...}}
  static Future<Map<String, dynamic>> createOrder({
    required String title,
    required String description,
    required double price,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: headers,
        body: jsonEncode({
          'title': title,
          'description': description,
          'price': price,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to create order');
      }
    } catch (e) {
      throw Exception('Create order error: $e');
    }
  }

  /// Get list of orders
  /// Requires: Authorization header
  /// Non-admin users see only their own orders
  /// Admin users see all orders
  /// Returns: {orders: [...], count}
  static Future<List<dynamic>> getOrders({String? status}) async {
    try {
      final headers = await _getHeaders();
      String url = '$baseUrl/orders';
      if (status != null) {
        url += '?status=$status';
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['orders'] ?? [];
      } else {
        throw Exception('Failed to fetch orders');
      }
    } catch (e) {
      throw Exception('Get orders error: $e');
    }
  }

  /// Get specific order by ID
  /// Requires: Authorization header
  /// Non-admin users can only view their own orders
  static Future<Map<String, dynamic>> getOrderById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch order');
      }
    } catch (e) {
      throw Exception('Get order error: $e');
    }
  }

  /// Update order status (admin only)
  /// Requires: Authorization header + admin role
  /// Valid statuses: baru, dikerjakan, selesai
  static Future<Map<String, dynamic>> updateOrderStatus({
    required String id,
    required String status,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$id/status'),
        headers: headers,
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to update order');
      }
    } catch (e) {
      throw Exception('Update order error: $e');
    }
  }

  /// Get order history (completed orders)
  /// Requires: Authorization header
  /// Non-admin users see only their own completed orders
  /// Admin users see all completed orders
  static Future<List<dynamic>> getOrderHistory() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/orders/history/all'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['orders'] ?? [];
      } else {
        throw Exception('Failed to fetch history');
      }
    } catch (e) {
      throw Exception('Get history error: $e');
    }
  }

  /// Get dashboard statistics (admin only)
  /// Requires: Authorization header + admin role
  /// Returns: {totalOrders, completedOrders, pendingOrders, totalRevenue, recentOrders}
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/orders/stats/dashboard'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch stats');
      }
    } catch (e) {
      throw Exception('Get stats error: $e');
    }
  }

  // ===== Price Endpoints =====

  /// Get all service prices (public endpoint, no auth required)
  /// Returns: {prices: [...]}
  static Future<List<dynamic>> getPrices() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/prices'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['prices'] ?? [];
      } else {
        throw Exception('Failed to fetch prices');
      }
    } catch (e) {
      throw Exception('Get prices error: $e');
    }
  }

  /// Create new service price (admin only)
  /// Requires: Authorization header + admin role
  static Future<Map<String, dynamic>> createPrice({
    required String name,
    required double price,
    required String unit,
    required int defaultQty,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/prices'),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'price': price,
          'unit': unit,
          'defaultQty': defaultQty,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to create price');
      }
    } catch (e) {
      throw Exception('Create price error: $e');
    }
  }

  /// Update service price (admin only)
  /// Requires: Authorization header + admin role
  static Future<Map<String, dynamic>> updatePrice({
    required String id,
    required double price,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/prices/$id'),
        headers: headers,
        body: jsonEncode({'price': price}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to update price');
      }
    } catch (e) {
      throw Exception('Update price error: $e');
    }
  }

  /// Delete service price (admin only)
  /// Requires: Authorization header + admin role
  static Future<void> deletePrice(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/prices/$id'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete price');
      }
    } catch (e) {
      throw Exception('Delete price error: $e');
    }
  }

  // ===== Notification Endpoints =====

  /// Get user notifications
  /// Requires: Authorization header
  /// Returns: {notifications: [...], unreadCount: number}
  static Future<Map<String, dynamic>> getNotifications() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch notifications');
      }
    } catch (e) {
      throw Exception('Get notifications error: $e');
    }
  }

  /// Mark notification as read
  /// Requires: Authorization header
  static Future<Map<String, dynamic>> markNotificationAsRead(
    String notificationId,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to mark notification as read');
      }
    } catch (e) {
      throw Exception('Mark notification error: $e');
    }
  }

  /// Mark all notifications as read
  /// Requires: Authorization header
  static Future<void> markAllNotificationsAsRead() async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/read/all'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark all notifications as read');
      }
    } catch (e) {
      throw Exception('Mark all notifications error: $e');
    }
  }

  /// Delete notification
  /// Requires: Authorization header
  static Future<void> deleteNotification(String notificationId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/notifications/$notificationId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete notification');
      }
    } catch (e) {
      throw Exception('Delete notification error: $e');
    }
  }
}
