class StoreModel {
  final int id;
  final String namaToko;
  final String? alamat;
  final String? telepon;
  final int? ownerId;
  final String? createdAt;
  final String? updatedAt;

  StoreModel({
    required this.id,
    required this.namaToko,
    this.alamat,
    this.telepon,
    this.ownerId,
    this.createdAt,
    this.updatedAt,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] ?? 0,
      namaToko: json['nama_toko'] ?? json['nama'] ?? '',
      alamat: json['alamat'],
      telepon: json['telepon'],
      ownerId: json['owner_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_toko': namaToko,
      'alamat': alamat,
      'telepon': telepon,
      'owner_id': ownerId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
