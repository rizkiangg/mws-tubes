# Firebase to Express.js Migration - Complete Documentation

## Project Overview

This document provides complete instructions for migrating the Logu Laundry application from Firebase Firestore to Express.js with MongoDB backend.

## What's Been Created

### Backend (Express.js)

Located in: `server/`

✅ **Complete Backend Structure**
- `src/index.js` - Main Express server (MongoDB connection, route registration)
- `src/models/` - MongoDB schemas (User, Order, Price)
- `src/controllers/` - Business logic for auth, orders, prices
- `src/routes/` - API endpoint definitions
- `src/middleware/` - JWT authentication and admin authorization
- `package.json` - Dependencies and npm scripts
- `.env.example` - Configuration template
- `README.md` - Backend documentation
- `MIGRATION_GUIDE.md` - Complete migration guide with API docs

### Frontend (Flutter)

Located in: `lib/src/services/`

✅ **HTTP Client Service**
- `services/http_client.dart` - Complete API client with all endpoints
- Handles JWT token management
- Automatic header injection
- Error handling with meaningful messages

✅ **Documentation**
- `HTTP_INTEGRATION_GUIDE.md` - Step-by-step Flutter integration guide
- `MIGRATION_GUIDE.md` - Server setup and API reference

---

## Quick Start Guide

### Phase 1: Set Up Express Backend (15 minutes)

1. **Install Dependencies**
   ```bash
   cd server
   npm install
   ```

2. **Create `.env` file** (copy from `.env.example`)
   ```bash
   cp .env.example .env
   ```

3. **Configure MongoDB**
   - **Option A (Local):** Start MongoDB
     ```bash
     mongod
     ```
     Then `.env` should contain:
     ```
     MONGODB_URI=mongodb://localhost:27017/logu_laundry
     ```
   
   - **Option B (MongoDB Atlas Cloud)**
     1. Create account at https://www.mongodb.com/cloud/atlas
     2. Create cluster and get connection string
     3. Update `.env`:
        ```
        MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/logu_laundry
        ```

4. **Generate JWT Secret**
   ```bash
   node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
   ```
   Copy output to `.env` as `JWT_SECRET`

5. **Start Server**
   ```bash
   npm start
   # or for development with auto-reload:
   npm run dev
   ```
   
   Expected output:
   ```
   MongoDB connected
   Server running on port 5000
   ```

### Phase 2: Update Flutter App (20 minutes)

1. **Add HTTP Dependency**
   ```bash
   flutter pub add http
   ```

2. **Verify HTTP Service Exists**
   - Check `lib/src/services/http_client.dart` exists
   - Review available methods (all documented with comments)

3. **Update API Endpoint** (if not localhost:5000)
   - Edit `lib/src/services/http_client.dart` line 5:
     ```dart
     static const String baseUrl = 'http://YOUR_SERVER:5000/api';
     ```

4. **Update LoginPage**
   - Replace Hive login logic with:
     ```dart
     try {
       final result = await HttpClientService.login(
         email: email,
         password: password,
       );
       // Handle successful login
     } catch (e) {
       // Show error
     }
     ```

5. **Update OrderProvider** (or similar)
   - Replace `_orderRepository.getOrders()` with:
     ```dart
     final orders = await HttpClientService.getOrders();
     ```

### Phase 3: Test Integration (10 minutes)

1. **Start Backend**
   ```bash
   cd server && npm start
   ```

2. **Run Flutter App**
   ```bash
   flutter run
   ```

3. **Test Login Flow**
   - Register new user
   - Login with credentials
   - Verify token is saved (check SharedPreferences)

4. **Test Order Operations**
   - Create order
   - View order list
   - Admin: Update order status

---

## Architecture

### Before (Firebase)

```
Flutter App
    ↓
Hive (Local Cache) + Firebase SDK
    ↓
Firebase Firestore (Cloud)
Firebase Authentication
```

### After (Express.js)

```
Flutter App
    ↓
HTTP Client (lib/src/services/http_client.dart)
    ↓
Express.js Server (Node.js)
    ↓
MongoDB (Database)
JWT Authentication (Stateless)
```

### Key Differences

