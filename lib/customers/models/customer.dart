class Customer {
  final int? id;
  final int? ownerId;
  final String nama;
  final String? slug;
  final String? nomorHp;
  final String? email;
  final String? alamat;
  final DateTime? tanggalBergabung;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Statistics - calculated fields
  final int? totalTransaksi;
  final double? totalNilaiTransaksi;

  Customer({
    this.id,
    this.ownerId,
    required this.nama,
    this.slug,
    this.nomorHp,
    this.email,
    this.alamat,
    this.tanggalBergabung,
    this.createdAt,
    this.updatedAt,
    this.totalTransaksi,
    this.totalNilaiTransaksi,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      ownerId: json['owner_id'],
      nama: json['nama'] ?? '',
      slug: json['slug'],
      nomorHp: json['nomor_hp'],
      email: json['email'],
      alamat: json['alamat'],
      tanggalBergabung: json['tanggal_bergabung'] != null
          ? DateTime.parse(json['tanggal_bergabung'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      totalTransaksi: json['transaksi_count'] ?? json['total_transaksi'],
      totalNilaiTransaksi: json['transaksi_sum_total_harga'] != null 
          ? double.tryParse(json['transaksi_sum_total_harga'].toString())
          : json['total_nilai_transaksi'] != null 
              ? double.tryParse(json['total_nilai_transaksi'].toString())
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
      'tanggal_bergabung': tanggalBergabung?.toIso8601String().split('T')[0],
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'nama': nama,
      'nomor_hp': nomorHp,
      'email': email,
      'alamat': alamat,
      'tanggal_bergabung': tanggalBergabung?.toIso8601String().split('T')[0],
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'nama': nama,
      'nomor_hp': nomorHp,
      'email': email,
      'alamat': alamat,
      'tanggal_bergabung': tanggalBergabung?.toIso8601String().split('T')[0],
    };
  }

  Customer copyWith({
    int? id,
    int? ownerId,
    String? nama,
    String? slug,
    String? nomorHp,
    String? email,
    String? alamat,
    DateTime? tanggalBergabung,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalTransaksi,
    double? totalNilaiTransaksi,
  }) {
    return Customer(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      nama: nama ?? this.nama,
      slug: slug ?? this.slug,
      nomorHp: nomorHp ?? this.nomorHp,
      email: email ?? this.email,
      alamat: alamat ?? this.alamat,
      tanggalBergabung: tanggalBergabung ?? this.tanggalBergabung,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalTransaksi: totalTransaksi ?? this.totalTransaksi,
      totalNilaiTransaksi: totalNilaiTransaksi ?? this.totalNilaiTransaksi,
    );
  }

  @override
  String toString() {
    return 'Customer{id: $id, nama: $nama, nomorHp: $nomorHp, email: $email}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Customer &&
        other.id == id &&
        other.nama == nama &&
        other.email == email;
  }

  @override
  int get hashCode {
    return Object.hash(id, nama, email);
  }
}

// Response models for API
class CustomerResponse {
  final bool success;
  final String message;
  final Customer? data;
  final List<Customer>? customers;
  final CustomerPagination? pagination;

  CustomerResponse({
    required this.success,
    required this.message,
    this.data,
    this.customers,
    this.pagination,
  });

  factory CustomerResponse.fromJson(Map<String, dynamic> json) {
    return CustomerResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? Customer.fromJson(json['data'])
          : null,
      customers: json['data'] is List
          ? (json['data'] as List).map((e) => Customer.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      pagination: json['pagination'] != null
          ? CustomerPagination.fromJson(json['pagination'])
          : null,
    );
  }
}

class CustomerPagination {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  CustomerPagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory CustomerPagination.fromJson(Map<String, dynamic> json) {
    return CustomerPagination(
      currentPage: json['current_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
      lastPage: json['last_page'] ?? 1,
    );
  }
}

// Statistics model
class CustomerStats {
  final int totalCustomers;
  final int newThisMonth;
  final double avgTransactionValue;
  final int totalTransactions;

  CustomerStats({
    required this.totalCustomers,
    required this.newThisMonth,
    required this.avgTransactionValue,
    required this.totalTransactions,
  });

  factory CustomerStats.fromJson(Map<String, dynamic> json) {
    return CustomerStats(
      totalCustomers: json['total_customers'] ?? 0,
      newThisMonth: json['new_this_month'] ?? 0,
      avgTransactionValue: double.tryParse(json['avg_transaction_value'].toString()) ?? 0.0,
      totalTransactions: json['total_transactions'] ?? 0,
    );
  }
}
