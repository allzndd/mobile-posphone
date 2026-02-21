class HistoryTransaction {
  final int? id;
  final int? ownerId;
  final int? posTokoId;
  final int? posPelangganId;
  final int? posTukarTambahId;
  final int? posSupplierId;
  final int? isTransaksiMasuk;
  final String? invoice;
  final double? totalHarga;
  final String? keterangan;
  final String? status;
  final String? metodePembayaran;
  final String? createdAt;
  final String? updatedAt;

  // Relations
  final Store? toko;
  final Customer? pelanggan;
  final Supplier? supplier;
  final TradeIn? tukarTambah;
  final List<TransactionItem>? items;

  HistoryTransaction({
    this.id,
    this.ownerId,
    this.posTokoId,
    this.posPelangganId,
    this.posTukarTambahId,
    this.posSupplierId,
    this.isTransaksiMasuk,
    this.invoice,
    this.totalHarga,
    this.keterangan,
    this.status,
    this.metodePembayaran,
    this.createdAt,
    this.updatedAt,
    this.toko,
    this.pelanggan,
    this.supplier,
    this.tukarTambah,
    this.items,
  });

  factory HistoryTransaction.fromJson(Map<String, dynamic> json) {
    return HistoryTransaction(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'],
      ownerId: json['owner_id'] is String ? int.tryParse(json['owner_id']) : json['owner_id'],
      posTokoId: json['pos_toko_id'] is String ? int.tryParse(json['pos_toko_id']) : json['pos_toko_id'],
      posPelangganId: json['pos_pelanggan_id'] is String ? int.tryParse(json['pos_pelanggan_id']) : json['pos_pelanggan_id'],
      posTukarTambahId: json['pos_tukar_tambah_id'] is String ? int.tryParse(json['pos_tukar_tambah_id']) : json['pos_tukar_tambah_id'],
      posSupplierId: json['pos_supplier_id'] is String ? int.tryParse(json['pos_supplier_id']) : json['pos_supplier_id'],
      isTransaksiMasuk: json['is_transaksi_masuk'] is String ? int.tryParse(json['is_transaksi_masuk']) : json['is_transaksi_masuk'],
      invoice: json['invoice'],
      totalHarga: json['total_harga'] != null
          ? double.parse(json['total_harga'].toString())
          : null,
      keterangan: json['keterangan'],
      status: json['status'],
      metodePembayaran: json['metode_pembayaran'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      toko: json['toko'] != null ? Store.fromJson(json['toko']) : null,
      pelanggan: json['pelanggan'] != null
          ? Customer.fromJson(json['pelanggan'])
          : null,
      supplier: json['supplier'] != null
          ? Supplier.fromJson(json['supplier'])
          : null,
      tukarTambah: json['tukar_tambah'] != null
          ? TradeIn.fromJson(json['tukar_tambah'])
          : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => TransactionItem.fromJson(item))
              .toList()
          : null,
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
      'is_transaksi_masuk': isTransaksiMasuk,
      'invoice': invoice,
      'total_harga': totalHarga,
      'keterangan': keterangan,
      'status': status,
      'metode_pembayaran': metodePembayaran,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'toko': toko?.toJson(),
      'pelanggan': pelanggan?.toJson(),
      'supplier': supplier?.toJson(),
      'tukar_tambah': tukarTambah?.toJson(),
      'items': items?.map((item) => item.toJson()).toList(),
    };
  }

  // Helper to check if transaction is incoming
  bool get isIncoming => isTransaksiMasuk == 1;
  
  // Helper to check if transaction is outgoing
  bool get isOutgoing => isTransaksiMasuk == 0;
}

class Store {
  final int? id;
  final String? nama;
  final String? alamat;
  final String? noTelp;

  Store({
    this.id,
    this.nama,
    this.alamat,
    this.noTelp,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      nama: json['nama'],
      alamat: json['alamat'],
      noTelp: json['no_telp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'alamat': alamat,
      'no_telp': noTelp,
    };
  }
}

class Customer {
  final int? id;
  final String? nama;
  final String? noTelp;
  final String? alamat;
  final String? email;

  Customer({
    this.id,
    this.nama,
    this.noTelp,
    this.alamat,
    this.email,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      nama: json['nama'],
      noTelp: json['no_telp'],
      alamat: json['alamat'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'no_telp': noTelp,
      'alamat': alamat,
      'email': email,
    };
  }
}

class Supplier {
  final int? id;
  final String? nama;
  final String? noTelp;
  final String? alamat;
  final String? email;

