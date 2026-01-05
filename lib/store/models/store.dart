class Store {
  final int id;
  final int? ownerId;
  final String nama;
  final String? slug;
  final String? alamat;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Store({
    required this.id,
    this.ownerId,
    required this.nama,
    this.slug,
    this.alamat,
    required this.createdAt,
    this.updatedAt,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] ?? 0,
      ownerId: json['owner_id'],
      nama: json['nama'] ?? '',
      slug: json['slug'],
      alamat: json['alamat'],
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
      'alamat': alamat,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Store copyWith({
    int? id,
    int? ownerId,
    String? nama,
    String? slug,
    String? alamat,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Store(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      nama: nama ?? this.nama,
      slug: slug ?? this.slug,
      alamat: alamat ?? this.alamat,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Store(id: $id, ownerId: $ownerId, nama: $nama, alamat: $alamat)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Store && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
