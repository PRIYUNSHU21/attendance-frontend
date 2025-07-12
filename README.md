# Attendance Management System

A comprehensive Flutter-based attendance management application designed for educational institutions. This mobile and web-friendly system allows administrators, teachers, and students to manage and track attendance efficiently with a modern, animated UI.

## 📱 Screenshots

*Note: Add actual screenshots here after deployment. Include images of:*
- *Login screen*
- *Admin dashboard*
- *Teacher dashboard*
- *Student attendance view*
- *Session management*

## ✨ Features

### Multi-Role Support
- **Admin**: Manage organizations, users, sessions, and view analytics
- **Teacher**: Create and manage attendance sessions, view student attendance records
- **Student**: Mark attendance, view attendance history

### Core Functionality
- **Organization Management**: Create and manage multiple educational organizations
- **User Management**: Create and manage admin, teacher, and student accounts
- **Session Management**: Create, activate, and close attendance sessions
- **Attendance Tracking**: Record and track student attendance with location validation
- **Analytics**: View attendance statistics and reports

### Technical Highlights
- **Modern UI/UX**: Smooth animations and intuitive interface
- **Responsive Design**: Works on mobile, tablet, and web platforms
- **Location-Based Verification**: Ensures students are physically present
- **Role-Based Access Control**: Different interfaces for admins, teachers, and students
- **Multi-Organization Support**: Data isolation between different organizations

## 🛠️ Technologies Used

- **Frontend**: Flutter, Dart
- **State Management**: Provider
- **HTTP Client**: http package
- **Local Storage**: shared_preferences
- **Location Services**: geolocator
- **Charts & Graphs**: fl_chart
- **Animations**: flutter_animate, lottie

## 📋 Prerequisites

- Flutter SDK (3.8.0 or later)
- Dart SDK (3.8.1 or later)
- Android Studio / VS Code with Flutter extensions
- A connected device or emulator

## 🚀 Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/attendance-management-system.git
   cd attendance-management-system
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

## 📲 Usage Guide

### Admin User
1. Register as an admin user
2. Create your organization
3. Manage users, sessions, and view analytics from the admin dashboard
4. Create and manage sessions for attendance

### Teacher User
1. Login with teacher credentials
2. View the teacher dashboard
3. Create attendance sessions
4. View student attendance records

### Student User
1. Login with student credentials
2. Mark attendance for active sessions
3. View attendance history

## 📁 Project Structure

```
lib/
├── main.dart                  # Application entry point
├── src/
│   ├── app.dart               # Main app configuration
│   ├── models/                # Data models
│   ├── providers/             # State management
│   ├── routes/                # Screen implementations
│   ├── services/              # API and backend services
│   ├── utils/                 # Utility functions and constants
│   └── widgets/               # Reusable UI components
```

## 🌐 Pushing to GitHub

Follow these steps to push this project to GitHub as a separate repository:

1. **Create a new GitHub repository**
   - Go to [GitHub](https://github.com) and sign in
   - Click on the "+" icon in the top right corner and select "New repository"
   - Name your repository (e.g., "attendance-management-system")
   - Choose public or private visibility
   - Do not initialize with README, .gitignore, or license (we already have these)
   - Click "Create repository"

2. **Initialize Git in your local project (if not already done)**
   ```bash
   git init
   ```

3. **Add all files to Git staging**
   ```bash
   git add .
   ```

4. **Commit the changes**
   ```bash
   git commit -m "Initial commit"
   ```

5. **Add the GitHub repository as remote**
   ```bash
   git remote add origin https://github.com/yourusername/attendance-management-system.git
   ```

6. **Push to GitHub**
   ```bash
   git push -u origin master
   # or if you're using 'main' as default branch
   git push -u origin main
   ```

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request