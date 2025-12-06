# Theme Customizer - Panduan Integrasi

## 📋 File yang Dibuat

1. **`lib/config/theme_schemes.dart`** - Definisi skema warna preset (8 tema)
2. **`lib/config/theme_provider.dart`** - Provider untuk manajemen tema
3. **`lib/theme/screens/theme_customizer_screen.dart`** - Halaman customizer UI

## 🔧 Cara Integrasi

### 1. Tambahkan Dependency (jika belum ada)

Pastikan `pubspec.yaml` sudah memiliki:
```yaml
dependencies:
  provider: ^6.1.1
  shared_preferences: ^2.2.2
```

Run: `flutter pub get`

### 2. Update `main.dart`

Tambahkan import:
```dart
import 'package:provider/provider.dart';
import 'config/theme_provider.dart';
```

Wrap `MaterialApp` dengan `MultiProvider`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BrandingProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // ← TAMBAHKAN INI
      ],
      child: const MyApp(),
    ),
  );
}
```

### 3. Update Komponen untuk Menggunakan ThemeProvider

#### Contoh: Update Header dengan Gradient Dinamis

Tambahkan import di file screen:
```dart
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
```

Update `_buildHeader`:
```dart
Widget _buildHeader(bool isDesktop) {
  final themeProvider = context.watch<ThemeProvider>();
  
  return Container(
    padding: EdgeInsets.all(isDesktop ? 24 : 12),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [themeProvider.primaryDark, themeProvider.primaryMain], // ← GUNAKAN INI
      ),
      // ... rest of code
    ),
  );
}
```

#### Properties ThemeProvider yang Tersedia:
- `primaryDark` - Warna primary gelap
- `primaryMain` - Warna primary utama
- `primaryLight` - Warna primary terang
- `secondaryDark` - Warna secondary gelap
- `secondaryMain` - Warna secondary utama
- `secondaryLight` - Warna secondary terang
- `sidebarStart` - Warna awal gradient sidebar
- `sidebarEnd` - Warna akhir gradient sidebar

## 🎨 Tema Preset yang Tersedia

1. **Blue Ocean** (Default) - Biru profesional
2. **Purple Dream** - Ungu modern
3. **Green Forest** - Hijau natural
4. **Orange Sunset** - Orange energik
5. **Red Fire** - Merah berani
6. **Teal Ocean** - Teal segar
7. **Pink Blossom** - Pink feminin
8. **Indigo Night** - Indigo elegan

## 📱 Akses Menu Theme

### Desktop:
Sidebar → **Theme** (icon palette)

### Mobile:
Bottom Nav → **Lainnya** → **Theme**

## ✅ Sudah Terintegrasi

- ✅ Sidebar gradient (otomatis update sesuai tema)
- ✅ Menu navigasi sudah ditambahkan
- ✅ Theme Customizer screen sudah dibuat
- ✅ Mobile bottom nav sudah support

## 🔄 Next Steps (Opsional)

Untuk membuat tema lebih dinamis, update komponen berikut untuk menggunakan ThemeProvider:

1. **Headers** di setiap screen (`produk_screen.dart`, `pelanggan_screen.dart`, dll)
2. **Stat cards** dengan warna accent
3. **FAB buttons** dengan warna primary
4. **Custom app bar** gradient

Contoh cepat:
```dart
final theme = context.watch<ThemeProvider>();

// Untuk gradient header
colors: [theme.primaryDark, theme.primaryMain]

// Untuk button color
backgroundColor: theme.primaryMain

// Untuk accent color
color: theme.secondaryMain
```

## 💾 Persistence

Tema yang dipilih otomatis tersimpan di `SharedPreferences` dan akan dimuat kembali saat aplikasi dibuka.

## 🔄 Reset Tema

User bisa reset tema ke default (Blue Ocean) melalui tombol **Reset** di halaman Theme Customizer.

---

**Status**: ✅ Ready to use
**Last Updated**: December 6, 2025
