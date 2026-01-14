class Outgoing {
  final int? id;
  final int? ownerId;
  final int? posTokoId;
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
  final OutgoingStore? store;
  final Supplier? supplier;
  final List<OutgoingTransactionItem>? items;

  Outgoing({
    this.id,
    this.ownerId,
    this.posTokoId,
    this.posSupplierId,
    this.isTransaksiMasuk,
    this.invoice,
    this.totalHarga,
    this.keterangan,
    this.status,
    this.metodePembayaran,
    this.createdAt,
    this.updatedAt,
    this.store,
    this.supplier,
    this.items,
  });

  factory Outgoing.fromJson(Map<String, dynamic> json) {
    return Outgoing(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'],
      ownerId: json['owner_id'] is String
          ? int.tryParse(json['owner_id'])
          : json['owner_id'],
      posTokoId: json['pos_toko_id'] is String
          ? int.tryParse(json['pos_toko_id'])
          : json['pos_toko_id'],
      posSupplierId: json['pos_supplier_id'] is String
          ? int.tryParse(json['pos_supplier_id'])
          : json['pos_supplier_id'],
      isTransaksiMasuk: json['is_transaksi_masuk'] is String
          ? int.tryParse(json['is_transaksi_masuk'])
          : json['is_transaksi_masuk'],
      invoice: json['invoice'],
      totalHarga: json['total_harga'] != null
          ? double.parse(json['total_harga'].toString())
          : null,
      keterangan: json['keterangan'],
      status: json['status'],
      metodePembayaran: json['metode_pembayaran'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      store: json['toko'] != null || json['store'] != null
          ? OutgoingStore.fromJson(json['toko'] ?? json['store'])
          : null,
      supplier: json['supplier'] != null
          ? Supplier.fromJson(json['supplier'])
          : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => OutgoingTransactionItem.fromJson(item))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'pos_toko_id': posTokoId,
      'pos_supplier_id': posSupplierId,
      'is_transaksi_masuk': isTransaksiMasuk,
      'invoice': invoice,
      'total_harga': totalHarga,
      'keterangan': keterangan,
      'status': status,
      'metode_pembayaran': metodePembayaran,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'store': store?.toJson(),
      'supplier': supplier?.toJson(),
      'items': items?.map((item) => item.toJson()).toList(),
    };
  }
}

class OutgoingStore {
  final int? id;
  final String? nama;
  final String? alamat;
  final String? noTelp;

  OutgoingStore({
    this.id,
    this.nama,
    this.alamat,
    this.noTelp,
  });

  factory OutgoingStore.fromJson(Map<String, dynamic> json) {
    return OutgoingStore(
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

class Supplier {
  final int? id;
  final String? nama;
  final String? alamat;
  final String? noTelp;
  final String? email;
  final String? kontak;

  Supplier({
    this.id,
    this.nama,
    this.alamat,
    this.noTelp,
    this.email,
    this.kontak,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      nama: json['nama'],
      alamat: json['alamat'],
      noTelp: json['no_telp'],
      email: json['email'],
      kontak: json['kontak'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'alamat': alamat,
      'no_telp': noTelp,
      'email': email,
      'kontak': kontak,
    };
  }
}

class OutgoingTransactionItem {
  final int? id;
  final int? posTransaksiId;
  final int? posProdukId;
  final int? quantity;
  final double? hargaSatuan;
  final double? subtotal;
  final double? diskon;

  // Relations
  final OutgoingProduct? product;

  OutgoingTransactionItem({
    this.id,
    this.posTransaksiId,
    this.posProdukId,
    this.quantity,
    this.hargaSatuan,
    this.subtotal,
    this.diskon,
    this.product,
  });

  factory OutgoingTransactionItem.fromJson(Map<String, dynamic> json) {
    return OutgoingTransactionItem(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'],
      posTransaksiId: json['pos_transaksi_id'] is String
          ? int.tryParse(json['pos_transaksi_id'])
          : json['pos_transaksi_id'],
      posProdukId: json['pos_produk_id'] is String
          ? int.tryParse(json['pos_produk_id'])
          : json['pos_produk_id'],
      quantity:
          json['quantity'] is String
              ? int.tryParse(json['quantity'])
              : json['quantity'],
      hargaSatuan: json['harga_satuan'] != null
          ? double.parse(json['harga_satuan'].toString())
          : null,
      subtotal: json['subtotal'] != null
          ? double.parse(json['subtotal'].toString())
          : null,
      diskon: json['diskon'] != null
          ? double.parse(json['diskon'].toString())
          : null,
      product: json['product'] != null || json['produk'] != null
          ? OutgoingProduct.fromJson(json['product'] ?? json['produk'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pos_transaksi_id': posTransaksiId,
      'pos_produk_id': posProdukId,
      'quantity': quantity,
      'harga_satuan': hargaSatuan,
      'subtotal': subtotal,
      'diskon': diskon,
      'product': product?.toJson(),
    };
  }
}

class OutgoingProduct {
  final int? id;
  final String? nama;
  final String? kode;
  final String? merek;
  final String? kategori;
  final double? hargaBeli;
  final double? hargaJual;
  final int? stok;

  OutgoingProduct({
    this.id,
    this.nama,
    this.kode,
    this.merek,
    this.kategori,
    this.hargaBeli,
    this.hargaJual,
    this.stok,
  });

  factory OutgoingProduct.fromJson(Map<String, dynamic> json) {
    return OutgoingProduct(
      id: json['id'],
      nama: json['nama'],
      kode: json['kode'],
      merek: json['merek'],
      kategori: json['kategori'],
      hargaBeli: json['harga_beli'] != null
          ? double.parse(json['harga_beli'].toString())
          : null,
      hargaJual: json['harga_jual'] != null
          ? double.parse(json['harga_jual'].toString())
          : null,
      stok: json['stok'] is String ? int.tryParse(json['stok']) : json['stok'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'kode': kode,
      'merek': merek,
      'kategori': kategori,
      'harga_beli': hargaBeli,
      'harga_jual': hargaJual,
      'stok': stok,
    };
  }
}
