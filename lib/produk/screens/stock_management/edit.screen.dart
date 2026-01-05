import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../config/theme_provider.dart';
import '../../../component/validation_handler.dart';
import '../../models/stock_management.dart';
import '../../models/product.dart';
import '../../services/management_service.dart';
import '../../services/product_service.dart';

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

class StockEditScreen extends StatefulWidget {
  final ProdukStok stock;
  final Map<String, dynamic>? productData;
  final Map<String, dynamic>? storeData;
  
  const StockEditScreen({
    super.key,
    required this.stock,
    this.productData,
    this.storeData,
  });

  @override
  State<StockEditScreen> createState() => _StockEditScreenState();
}

class _StockEditScreenState extends State<StockEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _productController = TextEditingController();
  final _storeController = TextEditingController();
  final _stockController = TextEditingController();
  
  int? _selectedProductId;
  int? _selectedStoreId;
  int _initialStock = 0;
  bool _isLoading = false;
  bool _isDataLoading = false;
  
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _stores = [];

  // Focus Nodes for better UX
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    
    // Set initial values from stock item
    _selectedProductId = widget.stock.posProdukId;
    _selectedStoreId = widget.stock.posTokoId;
    _initialStock = widget.stock.stok;
    _stockController.text = widget.stock.stok.toString();
    
    // Initialize focus nodes
    for (int i = 0; i < 3; i++) {
      _focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    _productController.dispose();
    _storeController.dispose();
    _stockController.dispose();
    _scrollController.dispose();
    
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    
    super.dispose();
  }

  void _incrementStock() {
    final currentValue = int.tryParse(_stockController.text) ?? 0;
    _stockController.text = (currentValue + 1).toString();
  }

  void _decrementStock() {
    final currentValue = int.tryParse(_stockController.text) ?? 0;
    if (currentValue > 0) {
      _stockController.text = (currentValue - 1).toString();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isDataLoading = true);
    try {
      // Load products from API
      final productsResponse = await ProductService.getAllProducts(
        page: 1,
        perPage: 1000,
      );
      
      if (productsResponse.success == true && productsResponse.data != null) {
        _products = productsResponse.data!.map((product) => {
          'id': product.id,
          'nama': product.nama,
          'merk': {'nama': product.merk?.nama ?? 'Unknown'},
          'warna': product.warna,
          'penyimpanan': product.penyimpanan,
        }).toList();
      }
      
      // Load stores from stock API and extract unique stores
      final stocksResponse = await StockService.getStocks(
        page: 1,
        perPage: 1000,
      );
      
      if (stocksResponse['success'] == true) {
        final dynamic responseData = stocksResponse['data'];
        List<dynamic> stocksData = [];
        if (responseData is List) {
          stocksData = responseData;
        } else if (responseData is Map && responseData['data'] is List) {
          stocksData = responseData['data'];
        }
        
        // Extract unique stores from stock data
        final Set<int> storeIds = {};
        final List<Map<String, dynamic>> uniqueStores = [];
        
        for (var stockData in stocksData) {
          if (stockData['toko'] != null) {
            final tokoId = stockData['pos_toko_id'] ?? stockData['posTokoId'];
            if (tokoId != null && !storeIds.contains(tokoId)) {
              storeIds.add(tokoId);
              uniqueStores.add({
                'id': tokoId,
                'nama': stockData['toko']['nama'],
                'alamat': stockData['toko']['alamat'] ?? '',
              });
            }
          }
        }
        
        _stores = uniqueStores;
      }
      
      // Set product and store controllers if data is provided
      if (widget.productData != null) {
        final product = widget.productData!;
        _productController.text = '${product['nama']} - ${product['merk']?['nama'] ?? ''}';
      }
      
      if (widget.storeData != null) {
        final store = widget.storeData!;
        _storeController.text = store['nama'] ?? '';
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      setState(() => _isDataLoading = false);
    }
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
          'Edit Stock',
          style: TextStyle(color: themeProvider.textPrimary),
        ),
        backgroundColor: themeProvider.surfaceColor,
        elevation: 0,
        iconTheme: IconThemeData(color: themeProvider.textPrimary),
        actions: [
          if (!_isLoading)
            TextButton.icon(
              onPressed: _saveChanges,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              style: TextButton.styleFrom(
                foregroundColor: themeProvider.primaryMain,
              ),
            ),
        ],
      ),
      body: _isLoading || _isDataLoading
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
                    _buildHeaderCard(themeProvider, isMobile),
                    SizedBox(height: isMobile ? 20 : 24),

                    // Product Information Section
                    _buildProductInfoSection(themeProvider, isMobile),
                    SizedBox(height: isMobile ? 20 : 24),

                    // Stock Quantity Section
                    _buildStockQuantitySection(themeProvider, isMobile),
                    SizedBox(height: isMobile ? 32 : 40),

                    // Submit Button
                    _buildSubmitButton(themeProvider, isMobile),
                    SizedBox(height: isMobile ? 16 : 20),
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
                  'Edit Stock',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Update stock information and quantity',
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
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
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
    if (_isDataLoading) {
      return _buildSectionCard(
        title: 'Product & Store Information',
        icon: Icons.info_outline,
        themeProvider: themeProvider,
        isMobile: isMobile,
        children: [
          Center(
            child: CircularProgressIndicator(
              color: themeProvider.primaryMain,
            ),
          ),
        ],
      );
    }

    final productName = widget.productData?['nama'] ?? 'Unknown Product';
    final brandName = widget.productData?['merk']?['nama'] ?? 'Unknown Brand';
    final warna = widget.productData?['warna'];
    final penyimpanan = widget.productData?['penyimpanan'];
    final storeName = widget.storeData?['nama'] ?? 'Unknown Store';
    final storeAddress = widget.storeData?['alamat'];

    return _buildSectionCard(
      title: 'Product & Store Information',
      icon: Icons.info_outline,
      themeProvider: themeProvider,
      isMobile: isMobile,
      children: [
        // Product Info (Read-only)
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: themeProvider.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: themeProvider.borderColor.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag,
                    size: isMobile ? 16 : 18,
                    color: themeProvider.textSecondary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Product',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: themeProvider.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                productName,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.textPrimary,
                ),
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 8 : 10,
                      vertical: isMobile ? 4 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: themeProvider.primaryMain.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.business,
                          size: isMobile ? 10 : 12,
                          color: themeProvider.primaryMain,
                        ),
                        SizedBox(width: 4),
                        Text(
                          brandName,
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 12,
                            fontWeight: FontWeight.w500,
                            color: themeProvider.primaryMain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (warna != null || penyimpanan != null) ...[
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 8 : 10,
                        vertical: isMobile ? 4 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        [
                          if (warna != null) warna,
                          if (penyimpanan != null) '${penyimpanan}GB',
                        ].join(' • '),
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        
        SizedBox(height: isMobile ? 12 : 16),
        
        // Store Info (Read-only)
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: themeProvider.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: themeProvider.borderColor.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.store,
                    size: isMobile ? 16 : 18,
                    color: themeProvider.textSecondary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Store',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: themeProvider.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                storeName,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.textPrimary,
                ),
              ),
              if (storeAddress != null && storeAddress.isNotEmpty) ...[
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: isMobile ? 12 : 14,
                      color: themeProvider.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        storeAddress,
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          color: themeProvider.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStockQuantitySection(ThemeProvider themeProvider, bool isMobile) {
    return _buildSectionCard(
      title: 'Stock Quantity',
      icon: Icons.inventory,
      themeProvider: themeProvider,
      isMobile: isMobile,
      children: [
        // Current stock info
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue.shade700,
                size: isMobile ? 16 : 18,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Current stock: $_initialStock units',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: isMobile ? 16 : 20),
        
        // Quantity field with increment/decrement
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.format_list_numbered,
                  size: isMobile ? 16 : 18,
                  color: themeProvider.textSecondary,
                ),
                SizedBox(width: 8),
                Text(
                  'New Quantity *',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w500,
                    color: themeProvider.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 8 : 12),
            Row(
              children: [
                // Decrement button
                Container(
                  width: isMobile ? 44 : 52,
                  height: isMobile ? 44 : 52,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: themeProvider.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _decrementStock,
                    icon: Icon(
                      Icons.remove,
                      color: themeProvider.textPrimary,
                      size: isMobile ? 20 : 24,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
                
                SizedBox(width: isMobile ? 12 : 16),
                
                // Quantity field
                Expanded(
                  child: TextFormField(
                    controller: _stockController,
                    focusNode: _focusNodes[2],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textPrimary,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter quantity';
                      }
                      final quantity = int.tryParse(value);
                      if (quantity == null || quantity < 0) {
                        return 'Please enter a valid quantity';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: '0',
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
                ),
                
                SizedBox(width: isMobile ? 12 : 16),
                
                // Increment button
                Container(
                  width: isMobile ? 44 : 52,
                  height: isMobile ? 44 : 52,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: themeProvider.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _incrementStock,
                    icon: Icon(
                      Icons.add,
                      color: themeProvider.textPrimary,
                      size: isMobile ? 20 : 24,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductDropdown(ThemeProvider themeProvider, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.shopping_bag,
              size: isMobile ? 16 : 18,
              color: themeProvider.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Product *',
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w500,
                color: themeProvider.textPrimary,
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
            value: _selectedProductId,
            isDense: true,
            decoration: InputDecoration(
              hintText: 'Select product',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 8 : 12,
              ),
            ),
            validator: (value) {
              if (value == null) return 'Please select a product';
              return null;
            },
            items: _products.map<DropdownMenuItem<int>>((product) {
              return DropdownMenuItem<int>(
                value: product['id'],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product['nama'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product['merk']['nama'],
                      style: TextStyle(
                        fontSize: 11,
                        color: themeProvider.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedProductId = value;
                final product = _products.firstWhere((p) => p['id'] == value);
                _productController.text = '${product['nama']} - ${product['merk']['nama']}';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStoreDropdown(ThemeProvider themeProvider, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.store,
              size: isMobile ? 16 : 18,
              color: themeProvider.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Store *',
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w500,
                color: themeProvider.textPrimary,
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
            value: _selectedStoreId,
            isDense: true,
            decoration: InputDecoration(
              hintText: 'Select store',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 8 : 12,
              ),
            ),
            validator: (value) {
              if (value == null) return 'Please select a store';
              return null;
            },
            items: _stores.map<DropdownMenuItem<int>>((store) {
              return DropdownMenuItem<int>(
                value: store['id'],
                child: Text(store['nama']),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStoreId = value;
                final store = _stores.firstWhere((s) => s['id'] == value);
                _storeController.text = store['nama'];
              });
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
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 12,
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

  Widget _buildSubmitButton(ThemeProvider themeProvider, bool isMobile) {
    return SizedBox(
      width: double.infinity,
      height: isMobile ? 48 : 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeProvider.primaryMain,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: themeProvider.primaryMain.withOpacity(0.3),
        ),
        child: _isLoading
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
                    'Saving...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.save_rounded,
                    size: isMobile ? 18 : 20,
                    color: Colors.white,
                  ),
                  SizedBox(width: isMobile ? 8 : 12),
                  Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final newQuantity = int.parse(_stockController.text);
      final difference = newQuantity - _initialStock;
      
      if (difference == 0) {
        // No changes, just close and return success
        if (mounted) {
          await ValidationHandler.showSuccessDialog(
            context: context,
            title: 'Success',
            message: 'No changes made to stock quantity',
          );
          Navigator.pop(context, true);
        }
        return;
      }
      
      // Call API to adjust stock
      final result = await StockService.adjustStock(
        posProdukId: widget.stock.posProdukId,
        posTokoId: widget.stock.posTokoId,
        jumlah: difference.abs(),
        tipe: difference > 0 ? 'masuk' : 'keluar',
        keterangan: 'Stock quantity updated from $_initialStock to $newQuantity',
      );
      
      if (mounted) {
        if (result['success']) {
          await ValidationHandler.showSuccessDialog(
            context: context,
            title: 'Success',
            message: result['message'] ?? 'Stock updated successfully!',
          );
          Navigator.pop(context, true);
        } else {
          await ValidationHandler.showErrorDialog(
            context: context,
            title: 'Error',
            message: result['message'] ?? 'Failed to update stock',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        await ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'Failed to update stock: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}