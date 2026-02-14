class Storage {
  final int id;
  final int idOwner;
  final int? posProdukId;
  final String kapasitas;
  final String? idGlobal;
  final DateTime createdAt;
  final DateTime updatedAt;

  Storage({
    required this.id,
    required this.idOwner,
    this.posProdukId,
    required this.kapasitas,
    this.idGlobal,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Storage.fromJson(Map<String, dynamic> json) {
    return Storage(
      id: (json['id'] as int?) ?? 0,
      idOwner: (json['id_owner'] as int?) ?? 0,
      posProdukId: json['pos_produk_id'] as int?,
      kapasitas: (json['kapasitas'] ?? '').toString(),
      idGlobal: json['id_global'] != null ? json['id_global'].toString() : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_owner': idOwner,
      'pos_produk_id': posProdukId,
      'kapasitas': kapasitas,
      'id_global': idGlobal,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Storage copyWith({
    int? id,
    int? idOwner,
    int? posProdukId,
    String? kapasitas,
    String? idGlobal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Storage(
      id: id ?? this.id,
      idOwner: idOwner ?? this.idOwner,
      posProdukId: posProdukId ?? this.posProdukId,
      kapasitas: kapasitas ?? this.kapasitas,
      idGlobal: idGlobal ?? this.idGlobal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
