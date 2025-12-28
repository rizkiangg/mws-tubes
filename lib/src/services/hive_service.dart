import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Seeds default users into SharedPreferences so the app has credentials
/// available on first launch (admin/admin123 and user/user123).
Future<void> initializeHiveAndSeedAdmin() async {
  final prefs = await SharedPreferences.getInstance();

  final existingJson = prefs.getString('users');
  Map<String, dynamic> users = {};
  if (existingJson != null) {
    try {
      final decoded = jsonDecode(existingJson);
      if (decoded is Map<String, dynamic>) {
        users = decoded;
      }
    } catch (_) {
      users = {};
    }
  }

  // Default accounts used by the current UI login flow.
  const defaults = {
    'admin': {
      'password': 'admin123',
      'name': 'Administrator',
      'email': 'admin@example.com',
      'role': 'admin',
    },
    'user': {
      'password': 'user123',
      'name': 'Default User',
      'email': 'user@example.com',
      'role': 'user',
    },
  };

  bool changed = false;
  defaults.forEach((key, value) {
    if (!users.containsKey(key)) {
      users[key] = value;
      changed = true;
    }
  });

  if (changed) {
    await prefs.setString('users', jsonEncode(users));
  }
}
