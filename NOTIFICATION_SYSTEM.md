# Notification System Documentation

## Fitur

Sistem notifikasi real-time untuk memberitahu user ketika admin menandai pesanan sebagai "selesai".

### Yang Terjadi:

1. **Admin menandai order selesai** → Order status berubah ke "selesai"
2. **Backend membuat notifikasi** → Notifikasi tersimpan di database
3. **Client (user) menerima notifikasi** → User bisa melihat notifikasi di aplikasi

---

## API Endpoints

### Get Notifications
```
GET /api/notifications
Authorization: Bearer <token>
```

**Response:**
```json
{
  "notifications": [
    {
      "_id": "...",
      "userId": "...",
      "orderId": "...",
      "orderTitle": "Cuci Reguler",
      "message": "Pesanan 'Cuci Reguler' Anda telah selesai! Silakan ambil di toko kami.",
      "type": "order_completed",
      "read": false,
      "createdAt": "2024-01-15T10:30:00Z"
    }
  ],
  "unreadCount": 2
}
```

### Mark Notification as Read
```
PUT /api/notifications/:notificationId/read
Authorization: Bearer <token>
```

### Mark All Notifications as Read
```
PUT /api/notifications/read/all
Authorization: Bearer <token>
```

### Delete Notification
```
DELETE /api/notifications/:notificationId
Authorization: Bearer <token>
```

---

## Flutter Implementation

### 1. Tambahkan HTTP methods (sudah ada di http_client.dart)

```dart
// Get notifications
final result = await HttpClientService.getNotifications();
final notifications = result['notifications'];
final unreadCount = result['unreadCount'];

// Mark as read
await HttpClientService.markNotificationAsRead(notificationId);

// Mark all as read
await HttpClientService.markAllNotificationsAsRead();

// Delete notification
await HttpClientService.deleteNotification(notificationId);
```

### 2. Buat Notification Provider

Buat file `lib/src/providers/notification_provider.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:tugasbesar/src/services/http_client.dart';

class NotificationProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;
  bool _loading = false;

  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get loading => _loading;

  Future<void> loadNotifications() async {
    _loading = true;
    notifyListeners();

    try {
      final result = await HttpClientService.getNotifications();
      _notifications = List<Map<String, dynamic>>.from(result['notifications'] ?? []);
      _unreadCount = result['unreadCount'] ?? 0;
    } catch (e) {
      print('Error loading notifications: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await HttpClientService.markNotificationAsRead(notificationId);
      // Update local state
      final index = _notifications.indexWhere((n) => n['_id'] == notificationId);
      if (index != -1) {
        _notifications[index]['read'] = true;
        _unreadCount--;
        notifyListeners();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await HttpClientService.markAllNotificationsAsRead();
      for (var notification in _notifications) {
        notification['read'] = true;
      }
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await HttpClientService.deleteNotification(notificationId);
      _notifications.removeWhere((n) => n['_id'] == notificationId);
      notifyListeners();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  // Auto-fetch notifications setiap 10 detik
  void startPolling() {
    Future.delayed(Duration(seconds: 10), () {
      loadNotifications();
      if (_notifications.isNotEmpty) {
        startPolling();
      }
    });
  }
}
```

### 3. Buat Notification UI

Buat file `lib/src/widgets/notification_bell.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tugasbesar/src/providers/notification_provider.dart';

class NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        return Stack(
          children: [
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                showNotificationDialog(context, notificationProvider);
              },
            ),
            if (notificationProvider.unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                  child: Text(
                    '${notificationProvider.unreadCount}',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void showNotificationDialog(BuildContext context, NotificationProvider notificationProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Notifikasi'),
            TextButton(
              onPressed: () => notificationProvider.markAllAsRead(),
              child: Text('Tandai Semua'),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: notificationProvider.notifications.length,
            itemBuilder: (context, index) {
              final notification = notificationProvider.notifications[index];
              return NotificationTile(
                notification: notification,
                onMarkRead: () => notificationProvider.markAsRead(notification['_id']),
                onDelete: () => notificationProvider.deleteNotification(notification['_id']),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;

  const NotificationTile({
    required this.notification,
    required this.onMarkRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(
          Icons.check_circle,
          color: notification['read'] ? Colors.grey : Colors.green,
        ),
        title: Text(notification['orderTitle']),
        subtitle: Text(
          notification['message'],
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Text('Tandai Terbaca'),
              value: 'read',
              onTap: onMarkRead,
            ),
            PopupMenuItem(
              child: Text('Hapus'),
              value: 'delete',
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4. Gunakan di HomePage

Update `lib/src/pages/home_page.dart`:

```dart
import 'package:tugasbesar/src/widgets/notification_bell.dart';
import 'package:tugasbesar/src/providers/notification_provider.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load notifications saat aplikasi dibuka
    Future.delayed(Duration.zero, () {
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      notificationProvider.loadNotifications();
      notificationProvider.startPolling(); // Auto-refresh setiap 10 detik
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logu Laundry'),
        actions: [
          NotificationBell(), // Tambahkan notification bell
          // ... other actions
        ],
      ),
      body: // ... existing body
    );
  }
}
```

### 5. Setup Provider

Update `lib/main.dart`:

```dart
import 'package:tugasbesar/src/providers/notification_provider.dart';

void main() async {
  // ... existing code
  
  runApp(
    MultiProvider(
      providers: [
        // ... existing providers
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
```

---

## Workflow Lengkap

1. **Admin buka OrderDetailPage** → Lihat status order
2. **Admin klik "Ubah Status"** → Pilih "selesai"
3. **Backend update order status** → Buat notifikasi untuk user
4. **User lihat notification bell** → Ada badge unread count
5. **User buka notifikasi** → Lihat pesan order selesai
6. **User tandai terbaca** → Badge hilang, notifikasi di-mark sebagai read

---

## Polling vs Real-time

### Polling (Implementasi Saat Ini)
- ✅ Simple, tidak perlu WebSocket
- ✅ Kompatibel dengan semua platform
- ⚠️ Delay beberapa detik (polling interval)
- ⚠️ Lebih banyak request ke server

### Real-time (Future Enhancement)
- Gunakan Socket.io atau WebSocket
- Notifikasi instant tanpa delay
- Lebih complex setup

---

## Testing

Curl test notification endpoints:

```bash
# Get notifications
curl -X GET http://localhost:5000/api/notifications \
  -H "Authorization: Bearer <token>"

# Mark as read
curl -X PUT http://localhost:5000/api/notifications/<notificationId>/read \
  -H "Authorization: Bearer <token>"

# Delete notification
curl -X DELETE http://localhost:5000/api/notifications/<notificationId> \
  -H "Authorization: Bearer <token>"
```

---

## Summary

✅ Backend: Notifikasi tersimpan saat order selesai
✅ API: 4 endpoints untuk manage notifikasi
✅ Flutter: HTTP methods siap pakai
✅ UI: Notification bell dengan unread badge
✅ Auto-polling: Refresh otomatis setiap 10 detik

Tinggal implementasikan Flutter UI dan provider! 🚀
