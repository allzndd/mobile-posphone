import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import '../../component/validation_handler.dart';
import '../services/trade_in_service.dart';
import '../../customers/services/customer_service.dart';
import '../../store/services/store_service.dart';
import '../../produk/services/product_service.dart';

class TradeInCreateScreen extends StatefulWidget {
  const TradeInCreateScreen({super.key});

  @override
  State<TradeInCreateScreen> createState() => _TradeInCreateScreenState();
}

class _TradeInCreateScreenState extends State<TradeInCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers for text fields
  final _produkMasukHargaController = TextEditingController();
  final _produkKeluarHargaController = TextEditingController();
  final _diskonController = TextEditingController(text: '0');
  final _catatanController = TextEditingController();

  // Dropdown values
  int? _selectedCustomerId;
  int? _selectedStoreId;
  int? _selectedProdukMasukId;
  int? _selectedProdukKeluarId;
  String? _selectedPaymentMethod;
  String _productType = 'existing'; // 'existing' or 'new'

  // Controllers for new product
  final _newProductNameController = TextEditingController();
  final _newProductBrandController = TextEditingController();
  final _newProductColorController = TextEditingController();
  final _newProductStorageController = TextEditingController();
  final _newProductBatteryHealthController = TextEditingController();
  final _newProductImeiController = TextEditingController();
  final _newProductAccessoriesController = TextEditingController();

  // Data lists
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _stores = [];
  List<Map<String, dynamic>> _products = [];

  bool _isLoading = false;
  bool _isLoadingData = true;
  Map<String, String> _fieldErrors = {};
  int _selisihHarga = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _produkMasukHargaController.dispose();
    _produkKeluarHargaController.dispose();
    _diskonController.dispose();
    _catatanController.dispose();
    _newProductNameController.dispose();
    _newProductBrandController.dispose();
    _newProductColorController.dispose();
    _newProductStorageController.dispose();
    _newProductBatteryHealthController.dispose();
    _newProductImeiController.dispose();
    _newProductAccessoriesController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoadingData = true);

    try {
      // Load customers
      final customerService = CustomerService();
      final customerResponse = await customerService.getCustomers(perPage: 100);
      if (customerResponse.success && customerResponse.customers != null) {
        _customers =
            customerResponse.customers!.map((customer) {
              return {'id': customer.id, 'nama': customer.nama};
            }).toList();
      }

      // Load stores
      final storeResponse = await StoreService.getStores(perPage: 100);
      if (storeResponse['success'] == true) {
        _stores =
            (storeResponse['data'] as List).map((store) {
              return {'id': store['id'], 'nama': store['nama']};
            }).toList();
      }

      // Load products
      final productResponse = await ProductService.getAllProducts(perPage: 100);
      if (productResponse.success && productResponse.data != null) {
        _products =
            productResponse.data!.map((product) {
              return {
                'id': product.id,
                'nama': product.nama,
                'merk': product.merk?.nama ?? '-',
                'harga': product.hargaJual,
              };
            }).toList();
      }
    } catch (e) {
      if (mounted) {
        await ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'Failed to load data: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  void _calculateSelisih() {
    final hargaMasuk =
        int.tryParse(
          _produkMasukHargaController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;
    final hargaKeluar =
        int.tryParse(
          _produkKeluarHargaController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;
    final diskonPersen =
        int.tryParse(
          _diskonController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;
    final diskonAmount = (hargaKeluar * diskonPersen / 100).round();

    setState(() {
      _selisihHarga = (hargaKeluar - diskonAmount) - hargaMasuk;
    });
  }

  void _onProdukMasukSelected(int? productId) {
    if (productId == null) return;

    final product = _products.firstWhere((p) => p['id'] == productId);
    setState(() {
      _selectedProdukMasukId = productId;
      _produkMasukHargaController.text = (product['harga'] as int).toString();
      _calculateSelisih();
    });
  }

  void _onProdukKeluarSelected(int? productId) {
    if (productId == null) return;

    final product = _products.firstWhere((p) => p['id'] == productId);
    setState(() {
      _selectedProdukKeluarId = productId;
      _produkKeluarHargaController.text = (product['harga'] as int).toString();
      _calculateSelisih();
    });
  }

  Future<void> _saveTradeIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _fieldErrors = {};
    });

    try {
      final hargaMasuk = int.parse(
        _produkMasukHargaController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      final hargaKeluar = int.parse(
        _produkKeluarHargaController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      final diskonPersen = int.parse(
        _diskonController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      final diskonAmount = (hargaKeluar * diskonPersen / 100).round();

      // Build data according to backend API requirements
      final data = {
        'pos_toko_id': _selectedStoreId,
        'pos_pelanggan_id': _selectedCustomerId,

        // Produk Keluar (Penjualan) - existing product
        'pos_produk_keluar_id': _selectedProdukKeluarId,
        'harga_jual_keluar': hargaKeluar,
        'diskon_keluar': diskonAmount,

        // Produk Masuk (Pembelian)
        'produk_masuk_type': _productType == 'existing' ? 'existing' : 'new',
        'pos_produk_masuk_id':
            _productType == 'existing' ? _selectedProdukMasukId : null,
        'harga_beli_masuk': hargaMasuk,

        // Transaction details
        'metode_pembayaran': _selectedPaymentMethod,
        'keterangan': _catatanController.text.trim(),
      };

      // Add new product fields if product type is new
      if (_productType == 'new') {
        data['merk_type'] =
            'new'; // For now, always create new brand for new products
        data['merk_nama_baru'] = _newProductBrandController.text.trim();
        data['produk_nama_baru'] = _newProductNameController.text.trim();
        data['warna'] = _newProductColorController.text.trim();
        data['penyimpanan'] = _newProductStorageController.text.trim();
        data['battery_health'] = _newProductBatteryHealthController.text.trim();
        data['imei'] = _newProductImeiController.text.trim();
        data['aksesoris'] = _newProductAccessoriesController.text.trim();
      }

      final response = await TradeInService.createTradeIn(data);

      if (!mounted) return;

      if (response['success'] == true) {
        await ValidationHandler.showSuccessDialog(
          context: context,
          title: 'Success',
          message: 'Trade-in created successfully',
        );
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        if (response['errors'] != null) {
          setState(() {
            _fieldErrors = Map<String, String>.from(
              (response['errors'] as Map).map(
                (key, value) => MapEntry(
                  key.toString(),
                  (value is List ? value.first : value).toString(),
                ),
              ),
            );
          });
        }
        await ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: response['message'] ?? 'Failed to create trade-in',
        );
      }
    } catch (e) {
      if (mounted) {
        await ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'Error creating trade-in: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.surfaceColor,
        elevation: 0,
        title: Text(
          'Add Trade-In',
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: themeProvider.textPrimary),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveTradeIn,
              child: Text(
                'Save',
                style: TextStyle(
                  color: themeProvider.primaryMain,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body:
          _isLoadingData
              ? Center(
                child: CircularProgressIndicator(
                  color: themeProvider.primaryMain,
                ),
              )
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDropdown(
                        'Customer',
                        _selectedCustomerId,
                        _customers,
                        (value) => setState(() => _selectedCustomerId = value),
                        themeProvider,
                        isMobile,
                        fieldKey: 'pos_pelanggan_id',
                        isRequired: false,
                      ),
                      SizedBox(height: isMobile ? 16 : 20),
                      _buildDropdown(
                        'Store Branch',
                        _selectedStoreId,
                        _stores,
                        (value) => setState(() => _selectedStoreId = value),
                        themeProvider,
                        isMobile,
                        fieldKey: 'pos_toko_id',
                      ),
                      SizedBox(height: isMobile ? 20 : 24),
                      Text(
                        'Product IN (Incoming)',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textPrimary,
                        ),
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      // Product Type Selection
                      Text(
                        'Product Type',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: themeProvider.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text(
                                'Existing Product',
                                style: TextStyle(
                                  fontSize: isMobile ? 13 : 14,
                                  color: themeProvider.textPrimary,
                                ),
                              ),
                              value: 'existing',
                              groupValue: _productType,
                              activeColor: themeProvider.primaryMain,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (value) {
                                setState(() {
                                  _productType = value!;
                                  _selectedProdukMasukId = null;
                                  _produkMasukHargaController.clear();
                                  _newProductNameController.clear();
                                  _newProductBrandController.clear();
                                  _newProductColorController.clear();
                                  _newProductStorageController.clear();
                                  _newProductBatteryHealthController.clear();
                                  _newProductImeiController.clear();
                                  _newProductAccessoriesController.clear();
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text(
                                'New Product',
                                style: TextStyle(
                                  fontSize: isMobile ? 13 : 14,
                                  color: themeProvider.textPrimary,
                                ),
                              ),
                              value: 'new',
                              groupValue: _productType,
                              activeColor: themeProvider.primaryMain,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (value) {
                                setState(() {
                                  _productType = value!;
                                  _selectedProdukMasukId = null;
                                  _produkMasukHargaController.clear();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 16 : 20),
                      // Conditional fields based on product type
                      if (_productType == 'existing') ...[
                        _buildDropdown(
                          'Select Existing Product',
                          _selectedProdukMasukId,
                          _products,
                          _onProdukMasukSelected,
                          themeProvider,
                          isMobile,
                          fieldKey: 'pos_produk_masuk_id',
                        ),
                      ] else ...[
                        _buildTextField(
                          'Product Name',
                          _newProductNameController,
                          'Enter product name',
                          themeProvider,
                          isMobile,
                          fieldKey: 'produk_nama_baru',
                        ),
                        SizedBox(height: isMobile ? 16 : 20),
                        _buildTextField(
                          'Brand',
                          _newProductBrandController,
                          'Enter brand name',
                          themeProvider,
                          isMobile,
                          fieldKey: 'merk_nama_baru',
                        ),
                        SizedBox(height: isMobile ? 16 : 20),
                        _buildTextField(
                          'Color (Optional)',
                          _newProductColorController,
                          'Enter color',
                          themeProvider,
                          isMobile,
                          fieldKey: 'warna',
                          isRequired: false,
                        ),
                        SizedBox(height: isMobile ? 16 : 20),
                        _buildTextField(
                          'Storage (Optional)',
                          _newProductStorageController,
                          'Enter storage (e.g., 128GB)',
                          themeProvider,
                          isMobile,
                          fieldKey: 'penyimpanan',
                          isRequired: false,
                        ),
                        SizedBox(height: isMobile ? 16 : 20),
                        _buildTextField(
                          'Battery Health (Optional)',
                          _newProductBatteryHealthController,
                          'Enter battery health (%)',
                          themeProvider,
                          isMobile,
                          fieldKey: 'battery_health',
                          isRequired: false,
                        ),
                        SizedBox(height: isMobile ? 16 : 20),
                        _buildTextField(
                          'IMEI (Optional)',
                          _newProductImeiController,
                          'Enter IMEI number',
                          themeProvider,
                          isMobile,
                          fieldKey: 'imei',
                          isRequired: false,
                        ),
                        SizedBox(height: isMobile ? 16 : 20),
                        _buildTextField(
                          'Accessories (Optional)',
                          _newProductAccessoriesController,
                          'Enter accessories',
                          themeProvider,
                          isMobile,
                          fieldKey: 'aksesoris',
                          maxLines: 2,
                          isRequired: false,
                        ),
                      ],
                      SizedBox(height: isMobile ? 16 : 20),
                      _buildTextField(
                        'Purchase Price',
                        _produkMasukHargaController,
                        'Enter purchase price',
                        themeProvider,
                        isMobile,
                        fieldKey: 'harga_beli_masuk',
                        isNumber: true,
                        onChanged: () => _calculateSelisih(),
                      ),
                      SizedBox(height: isMobile ? 20 : 24),
                      Text(
                        'Product OUT (Outgoing)',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textPrimary,
                        ),
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      _buildDropdown(
                        'Product',
                        _selectedProdukKeluarId,
                        _products,
                        _onProdukKeluarSelected,
                        themeProvider,
                        isMobile,
                        fieldKey: 'pos_produk_keluar_id',
                      ),
                      SizedBox(height: isMobile ? 16 : 20),
                      _buildTextField(
                        'Price',
                        _produkKeluarHargaController,
                        'Enter price',
                        themeProvider,
                        isMobile,
                        fieldKey: 'harga_jual_keluar',
                        isNumber: true,
                        onChanged: () => _calculateSelisih(),
                      ),
                      SizedBox(height: isMobile ? 16 : 20),
                      _buildTextField(
                        'Discount (%)',
                        _diskonController,
                        'Enter discount percentage',
                        themeProvider,
                        isMobile,
                        fieldKey: 'diskon_keluar',
                        isNumber: true,
                        isRequired: false,
                        onChanged: () => _calculateSelisih(),
                      ),
                      SizedBox(height: isMobile ? 16 : 20),
                      _buildNetAmountCard(themeProvider, isMobile),
                      SizedBox(height: isMobile ? 20 : 24),
                      Text(
                        'Transaction Details',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textPrimary,
                        ),
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      _buildPaymentMethodDropdown(themeProvider, isMobile),
                      SizedBox(height: isMobile ? 20 : 24),
                      _buildTransactionSummary(themeProvider, isMobile),
                      SizedBox(height: isMobile ? 20 : 24),
                      _buildTextField(
                        'Notes (Optional)',
                        _catatanController,
                        'Enter notes',
                        themeProvider,
                        isMobile,
                        fieldKey: 'keterangan',
                        maxLines: 3,
                        isRequired: false,
                      ),
                      SizedBox(height: isMobile ? 24 : 32),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveTradeIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeProvider.primaryMain,
                              padding: EdgeInsets.symmetric(
                                vertical: isMobile ? 14 : 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Save Trade-In',
                              style: TextStyle(
                                fontSize: isMobile ? 16 : 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildDropdown(
    String label,
    int? selectedValue,
    List<Map<String, dynamic>> items,
    void Function(int?) onChanged,
    ThemeProvider themeProvider,
    bool isMobile, {
    String? fieldKey,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: themeProvider.textPrimary,
            ),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: selectedValue,
          decoration: InputDecoration(
            hintText: 'Select $label',
            hintStyle: TextStyle(color: themeProvider.textSecondary),
            filled: true,
            fillColor: themeProvider.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: themeProvider.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: themeProvider.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeProvider.primaryMain,
                width: 2,
              ),
            ),
            errorText: fieldKey != null ? _fieldErrors[fieldKey] : null,
          ),
          dropdownColor: themeProvider.surfaceColor,
          style: TextStyle(color: themeProvider.textPrimary),
          items:
              items.map((item) {
                return DropdownMenuItem<int>(
                  value: item['id'] as int,
                  child: Text(
                    item['nama'] as String,
                    style: TextStyle(color: themeProvider.textPrimary),
                  ),
                );
              }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (isRequired && value == null) {
              return '$label is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint,
    ThemeProvider themeProvider,
    bool isMobile, {
    String? fieldKey,
    bool isNumber = false,
    bool isRequired = true,
    int maxLines = 1,
    VoidCallback? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: themeProvider.textPrimary,
            ),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          style: TextStyle(color: themeProvider.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: themeProvider.textSecondary),
            filled: true,
            fillColor: themeProvider.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: themeProvider.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: themeProvider.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeProvider.primaryMain,
                width: 2,
              ),
            ),
            errorText: fieldKey != null ? _fieldErrors[fieldKey] : null,
          ),
          validator:
              isRequired
                  ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '$label is required';
                    }
                    if (isNumber) {
                      final numValue = int.tryParse(
                        value.replaceAll(RegExp(r'[^0-9]'), ''),
                      );
                      if (numValue == null || numValue <= 0) {
                        return '$label must be a valid number';
                      }
                    }
                    return null;
                  }
                  : null,
          onChanged: onChanged != null ? (_) => onChanged() : null,
        ),
      ],
    );
  }

  Widget _buildPriceDifferenceCard(ThemeProvider themeProvider, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color:
            _selisihHarga >= 0
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _selisihHarga >= 0
                  ? Colors.green.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price Difference',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.textPrimary,
                ),
              ),
              Text(
                'Rp ${_formatCurrency(_selisihHarga)}',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: _selisihHarga >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _selisihHarga >= 0
                ? 'Customer pays the difference'
                : 'Store pays the difference',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: themeProvider.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetAmountCard(ThemeProvider themeProvider, bool isMobile) {
    final hargaKeluar =
        int.tryParse(
          _produkKeluarHargaController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;
    final diskonPersen =
        int.tryParse(
          _diskonController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;
    final diskonAmount = (hargaKeluar * diskonPersen / 100).round();
    final netAmount = hargaKeluar - diskonAmount;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Net Amount',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: themeProvider.textPrimary,
            ),
          ),
          Text(
            'Rp ${_formatCurrency(netAmount)}',
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: themeProvider.primaryMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodDropdown(
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    final paymentMethods = [
      {'value': 'cash', 'label': 'Cash'},
      {'value': 'transfer', 'label': 'Bank Transfer'},
      {'value': 'credit_card', 'label': 'Credit Card'},
      {'value': 'debit_card', 'label': 'Debit Card'},
      {'value': 'qris', 'label': 'QRIS'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Payment Method',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: themeProvider.textPrimary,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedPaymentMethod,
          decoration: InputDecoration(
            hintText: 'Select Payment Method',
            hintStyle: TextStyle(color: themeProvider.textSecondary),
            filled: true,
            fillColor: themeProvider.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: themeProvider.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: themeProvider.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeProvider.primaryMain,
                width: 2,
              ),
            ),
            errorText: _fieldErrors['metode_pembayaran'],
          ),
          dropdownColor: themeProvider.surfaceColor,
          style: TextStyle(color: themeProvider.textPrimary),
          items:
              paymentMethods.map((method) {
                return DropdownMenuItem<String>(
                  value: method['value'] as String,
                  child: Text(
                    method['label'] as String,
                    style: TextStyle(color: themeProvider.textPrimary),
                  ),
                );
              }).toList(),
          onChanged: (value) => setState(() => _selectedPaymentMethod = value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Payment Method is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTransactionSummary(ThemeProvider themeProvider, bool isMobile) {
    final hargaMasuk =
        int.tryParse(
          _produkMasukHargaController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;
    final hargaKeluar =
        int.tryParse(
          _produkKeluarHargaController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;
    final diskonPersen =
        int.tryParse(
          _diskonController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;
    final diskonAmount = (hargaKeluar * diskonPersen / 100).round();

    final saleRevenue = hargaKeluar - diskonAmount;
    final purchaseCost = hargaMasuk;
    final netProfit = saleRevenue - purchaseCost;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Summary',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.textPrimary,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Sale Revenue',
                  saleRevenue,
                  Colors.green,
                  themeProvider,
                  isMobile,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: _buildSummaryCard(
                  'Purchase Cost',
                  purchaseCost,
                  Colors.red,
                  themeProvider,
                  isMobile,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: _buildSummaryCard(
                  'Net Profit',
                  netProfit,
                  netProfit >= 0 ? Colors.green : Colors.red,
                  themeProvider,
                  isMobile,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    int amount,
    Color color,
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              color: themeProvider.textSecondary,
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            'Rp ${_formatCurrency(amount)}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    return amount.abs().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
