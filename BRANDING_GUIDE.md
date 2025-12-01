# Branding Configuration Guide

## Overview
Sistem branding di aplikasi POS Phone memungkinkan setiap buyer untuk mengkustomisasi nama aplikasi dan tagline mereka sendiri melalui admin panel Laravel.

## Fitur Branding

### 1. App Name (Nama Aplikasi)
- **Default**: "POS Phone"
- **Customizable**: Ya
- **Digunakan di**: 
  - Login screen header
  - Register screen header
  - Sidebar aplikasi
  - App title

### 2. App Tagline
- **Default**: "Sistem Point of Sale Counter HP"
- **Customizable**: Ya
- **Digunakan di**:
  - Login screen subtitle
  - About page

### 3. Logo
- **Default**: Icon store
- **Customizable**: Ya (URL-based)
- **Format**: PNG, JPG, SVG
- **Digunakan di**:
  - Login screen
  - Register screen
  - Sidebar
  - Dashboard header

## Laravel Backend Setup

### 1. Database Migration

```php
// database/migrations/xxxx_create_branding_configs_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('branding_configs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('app_name')->default('POS Phone');
            $table->string('app_tagline')->default('Sistem Point of Sale Counter HP');
            $table->string('logo_url')->nullable();
            $table->string('primary_dark')->default('#1E3A8A');
            $table->string('primary_main')->default('#3B82F6');
            $table->string('primary_light')->default('#93C5FD');
            $table->string('background_image_url')->nullable();
            $table->boolean('use_background_image')->default(false);
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('branding_configs');
    }
};
```

### 2. Model

```php
// app/Models/BrandingConfig.php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BrandingConfig extends Model
{
    protected $fillable = [
        'user_id',
        'app_name',
        'app_tagline',
        'logo_url',
        'primary_dark',
        'primary_main',
        'primary_light',
        'background_image_url',
        'use_background_image',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
```

### 3. Controller

```php
// app/Http/Controllers/Api/BrandingConfigController.php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\BrandingConfig;
use Illuminate\Http\Request;

class BrandingConfigController extends Controller
{
    /**
     * Get branding configuration for current user
     */
    public function show(Request $request)
    {
        $userId = $request->user()->id ?? 1; // Default user for testing
        
        $config = BrandingConfig::where('user_id', $userId)->first();
        
        if (!$config) {
            // Return default configuration
            return response()->json([
                'app_name' => 'POS Phone',
                'app_tagline' => 'Sistem Point of Sale Counter HP',
                'logo_url' => null,
                'primary_dark' => '#1E3A8A',
                'primary_main' => '#3B82F6',
                'primary_light' => '#93C5FD',
                'background_image_url' => null,
                'use_background_image' => false,
            ]);
        }
        
        return response()->json([
            'app_name' => $config->app_name,
            'app_tagline' => $config->app_tagline,
            'logo_url' => $config->logo_url,
            'primary_dark' => $config->primary_dark,
            'primary_main' => $config->primary_main,
            'primary_light' => $config->primary_light,
            'background_image_url' => $config->background_image_url,
            'use_background_image' => $config->use_background_image,
        ]);
    }

    /**
     * Update branding configuration
     */
    public function update(Request $request)
    {
        $validated = $request->validate([
            'app_name' => 'required|string|max:255',
            'app_tagline' => 'required|string|max:255',
            'logo_url' => 'nullable|url',
            'primary_dark' => 'required|string|regex:/^#[0-9A-F]{6}$/i',
            'primary_main' => 'required|string|regex:/^#[0-9A-F]{6}$/i',
            'primary_light' => 'required|string|regex:/^#[0-9A-F]{6}$/i',
            'background_image_url' => 'nullable|url',
            'use_background_image' => 'boolean',
        ]);

        $config = BrandingConfig::updateOrCreate(
            ['user_id' => $request->user()->id],
            $validated
        );

        return response()->json([
            'message' => 'Branding configuration updated successfully',
            'data' => $config,
        ]);
    }
}
```

### 4. Routes

