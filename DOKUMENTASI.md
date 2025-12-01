# 📚 Dokumentasi Mobile PosPhone

Dokumentasi lengkap aplikasi POS untuk toko counter HP berbasis Flutter.

---

## 📖 Daftar Isi

1. [Arsitektur Sistem](#arsitektur-sistem)
2. [Struktur Folder](#struktur-folder)
3. [Fitur Aplikasi](#fitur-aplikasi)
4. [Panduan Development](#panduan-development)
5. [Widget Reusable](#widget-reusable)
6. [Tema & Kustomisasi](#tema--kustomisasi)
7. [API Integration](#api-integration)
8. [Deployment](#deployment)

---

## 🏗️ Arsitektur Sistem

### Komponen Utama:

```
┌─────────────────────────────────────┐
│   Flutter App (Desktop + Mobile)    │
│   - Login/Register                  │
│   - Dashboard POS                   │
│   - Transaction Management          │
└──────────────┬──────────────────────┘
               │
               │ REST API
               ▼
┌─────────────────────────────────────┐
│      Laravel Backend (Admin)        │
│   - User Management                 │
│   - Theme Configuration             │
│   - Product Management              │
└─────────────────────────────────────┘
```

### Flow Customization:

1. **Admin** login ke **Laravel Web Panel**
2. **Admin** mengatur tema (warna, background, logo) di dashboard
3. **Flutter App** fetch konfigurasi tema dari **API Laravel**
4. **UI berubah** sesuai setting admin (real-time)

---

## 📂 Struktur Folder

```
mobile-posphone/
├── lib/
│   ├── main.dart                    # Entry point aplikasi
│   └── auth/                        # Module Authentication
│       ├── config/
│       │   └── app_theme.dart       # Konfigurasi tema & warna
│       ├── models/
│       │   └── theme_config.dart    # Model data tema dari API
│       ├── screens/
│       │   ├── login_screen.dart    # Halaman Login
│       │   └── register_screen.dart # Halaman Register
│       ├── services/
│       │   └── theme_service.dart   # Service untuk fetch tema dari API
│       └── widgets/                 # Reusable widgets
│           ├── auth_background.dart
│           ├── auth_card.dart
│           ├── auth_header.dart
│           ├── custom_text_field.dart
│           ├── primary_button.dart
│           ├── social_login_button.dart
│           └── divider_with_text.dart
├── assets/
│   └── images/                      # Asset gambar
├── pubspec.yaml                     # Dependencies
└── README.md
```

---

## ✨ Fitur Aplikasi

### Authentication
- ✅ Login dengan Email & Password
- ✅ Register/Daftar Akun
- ✅ Remember Me
- ✅ Forgot Password
- ✅ Social Login (Google, Facebook, Apple)
- ✅ Form Validation
- ✅ Loading State

### UI/UX
- ✅ Modern & Clean Design
- ✅ Responsive (Desktop & Mobile)
- ✅ Gradient Background
- ✅ Smooth Animations
- ✅ User-friendly Interface
- ✅ Konsisten Styling

### Customization (via Admin Panel Laravel)
- 🔜 Dynamic Color Palette
- 🔜 Custom Background Image
- 🔜 Custom Logo
- 🔜 App Name Configuration

---

## 🛠️ Panduan Development

### Prerequisites

- Flutter SDK 3.7+
- Dart 3.7+
- VS Code / Android Studio
- Git

### Installation

```bash
# Clone repository
git clone https://github.com/allzndd/mobile-posphone.git
cd mobile-posphone

# Install dependencies
flutter pub get

# Run aplikasi
flutter run

# Build untuk production
flutter build windows  # Untuk Windows Desktop
flutter build apk      # Untuk Android
```

### Testing

```bash
# Run tests
flutter test

# Run dengan hot reload
flutter run --hot

# Check for errors
flutter analyze
```

---

## 🎨 Widget Reusable

Semua widget auth ada di `lib/auth/widgets/`. Lihat dokumentasi lengkap di:
📄 [Widget Documentation](lib/auth/widgets/README.md)

### Quick Example:

```dart
// Login Screen menggunakan widgets
AuthBackground(
  child: AuthCard(
    isDesktop: true,
    child: Column(
      children: [
        AuthHeader(
          title: 'Selamat Datang',
          subtitle: 'Masuk ke akun Anda',
        ),
        CustomTextField(
          controller: _emailController,
          labelText: 'Email',
          prefixIcon: Icons.email_outlined,
        ),
        PrimaryButton(
          text: 'Masuk',
          onPressed: _handleLogin,
        ),
      ],
    ),
  ),
)
```

---

## 🎨 Tema & Kustomisasi

### Default Theme

File: `lib/auth/config/app_theme.dart`

```dart
// Warna Default
static const Color primaryDark = Color(0xFF1E3A8A);  // Biru Tua
static const Color primaryMain = Color(0xFF3B82F6);  // Biru
static const Color primaryLight = Color(0xFF93C5FD); // Biru Muda
static const Color primaryWhite = Color(0xFFFFFFFF); // Putih
```

### Mengubah Tema

**Opsi 1: Edit Hardcoded (Development)**
```dart
// Edit di lib/auth/config/app_theme.dart
static const Color primaryMain = Color(0xFFFF0000); // Ganti ke merah
```

**Opsi 2: Via API (Production)**
```dart
// Nanti akan fetch dari Laravel API
// GET /api/theme-config
{
  "primary_dark": "#1E3A8A",
  "primary_main": "#3B82F6",
  "primary_light": "#93C5FD"
}
```

---

## 🔌 API Integration

### Endpoint yang Dibutuhkan

#### 1. Get Theme Configuration
```http
GET /api/theme-config
Response:
{
  "success": true,
  "data": {
    "primary_dark": "#1E3A8A",
    "primary_main": "#3B82F6",
    "primary_light": "#93C5FD",
    "background_image_url": "https://api.example.com/storage/bg.jpg",
    "use_background_image": true,
    "logo_url": "https://api.example.com/storage/logo.png",
    "app_name": "Toko HP Sejahtera"
  }
}
```

#### 2. Login
```http
POST /api/auth/login
Body:
{
  "email": "user@example.com",
  "password": "password123",
  "remember_me": true
}
Response:
{
  "success": true,
  "token": "xxxxx",
  "user": {...}
}
```

#### 3. Register
```http
POST /api/auth/register
Body:
{
  "name": "John Doe",
  "email": "user@example.com",
  "password": "password123",
  "password_confirmation": "password123"
}
Response:
{
  "success": true,
  "token": "xxxxx",
  "user": {...}
}
```

### Implementasi di Flutter

File: `lib/auth/services/theme_service.dart`

```dart
// TODO: Uncomment dan implementasi setelah Laravel API ready
static Future<ThemeConfig> loadThemeFromAPI() async {
  final response = await http.get(
    Uri.parse('${API_BASE_URL}/api/theme-config'),
  );
  
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return ThemeConfig.fromJson(json['data']);
  }
  
  throw Exception('Failed to load theme');
}
```

---

## 🚀 Deployment

### Desktop (Windows)

```bash
# Build
flutter build windows --release

# Output ada di:
build/windows/runner/Release/
```

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (untuk Play Store)
flutter build appbundle --release

# Output ada di:
build/app/outputs/flutter-apk/app-release.apk
```

### iOS

```bash
# Build
flutter build ios --release

# Atau buka di Xcode:
open ios/Runner.xcworkspace
```

---

## 📱 Navigasi Antar Halaman

### Login ke Register

```dart
// Di Login Screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const RegisterScreen(),
  ),
);
```

### Register ke Login

```dart
// Di Register Screen
Navigator.pop(context); // Kembali ke halaman sebelumnya
```

---

## 🔐 Keamanan

### Password Requirements
- Minimal 6 karakter
- Kombinasi huruf dan angka (recommended)
- Case sensitive

### Token Management
- JWT Token untuk authentication
- Refresh token untuk session management
- Secure storage untuk token (SharedPreferences/FlutterSecureStorage)

---

## 📝 TODO List

### Phase 1: Authentication (✅ DONE)
- [x] Login UI
- [x] Register UI
- [x] Form Validation
- [x] Reusable Widgets
- [x] Theme Configuration
- [x] Navigation

### Phase 2: API Integration (🔜 IN PROGRESS)
- [ ] HTTP Client Setup (dio/http)
- [ ] Login API
- [ ] Register API
- [ ] Theme API
- [ ] Error Handling
- [ ] Loading States

### Phase 3: POS Features (🔜 UPCOMING)
- [ ] Dashboard
- [ ] Product Management
- [ ] Transaction
- [ ] Reporting
- [ ] Settings

---

## 🤝 Contributing

Untuk berkontribusi:

1. Fork repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

---

## 📞 Support

Jika ada pertanyaan atau masalah:

- GitHub Issues: [Create Issue](https://github.com/allzndd/mobile-posphone/issues)
- Email: support@example.com

---

## 📄 License

This project is licensed under the MIT License.

---

**Last Updated:** December 1, 2025
**Version:** 1.0.0
**Author:** allzndd
