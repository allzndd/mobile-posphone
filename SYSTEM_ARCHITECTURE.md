# Arsitektur Sistem Mobile PosPhone

## 📱 Struktur Aplikasi

### 1. **Flutter App (Desktop + Mobile)**
   - Aplikasi POS untuk toko counter HP
   - Support Desktop dan Mobile
   - UI yang dapat dikustomisasi dari admin panel

### 2. **Laravel Web Admin**
   - Dashboard untuk admin
   - Konfigurasi tema aplikasi (warna, background, logo)
   - Manajemen data toko

### 3. **API Integration**
   - Flutter mengambil konfigurasi tema dari Laravel API
   - Endpoint: `GET /api/theme-config`

---

## 🎨 Fitur Customization (Untuk Admin di Web Laravel)

Admin dapat mengatur:
- ✅ Warna Pallet (Primary Dark, Primary Main, Primary Light)
- ✅ Background Login (Gambar atau Gradient)
- ✅ Logo Aplikasi
- ✅ Nama Aplikasi

---

## 📂 Struktur File Flutter

```
lib/
├── auth/
│   └── screens/
│       └── login_screen.dart          # UI Login
├── config/
│   └── app_theme.dart                 # Konfigurasi tema (default values)
├── models/
│   └── theme_config.dart              # Model untuk tema dari API
└── services/
    └── theme_service.dart             # Service untuk fetch tema dari API
```

---

## 🔄 Alur Kerja

### Saat Ini (Phase 1):
1. ✅ Login screen menggunakan **hardcoded theme** (gradient biru)
2. ✅ Konfigurasi ada di `AppTheme` class
3. ✅ Struktur sudah siap untuk integrasi API

### Nanti (Phase 2 - Setelah Laravel API Ready):
1. 🔜 Admin set tema di Laravel web panel
2. 🔜 Flutter fetch tema via API saat app start
3. 🔜 UI otomatis update sesuai konfigurasi admin
4. 🔜 Support dynamic image background dari URL

---

## 🛠️ TODO Next Steps

### Flutter Side:
- [ ] Implementasi HTTP client (dio/http package)
- [ ] Connect ke Laravel API
- [ ] Implementasi caching tema (SharedPreferences)
- [ ] Handle offline mode dengan fallback tema

### Laravel Side:
- [ ] Buat migration `theme_configs` table
- [ ] Buat API endpoint `/api/theme-config`
- [ ] Admin panel untuk edit tema
- [ ] Upload & serve background images

---

## 📋 Contoh API Response dari Laravel

```json
{
  "success": true,
  "data": {
    "primary_dark": "#1E3A8A",
    "primary_main": "#3B82F6",
    "primary_light": "#93C5FD",
    "background_image_url": "https://api.example.com/storage/backgrounds/login_bg.jpg",
    "use_background_image": true,
    "logo_url": "https://api.example.com/storage/logos/app_logo.png",
    "app_name": "Toko HP Sejahtera"
  }
}
```

---

## 🚀 Cara Menjalankan (Development)

```bash
# Install dependencies
flutter pub get

# Run aplikasi
flutter run

# Build untuk desktop (Windows)
flutter build windows

# Build untuk mobile (Android)
flutter build apk
```

---

## 📝 Notes

- Tema default (biru) sudah diset dan siap digunakan
- Background saat ini menggunakan **gradient** (bukan gambar)
- Semua konfigurasi tersentralisasi di `AppTheme` class
- Struktur sudah siap untuk integrasi dengan Laravel API
