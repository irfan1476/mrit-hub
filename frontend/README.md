# MRIT Hub Frontend

Simple HTML/CSS/JavaScript frontend for testing the MRIT Hub authentication system.

## 🚀 Quick Start

1. **Start the backend** (if not already running):
   ```bash
   cd ../
   docker-compose up -d
   ```

2. **Start the frontend server**:
   ```bash
   ./start.sh
   ```

3. **Open in browser**:
   - Go to: http://localhost:8080
   - Try registering with `@mysururoyal.org` email
   - Login and access the dashboard

## 📱 Features

### Login/Register Page (`index.html`)
- ✅ User registration with email validation
- ✅ User login with JWT tokens
- ✅ Domain restriction (`@mysururoyal.org` only)
- ✅ Password reset functionality
- ✅ Real-time error/success messages

### Dashboard (`dashboard.html`)
- ✅ User profile display
- ✅ Email verification status
- ✅ System statistics
- ✅ Feature overview
- ✅ Secure logout

## 🔧 API Integration

The frontend connects to the backend API at `http://localhost:3000/api/v1`:

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/auth/register` | POST | User registration |
| `/auth/login` | POST | User login |
| `/auth/me` | GET | Get user profile |
| `/auth/logout` | POST | User logout |
| `/auth/forgot-password` | POST | Password reset |

## 🎨 Styling

- Clean, modern design
- Responsive layout
- Blue color scheme matching MRIT branding
- Form validation and feedback
- Loading states and error handling

## 🔒 Security

- JWT tokens stored in localStorage
- Automatic token validation
- Secure logout (clears tokens)
- Protected dashboard route
- CORS-enabled backend communication

## 📂 File Structure

```
frontend/
├── index.html          # Login/Register page
├── dashboard.html      # User dashboard
├── server.py          # Simple HTTP server
├── start.sh           # Start script
└── README.md          # This file
```

## 🧪 Testing

1. **Register a new user**:
   - Email: `test@mysururoyal.org`
   - Password: `SecurePass123!`

2. **Verify email** (check backend logs for verification URL)

3. **Login** with the same credentials

4. **Access dashboard** and explore features

## 🚀 Next Steps

This is a basic frontend for testing. For production, consider:

- React/Vue/Angular framework
- Proper state management
- Advanced UI components
- Mobile responsiveness
- Progressive Web App features