| Aspect | Firebase | Express.js |
|--------|----------|-----------|
| **Server Type** | Managed service | Custom Node.js |
| **Database** | Firestore (document) | MongoDB (NoSQL) |
| **Authentication** | Firebase Auth SDK | JWT tokens + SharedPreferences |
| **Network** | Direct SDK calls | REST HTTP endpoints |
| **Deployment** | Google Cloud | Any server (Heroku, AWS, etc.) |
| **Cost** | Pay per read/write | Pay per server instance |

---

## API Reference

All API calls require `Authorization: Bearer <token>` except:
- `POST /auth/register`
- `POST /auth/login`
- `GET /prices`

### Example: Create Order
```bash
curl -X POST http://localhost:5000/api/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGc..." \
  -d '{
    "title": "Cuci Reguler",
    "description": "5kg",
    "price": 25000
  }'
```

### Example: Get Orders (Filtered by User)
```bash
curl -X GET http://localhost:5000/api/orders \
  -H "Authorization: Bearer eyJhbGc..."
```

Response:
```json
{
  "orders": [
    {
      "id": "...",
      "title": "Cuci Reguler",
      "status": "baru",
      "owner": "...",
      "ownerUsername": "john_doe",
      "createdAt": "2024-01-15T10:30:00Z"
    }
  ],
  "count": 1
}
```

**For complete API docs**, see: [server/MIGRATION_GUIDE.md](server/MIGRATION_GUIDE.md)

---

## File Structure Reference

```
tugasbesar/
├── server/                           # NEW: Express.js Backend
│   ├── src/
│   │   ├── index.js                 # Main server file
│   │   ├── middleware/
│   │   │   └── auth.js              # JWT middleware
│   │   ├── models/
│   │   │   ├── User.js
│   │   │   ├── Order.js
│   │   │   └── Price.js
│   │   ├── controllers/
│   │   │   ├── authController.js
│   │   │   ├── orderController.js
│   │   │   └── priceController.js
│   │   └── routes/
│   │       ├── auth.js
│   │       ├── orders.js
│   │       └── prices.js
│   ├── package.json
│   ├── .env.example
│   ├── README.md
│   └── MIGRATION_GUIDE.md
│
├── lib/
│   └── src/
│       ├── services/
│       │   └── http_client.dart      # NEW: HTTP API client
│       └── ... (existing Flutter code)
│
├── HTTP_INTEGRATION_GUIDE.md         # NEW: Flutter integration guide
└── ... (existing Flutter files)
```

---

## Security Features

✅ **Implemented**
- Password hashing with bcryptjs (salted)
- JWT token-based authentication (stateless)
- Authorization middleware (admin-only routes)
- Per-user data filtering (users can't access others' orders)
- CORS enabled for Flutter app

⚠️ **Recommended for Production**
- Use HTTPS (not HTTP)
- Add rate limiting to auth endpoints
- Set strong JWT_SECRET (32+ characters)
- Enable MongoDB authentication
- Use environment variables for all secrets
- Add email verification
- Implement token refresh mechanism

---

## Common Workflows

### Workflow 1: User Login

```
User enters email/password
        ↓
LoginPage calls HttpClientService.login()
        ↓
Express server validates credentials (bcrypt)
        ↓
If valid: Generate JWT token and return
        ↓
Flutter saves token in SharedPreferences
        ↓
All future requests include token in Authorization header
        ↓
Subsequent API calls auto-attach token
```

### Workflow 2: Create Order

```
User fills form (title, description, price)
        ↓
OrderPage calls HttpClientService.createOrder()
        ↓
HTTP service adds Authorization header + token
        ↓
Express validates JWT token
        ↓
Express extracts userId from token
        ↓
Server creates order with owner = userId
        ↓
Order saved to MongoDB
        ↓
Response returned to Flutter
        ↓
OrderProvider updates local state
        ↓
UI re-renders with new order
```

### Workflow 3: Admin Updates Order Status

```
Admin clicks "Selesai" button
        ↓
OrderDetailPage calls HttpClientService.updateOrderStatus()
        ↓
Express checks if user is admin (adminOnly middleware)
        ↓
If not admin: return 403 Forbidden
        ↓
If admin: Update order.status = "selesai"
        ↓
Set completedAt = current timestamp
        ↓
Save to MongoDB
        ↓
Return updated order to Flutter
        ↓
UI updates to show completion time
```

---

## Troubleshooting

