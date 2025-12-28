# Logu Laundry Backend

Express.js REST API backend for Logu Laundry Flutter application. Replaces Firebase Firestore with MongoDB and provides stateless JWT-based authentication.

## Quick Start

### 1. Prerequisites

- Node.js 14+ with npm
- MongoDB instance (local or MongoDB Atlas)

### 2. Installation

```bash
npm install
```

### 3. Environment Configuration

Create `.env` file:

```env
PORT=5000
MONGODB_URI=mongodb://localhost:27017/logu_laundry
JWT_SECRET=your_secure_secret_key_here
NODE_ENV=development
```

For MongoDB Atlas (cloud):
```env
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/logu_laundry?retryWrites=true&w=majority
```

### 4. Start Server

**Development (with auto-reload):**
```bash
npm run dev
```

**Production:**
```bash
npm start
```

Server runs on `http://localhost:5000`

## Project Structure

```
server/
├── src/
│   ├── index.js                 # Express app initialization & route setup
│   ├── middleware/
│   │   └── auth.js              # JWT authentication & authorization
│   ├── models/
│   │   ├── User.js              # User schema
│   │   ├── Order.js             # Order schema
│   │   └── Price.js             # Service price schema
│   ├── controllers/
│   │   ├── authController.js    # Auth logic (register, login, profile)
│   │   ├── orderController.js   # Order CRUD & statistics
│   │   └── priceController.js   # Price CRUD
│   └── routes/
│       ├── auth.js              # Authentication endpoints
│       ├── orders.js            # Order management endpoints
│       └── prices.js            # Price management endpoints
├── .env.example                 # Environment variables template
├── package.json                 # Dependencies
└── MIGRATION_GUIDE.md           # Migration documentation
```

## API Overview

### Base URL
```
http://localhost:5000/api
```

### Authentication
All protected endpoints require JWT token in `Authorization` header:
```
Authorization: Bearer <token>
```

### Response Format
All responses are JSON:
```json
{
  "message": "Success message",
  "data": {...}
}
```

Errors:
```json
{
  "error": "Error message"
}
```

## API Endpoints

### Authentication (`/api/auth`)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/register` | No | Register new user |
| POST | `/login` | No | Login user |
| GET | `/profile` | Yes | Get current user |

### Orders (`/api/orders`)

| Method | Endpoint | Auth | Role | Description |
|--------|----------|------|------|-------------|
| POST | `/` | Yes | User | Create order |
| GET | `/` | Yes | User | List orders (filtered) |
| GET | `/:id` | Yes | User | Get order details |
| GET | `/history/all` | Yes | User | Get completed orders |
| PUT | `/:id/status` | Yes | Admin | Update order status |
| GET | `/stats/dashboard` | Yes | Admin | Get statistics |

### Prices (`/api/prices`)

| Method | Endpoint | Auth | Role | Description |
|--------|----------|------|------|-------------|
| GET | `/` | No | - | Get all prices |
| POST | `/` | Yes | Admin | Create price |
| PUT | `/:id` | Yes | Admin | Update price |
| DELETE | `/:id` | Yes | Admin | Delete price |

## Data Models

### User
```json
{
  "_id": "ObjectId",
  "username": "string (unique)",
  "email": "string (unique)",
  "password": "string (hashed)",
  "name": "string",
  "role": "user|admin",
  "createdAt": "DateTime"
}
```

### Order
```json
{
  "_id": "ObjectId",
  "title": "string",
  "description": "string",
  "price": "number",
  "status": "baru|dikerjakan|selesai",
  "owner": "ObjectId (ref: User)",
  "ownerUsername": "string",
  "createdAt": "DateTime",
  "completedAt": "DateTime|null"
}
```

### Price
```json
{
  "_id": "ObjectId",
  "name": "string",
  "price": "number",
  "unit": "string",
  "defaultQty": "number",
  "createdAt": "DateTime",
  "updatedAt": "DateTime"
}
```

## Key Features

### 1. User Management
- User registration with hashed passwords (bcryptjs)
- Login with JWT token generation
- Profile retrieval with auth validation
- Role-based access control (user/admin)

### 2. Order Management
- Create orders with automatic owner assignment
- View orders (users see own, admins see all)
- Update order status (admin only)
- Track completion timestamps
- Access control at API level (users cannot access others' orders)

### 3. Price Management
- Public price list viewing
- Admin-only create/update/delete operations
- Service configuration via prices

### 4. Security
- JWT-based stateless authentication
- Password hashing with bcryptjs
- Role-based authorization middleware
- CORS support for cross-origin requests
- Environment variable protection

## Usage Examples

### Register User
```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "email": "john@example.com",
    "password": "securepassword",
    "name": "John Doe"
  }'
```

### Login
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "securepassword"
  }'
```

Response:
```json
{
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "...",
    "username": "john_doe",
    "email": "john@example.com",
    "name": "John Doe",
    "role": "user"
  }
}
```

### Create Order
```bash
curl -X POST http://localhost:5000/api/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "title": "Cuci Reguler",
    "description": "5kg pakaian biasa",
    "price": 25000
  }'