  Supplier({
    this.id,
    this.nama,
    this.noTelp,
    this.alamat,
    this.email,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      nama: json['nama'],
      noTelp: json['no_telp'],
      alamat: json['alamat'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'no_telp': noTelp,
      'alamat': alamat,
      'email': email,
    };
  }
}

class TradeIn {
  final int? id;
  final String? nama;
  final String? merek;
  final String? tipe;
  final double? hargaTukarTambah;

  TradeIn({
    this.id,
    this.nama,
    this.merek,
    this.tipe,
    this.hargaTukarTambah,
  });

  factory TradeIn.fromJson(Map<String, dynamic> json) {
    return TradeIn(
      id: json['id'],
      nama: json['nama'],
      merek: json['merek'],
      tipe: json['tipe'],
      hargaTukarTambah: json['harga_tukar_tambah'] != null
          ? double.parse(json['harga_tukar_tambah'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'merek': merek,
      'tipe': tipe,
      'harga_tukar_tambah': hargaTukarTambah,
    };
  }
}

class TransactionItem {
  final int? id;
  final int? posTransaksiId;
  final int? posProdukId;
  final int? posServiceId;
  final int? quantity;
  final double? hargaSatuan;
  final double? subtotal;
  final double? diskon;
  final int? garansi;
  final String? garansiExpiresAt;
  final double? pajak;

  // Relations
  final Product? produk;
  final Service? service;

  TransactionItem({
    this.id,
    this.posTransaksiId,
    this.posProdukId,
    this.posServiceId,
    this.quantity,
    this.hargaSatuan,
    this.subtotal,
    this.diskon,
    this.garansi,
    this.garansiExpiresAt,
    this.pajak,
    this.produk,
    this.service,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'],
      posTransaksiId: json['pos_transaksi_id'],
      posProdukId: json['pos_produk_id'],
      posServiceId: json['pos_service_id'],
      quantity: json['quantity'] is String 
          ? int.tryParse(json['quantity']) 
          : json['quantity'],
      hargaSatuan: json['harga_satuan'] != null
          ? double.parse(json['harga_satuan'].toString())
          : null,
      subtotal: json['subtotal'] != null
          ? double.parse(json['subtotal'].toString())
          : null,
      diskon:
          json['diskon'] != null ? double.parse(json['diskon'].toString()) : null,
      garansi: json['garansi'] is String 
          ? int.tryParse(json['garansi']) 
          : json['garansi'],
      garansiExpiresAt: json['garansi_expires_at'],
      pajak: json['pajak'] != null ? double.parse(json['pajak'].toString()) : null,
      produk: json['produk'] != null ? Product.fromJson(json['produk']) : null,
      service:
          json['service'] != null ? Service.fromJson(json['service']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pos_transaksi_id': posTransaksiId,
      'pos_produk_id': posProdukId,
      'pos_service_id': posServiceId,
      'quantity': quantity,
      'harga_satuan': hargaSatuan,
      'subtotal': subtotal,
      'diskon': diskon,
      'garansi': garansi,
      'garansi_expires_at': garansiExpiresAt,
      'pajak': pajak,
      'produk': produk?.toJson(),
      'service': service?.toJson(),
    };
  }
}

class Product {
  final int? id;
  final String? nama;
  final String? merek;
  final String? tipe;
  final double? hargaBeli;
  final double? hargaJual;
  final int? stok;

  Product({
    this.id,
    this.nama,
    this.merek,
    this.tipe,
    this.hargaBeli,
    this.hargaJual,
    this.stok,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nama: json['nama'],
      merek: json['merek'],
      tipe: json['tipe'],
      hargaBeli: json['harga_beli'] != null
          ? double.parse(json['harga_beli'].toString())
          : null,
      hargaJual: json['harga_jual'] != null
          ? double.parse(json['harga_jual'].toString())
          : null,
      stok: json['stok'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'merek': merek,
      'tipe': tipe,
      'harga_beli': hargaBeli,
      'harga_jual': hargaJual,
      'stok': stok,
    };
  }
}

class Service {
  final int? id;
  final String? nama;
  final String? deskripsi;
  final double? harga;

  Service({
    this.id,
    this.nama,
    this.deskripsi,
    this.harga,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      nama: json['nama'],
      deskripsi: json['deskripsi'],
      harga:
          json['harga'] != null ? double.parse(json['harga'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'harga': harga,
    };
  }
}
