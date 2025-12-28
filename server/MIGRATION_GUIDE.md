# Firebase to Express.js Migration Guide

## Overview

This document describes the migration from Firebase (Firestore) and local Hive storage to Express.js backend with MongoDB.

### What Changed

| Component | Before (Firebase) | After (Express.js) |
|-----------|-------------------|--------------------|
| **Backend** | Firebase Firestore | Node.js + Express |
| **Database** | Firestore | MongoDB |
| **Authentication** | Firebase Auth | JWT (JSON Web Tokens) |
| **Local Storage** | Hive (persistent) | Still Hive (during transition) |
| **API Communication** | Direct Firestore | REST HTTP endpoints |

---

## Backend Setup

### Prerequisites

- Node.js 14+ and npm
- MongoDB instance (local or cloud like MongoDB Atlas)
- `.env` file with configuration

### Installation

1. **Install Dependencies**

```bash
cd server
npm install
```

2. **Configure Environment Variables**

Create `server/.env` from `.env.example`:

```
PORT=5000
MONGODB_URI=mongodb://localhost:27017/logu_laundry
JWT_SECRET=your_super_secret_jwt_key_here
NODE_ENV=development
```

For MongoDB Atlas (cloud), use:
```
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/logu_laundry
```

3. **Start the Server**

```bash
npm start
# or for development with auto-reload:
npm run dev
```

Server runs on `http://localhost:5000`

---

## API Endpoints

### Authentication

#### Register User
- **POST** `/api/auth/register`
- **Body:**
  ```json
  {
    "username": "john_doe",
    "email": "john@example.com",
    "password": "securepassword",
    "name": "John Doe"
  }
  ```
- **Response:**
  ```json
  {
    "message": "User registered successfully",
    "user": {
      "id": "...",
      "username": "john_doe",
      "email": "john@example.com",
      "name": "John Doe",
      "role": "user"
    }
  }
  ```

#### Login
- **POST** `/api/auth/login`
- **Body:**
  ```json
  {
    "email": "john@example.com",
    "password": "securepassword"
  }
  ```
- **Response:**
  ```json
  {
    "message": "Login successful",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "...",
      "username": "john_doe",
      "email": "john@example.com",
      "name": "John Doe",
      "role": "user"
    }
  }
  ```

#### Get Profile
- **GET** `/api/auth/profile`
- **Headers:** `Authorization: Bearer <token>`
- **Response:** User object with all details

---

### Orders

All order endpoints require `Authorization: Bearer <token>` header.

#### Create Order
- **POST** `/api/orders`
- **Body:**
  ```json
  {
    "title": "Cuci Reguler",
    "description": "5kg pakaian biasa",
    "price": 25000
  }
  ```
- **Response:**
  ```json
  {
    "message": "Order created successfully",
    "order": {
      "id": "...",
      "title": "Cuci Reguler",
      "description": "5kg pakaian biasa",
      "price": 25000,
      "status": "baru",
      "owner": "user_id",
      "ownerUsername": "john_doe",
      "createdAt": "2024-01-15T10:30:00Z",
      "completedAt": null
    }
  }
  ```

#### Get Orders List
- **GET** `/api/orders`
- **Query Parameters:**
  - `status` (optional): Filter by status (baru, dikerjakan, selesai)
- **Response:**
  ```json
  {
    "orders": [
      {
        "id": "...",
        "title": "Cuci Reguler",
        "status": "baru",
        "owner": "user_id",
        "ownerUsername": "john_doe",
        "createdAt": "2024-01-15T10:30:00Z"
      }
    ],
    "count": 1
  }
  ```

**Note:** Non-admin users see only their own orders. Admin users see all orders.

#### Get Order Details
- **GET** `/api/orders/:id`
- **Response:**
  ```json
  {
    "id": "...",
    "title": "Cuci Reguler",
    "description": "5kg pakaian biasa",
    "price": 25000,
    "status": "dikerjakan",
    "owner": "user_id",
    "ownerUsername": "john_doe",
    "createdAt": "2024-01-15T10:30:00Z",
    "completedAt": null
  }
  ```

#### Update Order Status (Admin Only)
- **PUT** `/api/orders/:id/status`
- **Body:**
  ```json
  {
    "status": "selesai"
  }
  ```
- **Valid Statuses:** baru, dikerjakan, selesai
- **Response:**
  ```json
  {
    "message": "Order status updated",
    "order": { ... }
  }
  ```

#### Get Order History
- **GET** `/api/orders/history/all`
- **Response:** List of completed orders (filtered by user for non-admin)

#### Get Dashboard Statistics (Admin Only)
- **GET** `/api/orders/stats/dashboard`
- **Response:**
  ```json
  {
    "totalOrders": 50,
    "completedOrders": 45,
    "pendingOrders": 5,
    "totalRevenue": 1250000,
    "recentOrders": [...]
  }
  ```

---

### Prices

#### Get Prices (Public)
- **GET** `/api/prices`
- **Response:**
  ```json
  {
    "prices": [
      {
        "id": "...",
        "name": "Cuci Reguler",
        "price": 25000,
        "unit": "per 5kg",
        "defaultQty": 5
      }
    ]
  }
  ```

