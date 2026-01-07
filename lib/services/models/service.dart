class Service {
  final int? id;
  final String nama;
  final String? keterangan;
  final double harga;
  final int durasi;
  final int posTokoId;
  final String? tokoNama;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Service({
    this.id,
    required this.nama,
    this.keterangan,
    required this.harga,
    required this.durasi,
    required this.posTokoId,
    this.tokoNama,
    this.createdAt,
    this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      nama: json['nama'] ?? '',
      keterangan: json['keterangan'],
      harga: double.tryParse(json['harga'].toString()) ?? 0.0,
      durasi: int.tryParse(json['durasi'].toString()) ?? 0,
      posTokoId: json['pos_toko_id'] ?? 0,
      tokoNama: json['toko']?['nama'],
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'keterangan': keterangan,
      'harga': harga,
      'durasi': durasi,
      'pos_toko_id': posTokoId,
    };
  }

  Service copyWith({
    int? id,
    String? nama,
    String? keterangan,
    double? harga,
    int? durasi,
    int? posTokoId,
    String? tokoNama,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Service(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      keterangan: keterangan ?? this.keterangan,
      harga: harga ?? this.harga,
      durasi: durasi ?? this.durasi,
      posTokoId: posTokoId ?? this.posTokoId,
      tokoNama: tokoNama ?? this.tokoNama,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
