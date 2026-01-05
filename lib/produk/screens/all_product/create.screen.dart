import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../config/theme_provider.dart';
import '../../../component/validation_handler.dart';
import '../../services/product_service.dart';
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

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
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
    _addCostField(); // Add initial cost field

    // Initialize focus nodes
    for (int i = 0; i < 10; i++) {
      _focusNodes.add(FocusNode());
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

    for (var controller in _costNameControllers) {
      controller.dispose();
    }
    for (var controller in _costAmountControllers) {
      controller.dispose();
    }

    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  Future<void> _loadBrands() async {
    setState(() => _isBrandsLoading = true);

    try {
      final response = await ProductService.getProductBrands();
      if (response.success == true && response.data != null) {
        setState(() {
          _brands = response.data!;
        });
      }
    } catch (e) {
      debugPrint('Error loading brands: $e');
    } finally {
      setState(() => _isBrandsLoading = false);
    }
  }

  void _addCostField() {
    setState(() {
      _costNameControllers.add(TextEditingController());
      _costAmountControllers.add(TextEditingController());
    });
  }

  void _removeCostField(int index) {
    if (_costNameControllers.length > 1) {
      setState(() {
        _costNameControllers[index].dispose();
        _costAmountControllers[index].dispose();
        _costNameControllers.removeAt(index);
        _costAmountControllers.removeAt(index);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Prepare additional costs
      Map<String, double> biayaTambahan = {};
      for (int i = 0; i < _costNameControllers.length; i++) {
        final name = _costNameControllers[i].text.trim();
        final amountText = _costAmountControllers[i].text.trim();

        if (name.isNotEmpty && amountText.isNotEmpty) {
          final amount = double.tryParse(amountText);
          if (amount != null) {
            biayaTambahan[name] = amount;
          }
        }
      }

      // Clean currency formatting before parsing
      final cleanBuyPrice = _hargaBeliController.text.replaceAll(
        RegExp(r'[^\d]'),
        '',
      );
      final cleanSellPrice = _hargaJualController.text.replaceAll(
        RegExp(r'[^\d]'),
        '',
      );

      final response = await ProductService.createProduct(
        nama: null, // Auto-generated by backend based on brand + specs
        merkId: _selectedBrandId!,
        productType: _selectedProductType,
        deskripsi:
            _deskripsiController.text.trim().isEmpty
                ? null
                : _deskripsiController.text.trim(),
        warna:
            _warnaController.text.trim().isEmpty
                ? null
                : _warnaController.text.trim(),
        penyimpanan:
            _penyimpananController.text.trim().isEmpty
                ? null
                : _penyimpananController.text.trim(),
        batteryHealth:
            _batteryHealthController.text.trim().isEmpty
                ? null
                : _batteryHealthController.text.trim(),
        hargaBeli: double.parse(cleanBuyPrice),
        hargaJual: double.parse(cleanSellPrice),
        biayaTambahan: biayaTambahan.isEmpty ? null : biayaTambahan,
        imei: _imeiController.text.trim(),
        aksesoris:
            _aksesorisController.text.trim().isEmpty
                ? null
                : _aksesorisController.text.trim(),
      );

      if (response.success == true) {
        if (mounted) {
          await ValidationHandler.showSuccessDialog(
            context: context,
            title: 'Success',
            message: response.message ?? 'Product has been created successfully!',
          );
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          await ValidationHandler.showErrorDialog(
            context: context,
            title: 'Error',
            message: response.message ?? 'Failed to create product',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        await ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'Failed to create product: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.surfaceColor,
        elevation: 0,
        title: Text(
          'Create Product',
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: themeProvider.textPrimary),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _submitForm,
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              _buildHeaderCard(themeProvider, isMobile),

              SizedBox(height: isMobile ? 16 : 24),

              // Product Information Section
              _buildProductInfoSection(themeProvider, isMobile),

              SizedBox(height: isMobile ? 16 : 24),

              // Specifications Section (hide for accessories)
              if (_selectedProductType != 'accessories') ...[
                _buildSpecificationsSection(themeProvider, isMobile),
                SizedBox(height: isMobile ? 16 : 24),
              ],

              // Pricing Section
              _buildPricingSection(themeProvider, isMobile),

              SizedBox(height: isMobile ? 16 : 24),

              // Additional Costs Section
              _buildAdditionalCostsSection(themeProvider, isMobile),

              SizedBox(height: isMobile ? 16 : 24),

              // Device Information Section (hide for accessories)
              if (_selectedProductType != 'accessories') ...[
                _buildDeviceInfoSection(themeProvider, isMobile),
                SizedBox(height: isMobile ? 16 : 24),
              ],

              SizedBox(height: isMobile ? 16 : 24),

              // Submit Button
              _buildSubmitButton(themeProvider, isMobile),

              SizedBox(height: isMobile ? 16 : 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ThemeProvider themeProvider, bool isMobile) {
    return Container(
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
              Icons.add_box,
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
                  'New Product',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Create a new product with detailed specifications',
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
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required ThemeProvider themeProvider,
    required bool isMobile,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeProvider.borderColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: themeProvider.backgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(
                  color: themeProvider.borderColor.withOpacity(0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 6 : 8),
                  decoration: BoxDecoration(
                    color: themeProvider.primaryMain.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: themeProvider.primaryMain,
                    size: isMobile ? 16 : 18,
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 12),
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
          ),

          // Section Content
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfoSection(ThemeProvider themeProvider, bool isMobile) {
    return _buildSectionCard(
      title: 'Product Information',
      icon: Icons.info_outline,
      themeProvider: themeProvider,
      isMobile: isMobile,
      children: [
        // Brand Dropdown
        _buildBrandDropdown(themeProvider, isMobile),

        SizedBox(height: isMobile ? 16 : 20),

        // Product Type
        _buildProductTypeDropdown(themeProvider, isMobile),

        SizedBox(height: isMobile ? 16 : 20),

        // Description
        _buildFormField(
          label: 'Description',
          hint: 'Enter product description (optional)',
          controller: _deskripsiController,
          focusNode: _focusNodes[1],
          nextFocusNode: _focusNodes[2],
          themeProvider: themeProvider,
          isMobile: isMobile,
          icon: Icons.description,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildSpecificationsSection(
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    return _buildSectionCard(
      title: 'Specifications',
      icon: Icons.settings,
      themeProvider: themeProvider,
      isMobile: isMobile,
      children: [
        Row(
          children: [
            // Color
            Expanded(
              child: _buildFormField(
                label: 'Color',
                hint: 'e.g., Black, White',
                controller: _warnaController,
                focusNode: _focusNodes[2],
                nextFocusNode: _focusNodes[3],
                themeProvider: themeProvider,
                isMobile: isMobile,
                icon: Icons.palette,
              ),
            ),

            SizedBox(width: isMobile ? 12 : 16),

            // Storage
            Expanded(
              child: _buildFormField(
                label: 'Storage (GB)',
                hint: 'e.g., 256',
                controller: _penyimpananController,
                focusNode: _focusNodes[3],
                nextFocusNode: _focusNodes[4],
                themeProvider: themeProvider,
                isMobile: isMobile,
                icon: Icons.storage,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),

        SizedBox(height: isMobile ? 16 : 20),

        // Battery Health
        _buildFormField(
          label: 'Battery Health (%)',
          hint: 'e.g., 85',
          controller: _batteryHealthController,
          focusNode: _focusNodes[4],
          nextFocusNode: _focusNodes[5],
          themeProvider: themeProvider,
          isMobile: isMobile,
          icon: Icons.battery_std,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
        ),
      ],
    );
  }

  Widget _buildPricingSection(ThemeProvider themeProvider, bool isMobile) {
    return _buildSectionCard(
      title: 'Pricing',
      icon: Icons.attach_money,
      themeProvider: themeProvider,
      isMobile: isMobile,
      children: [
        Row(
          children: [
            // Buy Price
            Expanded(
              child: _buildFormField(
                label: 'Buy Price',
                hint: 'Enter buy price',
                controller: _hargaBeliController,
                focusNode: _focusNodes[5],
                nextFocusNode: _focusNodes[6],
                themeProvider: themeProvider,
                isMobile: isMobile,
                icon: Icons.shopping_cart,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Buy price is required';
                  }
                  final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
                  final price = double.tryParse(cleanValue);
                  if (price == null || price <= 0) {
                    return 'Buy price must be greater than 0';
                  }
                  return null;
                },
              ),
            ),

            SizedBox(width: isMobile ? 12 : 16),

            // Sell Price
            Expanded(
              child: _buildFormField(
                label: 'Sell Price',
                hint: 'Enter sell price',
                controller: _hargaJualController,
                focusNode: _focusNodes[6],
                nextFocusNode: _focusNodes[7],
                themeProvider: themeProvider,
                isMobile: isMobile,
                icon: Icons.sell,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Sell price is required';
                  }
                  final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
                  final price = double.tryParse(cleanValue);
                  if (price == null || price <= 0) {
                    return 'Sell price must be greater than 0';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalCostsSection(
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    return _buildSectionCard(
      title: 'Additional Costs',
      icon: Icons.receipt_long,
      themeProvider: themeProvider,
      isMobile: isMobile,
      children: [
        ...List.generate(_costNameControllers.length, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: isMobile ? 12 : 16),
            child: Row(
              children: [
                // Cost Name
                Expanded(
                  flex: 2,
                  child: _buildFormField(
                    label: 'Cost Name',
                    hint: 'e.g., Packaging',
                    controller: _costNameControllers[index],
                    themeProvider: themeProvider,
                    isMobile: isMobile,
                    icon: Icons.label_outline,
                  ),
                ),

                SizedBox(width: isMobile ? 8 : 12),

                // Cost Amount
                Expanded(
                  flex: 1,
                  child: _buildFormField(
                    label: 'Amount',
                    hint: '0',
                    controller: _costAmountControllers[index],
                    themeProvider: themeProvider,
                    isMobile: isMobile,
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                  ),
                ),

                SizedBox(width: isMobile ? 8 : 12),

                // Remove Button
                if (_costNameControllers.length > 1)
                  IconButton(
                    onPressed: () => _removeCostField(index),
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                      size: isMobile ? 20 : 24,
                    ),
                  ),
              ],
            ),
          );
        }),

        // Add Cost Button
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: _addCostField,
            icon: Icon(Icons.add, size: isMobile ? 16 : 18),
            label: Text(
              'Add Additional Cost',
              style: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
            style: TextButton.styleFrom(
              foregroundColor: themeProvider.primaryMain,
              side: BorderSide(
                color: themeProvider.primaryMain.withOpacity(0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceInfoSection(ThemeProvider themeProvider, bool isMobile) {
    return _buildSectionCard(
      title: 'Device Information',
      icon: Icons.phone_android,
      themeProvider: themeProvider,
      isMobile: isMobile,
      children: [
        // IMEI
        _buildFormField(
          label: 'IMEI',
          hint: 'Enter device IMEI',
          controller: _imeiController,
          focusNode: _focusNodes[7],
          nextFocusNode: _focusNodes[8],
          themeProvider: themeProvider,
          isMobile: isMobile,
          icon: Icons.qr_code,
          isRequired: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'IMEI is required';
            }
            return null;
          },
        ),

        SizedBox(height: isMobile ? 16 : 20),

        // Accessories
        _buildFormField(
          label: 'Accessories',
          hint: 'e.g., Charger, Cable, Box',
          controller: _aksesorisController,
          focusNode: _focusNodes[8],
          themeProvider: themeProvider,
          isMobile: isMobile,
          icon: Icons.headphones,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildSubmitButton(ThemeProvider themeProvider, bool isMobile) {
    return SizedBox(
      width: double.infinity,
      height: isMobile ? 48 : 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeProvider.primaryMain,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: themeProvider.primaryMain.withOpacity(0.3),
        ),
        child:
            _isLoading
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: isMobile ? 16 : 20,
                      height: isMobile ? 16 : 20,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    Text(
                      'Creating Product...',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.save,
                      size: isMobile ? 18 : 20,
                      color: Colors.white,
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    Text(
                      'Create Product',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
      ),
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
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: Colors.red,
              ),
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
            style: TextStyle(
              color: themeProvider.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: _isBrandsLoading ? 'Loading brands...' : 'Select brand',
              hintStyle: TextStyle(
                color: themeProvider.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 12 : 16,
              ),
            ),
            dropdownColor: themeProvider.surfaceColor,
            items:
                _brands.map((brand) {
                  return DropdownMenuItem<int>(
                    value: brand.id,
                    child: Text(
                      brand.nama,
                      style: TextStyle(
                        color: themeProvider.textPrimary,
                      ),
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
              if (value == null) return 'Brand is required';
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
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: Colors.red,
              ),
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
            style: TextStyle(
              color: themeProvider.textPrimary,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 12 : 16,
              ),
            ),
            dropdownColor: themeProvider.surfaceColor,
            items: [
              DropdownMenuItem(
                value: 'electronic',
                child: Text(
                  'Electronic',
                  style: TextStyle(
                    color: themeProvider.textPrimary,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 'accessories',
                child: Text(
                  'Accessories',
                  style: TextStyle(
                    color: themeProvider.textPrimary,
                  ),
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
            hintStyle: TextStyle(
              color: themeProvider.textSecondary,
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
}
