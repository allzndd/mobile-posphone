class UserModel {
  final int id;
  final String nama;
  final String email;
  final int roleId;
  final bool isOwner;
  final bool isPosUser;
  final int ownerId;
  final int? tokoId;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.roleId,
    this.isOwner = false,
    this.isPosUser = false,
    required this.ownerId,
    this.tokoId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      roleId: json['role_id'] ?? 0,
      isOwner: json['is_owner'] ?? false,
      isPosUser: json['is_pos_user'] ?? false,
      ownerId: json['owner_id'] ?? 0,
      tokoId: json['toko_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'role_id': roleId,
      'is_owner': isOwner,
      'is_pos_user': isPosUser,
      'owner_id': ownerId,
      'toko_id': tokoId,
    };
  }
}

class LoginResponse {
  final bool success;
  final String message;
  final UserModel user;
  final String token;
  final String tokenType;

  LoginResponse({
    required this.success,
    required this.message,
    required this.user,
    required this.token,
    required this.tokenType,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: UserModel.fromJson(json['data']['user']),
      token: json['data']['token'] ?? '',
      tokenType: json['data']['token_type'] ?? 'Bearer',
    );
  }
}