```php
// routes/api.php
use App\Http\Controllers\Api\BrandingConfigController;

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/branding-config', [BrandingConfigController::class, 'show']);
    Route::put('/branding-config', [BrandingConfigController::class, 'update']);
});

// Public route for login screen (before authentication)
Route::get('/branding-config/public', [BrandingConfigController::class, 'show']);
```

### 5. Admin Panel Form

```blade
<!-- resources/views/admin/branding/edit.blade.php -->
<form action="{{ route('admin.branding.update') }}" method="POST" enctype="multipart/form-data">
    @csrf
    @method('PUT')
    
    <div class="form-group">
        <label>Nama Aplikasi</label>
        <input type="text" name="app_name" class="form-control" 
               value="{{ $config->app_name ?? 'POS Phone' }}" required>
    </div>
    
    <div class="form-group">
        <label>Tagline</label>
        <input type="text" name="app_tagline" class="form-control" 
               value="{{ $config->app_tagline ?? 'Sistem Point of Sale Counter HP' }}" required>
    </div>
    
    <div class="form-group">
        <label>Logo (Upload)</label>
        <input type="file" name="logo" class="form-control" accept="image/*">
        @if($config->logo_url)
            <img src="{{ $config->logo_url }}" width="100" class="mt-2">
        @endif
    </div>
    
    <div class="row">
        <div class="col-md-4">
            <div class="form-group">
                <label>Primary Dark Color</label>
                <input type="color" name="primary_dark" class="form-control" 
                       value="{{ $config->primary_dark ?? '#1E3A8A' }}">
            </div>
        </div>
        <div class="col-md-4">
            <div class="form-group">
                <label>Primary Main Color</label>
                <input type="color" name="primary_main" class="form-control" 
                       value="{{ $config->primary_main ?? '#3B82F6' }}">
            </div>
        </div>
        <div class="col-md-4">
            <div class="form-group">
                <label>Primary Light Color</label>
                <input type="color" name="primary_light" class="form-control" 
                       value="{{ $config->primary_light ?? '#93C5FD' }}">
            </div>
        </div>
    </div>
    
    <button type="submit" class="btn btn-primary">Simpan Perubahan</button>
</form>
```

## Flutter Implementation

### 1. File Structure
```
lib/
├── auth/
│   ├── models/
│   │   └── theme_config.dart          # Model untuk branding config
│   ├── providers/
│   │   └── branding_provider.dart     # State management branding
│   └── services/
│       └── theme_service.dart         # API service untuk fetch config
```

### 2. Usage di Screens

```dart
// Login Screen
final branding = context.watch<BrandingProvider>();

AuthHeader(
  title: branding.appName,           // Dynamic dari API
  subtitle: branding.appTagline,     // Dynamic dari API
  logoUrl: branding.logoUrl,         // Dynamic dari API
  isDesktop: isDesktop,
)
```

### 3. API Configuration

Update `theme_service.dart` dengan URL Laravel API Anda:

```dart
class ThemeService {
  static const String baseUrl = 'https://your-laravel-api.com';
  
  static Future<ThemeConfig> fetchThemeConfig() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/branding-config/public'),
    );
    // ... rest of code
  }
}
```

## Testing

### 1. Test dengan Data Default
Aplikasi akan menggunakan default values jika API tidak tersedia:
- App Name: "POS Phone"
- Tagline: "Sistem Point of Sale Counter HP"

### 2. Test dengan Custom Data
Setelah buyer update branding di admin panel Laravel, aplikasi akan otomatis load data custom saat dibuka.

## Customization Examples

### Contoh 1: Toko HP Jaya
```json
{
  "app_name": "Toko HP Jaya",
  "app_tagline": "Solusi Terbaik Gadget Anda",
  "logo_url": "https://example.com/logos/toko-hp-jaya.png"
}
```

### Contoh 2: Counter Gadget 88
```json
{
  "app_name": "Counter Gadget 88",
  "app_tagline": "Pusat Smartphone Terlengkap",
  "logo_url": "https://example.com/logos/counter-88.png"
}
```

## Notes
- Logo harus di-upload ke storage Laravel dan return URL yang bisa diakses public
- Pastikan CORS di Laravel sudah di-configure untuk Flutter app
- Branding config di-load saat pertama kali buka login screen
- Jika API gagal, akan fallback ke default branding
