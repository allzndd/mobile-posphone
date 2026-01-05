import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../config/theme_provider.dart';
import '../../../component/validation_handler.dart';
import '../../services/product_service.dart';
import '../../models/product.dart';
import '../../models/product_brand.dart';

// Custom formatter untuk currency Indonesia
class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,##0', 'id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Parse and format the number
    int value = int.tryParse(digitsOnly) ?? 0;
    String formatted = _formatter.format(value);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form Controllers
  final _deskripsiController = TextEditingController();
  final _warnaController = TextEditingController();
  final _penyimpananController = TextEditingController();
  final _batteryHealthController = TextEditingController();
  final _hargaBeliController = TextEditingController();
  final _hargaJualController = TextEditingController();
  final _imeiController = TextEditingController();
  final _aksesorisController = TextEditingController();

  // Additional cost controllers
  final List<TextEditingController> _costNameControllers = [];
  final List<TextEditingController> _costAmountControllers = [];

  // Form State
  bool _isLoading = false;
  bool _isBrandsLoading = false;
  List<ProductBrand> _brands = [];
  int? _selectedBrandId;
  String _selectedProductType = 'electronic';

  // Focus Nodes for better UX
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    _loadBrands();
    _initializeFormData();

    // Initialize focus nodes
    for (int i = 0; i < 10; i++) {
      _focusNodes.add(FocusNode());
    }
  }

  void _initializeFormData() {
    // Populate form fields with existing product data
    _deskripsiController.text = widget.product.deskripsi ?? '';
    _warnaController.text = widget.product.warna ?? '';
    _penyimpananController.text = widget.product.penyimpanan ?? '';
    _batteryHealthController.text = widget.product.batteryHealth ?? '';
    _imeiController.text = widget.product.imei ?? '';
    _aksesorisController.text = widget.product.aksesoris ?? '';

    // Format currency values
    final currencyFormat = NumberFormat('#,##0', 'id_ID');
    _hargaBeliController.text = currencyFormat.format(widget.product.hargaBeli);
    _hargaJualController.text = currencyFormat.format(widget.product.hargaJual);

    // Set selected brand
    _selectedBrandId = widget.product.posProdukMerkId;
    // Keep default product type as 'electronic' since it's not stored in Product model
    _selectedProductType = 'electronic';

    // TODO: Load additional costs if available from API
    if (_costNameControllers.isEmpty) {
      _addCostField(); // Add initial cost field
    }
  }

  @override
  void dispose() {
    _deskripsiController.dispose();
    _warnaController.dispose();
    _penyimpananController.dispose();
    _batteryHealthController.dispose();
    _hargaBeliController.dispose();
    _hargaJualController.dispose();
    _imeiController.dispose();
    _aksesorisController.dispose();
    _scrollController.dispose();

    // Dispose cost controllers
    for (var controller in _costNameControllers) {
      controller.dispose();
    }
    for (var controller in _costAmountControllers) {
      controller.dispose();
    }

    // Dispose focus nodes
    for (var node in _focusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  Future<void> _loadBrands() async {
    setState(() => _isBrandsLoading = true);

    try {
      final response = await ProductService.getProductBrands();

      if (mounted) {
        setState(() {
          _isBrandsLoading = false;
          if (response.success && response.data != null) {
            _brands = response.data!;
          }
        });

        // Show error message outside setState if needed
        if (!response.success || response.data == null) {
          await _showErrorMessage(response.message ?? 'Gagal load brands');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isBrandsLoading = false);
        await _showErrorMessage('Error loading brands: ${e.toString()}');
      }
    }
  }

  void _addCostField() {
    setState(() {
      _costNameControllers.add(TextEditingController());
      _costAmountControllers.add(TextEditingController());
    });
  }

  void _removeCostField(int index) {
    setState(() {
      _costNameControllers[index].dispose();
      _costAmountControllers[index].dispose();
      _costNameControllers.removeAt(index);
      _costAmountControllers.removeAt(index);
    });
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) {
      await _showErrorMessage('Mohon lengkapi semua field yang diperlukan');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Parse currency values (remove dots)
      final hargaBeli = double.parse(
        _hargaBeliController.text.replaceAll('.', ''),
      );
      final hargaJual = double.parse(
        _hargaJualController.text.replaceAll('.', ''),
      );

      // Check if there are any changes
      bool hasChanges = false;
      
      if (_selectedBrandId != widget.product.posProdukMerkId) hasChanges = true;
      if (hargaBeli != widget.product.hargaBeli) hasChanges = true;
      if (hargaJual != widget.product.hargaJual) hasChanges = true;
      if (_imeiController.text.trim() != (widget.product.imei ?? '')) hasChanges = true;
      if (_deskripsiController.text.trim() != (widget.product.deskripsi ?? '')) hasChanges = true;
      if (_warnaController.text.trim() != (widget.product.warna ?? '')) hasChanges = true;
      if (_penyimpananController.text.trim() != (widget.product.penyimpanan ?? '')) hasChanges = true;
      if (_batteryHealthController.text.trim() != (widget.product.batteryHealth ?? '')) hasChanges = true;
      if (_aksesorisController.text.trim() != (widget.product.aksesoris ?? '')) hasChanges = true;

      if (!hasChanges) {
        if (mounted) {
          setState(() => _isLoading = false);
          await _showSuccessMessage('No changes made to product');
          Navigator.pop(context, true);
        }
        return;
      }

      // Parse additional costs
      Map<String, double> biayaTambahan = {};
      for (int i = 0; i < _costNameControllers.length; i++) {
        final name = _costNameControllers[i].text.trim();
        final amountText = _costAmountControllers[i].text.replaceAll('.', '');

        if (name.isNotEmpty && amountText.isNotEmpty) {
          biayaTambahan[name] = double.parse(amountText);
        }
      }

      // Prepare request data
      Map<String, dynamic> productData = {
        'pos_produk_merk_id': _selectedBrandId,
        'product_type': _selectedProductType,
        'harga_beli': hargaBeli,
        'harga_jual': hargaJual,
        'imei': _imeiController.text.trim(),
      };

      // Add optional fields
      if (_deskripsiController.text.isNotEmpty) {
        productData['deskripsi'] = _deskripsiController.text.trim();
      }
      if (_warnaController.text.isNotEmpty) {
        productData['warna'] = _warnaController.text.trim();
      }
      if (_penyimpananController.text.isNotEmpty) {
        productData['penyimpanan'] = _penyimpananController.text.trim();
      }
      if (_batteryHealthController.text.isNotEmpty) {
        productData['battery_health'] = _batteryHealthController.text.trim();
      }
      if (_aksesorisController.text.isNotEmpty) {
        productData['aksesoris'] = _aksesorisController.text.trim();
      }

      // Add additional costs
      if (biayaTambahan.isNotEmpty) {
        List<String> costNames = [];
        List<double> costAmounts = [];

        biayaTambahan.forEach((name, amount) {
          costNames.add(name);
          costAmounts.add(amount);
        });

        productData['cost_names'] = costNames;
        productData['cost_amounts'] = costAmounts;
      }

      // Call API
      final response = await ProductService.updateProduct(
        widget.product.id!,
        productData,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (response['success'] == true || response['data'] != null) {
          await _showSuccessMessage('Produk berhasil diupdate!');
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          await _showErrorMessage(response['message'] ?? 'Gagal update produk');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        await _showErrorMessage('Error: ${e.toString()}');
      }
    }
  }

  Future<void> _showSuccessMessage(String message) async {
    await context.showSuccess(title: 'Berhasil', message: message);
  }

  Future<void> _showErrorMessage(String message) async {
    await context.showError(title: 'Kesalahan', message: message);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final isTablet = size.width >= 600 && size.width < 1024;

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Edit Product',
          style: TextStyle(color: themeProvider.textPrimary),
        ),
        backgroundColor: themeProvider.surfaceColor,
        elevation: 0,
        iconTheme: IconThemeData(color: themeProvider.textPrimary),
        actions: [
          if (!_isLoading)
            TextButton.icon(
              onPressed: _updateProduct,
              icon: const Icon(Icons.check),
              label: const Text('Save'),
              style: TextButton.styleFrom(
                foregroundColor: themeProvider.primaryMain,
              ),
            ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  color: themeProvider.primaryMain,
                ),
              )
              : SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isMobile ? 16 : 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              themeProvider.primaryMain,
                              themeProvider.primaryMain.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: themeProvider.primaryMain.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(isMobile ? 12 : 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: isMobile ? 24 : 32,
                              ),
                            ),
                            SizedBox(width: isMobile ? 12 : 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Edit Product',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isMobile ? 18 : 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Update product information and pricing',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: isMobile ? 12 : 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isMobile ? 20 : 24),

                      // Product Info Card
                      _buildSection(
                        title: 'Product Information',
                        icon: Icons.info_outline,
                        themeProvider: themeProvider,
                        isMobile: isMobile,
                        children: [
                          _buildBrandDropdown(themeProvider, isMobile),
                          SizedBox(height: isMobile ? 16 : 20),
                          _buildProductTypeDropdown(themeProvider, isMobile),
                          SizedBox(height: isMobile ? 16 : 20),
                          _buildFormField(
                            label: 'Color',
                            hint: 'e.g., Black, White, Blue',
                            controller: _warnaController,
                            themeProvider: themeProvider,
                            isMobile: isMobile,
                            icon: Icons.palette,
                            focusNode: _focusNodes[0],
                            nextFocusNode: _focusNodes[1],
                          ),
                          SizedBox(height: isMobile ? 16 : 20),
                          _buildFormField(
                            label: 'Storage',
                            hint: 'e.g., 64GB, 128GB, 256GB',
                            controller: _penyimpananController,
                            themeProvider: themeProvider,
                            isMobile: isMobile,
                            icon: Icons.storage,
                            focusNode: _focusNodes[1],
                            nextFocusNode: _focusNodes[2],
                          ),
                          SizedBox(height: isMobile ? 16 : 20),
                          _buildFormField(
                            label: 'Battery Health',
                            hint: 'e.g., 85%, 90%, 95%',
                            controller: _batteryHealthController,
                            themeProvider: themeProvider,
                            isMobile: isMobile,
                            icon: Icons.battery_charging_full,
                            focusNode: _focusNodes[2],
                            nextFocusNode: _focusNodes[3],
                          ),
                          SizedBox(height: isMobile ? 16 : 20),
                          _buildFormField(
                            label: 'Description',
                            hint: 'Product description',
                            controller: _deskripsiController,
                            themeProvider: themeProvider,
                            isMobile: isMobile,
                            icon: Icons.description,
                            focusNode: _focusNodes[3],
                            nextFocusNode: _focusNodes[4],
                            maxLines: 3,
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 20 : 24),

                      // Pricing Card
                      _buildSection(
                        title: 'Pricing',
                        icon: Icons.attach_money,
                        themeProvider: themeProvider,
                        isMobile: isMobile,
                        children: [
                          _buildCurrencyField(
                            label: 'Buy Price',
                            hint: '0',
                            controller: _hargaBeliController,
                            themeProvider: themeProvider,
                            isMobile: isMobile,
                            icon: Icons.shopping_cart,
                            isRequired: true,
                            focusNode: _focusNodes[4],
                            nextFocusNode: _focusNodes[5],
                          ),
                          SizedBox(height: isMobile ? 16 : 20),
                          _buildCurrencyField(
                            label: 'Sell Price',
                            hint: '0',
                            controller: _hargaJualController,
                            themeProvider: themeProvider,
                            isMobile: isMobile,
                            icon: Icons.sell,
                            isRequired: true,
                            focusNode: _focusNodes[5],
                            nextFocusNode: _focusNodes[6],
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 20 : 24),

                      // Additional Costs Card
                      _buildSection(
                        title: 'Additional Costs',
                        icon: Icons.add_circle_outline,
                        themeProvider: themeProvider,
                        isMobile: isMobile,
                        children: [
                          ..._buildAdditionalCosts(themeProvider, isMobile),
                          SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _addCostField,
                            icon: Icon(Icons.add, size: isMobile ? 18 : 20),
                            label: Text(
                              'Add Cost',
                              style: TextStyle(fontSize: isMobile ? 14 : 16),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: themeProvider.primaryMain,
                              side: BorderSide(
                                color: themeProvider.primaryMain,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 16 : 20,
                                vertical: isMobile ? 12 : 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 20 : 24),

                      // Device Information Card
                      _buildSection(
                        title: 'Device Information',
                        icon: Icons.phone_android,
                        themeProvider: themeProvider,
                        isMobile: isMobile,
                        children: [
                          _buildFormField(
                            label: 'IMEI',
                            hint: 'Device IMEI number',
                            controller: _imeiController,
                            themeProvider: themeProvider,
                            isMobile: isMobile,
                            icon: Icons.numbers,
                            isRequired: true,
                            focusNode: _focusNodes[6],
                            nextFocusNode: _focusNodes[7],
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'IMEI wajib diisi';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: isMobile ? 16 : 20),
                          _buildFormField(
                            label: 'Accessories',
                            hint: 'e.g., Charger, Cable, Box',
                            controller: _aksesorisController,
                            themeProvider: themeProvider,
                            isMobile: isMobile,
                            icon: Icons.phone_iphone,
                            focusNode: _focusNodes[7],
                            maxLines: 2,
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 32 : 40),

                      // Save Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _updateProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeProvider.primaryMain,
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 16 : 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child:
                            _isLoading
                                ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text(
                                  'Update Product',
                                  style: TextStyle(
                                    fontSize: isMobile ? 16 : 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                      SizedBox(height: isMobile ? 16 : 20),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required ThemeProvider themeProvider,
    required bool isMobile,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 10),
                decoration: BoxDecoration(
                  color: themeProvider.primaryMain.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: isMobile ? 20 : 24,
                  color: themeProvider.primaryMain,
                ),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          ...children,
        ],
      ),
    );
  }

  List<Widget> _buildAdditionalCosts(
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    List<Widget> widgets = [];

    for (int i = 0; i < _costNameControllers.length; i++) {
      widgets.add(
        Container(
          margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: themeProvider.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: themeProvider.borderColor),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cost ${i + 1}',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: themeProvider.textPrimary,
                    ),
                  ),
                  if (_costNameControllers.length > 1)
                    IconButton(
                      onPressed: () => _removeCostField(i),
                      icon: Icon(
                        Icons.delete_outline,
                        size: isMobile ? 20 : 22,
                      ),
                      color: Colors.red,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _costNameControllers[i],
                style: TextStyle(color: themeProvider.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Cost name',
                  hintStyle: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: themeProvider.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: themeProvider.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: themeProvider.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: themeProvider.primaryMain,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 14,
                    vertical: isMobile ? 10 : 12,
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _costAmountControllers[i],
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                style: TextStyle(color: themeProvider.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Amount',
                  hintStyle: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: themeProvider.textSecondary,
                  ),
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: themeProvider.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: themeProvider.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: themeProvider.primaryMain,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 14,
                    vertical: isMobile ? 10 : 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildCurrencyField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required ThemeProvider themeProvider,
    required bool isMobile,
    required IconData icon,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: isMobile ? 16 : 18,
              color: themeProvider.textSecondary,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w500,
                color: themeProvider.textPrimary,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        SizedBox(height: isMobile ? 6 : 8),

        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          inputFormatters: [CurrencyInputFormatter()],
          style: TextStyle(color: themeProvider.textPrimary),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return '$label wajib diisi';
            }
            if (value != null && value.isNotEmpty) {
              final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
              if (cleanValue.isEmpty) {
                return '$label tidak valid';
              }
              final price = double.tryParse(cleanValue);
              if (price == null || price <= 0) {
                return '$label harus lebih dari 0';
              }
            }
            return null;
          },
          onFieldSubmitted: (_) {
            if (nextFocusNode != null) {
              FocusScope.of(context).requestFocus(nextFocusNode);
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: themeProvider.textSecondary),
            prefixText: 'Rp ',
            prefixStyle: TextStyle(
              color: themeProvider.textPrimary,
              fontSize: isMobile ? 14 : 16,
            ),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: themeProvider.backgroundColor,
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 12 : 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandDropdown(ThemeProvider themeProvider, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.branding_watermark,
              size: isMobile ? 16 : 18,
              color: themeProvider.textSecondary,
            ),
            SizedBox(width: 8),
            Text(
              'Brand',
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w500,
                color: themeProvider.textPrimary,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.red),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 6 : 8),

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: themeProvider.borderColor),
          ),
          child: DropdownButtonFormField<int>(
            value: _selectedBrandId,
            style: TextStyle(color: themeProvider.textPrimary),
            dropdownColor: themeProvider.surfaceColor,
            decoration: InputDecoration(
              hintText: _isBrandsLoading ? 'Loading brands...' : 'Select brand',
              hintStyle: TextStyle(color: themeProvider.textSecondary),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 12 : 16,
              ),
            ),
            items:
                _brands.map((brand) {
                  return DropdownMenuItem<int>(
                    value: brand.id,
                    child: Text(
                      brand.nama,
                      style: TextStyle(color: themeProvider.textPrimary),
                    ),
                  );
                }).toList(),
            onChanged:
                _isBrandsLoading
                    ? null
                    : (value) {
                      setState(() => _selectedBrandId = value);
                    },
            validator: (value) {
              if (value == null) {
                return 'Brand wajib dipilih';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductTypeDropdown(ThemeProvider themeProvider, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.category,
              size: isMobile ? 16 : 18,
              color: themeProvider.textSecondary,
            ),
            SizedBox(width: 8),
            Text(
              'Product Type',
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w500,
                color: themeProvider.textPrimary,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.red),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 6 : 8),

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: themeProvider.borderColor),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedProductType,
            style: TextStyle(color: themeProvider.textPrimary),
            dropdownColor: themeProvider.surfaceColor,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 12 : 16,
              ),
            ),
            items: [
              DropdownMenuItem(
                value: 'electronic',
                child: Text(
                  'Electronic',
                  style: TextStyle(color: themeProvider.textPrimary),
                ),
              ),
              DropdownMenuItem(
                value: 'accessories',
                child: Text(
                  'Accessories',
                  style: TextStyle(color: themeProvider.textPrimary),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() => _selectedProductType = value!);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required ThemeProvider themeProvider,
    required bool isMobile,
    required IconData icon,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool isRequired = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: isMobile ? 16 : 18,
              color: themeProvider.textSecondary,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w500,
                color: themeProvider.textPrimary,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        SizedBox(height: isMobile ? 6 : 8),

        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          validator: validator,
          onFieldSubmitted: (_) {
            if (nextFocusNode != null) {
              FocusScope.of(context).requestFocus(nextFocusNode);
            }
          },
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: themeProvider.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: themeProvider.textSecondary),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: themeProvider.backgroundColor,
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 12 : 16,
            ),
          ),
        ),
      ],
    );
  }
}
