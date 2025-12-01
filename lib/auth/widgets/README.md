# Auth Widgets Documentation

Dokumentasi lengkap untuk widget-widget reusable di folder `auth/widgets`.

---

## 📦 Daftar Widget

### 1. **AuthBackground**
Widget untuk background gradient yang dapat dikustomisasi.

**File:** `auth_background.dart`

**Usage:**
```dart
AuthBackground(
  child: YourWidget(),
)
```

**Props:**
- `child` (Widget) - Widget yang akan dibungkus dengan background

---

### 2. **AuthCard**
Widget untuk card container dengan styling konsisten.

**File:** `auth_card.dart`

**Usage:**
```dart
AuthCard(
  isDesktop: true,
  child: YourFormWidget(),
)
```

**Props:**
- `child` (Widget) - Konten yang akan ditampilkan di dalam card
- `isDesktop` (bool) - Untuk responsive padding dan max-width

---

### 3. **AuthHeader**
Widget untuk header halaman auth (logo + title + subtitle).

**File:** `auth_header.dart`

**Usage:**

**Opsi 1: Pakai Icon (Default)**
```dart
AuthHeader(
  title: 'Selamat Datang',
  subtitle: 'Masuk ke akun Anda',
  icon: Icons.lock_outline,
  isDesktop: true,
)
```

**Opsi 2: Pakai Gambar dari Assets**
```dart
AuthHeader(
  title: 'Selamat Datang',
  subtitle: 'Masuk ke akun Anda',
  logoAssetPath: 'assets/images/logo.png',
  isDesktop: true,
)
```

**Opsi 3: Pakai Gambar dari URL (Dynamic dari Admin Panel)**
```dart
AuthHeader(
  title: 'Selamat Datang',
  subtitle: 'Masuk ke akun Anda',
  logoUrl: 'https://api.example.com/storage/logo.png',
  isDesktop: true,
)
```

**Props:**
- `title` (String) - Judul utama
- `subtitle` (String) - Subjudul/deskripsi
- `icon` (IconData?) - Icon yang ditampilkan (optional, default: lock_outline)
- `logoAssetPath` (String?) - Path gambar logo dari assets (optional)
- `logoUrl` (String?) - URL gambar logo dari internet (optional)
- `isDesktop` (bool) - Untuk responsive font size

**Priority Logo:**
1. `logoUrl` - Jika ada, pakai gambar dari URL
2. `logoAssetPath` - Jika logoUrl null, pakai gambar dari assets
3. `icon` - Jika keduanya null, pakai icon

**Notes:**
- Jika URL/Asset gagal load, otomatis fallback ke icon
- Logo akan di-clip menjadi circle
- Support loading indicator untuk URL


---

### 4. **CustomTextField**
Widget untuk input field dengan styling konsisten.

**File:** `custom_text_field.dart`

**Usage:**
```dart
CustomTextField(
  controller: _emailController,
  labelText: 'Email',
  hintText: 'nama@example.com',
  prefixIcon: Icons.email_outlined,
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    return null;
  },
)
```

**Props:**
- `controller` (TextEditingController) - Controller untuk input
- `labelText` (String) - Label field
- `hintText` (String) - Placeholder text
- `prefixIcon` (IconData) - Icon di sebelah kiri
- `keyboardType` (TextInputType?) - Tipe keyboard
- `obscureText` (bool) - Untuk password field (default: false)
- `suffixIcon` (Widget?) - Icon/widget di sebelah kanan
- `validator` (Function?) - Validasi function

---

### 5. **PrimaryButton**
Widget untuk tombol utama dengan loading state.

**File:** `primary_button.dart`

**Usage:**
```dart
PrimaryButton(
  text: 'Masuk',
  onPressed: _handleLogin,
  isLoading: _isLoading,
)
```

**Props:**
- `text` (String) - Text tombol
- `onPressed` (VoidCallback) - Function saat diklik
- `isLoading` (bool) - Menampilkan loading indicator (default: false)

---

### 6. **SocialLoginButton**
Widget untuk tombol social login (Google, Facebook, Apple).

**File:** `social_login_button.dart`

**Usage:**
```dart
SocialLoginButton(
  icon: Icons.g_mobiledata,
  onPressed: () {
    // Handle Google login
  },
)
```

**Props:**
- `icon` (IconData) - Icon social media
- `onPressed` (VoidCallback) - Function saat diklik

---

### 7. **DividerWithText**
Widget untuk divider dengan text di tengah.

**File:** `divider_with_text.dart`

**Usage:**
```dart
DividerWithText(text: 'atau')
```

**Props:**
- `text` (String) - Text yang ditampilkan (default: 'atau')

---

## 🎯 Contoh Penggunaan

### Login Screen
```dart
import '../widgets/auth_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: AuthCard(
          isDesktop: true,
          child: Column(
            children: [
              AuthHeader(
                title: 'Selamat Datang',
                subtitle: 'Masuk ke akun Anda',
              ),
              CustomTextField(...),
              PrimaryButton(...),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Register Screen
```dart
// Sama seperti Login Screen
// Tinggal ganti title, subtitle, dan tambah field yang diperlukan
AuthHeader(
  title: 'Buat Akun',
  subtitle: 'Daftar untuk memulai',
  icon: Icons.person_add_outlined,
)
```

---

## ✨ Keuntungan Menggunakan Widget Pattern

1. ✅ **Reusable** - Widget bisa dipakai di berbagai halaman
2. ✅ **Consistent** - Styling selalu konsisten
3. ✅ **Easy to Maintain** - Edit sekali, berubah di semua tempat
4. ✅ **Clean Code** - Kode lebih rapi dan mudah dibaca
5. ✅ **Scalable** - Mudah menambah fitur baru

---

## 🔄 Update Widget

Jika ingin mengubah style/warna:

1. Edit file widget di `auth/widgets/`
2. Atau edit `AppTheme` di `auth/config/app_theme.dart`
3. Semua halaman yang menggunakan widget akan otomatis update!

---

## 📝 Notes

- Semua widget menggunakan `AppTheme` untuk consistency
- Widget sudah responsive (desktop & mobile)
- Sudah include validasi dan error handling
- Support dark mode ready (tinggal tambah theme config)
