class AdminUserModel {
  final int id;
  final String nama;
  final String email;
  final int roleId;
  final int? storeId;
  final String? storeName;
  final String createdAt;
  final String updatedAt;

  AdminUserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.roleId,
    this.storeId,
    this.storeName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      roleId: json['role_id'] ?? 3,
      storeId: json['store_id'],
      storeName: json['store_name'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'role_id': roleId,
      'store_id': storeId,
      'store_name': storeName,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
