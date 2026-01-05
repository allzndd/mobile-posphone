import 'product_brand.dart';
import 'stock_management.dart';

class Product {
  final int id;
  final int ownerId;
  final int posProdukMerkId;
  final String nama;
  final String slug;
  final String? deskripsi;
  final String? warna;
  final String? penyimpanan;
  final String? batteryHealth;
  final int hargaBeli;
  final int hargaJual;
  final Map<String, dynamic>? biayaTambahan;
  final String? imei;
  final String? aksesoris;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Relations
  final ProductBrand? merk;
  final List<ProdukStok>? stok;
  final int? totalStok;

  Product({
    required this.id,
    required this.ownerId,
    required this.posProdukMerkId,
    required this.nama,
    required this.slug,
    this.deskripsi,
    this.warna,
    this.penyimpanan,
    this.batteryHealth,
    required this.hargaBeli,
    required this.hargaJual,
    this.biayaTambahan,
    this.imei,
    this.aksesoris,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.merk,
    this.stok,
    this.totalStok,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int? ?? 0,
      ownerId: json['owner_id'] as int? ?? 0,
      posProdukMerkId: json['pos_produk_merk_id'] as int? ?? 0,
      nama: _generateProductName(json),
      slug: json['slug'] as String? ?? '',
      deskripsi: json['deskripsi'] as String?,
      warna: json['warna'] as String?,
      penyimpanan: json['penyimpanan']?.toString(),
      batteryHealth: json['battery_health']?.toString(),
      hargaBeli: _safeParseInt(json['harga_beli']) ?? 0,
      hargaJual: _safeParseInt(json['harga_jual']) ?? 0,
      biayaTambahan: json['biaya_tambahan'] as Map<String, dynamic>?,
      imei: json['imei'] as String?,
      aksesoris: json['aksesoris'] as String?,
      status: json['status'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      merk: json['merk'] != null ? ProductBrand.fromJson(json['merk']) : null,
      stok:
          json['stok'] != null
              ? (json['stok'] as List)
                  .map((e) => ProdukStok.fromJson(e))
                  .toList()
              : null,
      totalStok: _safeParseInt(json['total_stok']) ?? 0,
    );
  }

  static String _generateProductName(Map<String, dynamic> json) {
    // If nama is available and not null, use it
    if (json['nama'] != null && (json['nama'] as String).isNotEmpty) {
      return json['nama'] as String;
    }

    // Generate name from available data
    List<String> nameParts = [];

    // Add brand name
    if (json['merk'] != null && json['merk']['nama'] != null) {
      nameParts.add(json['merk']['nama'] as String);
    }

    // Add color
    if (json['warna'] != null && (json['warna'] as String).isNotEmpty) {
      nameParts.add(json['warna'] as String);
    }

    // Add storage
    if (json['penyimpanan'] != null &&
        json['penyimpanan'].toString().isNotEmpty) {
      nameParts.add('${json['penyimpanan']}GB');
    }

    // If we have parts, join them, otherwise use fallback
    return nameParts.isNotEmpty ? nameParts.join(' ') : 'Unknown Product';
  }

  static int? _safeParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      // Try to parse as double first, then convert to int
      final doubleValue = double.tryParse(value);
      return doubleValue?.toInt();
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'pos_produk_merk_id': posProdukMerkId,
      'nama': nama,
      'slug': slug,
      'deskripsi': deskripsi,
      'warna': warna,
      'penyimpanan': penyimpanan,
      'battery_health': batteryHealth,
      'harga_beli': hargaBeli,
      'harga_jual': hargaJual,
      'biaya_tambahan': biayaTambahan,
      'imei': imei,
      'aksesoris': aksesoris,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'merk': merk?.toJson(),
      'stok': stok?.map((e) => e.toJson()).toList(),
      'total_stok': totalStok,
    };
  }

  // Helper methods
  String get formattedHargaJual {
    return 'Rp ${hargaJual.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]}.')}';
  }

  String get formattedHargaBeli {
    return 'Rp ${hargaBeli.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]}.')}';
  }

  bool get isAvailable => (totalStok ?? 0) > 0;

  String get stockStatus {
    final stock = totalStok ?? 0;
    if (stock == 0) return 'Out of Stock';
    if (stock <= 5) return 'Low Stock';
    return 'Available';
  }

  @override
  String toString() {
    return 'Product{id: $id, nama: $nama, totalStok: $totalStok}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
