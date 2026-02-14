class PosRamModel {
  final int id;
  final int? idOwner;
  final int? posProdukId;
  final String kapasitas;
  final bool isGlobal;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PosRamModel({
    required this.id,
    this.idOwner,
    this.posProdukId,
    required this.kapasitas,
    required this.isGlobal,
    this.createdAt,
    this.updatedAt,
  });

  factory PosRamModel.fromJson(Map<String, dynamic> json) {
    return PosRamModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      idOwner: json['id_owner'] != null 
          ? (json['id_owner'] is int ? json['id_owner'] : int.tryParse(json['id_owner'].toString()))
          : null,
      posProdukId: json['pos_produk_id'] != null
          ? (json['pos_produk_id'] is int ? json['pos_produk_id'] : int.tryParse(json['pos_produk_id'].toString()))
          : null,
      kapasitas: json['kapasitas']?.toString() ?? '',
      isGlobal: json['is_global'] == 1 || json['is_global'] == true || json['is_global'] == '1',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_owner': idOwner,
      'pos_produk_id': posProdukId,
      'kapasitas': kapasitas,
      'is_global': isGlobal ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

// Keep backward compatibility alias
typedef Ram = PosRamModel;
