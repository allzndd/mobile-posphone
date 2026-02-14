class PosWarnaModel {
  final int id;
  final int? idOwner;
  final String warna;
  final bool isGlobal;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PosWarnaModel({
    required this.id,
    this.idOwner,
    required this.warna,
    required this.isGlobal,
    this.createdAt,
    this.updatedAt,
  });

  factory PosWarnaModel.fromJson(Map<String, dynamic> json) {
    return PosWarnaModel(
      id: json['id'] ?? 0,
      idOwner: json['id_owner'],
      warna: json['warna'] ?? '',
      isGlobal: json['is_global'] == 1 || json['is_global'] == true,
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
      'warna': warna,
      'is_global': isGlobal ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

// Keep backward compatibility alias
typedef Color = PosWarnaModel;
