class PosExpenseTransactionModel {
  final int id;
  final int? ownerId;
  final int? posTokoId;
  final int? posPelangganId;
  final int? posTukarTambahId;
  final int? posSupplierId;
  final int? posKategoriExpenseId;
  final int isTransaksiMasuk;
  final String? invoice;
  final double totalHarga;
  final String? keterangan;
  final String? status;
  final String? metodePembayaran;
  final String? paymentStatus;
  final double? paidAmount;
  final DateTime? dueDate;
  final String? paymentTerms;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Related data
  final String? kategoriExpenseName;
  final String? tokoName;

  PosExpenseTransactionModel({
    required this.id,
    this.ownerId,
    this.posTokoId,
    this.posPelangganId,
    this.posTukarTambahId,
    this.posSupplierId,
    this.posKategoriExpenseId,
    required this.isTransaksiMasuk,
    this.invoice,
    required this.totalHarga,
    this.keterangan,
    this.status,
    this.metodePembayaran,
    this.paymentStatus,
    this.paidAmount,
    this.dueDate,
    this.paymentTerms,
    this.createdAt,
    this.updatedAt,
    this.kategoriExpenseName,
    this.tokoName,
  });

  factory PosExpenseTransactionModel.fromJson(Map<String, dynamic> json) {
    return PosExpenseTransactionModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      ownerId: json['owner_id'] != null 
          ? (json['owner_id'] is int ? json['owner_id'] : int.tryParse(json['owner_id'].toString()))
          : null,
      posTokoId: json['pos_toko_id'] != null
          ? (json['pos_toko_id'] is int ? json['pos_toko_id'] : int.tryParse(json['pos_toko_id'].toString()))
          : null,
      posPelangganId: json['pos_pelanggan_id'] != null
          ? (json['pos_pelanggan_id'] is int ? json['pos_pelanggan_id'] : int.tryParse(json['pos_pelanggan_id'].toString()))
          : null,
      posTukarTambahId: json['pos_tukar_tambah_id'] != null
          ? (json['pos_tukar_tambah_id'] is int ? json['pos_tukar_tambah_id'] : int.tryParse(json['pos_tukar_tambah_id'].toString()))
          : null,
      posSupplierId: json['pos_supplier_id'] != null
          ? (json['pos_supplier_id'] is int ? json['pos_supplier_id'] : int.tryParse(json['pos_supplier_id'].toString()))
          : null,
      posKategoriExpenseId: json['pos_kategori_expense_id'] != null
          ? (json['pos_kategori_expense_id'] is int ? json['pos_kategori_expense_id'] : int.tryParse(json['pos_kategori_expense_id'].toString()))
          : null,
      isTransaksiMasuk: json['is_transaksi_masuk'] is int 
          ? json['is_transaksi_masuk'] 
          : int.tryParse(json['is_transaksi_masuk'].toString()) ?? 0,
      invoice: json['invoice']?.toString(),
      totalHarga: json['total_harga'] is double 
          ? json['total_harga']
          : double.tryParse(json['total_harga'].toString()) ?? 0.0,
      keterangan: json['keterangan']?.toString(),
      status: json['status']?.toString(),
      metodePembayaran: json['metode_pembayaran']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      paidAmount: json['paid_amount'] != null
          ? (json['paid_amount'] is double 
              ? json['paid_amount']
              : double.tryParse(json['paid_amount'].toString()))
          : null,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : null,
      paymentTerms: json['payment_terms']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      kategoriExpenseName: json['kategori_expense_name']?.toString(),
      tokoName: json['toko_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'pos_toko_id': posTokoId,
      'pos_pelanggan_id': posPelangganId,
      'pos_tukar_tambah_id': posTukarTambahId,
      'pos_supplier_id': posSupplierId,
      'pos_kategori_expense_id': posKategoriExpenseId,
      'is_transaksi_masuk': isTransaksiMasuk,
      'invoice': invoice,
      'total_harga': totalHarga,
      'keterangan': keterangan,
      'status': status,
      'metode_pembayaran': metodePembayaran,
      'payment_status': paymentStatus,
      'paid_amount': paidAmount,
      'due_date': dueDate?.toIso8601String(),
      'payment_terms': paymentTerms,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

// Keep backward compatibility alias
typedef ExpenseTransaction = PosExpenseTransactionModel;
