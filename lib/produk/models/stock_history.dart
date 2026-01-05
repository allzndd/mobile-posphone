class StockItem {
  final int id;
  final int posProdukId;
  final int posTokoId;
  final int stok;
  final Product? produk;
  final Store? toko;
  final DateTime createdAt;
  final DateTime updatedAt;

  StockItem({
    required this.id,
    required this.posProdukId,
    required this.posTokoId,
    required this.stok,
    this.produk,
    this.toko,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      id: json['id'] ?? 0,
      posProdukId: json['pos_produk_id'] ?? 0,
      posTokoId: json['pos_toko_id'] ?? 0,
      stok: json['stok'] ?? 0,
      produk: json['produk'] != null ? Product.fromJson(json['produk']) : null,
      toko: json['toko'] != null ? Store.fromJson(json['toko']) : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pos_produk_id': posProdukId,
      'pos_toko_id': posTokoId,
      'stok': stok,
      'produk': produk?.toJson(),
      'toko': toko?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isLowStock => stok <= 5;
  bool get isOutOfStock => stok == 0;
  
  String get stockStatus {
    if (isOutOfStock) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    return 'In Stock';
  }

  String get displayName {
    if (produk != null) {
      final brandName = produk!.merk?.nama ?? 'Unknown Brand';
      return '$brandName ${produk!.nama}';
    }
    return 'Unknown Product';
  }
}

class Product {
  final int id;
  final String nama;
  final String? deskripsi;
  final String? warna;
  final String? penyimpanan;
  final double hargaBeli;
  final double hargaJual;
  final String? imei;
  final String? aksesoris;
  final ProductBrand? merk;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.nama,
    this.deskripsi,
    this.warna,
    this.penyimpanan,
    required this.hargaBeli,
    required this.hargaJual,
    this.imei,
    this.aksesoris,
    this.merk,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'],
      warna: json['warna'],
      penyimpanan: json['penyimpanan'],
      hargaBeli: double.tryParse(json['harga_beli']?.toString() ?? '0') ?? 0.0,
      hargaJual: double.tryParse(json['harga_jual']?.toString() ?? '0') ?? 0.0,
      imei: json['imei'],
      aksesoris: json['aksesoris'],
      merk: json['merk'] != null ? ProductBrand.fromJson(json['merk']) : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'warna': warna,
      'penyimpanan': penyimpanan,
      'harga_beli': hargaBeli,
      'harga_jual': hargaJual,
      'imei': imei,
      'aksesoris': aksesoris,
      'merk': merk?.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get formattedHargaJual {
    return 'Rp ${hargaJual.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  String get specs {
    List<String> specParts = [];
    if (warna != null) specParts.add(warna!);
    if (penyimpanan != null) specParts.add('${penyimpanan}GB');
    return specParts.join(' • ');
  }
}

class ProductBrand {
  final int id;
  final String nama;
  final String? slug;

  ProductBrand({
    required this.id,
    required this.nama,
    this.slug,
  });

  factory ProductBrand.fromJson(Map<String, dynamic> json) {
    return ProductBrand(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      slug: json['slug'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'slug': slug,
    };
  }
}

class Store {
  final int id;
  final String nama;
  final String? alamat;
  final String? telepon;

  Store({
    required this.id,
    required this.nama,
    this.alamat,
    this.telepon,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      alamat: json['alamat'],
      telepon: json['telepon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'alamat': alamat,
      'telepon': telepon,
    };
  }
}

class StockLog {
  final int id;
  final int posProdukId;
  final int posTokoId;
  final int stokSebelum;
  final int stokSesudah;
  final int perubahan;
  final String tipe;
  final String? referensi;
  final String? keterangan;
  final Product? produk;
  final Store? toko;
  final DateTime createdAt;

  StockLog({
    required this.id,
    required this.posProdukId,
    required this.posTokoId,
    required this.stokSebelum,
    required this.stokSesudah,
    required this.perubahan,
    required this.tipe,
    this.referensi,
    this.keterangan,
    this.produk,
    this.toko,
    required this.createdAt,
  });

  factory StockLog.fromJson(Map<String, dynamic> json) {
    return StockLog(
      id: json['id'] ?? 0,
      posProdukId: json['pos_produk_id'] ?? 0,
      posTokoId: json['pos_toko_id'] ?? 0,
      stokSebelum: json['stok_sebelum'] ?? 0,
      stokSesudah: json['stok_sesudah'] ?? 0,
      perubahan: json['perubahan'] ?? 0,
      tipe: json['tipe'] ?? '',
      referensi: json['referensi'],
      keterangan: json['keterangan'],
      produk: json['produk'] != null ? Product.fromJson(json['produk']) : null,
      toko: json['toko'] != null ? Store.fromJson(json['toko']) : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pos_produk_id': posProdukId,
      'pos_toko_id': posTokoId,
      'stok_sebelum': stokSebelum,
      'stok_sesudah': stokSesudah,
      'perubahan': perubahan,
      'tipe': tipe,
      'referensi': referensi,
      'keterangan': keterangan,
      'produk': produk?.toJson(),
      'toko': toko?.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isIncrease => perubahan > 0;
  bool get isDecrease => perubahan < 0;

  String get changeDescription {
    if (isIncrease) {
      return '+$perubahan';
    } else if (isDecrease) {
      return '$perubahan';
    }
    return '0';
  }

  String get tipeDescription {
    switch (tipe) {
      case 'masuk':
        return 'Stock In';
      case 'keluar':
        return 'Stock Out';
      case 'adjustment':
        return 'Adjustment';
      default:
        return tipe;
    }
  }
}

class StockSummary {
  final int totalProducts;
  final int totalStock;
  final int lowStockProducts;
  final int outOfStock;

  StockSummary({
    required this.totalProducts,
    required this.totalStock,
    required this.lowStockProducts,
    required this.outOfStock,
  });

  factory StockSummary.fromJson(Map<String, dynamic> json) {
    return StockSummary(
      totalProducts: json['total_products'] ?? 0,
      totalStock: json['total_stock'] ?? 0,
      lowStockProducts: json['low_stock_products'] ?? 0,
      outOfStock: json['out_of_stock'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_products': totalProducts,
      'total_stock': totalStock,
      'low_stock_products': lowStockProducts,
      'out_of_stock': outOfStock,
    };
  }

  double get stockHealthPercentage {
    if (totalProducts == 0) return 0;
    final healthyProducts = totalProducts - lowStockProducts - outOfStock;
    return (healthyProducts / totalProducts) * 100;
  }
}