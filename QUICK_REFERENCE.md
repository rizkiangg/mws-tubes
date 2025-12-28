# Quick Reference Card

## 🚀 Getting Started (45 minutes)

### 1️⃣ Backend Setup (15 min)
```bash
cd server
npm install
cp .env.example .env
# Edit .env: set MONGODB_URI and JWT_SECRET
npm start
```

### 2️⃣ Flutter Setup (10 min)
```bash
flutter pub add http
# Verify: lib/src/services/http_client.dart exists
```

### 3️⃣ Update LoginPage (10 min)
Replace Hive login with:
```dart
final result = await HttpClientService.login(
  email: email,
  password: password,
);
```

### 4️⃣ Test (10 min)
- Register user
- Login
- Create order
- View orders

---

## 📁 Key Files

| File | Purpose |
|------|---------|
| `server/src/index.js` | Express server startup |
| `server/src/models/*.js` | MongoDB schemas |
| `server/src/controllers/*.js` | Business logic |
| `server/src/routes/*.js` | API endpoints |
| `lib/src/services/http_client.dart` | Flutter HTTP client |
| `server/MIGRATION_GUIDE.md` | API documentation |
| `FIREBASE_TO_EXPRESS_MIGRATION.md` | Complete guide |

---

## 🔌 API Endpoints

### Auth
```
POST   /api/auth/register
POST   /api/auth/login
GET    /api/auth/profile          [AUTH]
```

### Orders
```
POST   /api/orders                [AUTH]
GET    /api/orders                [AUTH]
GET    /api/orders/:id            [AUTH]
PUT    /api/orders/:id/status     [AUTH, ADMIN]
GET    /api/orders/history/all    [AUTH]
GET    /api/orders/stats/dashboard [AUTH, ADMIN]
```

### Prices
```
GET    /api/prices
POST   /api/prices                [AUTH, ADMIN]
PUT    /api/prices/:id            [AUTH, ADMIN]
DELETE /api/prices/:id            [AUTH, ADMIN]
```

---

## 🔑 HTTP Client Usage

### Login
```dart
final result = await HttpClientService.login(
  email: 'user@example.com',
  password: 'password',
);
```

### Create Order
```dart
final result = await HttpClientService.createOrder(
  title: 'Cuci Reguler',
  description: '5kg',
  price: 25000,
);
```

### Get Orders
```dart
final orders = await HttpClientService.getOrders();
```

### Update Status (Admin)
```dart
await HttpClientService.updateOrderStatus(
  id: orderId,
  status: 'selesai',
);
```

---

## 🗄️ Environment Variables

Create `server/.env`:
```
PORT=5000
MONGODB_URI=mongodb://localhost:27017/logu_laundry
JWT_SECRET=your_secret_key_here
NODE_ENV=development
```

**Generate JWT_SECRET:**
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| "Cannot connect" | Ensure `npm start` running in server/ |
| "MongoDB error" | Start `mongod` or check MONGODB_URI |
| "Login failed" | Register user first, verify credentials |
| "Token error" | Login required; token auto-saved in SharedPreferences |
| "CORS error" | CORS enabled; check baseUrl in http_client.dart |

---

## 📱 Update Pages (Checklist)

- [ ] LoginPage - Use `HttpClientService.login()`
- [ ] RegisterPage - Use `HttpClientService.register()`
- [ ] OrderListPage - Use `HttpClientService.getOrders()`
- [ ] OrderDetailPage - Use `HttpClientService.getOrderById()`
- [ ] AdminDashboardPage - Use `HttpClientService.getDashboardStats()`
- [ ] OrderHistoryPage - Use `HttpClientService.getOrderHistory()`
- [ ] PricePage - Use `HttpClientService.getPrices()`

---

## 🚢 Deployment

### Heroku
```bash
heroku create your-app-name
heroku config:set MONGODB_URI=<atlas-uri>
heroku config:set JWT_SECRET=<secret>
git push heroku main
```

Update Flutter baseUrl to: `https://your-app-name.herokuapp.com/api`

---

## 📚 Documentation

- **Complete Overview**: `FIREBASE_TO_EXPRESS_MIGRATION.md`
- **API Reference**: `server/MIGRATION_GUIDE.md`
- **Flutter Guide**: `HTTP_INTEGRATION_GUIDE.md`
- **Backend Docs**: `server/README.md`

---

## ✨ What's New

✅ Express.js backend with MongoDB  
✅ JWT authentication system  
✅ Admin-only features enforcement  
✅ Per-user order visibility  
✅ Order completion tracking  
✅ Complete HTTP client service for Flutter  
✅ Full API documentation  

---

## 💡 Pro Tips

1. **Keep Hive for offline support** - Cache prices and orders
2. **Add error handling UI** - Show meaningful messages to users
3. **Use status filters** - `GET /orders?status=baru` reduces data
4. **Test with Postman** - Verify API before Flutter integration
5. **Use environment variables** - Different URLs for dev/prod

---

**Remember**: All documentation is in the repo - read FIREBASE_TO_EXPRESS_MIGRATION.md for complete details!
