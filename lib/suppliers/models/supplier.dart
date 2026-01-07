class Supplier {
  final int id;
  final int? ownerId;
  final String nama;
  final String? slug;
  final String? nomorHp;
  final String? email;
  final String? alamat;
  final String? keterangan;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Supplier({
    required this.id,
    this.ownerId,
    required this.nama,
    this.slug,
    this.nomorHp,
    this.email,
    this.alamat,
    this.keterangan,
    required this.createdAt,
    this.updatedAt,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] ?? 0,
      ownerId: json['owner_id'],
      nama: json['nama'] ?? '',
      slug: json['slug'],
      nomorHp: json['nomor_hp'],
      email: json['email'],
      alamat: json['alamat'],
      keterangan: json['keterangan'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'nama': nama,
      'slug': slug,
      'nomor_hp': nomorHp,
      'email': email,
      'alamat': alamat,
      'keterangan': keterangan,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Supplier copyWith({
    int? id,
    int? ownerId,
    String? nama,
    String? slug,
    String? nomorHp,
    String? email,
    String? alamat,
    String? keterangan,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Supplier(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      nama: nama ?? this.nama,
      slug: slug ?? this.slug,
      nomorHp: nomorHp ?? this.nomorHp,
      email: email ?? this.email,
      alamat: alamat ?? this.alamat,
      keterangan: keterangan ?? this.keterangan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Supplier(id: $id, ownerId: $ownerId, nama: $nama, nomorHp: $nomorHp, email: $email, alamat: $alamat)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Supplier && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