```

### Get Orders
```bash
curl -X GET http://localhost:5000/api/orders \
  -H "Authorization: Bearer <token>"
```

### Update Order Status (Admin)
```bash
curl -X PUT http://localhost:5000/api/orders/<order_id>/status \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"status": "selesai"}'
```

### Get Prices
```bash
curl -X GET http://localhost:5000/api/prices
```

## Middleware

### Authentication (`auth.js`)

**`auth()` - Validates JWT token**
- Extracts token from Authorization header
- Verifies signature using JWT_SECRET
- Attaches decoded user to request object

**`adminOnly()` - Checks admin role**
- Must be used after `auth()` middleware
- Returns 403 if user is not admin

Usage:
```javascript
router.get('/protected', auth, (req, res) => {
  // req.user contains decoded JWT
  res.json({ user: req.user });
});

router.post('/admin-only', auth, adminOnly, (req, res) => {
  // Only admins can access
  res.json({ message: 'Admin action' });
});
```

## Database Connection

### MongoDB Local
```env
MONGODB_URI=mongodb://localhost:27017/logu_laundry
```

Ensure MongoDB is running:
```bash
mongod
```

### MongoDB Atlas (Cloud)
1. Create cluster on [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Add network access (IP whitelist)
3. Create database user
4. Copy connection string:
```env
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/logu_laundry?retryWrites=true&w=majority
```

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| PORT | No | 5000 | Server port |
| MONGODB_URI | Yes | - | MongoDB connection string |
| JWT_SECRET | Yes | - | Secret key for JWT signing |
| NODE_ENV | No | development | Environment (development/production) |

## Error Handling

All errors are caught and returned as JSON:

```json
{
  "error": "Error message describing what went wrong"
}
```

HTTP Status Codes:
- `200` - Success
- `201` - Created
- `400` - Bad request (validation error)
- `401` - Unauthorized (missing/invalid token)
- `403` - Forbidden (insufficient permissions)
- `404` - Not found
- `500` - Server error

## Development

### Install Dev Dependencies

```bash
npm install --save-dev nodemon
```

### Run with Auto-reload

```bash
npm run dev
```

Uses Nodemon to automatically restart on file changes.

### Testing

Use Postman, Thunder Client, or curl to test endpoints. See examples above.

## Deployment

### Heroku

1. Create Heroku app:
```bash
heroku create your-app-name
```

2. Set environment variables:
```bash
heroku config:set MONGODB_URI=<atlas-connection>
heroku config:set JWT_SECRET=<strong-secret>
heroku config:set NODE_ENV=production
```

3. Deploy:
```bash
git push heroku main
```

### AWS/DigitalOcean

1. Set up Node.js server
2. Set environment variables
3. Run `npm install && npm start`
4. Use PM2 for process management:
```bash
npm install -g pm2
pm2 start src/index.js --name "logu-laundry-api"
pm2 save
```

## Troubleshooting

### MongoDB Connection Error
- **Local:** Ensure `mongod` is running
- **Atlas:** Verify IP whitelist and credentials
- **Check:** `MONGODB_URI` in `.env` is correct

### JWT Token Errors
- Verify token is included in `Authorization: Bearer <token>` header
- Check `JWT_SECRET` matches in `.env`
- Token may have expired (currently no expiration; consider adding)

### CORS Errors
- CORS is enabled in `index.js`
- If using different domain, update Flutter app's `baseUrl`

### Port Already in Use
- Change PORT in `.env`
- Or kill process: `lsof -i :5000` then `kill <PID>`

## Performance Considerations

1. **Database Indexing:** Add indexes on frequently queried fields:
   - User: email, username
   - Order: owner, status, createdAt

2. **Pagination:** Consider adding for large order lists

3. **Caching:** Add Redis for frequently accessed data (prices)

4. **Rate Limiting:** Add rate limiter for auth endpoints

## Security Checklist

- [ ] Generate strong JWT_SECRET (32+ characters)
- [ ] Use HTTPS in production
- [ ] Enable MongoDB authentication
- [ ] Set up IP whitelisting
- [ ] Add rate limiting to auth endpoints
- [ ] Validate all input data
- [ ] Use CORS selectively (specify origins)
- [ ] Keep dependencies updated

## Future Enhancements

- [ ] JWT token refresh mechanism
- [ ] Email verification on registration
- [ ] Password reset functionality
- [ ] Order notifications
- [ ] Order timeline/history tracking
- [ ] File uploads (photos)
- [ ] Advanced filtering & search
- [ ] Pagination for large lists
- [ ] Analytics dashboard
- [ ] Multi-location support

## Support

For issues or questions, refer to:
- [MIGRATION_GUIDE.md](./MIGRATION_GUIDE.md) - Flutter integration guide
- Express.js docs: https://expressjs.com/
- Mongoose docs: https://mongoosejs.com/
- JWT docs: https://jwt.io/

---

**Version:** 1.0.0  
**Last Updated:** 2024  
**License:** MIT
