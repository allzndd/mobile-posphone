class ProductBrand {
  final int id;
  final String? merk;
  final String nama;
  final String? slug;
  final int? produkCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductBrand({
    required this.id,
    this.merk,
    required this.nama,
    this.slug,
    this.produkCount,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductBrand.fromJson(Map<String, dynamic> json) {
    return ProductBrand(
      id: json['id'] as int? ?? 0,
      merk: json['merk'] as String?,
      nama: json['nama'] as String? ?? json['merk'] as String? ?? 'Unknown',
      slug: json['slug'] as String?,
      produkCount: json['produk_count'] as int?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merk': merk,
      'nama': nama,
      'slug': slug,
      'produk_count': produkCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ProductBrand{id: $id, merk: $merk, nama: $nama}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductBrand && other.id == id && other.nama == nama && other.merk == merk;
  }

  @override
  int get hashCode => id.hashCode ^ nama.hashCode ^ (merk?.hashCode ?? 0);
}
