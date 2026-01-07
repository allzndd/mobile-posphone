import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config/theme_provider.dart';
import '../../../core/api_config.dart';
import '../../../component/validation_handler.dart';
import '../../../auth/services/auth_service.dart';
import '../../services/management_service.dart';
import '../../services/product_service.dart';

class StockCreateScreen extends StatefulWidget {
  const StockCreateScreen({super.key});

  @override
  State<StockCreateScreen> createState() => _StockCreateScreenState();
}

class _StockCreateScreenState extends State<StockCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _productController = TextEditingController();
  final _storeController = TextEditingController();
  final _stockController = TextEditingController();
  
  int? _selectedProductId;
  int? _selectedStoreId;
  int _currentStock = 0;
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

  Future<void> _checkExistingStock() async {
    if (_selectedProductId == null || _selectedStoreId == null) {
      setState(() => _currentStock = 0);
      return;
    }

    try {
      final stocksResponse = await StockService.getStocks(
        page: 1,
        perPage: 100,
      );

      if (stocksResponse['success'] == true) {
        final dynamic responseData = stocksResponse['data'];
        List<dynamic> stocksData = [];
        if (responseData is List) {
          stocksData = responseData;
        } else if (responseData is Map && responseData['data'] is List) {
          stocksData = responseData['data'];
        }

        // Find existing stock for this product-store combination
        final existingStock = stocksData.firstWhere(
          (stock) =>
              (stock['pos_produk_id'] ?? stock['posProdukId']) == _selectedProductId &&
              (stock['pos_toko_id'] ?? stock['posTokoId']) == _selectedStoreId,
          orElse: () => null,
        );

        if (existingStock != null) {
          setState(() {
            _currentStock = existingStock['stok'] ?? 0;
            _stockController.text = _currentStock.toString();
          });
        } else {
          setState(() {
            _currentStock = 0;
            if (_stockController.text.isEmpty) {
              _stockController.text = '0';
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking existing stock: $e');
      setState(() => _currentStock = 0);
    }
  }

  void _incrementStock() {
    final currentValue = int.tryParse(_stockController.text) ?? 0;
    setState(() {
      _stockController.text = (currentValue + 1).toString();
    });
  }

  void _decrementStock() {
    final currentValue = int.tryParse(_stockController.text) ?? 0;
    if (currentValue > 0) {
      setState(() {
        _stockController.text = (currentValue - 1).toString();
      });
    }
  }

  Future<void> _loadData() async {
    setState(() => _isDataLoading = true);
    try {
      // Load products from API
      final productsResponse = await ProductService.getAllProducts(
        page: 1,
        perPage: 1000, // Get all products
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
      
      // Load stores directly from Store API
      try {
        final storesResponse = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/api/stores'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await AuthService.getToken()}',
          },
        );
        
        if (storesResponse.statusCode == 200) {
          final Map<String, dynamic> responseBody = jsonDecode(storesResponse.body);
          if (responseBody['success'] == true && responseBody['data'] != null) {
            final List<dynamic> storeData = responseBody['data'];
            _stores = storeData.map<Map<String, dynamic>>((store) => {
              'id': store['id'],
              'nama': store['nama'],
            }).toList();
          }
        }
      } catch (e) {
        debugPrint('Error loading stores: $e');
        // Fallback: Load stores from stock data if direct API fails
        await _loadStoresFromStockData();
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) {
        await _showErrorMessage('Failed to load data: $e');
      }
    } finally {
      setState(() => _isDataLoading = false);
    }
  }

  Future<void> _loadStoresFromStockData() async {
    try {
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
              });
            }
          }
        }
        
        _stores = uniqueStores;
      }
    } catch (e) {
      debugPrint('Error loading stores from stock data: $e');
    }
  }

  Future<void> _showSuccessMessage(String message) async {
    await ValidationHandler.showSuccessDialog(
      context: context,
      title: 'Success',
      message: message,
    );
  }

  Future<void> _showErrorMessage(String message) async {
    await ValidationHandler.showErrorDialog(
      context: context,
      title: 'Error',
      message: message,
    );
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
          'Add Stock',
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: themeProvider.textPrimary),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveStock,
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

              // Stock Quantity Section
              _buildStockQuantitySection(themeProvider, isMobile),

              SizedBox(height: isMobile ? 32 : 48),

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
              Icons.inventory_2,
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
                  'Stock Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add stock quantity for product in store',
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
                    fontWeight: FontWeight.w600,
                    color: themeProvider.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: themeProvider.textPrimary,
      ),
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
            const SizedBox(width: 8),
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
        onPressed: _isLoading ? null : _saveStock,
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
                    Icons.save,
                    size: isMobile ? 18 : 20,
                    color: Colors.white,
                  ),
                  SizedBox(width: isMobile ? 8 : 12),
                  Text(
                    'Create Stock',
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

  Future<void> _saveStock() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedProductId == null || _selectedStoreId == null) {
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final quantity = int.parse(_stockController.text);
      
      // Call API to adjust stock (add new stock)
      final result = await StockService.adjustStock(
        posProdukId: _selectedProductId!,
        posTokoId: _selectedStoreId!,
        jumlah: quantity,
        tipe: 'masuk',
        keterangan: 'Initial stock entry',
      );
      
      if (mounted) {
        if (result['success']) {
          await _showSuccessMessage(result['message'] ?? 'Stock saved successfully!');
          Navigator.pop(context, true);
        } else {
          await _showErrorMessage(result['message'] ?? 'Failed to save stock');
        }
      }
    } catch (e) {
      if (mounted) {
        await _showErrorMessage('Failed to save stock: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildProductInfoSection(ThemeProvider themeProvider, bool isMobile) {
    if (_isDataLoading) {
      return _buildSectionCard(
        title: 'Product Information',
        icon: Icons.info_outline,
        themeProvider: themeProvider,
        isMobile: isMobile,
        children: [
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    return _buildSectionCard(
      title: 'Product Information',
      icon: Icons.info_outline,
      themeProvider: themeProvider,
      isMobile: isMobile,
      children: [
        _buildProductDropdown(themeProvider, isMobile),
        SizedBox(height: isMobile ? 16 : 20),
        _buildStoreDropdown(themeProvider, isMobile),
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
        if (_currentStock > 0)
          Container(
            margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                  size: isMobile ? 18 : 20,
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Expanded(
                  child: Text(
                    'Current stock: $_currentStock units',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: isMobile ? 13 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                const SizedBox(width: 8),
                Text(
                  'Quantity',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w500,
                    color: themeProvider.textPrimary,
                  ),
                ),
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
            Row(
              children: [
                // Decrement button
                Container(
                  width: isMobile ? 44 : 50,
                  height: isMobile ? 44 : 50,
                  decoration: BoxDecoration(
                    color: themeProvider.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: themeProvider.borderColor),
                  ),
                  child: IconButton(
                    onPressed: _decrementStock,
                    icon: Icon(
                      Icons.remove,
                      size: isMobile ? 18 : 20,
                      color: themeProvider.primaryMain,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 12),
                // Quantity field
                Expanded(
                  child: TextFormField(
                    controller: _stockController,
                    focusNode: _focusNodes[2],
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
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
                      hintText: 'Enter stock quantity',
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
                SizedBox(width: isMobile ? 8 : 12),
                // Increment button
                Container(
                  width: isMobile ? 44 : 50,
                  height: isMobile ? 44 : 50,
                  decoration: BoxDecoration(
                    color: themeProvider.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: themeProvider.borderColor),
                  ),
                  child: IconButton(
                    onPressed: _incrementStock,
                    icon: Icon(
                      Icons.add,
                      size: isMobile ? 18 : 20,
                      color: themeProvider.primaryMain,
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
            color: themeProvider.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: themeProvider.borderColor),
          ),
          child: DropdownButtonFormField<int>(
            value: _selectedProductId,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: themeProvider.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Select product',
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
            validator: (value) {
              if (value == null) return 'Please select a product';
              return null;
            },
            items: _products.map<DropdownMenuItem<int>>((product) {
              return DropdownMenuItem<int>(
                value: product['id'],
                child: Text(
                  product['nama'],
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: themeProvider.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedProductId = value;
                final product = _products.firstWhere((p) => p['id'] == value);
                _productController.text = product['nama'];
              });
              _checkExistingStock();
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
            color: themeProvider.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: themeProvider.borderColor),
          ),
          child: DropdownButtonFormField<int>(
            value: _selectedStoreId,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: themeProvider.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Select store',
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
            validator: (value) {
              if (value == null) return 'Please select a store';
              return null;
            },
            items: _stores.map<DropdownMenuItem<int>>((store) {
              return DropdownMenuItem<int>(
                value: store['id'],
                child: Text(
                  store['nama'],
                  style: TextStyle(
                    color: themeProvider.textPrimary,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStoreId = value;
                final store = _stores.firstWhere((s) => s['id'] == value);
                _storeController.text = store['nama'];
              });
              _checkExistingStock();
            },
          ),
        ),
      ],
    );
  }


}