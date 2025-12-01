# 🎨 Panduan Mengganti Logo di Login & Register

Dokumentasi lengkap cara mengganti logo di halaman authentication.

---

## 📋 3 Cara Mengganti Logo

### **1. Pakai Icon (Default - Sekarang)**

**Keuntungan:**
- ✅ Paling simple
- ✅ Tidak perlu file gambar
- ✅ Banyak pilihan icon

**Cara:**
```dart
// Di login_screen.dart atau register_screen.dart
AuthHeader(
  title: 'Selamat Datang',
  subtitle: 'Masuk ke akun Anda',
  icon: Icons.store,  // Ganti icon di sini
  isDesktop: isDesktop,
)
```

**Pilihan Icon:**
- `Icons.lock_outline` (default)
- `Icons.store`
- `Icons.shopping_bag`
- `Icons.phone_android`
- `Icons.business`
- Dan ribuan icon lainnya dari Material Icons

---

### **2. Pakai Gambar dari Assets (Lokal)**

**Keuntungan:**
- ✅ Logo custom dari file
- ✅ Tidak perlu internet
- ✅ Load cepat

**Langkah:**

#### Step 1: Siapkan Logo
- Format: PNG dengan background transparan
- Ukuran: 512x512px (recommended)
- Bentuk: Square (nanti otomatis jadi circle)

#### Step 2: Letakkan di Folder Assets
```
assets/images/logo.png
```

#### Step 3: Pastikan Sudah di pubspec.yaml
```yaml
flutter:
  assets:
    - assets/images/
```

#### Step 4: Gunakan di Code
```dart
AuthHeader(
  title: 'Selamat Datang',
  subtitle: 'Masuk ke akun Anda',
  logoAssetPath: 'assets/images/logo.png',  // Path logo
  isDesktop: isDesktop,
)
```

#### Step 5: Update AppTheme (Optional - untuk default global)
```dart
// Di lib/auth/config/app_theme.dart
static const String? logoAssetPath = 'assets/images/logo.png';
```

---

### **3. Pakai Gambar dari URL (Dynamic - Nanti dari Admin Panel)**

**Keuntungan:**
- ✅ Logo bisa diganti dari admin panel
- ✅ Tidak perlu rebuild app
- ✅ Berbeda untuk setiap toko/buyer

**Cara:**
```dart
AuthHeader(
  title: 'Selamat Datang',
  subtitle: 'Masuk ke akun Anda',
  logoUrl: 'https://api.example.com/storage/logos/toko123.png',
  isDesktop: isDesktop,
)
```

**Nanti Integrasi API:**
```dart
// Akan fetch dari Laravel
final themeConfig = await ThemeService.loadThemeFromAPI();

AuthHeader(
  title: 'Selamat Datang',
  subtitle: 'Masuk ke akun Anda',
  logoUrl: themeConfig.logoUrl,  // Logo dari API
  isDesktop: isDesktop,
)
```

---

## 🔄 Priority Loading Logo

Widget `AuthHeader` akan load logo dengan urutan:

1. **logoUrl** (jika ada) → Load dari internet
2. **logoAssetPath** (jika logoUrl null) → Load dari assets
3. **icon** (jika keduanya null) → Pakai icon

**Auto Fallback:**
- Jika URL gagal load → fallback ke icon
- Jika Asset tidak ada → fallback ke icon

---

## 💡 Contoh Implementasi

### Login Screen dengan Logo Custom
```dart
// lib/auth/screens/login_screen.dart
AuthHeader(
  title: 'Toko HP Sejahtera',
  subtitle: 'Masuk ke akun Anda',
  logoAssetPath: 'assets/images/logo.png',  // Logo custom
  isDesktop: isDesktop,
)
```

### Register Screen dengan Icon Berbeda
```dart
// lib/auth/screens/register_screen.dart
AuthHeader(
  title: 'Buat Akun',
  subtitle: 'Daftar untuk memulai',
  icon: Icons.person_add_outlined,  // Icon berbeda
  isDesktop: isDesktop,
)
```

### Dynamic Logo dari API
```dart
// Future implementation
class LoginScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ThemeService.loadThemeFromAPI(),
      builder: (context, snapshot) {
        final logoUrl = snapshot.data?.logoUrl;
        
        return AuthHeader(
          title: 'Selamat Datang',
          subtitle: 'Masuk ke akun Anda',
          logoUrl: logoUrl,  // Dynamic dari API
          isDesktop: isDesktop,
        );
      },
    );
  }
}
```

---

## 🎨 Tips Logo Design

### Ukuran & Format
- **Ukuran:** 512x512px atau 1024x1024px
- **Format:** PNG dengan background transparan
- **Bentuk:** Square (akan otomatis di-clip menjadi circle)

### Style
- Logo simple dan clean
- Kontras yang baik
- Tidak terlalu detail (karena akan jadi kecil)

### Color
- Sesuaikan dengan brand toko
- Atau pakai warna yang kontras dengan gradient biru

---

## 🔧 Troubleshooting

### Logo tidak muncul dari Assets?
1. Cek path di pubspec.yaml
2. Jalankan `flutter pub get`
3. Hot restart (bukan hot reload)
4. Pastikan file ada di `assets/images/`

### Logo dari URL tidak load?
1. Cek koneksi internet
2. Cek URL valid dan accessible
3. Cek CORS settings di server
4. Lihat console untuk error message

### Logo terpotong atau blur?
1. Pastikan ukuran minimal 512x512px
2. Gunakan format PNG
3. Hindari gambar dengan rasio tidak 1:1

---

## 📝 Untuk Laravel Admin Panel (Nanti)

### API Response Format:
```json
{
  "success": true,
  "data": {
    "logo_url": "https://api.example.com/storage/logos/toko123.png",
    "app_name": "Toko HP Sejahtera",
    "primary_color": "#3B82F6"
  }
}
```

### Upload Logo di Admin Panel:
1. Admin upload logo via form
2. Laravel simpan ke storage
3. Return public URL
4. Flutter fetch & display

---

**Last Updated:** December 1, 2025