### "Cannot connect to server"
- [ ] Is Express running? (`npm start` in server/)
- [ ] Is MongoDB running? (`mongod` in separate terminal)
- [ ] Is baseUrl correct in HttpClientService?
- [ ] Are you on same network if using real device?

### "Login failed / Invalid credentials"
- [ ] Is user registered? (Check in MongoDB: `db.users.find()`)
- [ ] Is password correct?
- [ ] Is MONGODB_URI valid?

### "Unauthorized / Token invalid"
- [ ] Is token in SharedPreferences? (Login first)
- [ ] Is JWT_SECRET in .env same on server?
- [ ] Is token included in headers?

### "Order not found" (404)
- [ ] Non-admin users can only see their own orders
- [ ] Admin users can see all orders
- [ ] Verify order ID is correct

### "MongoDB connection error"
- [ ] Local: `mongod` command running?
- [ ] Atlas: IP whitelisted in cluster settings?
- [ ] MONGODB_URI format correct?
- [ ] Credentials correct (if using Atlas)?

---

## Performance Tips

1. **Caching**
   - Cache prices locally (rarely change)
   - Cache user profile
   - Keep order list in memory

2. **Pagination**
   - Currently returns all orders
   - For large datasets, add limit/offset
   - Example: `GET /orders?limit=20&offset=0`

3. **Filtering**
   - Use status filter: `GET /orders?status=baru`
   - Reduces network payload

4. **Database Indexes**
   - Already configured for user.email, order.owner, order.status

---

## Deployment

### Option 1: Heroku (Free tier available)

1. Create account at https://heroku.com
2. Install Heroku CLI
3. Deploy:
   ```bash
   heroku create your-app-name
   heroku config:set MONGODB_URI=<atlas-uri>
   heroku config:set JWT_SECRET=<secret>
   git push heroku main
   ```

4. Update Flutter baseUrl to production:
   ```dart
   static const String baseUrl = 'https://your-app-name.herokuapp.com/api';
   ```

### Option 2: AWS EC2

1. Create Ubuntu instance
2. Install Node.js and MongoDB
3. Clone code and run `npm start`
4. Use PM2 to manage process

### Option 3: DigitalOcean Droplet

Similar to AWS - simple VPS with full control

---

## Next Steps After Migration

1. **Immediate** (After basic integration)
   - Update all pages to use HTTP service
   - Test all CRUD operations
   - Verify offline handling

2. **Short-term** (Production readiness)
   - Add input validation on all forms
   - Implement error handling UI
   - Add loading indicators
   - Test with real MongoDB Atlas

3. **Long-term** (Enhancements)
   - Add order notifications
   - Implement order photo uploads
   - Add delivery tracking
   - Multi-location support
   - Analytics dashboard

---

## Key Files to Review

For understanding the system, read in this order:

1. **[server/MIGRATION_GUIDE.md](server/MIGRATION_GUIDE.md)** - API endpoints and Flutter integration
2. **[server/README.md](server/README.md)** - Backend setup and architecture
3. **[HTTP_INTEGRATION_GUIDE.md](HTTP_INTEGRATION_GUIDE.md)** - Flutter-specific guide
4. **`server/src/index.js`** - How server initializes
5. **`lib/src/services/http_client.dart`** - How Flutter communicates with server

---

## Support & Resources

- **Express.js**: https://expressjs.com/
- **MongoDB**: https://www.mongodb.com/docs/
- **Mongoose**: https://mongoosejs.com/
- **JWT**: https://jwt.io/
- **Flutter HTTP**: https://pub.dev/packages/http

---

## Summary Checklist

- [ ] Clone/pull latest code
- [ ] Review this document
- [ ] Set up Express backend
- [ ] Create `.env` file with MongoDB URI and JWT secret
- [ ] Start Express server (`npm start`)
- [ ] Add `http` package to Flutter
- [ ] Verify `http_client.dart` exists in `lib/src/services/`
- [ ] Update LoginPage to use HTTP service
- [ ] Test login flow end-to-end
- [ ] Update remaining pages to use HTTP
- [ ] Test all CRUD operations
- [ ] Deploy to production (Heroku/AWS)

---

**Version:** 1.0  
**Status:** Complete Migration Documentation  
**Last Updated:** 2024

For questions or issues, refer to the troubleshooting section above or the detailed guides in `server/` directory.