#### Create Price (Admin Only)
- **POST** `/api/prices`
- **Headers:** `Authorization: Bearer <token>`
- **Body:**
  ```json
  {
    "name": "Cuci Kilat",
    "price": 35000,
    "unit": "per 5kg",
    "defaultQty": 5
  }
  ```

#### Update Price (Admin Only)
- **PUT** `/api/prices/:id`
- **Headers:** `Authorization: Bearer <token>`
- **Body:**
  ```json
  {
    "price": 27000
  }
  ```

#### Delete Price (Admin Only)
- **DELETE** `/api/prices/:id`
- **Headers:** `Authorization: Bearer <token>`

---

## Flutter Integration

### 1. Create HTTP Service

Create `lib/src/services/http_client.dart`:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HttpClientService {
  static const String baseUrl = 'http://localhost:5000/api';
  static const String _tokenKey = 'jwt_token';

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

  static Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (requireAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // Auth endpoints
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
        throw Exception(jsonDecode(response.body)['error'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        return data;
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  static Future<void> logout() async {
    await _clearToken();
  }

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

  // Order endpoints
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
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to create order');
      }
    } catch (e) {
      throw Exception('Create order error: $e');
    }
  }

  static Future<List<dynamic>> getOrders({String? status}) async {
    try {
      final headers = await _getHeaders();
      String url = '$baseUrl/orders';
      if (status != null) {
        url += '?status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

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
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to update order');
      }
    } catch (e) {
      throw Exception('Update order error: $e');
    }
  }

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

  // Price endpoints
  static Future<List<dynamic>> getPrices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/prices'),
      );

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
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to create price');
      }
    } catch (e) {
      throw Exception('Create price error: $e');
    }
  }

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
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to update price');
      }
    } catch (e) {
      throw Exception('Update price error: $e');
    }
  }

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
}
```

### 2. Add HTTP Dependency

Update `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
  # ... other dependencies
```

Then run:
```bash
flutter pub get
```

### 3. Update LoginPage

Replace Hive-based login with API call. Update `lib/src/pages/login_page.dart` to use `HttpClientService.login()`.

### 4. Update Providers

Update order and user providers to fetch from Express API instead of Hive:
- Use `HttpClientService.getOrders()` instead of reading from Hive
- Use `HttpClientService.createOrder()` when creating orders
- Similar updates for other data operations

### 5. Update Pages

Update all pages that interact with orders or user data to use the HTTP service:
- OrderListPage
- OrderDetailPage
- AdminDashboardPage
- OrderHistoryPage
- Etc.

---

## Running Both

1. **Start Express Server:**
```bash
cd server
npm install
npm start
```

2. **Configure Flutter App:**
Update `baseUrl` in `HttpClientService` to match your server address:
- Local development: `http://localhost:5000/api`
- Production: `https://your-domain.com/api`

3. **Run Flutter App:**
```bash
flutter run
```

---

## Key Differences

### Authentication
- **Before:** Firebase Authentication → Auto-managed tokens
- **After:** Manual JWT token management in SharedPreferences

### Data Persistence
- **Before:** Firestore + Hive local cache
- **After:** Express/MongoDB backend + optional Hive for offline support

### User Visibility
- **Before:** Same filtering logic in provider
- **After:** **Filtering enforced on backend** (more secure)

### Timestamps
- **Before:** Stored in Hive as ISO strings
- **After:** Stored in MongoDB as native DateTime, serialized as ISO strings in JSON

---

## Troubleshooting

### MongoDB Connection Error
- Ensure MongoDB is running locally: `mongod`
- Or update MONGODB_URI in .env to valid Atlas connection string

### CORS Errors in Flutter
- Ensure Express has CORS enabled (already configured in index.js)
- Check that baseUrl matches server address

### Token Expired
- Implement token refresh logic if using short-lived JWTs
- Currently no expiration set; add in `authController.js` if needed

### Orders Not Showing
- Verify user is logged in and token is saved in SharedPreferences
- Check Express logs for auth errors
- Verify user exists in MongoDB

---

## Next Steps

1. Set up MongoDB locally or use MongoDB Atlas
2. Install Node dependencies: `npm install`
3. Configure .env file with valid MongoDB URI
4. Start Express server: `npm start`
5. Add `http` package to Flutter
6. Create HTTP service (see above)
7. Update Flutter pages to use HTTP calls
8. Test login, order creation, and order viewing

---

## Production Deployment

### Express Server (e.g., Heroku/AWS)

1. Set environment variables:
   - MONGODB_URI (Atlas connection)
   - JWT_SECRET (strong random string)
   - NODE_ENV=production

2. Update Flutter baseUrl to production domain

3. Add HTTPS enforcement

### Database (MongoDB Atlas)

1. Create cluster on MongoDB Atlas
2. Add IP whitelist for server
3. Create database user with strong password
4. Use connection string in MONGODB_URI

---

## Summary

The migration provides:
- ✓ Centralized backend for multi-user support
- ✓ Secure authentication with JWT
- ✓ Server-side order filtering (more secure than client-side)
- ✓ Scalable MongoDB database
- ✓ RESTful API for easy maintenance
- ✓ Clear separation of concerns (backend/frontend)

For questions or issues, refer to the API endpoint documentation above.
