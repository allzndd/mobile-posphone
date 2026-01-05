class ProdukStok {
  final int id;
  final int posTokoId;
  final int posProdukId;
  final int stok;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? toko;

  ProdukStok({
    required this.id,
    required this.posTokoId,
    required this.posProdukId,
    required this.stok,
    this.createdAt,
    this.updatedAt,
    this.toko,
  });

  factory ProdukStok.fromJson(Map<String, dynamic> json) {
    return ProdukStok(
      id: json['id'] as int? ?? 0,
      posTokoId: json['pos_toko_id'] as int? ?? 0,
      posProdukId: json['pos_produk_id'] as int? ?? 0,
      stok: json['stok'] as int? ?? 0,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      toko: json['toko'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pos_toko_id': posTokoId,
      'pos_produk_id': posProdukId,
      'stok': stok,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'toko': toko,
    };
  }
}
