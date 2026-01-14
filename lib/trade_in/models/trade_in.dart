class TradeIn {
  final int id;
  final String? pelangganNama;
  final String? tokoBranchNama;
  final String? produkMasukNama;
  final String? produkMasukMerk;
  final String? produkMasukKondisi;
  final int? produkMasukHarga;
  final String? produkKeluarNama;
  final String? produkKeluarMerk;
  final int? produkKeluarHarga;
  final int? diskonPersen;
  final int? diskonAmount;
  final int? netAmount;
  final String? paymentMethod;
  final String? catatan;
  final String? color;
  final String? storage;
  final String? batteryHealth;
  final String? imei;
  final String? accessories;
  final int? selisihHarga;
  final String? transaksiPenjualanInvoice;
  final String? transaksiPembelianInvoice;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TradeIn({
    required this.id,
    this.pelangganNama,
    this.tokoBranchNama,
    this.produkMasukNama,
    this.produkMasukMerk,
    this.produkMasukKondisi,
    this.produkMasukHarga,
    this.produkKeluarNama,
    this.produkKeluarMerk,
    this.produkKeluarHarga,
    this.diskonPersen,
    this.diskonAmount,
    this.netAmount,
    this.paymentMethod,
    this.catatan,
    this.color,
    this.storage,
    this.batteryHealth,
    this.imei,
    this.accessories,
    this.selisihHarga,
    this.transaksiPenjualanInvoice,
    this.transaksiPembelianInvoice,
    this.createdAt,
    this.updatedAt,
  });

  factory TradeIn.fromJson(Map<String, dynamic> json) {
    return TradeIn(
      id: json['id'] ?? 0,
      pelangganNama: json['pelanggan_nama']?.toString(),
      tokoBranchNama: json['toko_branch_nama']?.toString(),
      produkMasukNama: json['produk_masuk_nama']?.toString(),
      produkMasukMerk: json['produk_masuk_merk']?.toString(),
      produkMasukKondisi: json['produk_masuk_kondisi']?.toString(),
      produkMasukHarga: int.tryParse(
        json['produk_masuk_harga']?.toString() ?? '0',
      ),
      produkKeluarNama: json['produk_keluar_nama']?.toString(),
      produkKeluarMerk: json['produk_keluar_merk']?.toString(),
      produkKeluarHarga: int.tryParse(
        json['produk_keluar_harga']?.toString() ?? '0',
      ),
      diskonPersen: int.tryParse(json['diskon_persen']?.toString() ?? '0'),
      diskonAmount: int.tryParse(json['diskon_amount']?.toString() ?? '0'),
      netAmount: int.tryParse(json['net_amount']?.toString() ?? '0'),
      paymentMethod: json['payment_method']?.toString(),
      catatan: json['catatan']?.toString(),
      color: json['color']?.toString(),
      storage: json['storage']?.toString(),
      batteryHealth: json['battery_health']?.toString(),
      imei: json['imei']?.toString(),
      accessories: json['accessories']?.toString(),
      selisihHarga: int.tryParse(json['difference']?.toString() ?? '0'),
      transaksiPenjualanInvoice:
          json['transaksi_penjualan_invoice']?.toString(),
      transaksiPembelianInvoice:
          json['transaksi_pembelian_invoice']?.toString(),
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pelanggan_nama': pelangganNama,
      'toko_branch_nama': tokoBranchNama,
      'produk_masuk_nama': produkMasukNama,
      'produk_masuk_merk': produkMasukMerk,
      'produk_masuk_kondisi': produkMasukKondisi,
      'produk_masuk_harga': produkMasukHarga,
      'produk_keluar_nama': produkKeluarNama,
      'produk_keluar_merk': produkKeluarMerk,
      'produk_keluar_harga': produkKeluarHarga,
      'diskon_persen': diskonPersen,
      'diskon_amount': diskonAmount,
      'net_amount': netAmount,
      'payment_method': paymentMethod,
      'catatan': catatan,
      'color': color,
      'storage': storage,
      'battery_health': batteryHealth,
      'imei': imei,
      'accessories': accessories,
      'difference': selisihHarga,
      'transaksi_penjualan_invoice': transaksiPenjualanInvoice,
      'transaksi_pembelian_invoice': transaksiPembelianInvoice,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
