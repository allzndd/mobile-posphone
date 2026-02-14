import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme_provider.dart';
import '../../../component/validation_handler.dart';
import '../../../suppliers/services/supplier_service.dart';
import '../../../suppliers/models/supplier.dart';
import '../../../store/services/store_service.dart';
import '../../../store/models/store.dart';
import '../../../produk/services/product_service.dart';
import '../../../produk/services/brand_service.dart';
import '../../../produk/models/product.dart';
import '../../../produk/models/product_brand.dart';
import '../../../ram/services/ram_service.dart';
import '../../../ram/models/ram.dart' as RamModel;
import '../../../color/services/color_service.dart';
import '../../../color/models/color.dart' as ColorModel;
import '../../../storage/services/storage_service.dart';
import '../../../storage/models/storage.dart';
import '../../services/outgoing_service.dart';

class OutgoingTransactionCreateScreen extends StatefulWidget {
  const OutgoingTransactionCreateScreen({super.key});

  @override
  State<OutgoingTransactionCreateScreen> createState() =>
      _OutgoingTransactionCreateScreenState();
}

class _OutgoingTransactionCreateScreenState
    extends State<OutgoingTransactionCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _keteranganController = TextEditingController();
  final _invoiceController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingSuppliers = false;
  bool _isLoadingStores = false;
  bool _isLoadingProducts = false;
  Map<String, String> _fieldErrors = {};

  // Dropdowns
  List<Supplier> _suppliers = [];
  List<Store> _stores = [];
  List<Product> _products = [];

  int? _selectedSupplierId;
  int? _selectedStoreId;
  String _selectedStatus = 'completed';
  String _selectedPaymentMethod = 'cash';

  // Transaction Items
  final List<Map<String, dynamic>> _items = [];

  final List<String> _statusOptions = ['pending', 'completed', 'cancelled'];
  final List<String> _paymentMethods = [
    'cash',
    'transfer',
    'e-wallet',
    'credit',
  ];

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
    _loadStores();
    _loadProducts();
    _generateInvoiceNumber();
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    _invoiceController.dispose();
    super.dispose();
  }

  void _generateInvoiceNumber() async {
    try {
      // Fetch last transaction to get last invoice number
      final response = await OutgoingService.getOutgoingTransactions(
        page: 1,
        perPage: 1,
      );

      int nextNumber = 1;
      final now = DateTime.now();
      final dateStr =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

      if (response['success'] == true) {
        final transactions = response['data'] as List;
        if (transactions.isNotEmpty) {
          final lastInvoice = transactions[0].invoice ?? '';
          debugPrint('Last invoice: $lastInvoice');

          // Parse last invoice number (format: INV-OUT-YYYYMMDD-XXXX)
          final parts = lastInvoice.split('-');
          if (parts.length == 4) {
            final lastDate = parts[2];
            final lastNumber = int.tryParse(parts[3]) ?? 0;

            // If same date, increment. Otherwise start from 1
            if (lastDate == dateStr) {
              nextNumber = lastNumber + 1;
            }
          }
        }
      }

      // Generate invoice: INV-OUT-YYYYMMDD-XXXX
      final invoiceNumber =
          'INV-OUT-$dateStr-${nextNumber.toString().padLeft(4, '0')}';

      if (mounted) {
        setState(() {
          _invoiceController.text = invoiceNumber;
        });
      }

      debugPrint('Generated invoice: $invoiceNumber');
    } catch (e) {
      debugPrint('Error generating invoice: $e');

      // Fallback: use 0001
      final now = DateTime.now();
      final dateStr =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      final invoiceNumber = 'INV-OUT-$dateStr-0001';

      if (mounted) {
        setState(() {
          _invoiceController.text = invoiceNumber;
        });
      }
    }
  }

  Future<void> _loadSuppliers() async {
    setState(() => _isLoadingSuppliers = true);
    try {
      final response = await SupplierService.getSuppliers();
      debugPrint('Supplier response: $response');
      if (response['success'] == true) {
        setState(() {
          _suppliers =
              (response['data'] as List)
                  .map((json) => Supplier.fromJson(json))
                  .toList();
        });
        debugPrint('Suppliers loaded: ${_suppliers.length} suppliers');
      } else {
        debugPrint('Failed to load suppliers: ${response['message']}');
      }
    } catch (e) {
      debugPrint('Error loading suppliers: $e');
    } finally {
      setState(() => _isLoadingSuppliers = false);
    }
  }

  Future<void> _loadStores() async {
    setState(() => _isLoadingStores = true);
    try {
      final response = await StoreService.getStores();
      debugPrint('Store response: $response');
      if (response['success'] == true) {
        setState(() {
          _stores =
              (response['data'] as List)
                  .map((json) => Store.fromJson(json))
                  .toList();
        });
        debugPrint('Stores loaded: ${_stores.length} stores');
      } else {
        debugPrint('Failed to load stores: ${response['message']}');
      }
    } catch (e) {
      debugPrint('Error loading stores: $e');
    } finally {
      setState(() => _isLoadingStores = false);
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoadingProducts = true);
    try {
      final response = await ProductService.getAllProducts(perPage: 100);
      if (response.success && response.data != null) {
        setState(() {
          _products = response.data!;
        });
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
    } finally {
      setState(() => _isLoadingProducts = false);
    }
  }

  Future<bool?> _showAddProductDialog() async {
    final result = await showDialog<Product>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _QuickAddProductDialog(
        key: UniqueKey(),
        onProductAdded: () async {
          await _loadProducts();
        },
      ),
    );

    // Jika ada product baru, langsung tambahkan ke items
    if (result != null) {
      setState(() {
        _items.add({
          'product': result,
          'product_id': result.id,
          'quantity': 1,
          'price': result.hargaBeli,
        });
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added to transaction!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }

    return result != null;
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
          'Create Transaction',
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: themeProvider.textPrimary),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveTransaction,
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
        child: CustomScrollView(
          slivers: [
            // Modern Header Card
            SliverToBoxAdapter(
              child: _buildHeaderCard(themeProvider, isMobile),
            ),

            // Transaction Basic Info Section
            SliverToBoxAdapter(
              child: _buildBasicInfoSection(themeProvider, isMobile),
            ),

            // Transaction Items Section
            SliverToBoxAdapter(
              child: _buildItemsSection(themeProvider, isMobile),
            ),

            // Transaction Summary Section
            SliverToBoxAdapter(
              child: _buildSummarySection(themeProvider, isMobile),
            ),

            // Submit Button Section
            SliverToBoxAdapter(
              child: _buildSubmitButton(themeProvider, isMobile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ThemeProvider themeProvider, bool isMobile) {
    return Container(
      margin: EdgeInsets.all(isMobile ? 16 : 24),
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
              Icons.shopping_bag_outlined,
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
                  'New Transaction',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Create a new outgoing sales transaction',
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

  Widget _buildBasicInfoSection(ThemeProvider themeProvider, bool isMobile) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        isMobile ? 16 : 24,
        0,
        isMobile ? 16 : 24,
        isMobile ? 16 : 24,
      ),
      child: _buildSectionCard(
        title: 'Transaction Information',
        icon: Icons.info_outline_rounded,
        children: [
          _buildModernTextField(
            controller: _invoiceController,
            label: 'Invoice Number',
            hint: 'Auto-generated invoice number',
            icon: Icons.receipt_long_rounded,
            themeProvider: themeProvider,
            isMobile: isMobile,
            isReadOnly: true,
            isRequired: true,
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildModernDropdown<int>(
            label: 'Supplier',
            hint: 'Select supplier',
            icon: Icons.business_rounded,
            value: _selectedSupplierId,
            items:
                _suppliers
                    .map(
                      (supplier) => DropdownMenuItem<int>(
                        value: supplier.id,
                        child: Text(supplier.nama ?? ''),
                      ),
                    )
                    .toList(),
            onChanged: (value) => setState(() => _selectedSupplierId = value),
            isLoading: _isLoadingSuppliers,
            validator:
                (value) => value == null ? 'Please select a supplier' : null,
            themeProvider: themeProvider,
            isMobile: isMobile,
            isRequired: true,
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildModernDropdown<int>(
            label: 'Store',
            hint: 'Select store',
            icon: Icons.store_rounded,
            value: _selectedStoreId,
            items:
                _stores
                    .map(
                      (store) => DropdownMenuItem<int>(
                        value: store.id,
                        child: Text(store.nama ?? ''),
                      ),
                    )
                    .toList(),
            onChanged: (value) => setState(() => _selectedStoreId = value),
            isLoading: _isLoadingStores,
            validator:
                (value) => value == null ? 'Please select a store' : null,
            themeProvider: themeProvider,
            isMobile: isMobile,
            isRequired: true,
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildModernDropdown<String>(
            label: 'Payment Method',
            hint: 'Select payment method',
            icon: Icons.payment_rounded,
            value: _selectedPaymentMethod,
            items:
                _paymentMethods
                    .map(
                      (method) => DropdownMenuItem<String>(
                        value: method,
                        child: Text(_formatPaymentMethodText(method)),
                      ),
                    )
                    .toList(),
            onChanged:
                (value) => setState(() => _selectedPaymentMethod = value!),
            validator:
                (value) =>
                    value == null || value.isEmpty
                        ? 'Please select a payment method'
                        : null,
            themeProvider: themeProvider,
            isMobile: isMobile,
            isRequired: true,
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildModernDropdown<String>(
            label: 'Status',
            hint: 'Select status',
            icon: Icons.flag_rounded,
            value: _selectedStatus,
            items:
                _statusOptions
                    .map(
                      (status) => DropdownMenuItem<String>(
                        value: status,
                        child: Text(
                          status[0].toUpperCase() + status.substring(1),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (value) => setState(() => _selectedStatus = value!),
            validator:
                (value) =>
                    value == null || value.isEmpty
                        ? 'Please select a status'
                        : null,
            themeProvider: themeProvider,
            isMobile: isMobile,
            isRequired: true,
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildModernTextField(
            controller: _keteranganController,
            label: 'Notes',
            hint: 'Enter transaction order notes (optional)',
            icon: Icons.note_rounded,
            maxLines: 3,
            themeProvider: themeProvider,
            isMobile: isMobile,
          ),
        ],
        themeProvider: themeProvider,
        isMobile: isMobile,
      ),
    );
  }

  Widget _buildItemsSection(ThemeProvider themeProvider, bool isMobile) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        isMobile ? 16 : 24,
        0,
        isMobile ? 16 : 24,
        isMobile ? 16 : 24,
      ),
      child: _buildSectionCard(
        title: 'Transaction Items',
        icon: Icons.inventory_2_outlined,
        children: [
          if (_items.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 20 : 30),
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: isMobile ? 48 : 64,
                      color: themeProvider.textTertiary,
                    ),
                    SizedBox(height: isMobile ? 8 : 12),
                    Text(
                      'No items added yet',
                      style: TextStyle(
                        color: themeProvider.textSecondary,
                        fontSize: isMobile ? 14 : 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildItemCard(item, index, themeProvider, isMobile);
            }).toList(),
          SizedBox(height: isMobile ? 12 : 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showAddItemDialog(themeProvider, isMobile),
              icon: const Icon(Icons.add_rounded),
              label: Text(
                'Add Item',
                style: TextStyle(fontSize: isMobile ? 14 : 16),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: themeProvider.primaryMain,
                side: BorderSide(color: themeProvider.primaryMain),
                padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
        themeProvider: themeProvider,
        isMobile: isMobile,
      ),
    );
  }

  Widget _buildItemCard(
    Map<String, dynamic> item,
    int index,
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    final product = item['product'] as Product?;
    final quantity = item['quantity'] as int;
    final price = item['price'] as int;
    final subtotal = quantity * price;

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: themeProvider.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product?.nama ?? 'Unknown Product',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: isMobile ? 14 : 16,
                        color: themeProvider.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Rp ${_formatPrice(price)} × $quantity',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: themeProvider.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() => _items.removeAt(index));
                },
                icon: const Icon(Icons.delete_outline_rounded),
                color: Colors.red,
                iconSize: isMobile ? 20 : 24,
              ),
            ],
          ),
          Divider(height: isMobile ? 16 : 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 13 : 15,
                  color: themeProvider.textPrimary,
                ),
              ),
              Text(
                'Rp ${_formatPrice(subtotal)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 14 : 16,
                  color: themeProvider.primaryMain,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(ThemeProvider themeProvider, bool isMobile) {
    final total = _items.fold<int>(0, (sum, item) {
      final quantity = item['quantity'] as int;
      final price = item['price'] as int;
      return sum + (quantity * price);
    });

    return Container(
      margin: EdgeInsets.fromLTRB(
        isMobile ? 16 : 24,
        0,
        isMobile ? 16 : 24,
        isMobile ? 16 : 24,
      ),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeProvider.primaryMain.withOpacity(0.1),
            themeProvider.primaryMain.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeProvider.primaryMain.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Items:',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: themeProvider.textSecondary,
                ),
              ),
              Text(
                '${_items.length}',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Divider(color: themeProvider.borderColor),
          SizedBox(height: isMobile ? 12 : 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand Total:',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                ),
              ),
              Text(
                'Rp ${_formatPrice(total)}',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 22,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.primaryMain,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Divider(color: themeProvider.borderColor),
          SizedBox(height: isMobile ? 12 : 16),
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: themeProvider.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeProvider.borderColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  color: themeProvider.primaryMain,
                  size: isMobile ? 20 : 24,
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          color: themeProvider.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Rp ${_formatPrice(total)}',
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 22,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.primaryMain,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(ThemeProvider themeProvider, bool isMobile) {
    Product? selectedProduct;
    final quantityController = TextEditingController(text: '1');
    final unitPriceController = TextEditingController();
    int subtotal = 0;
    bool controllersDisposed = false;

    void disposeControllers() {
      if (!controllersDisposed) {
        quantityController.dispose();
        unitPriceController.dispose();
        controllersDisposed = true;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => StatefulBuilder(
            builder: (context, setDialogState) {
              void calculateSubtotal() {
                final qty = int.tryParse(quantityController.text) ?? 0;
                final price = int.tryParse(unitPriceController.text) ?? 0;
                setDialogState(() {
                  subtotal = qty * price;
                });
              }

              return WillPopScope(
                onWillPop: () async {
                  disposeControllers();
                  return true;
                },
                child: AlertDialog(
                backgroundColor: themeProvider.surfaceColor,
                title: Text(
                  'Add Product',
                  style: TextStyle(color: themeProvider.textPrimary),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Dropdown with +New Button
                      Text(
                        'Product',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: themeProvider.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<Product>(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              value: selectedProduct,
                              hint: const Text('Select Product'),
                              isExpanded: true,
                              items:
                                  _products
                                      .map(
                                        (product) => DropdownMenuItem<Product>(
                                          value: product,
                                          child: Text(
                                            product.nama ?? '',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                setDialogState(() {
                                  selectedProduct = value;
                                  unitPriceController.text =
                                      (selectedProduct?.hargaBeli ?? 0).toString();
                                  calculateSubtotal();
                                });
                              },
                              dropdownColor: themeProvider.surfaceColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () async {
                                // Don't dispose controllers yet, just close dialog
                                Navigator.pop(dialogContext);
                                
                                // Show product creation dialog
                                final result = await _showAddProductDialog();
                                
                                // If product was not added and widget is still mounted, reopen this dialog
                                if (result != true && mounted) {
                                  // Give a small delay to ensure clean state
                                  await Future.delayed(const Duration(milliseconds: 100));
                                  
                                  // Reopen with new controllers since old ones are closed with the dialog
                                  _showAddItemDialog(themeProvider, isMobile);
                                } else if (!mounted) {
                                  // Widget unmounted, dispose controllers
                                  disposeControllers();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeProvider.primaryMain,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                '+New',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Quantity
                      Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: themeProvider.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: quantityController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => calculateSubtotal(),
                        style: TextStyle(color: themeProvider.textPrimary),
                      ),
                      const SizedBox(height: 16),

                      // Unit Price
                      Text(
                        'Unit Price',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: themeProvider.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: unitPriceController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          prefixText: 'Rp ',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => calculateSubtotal(),
                        style: TextStyle(color: themeProvider.textPrimary),
                      ),
                      const SizedBox(height: 16),

                      // Subtotal Display
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: themeProvider.primaryMain.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: themeProvider.primaryMain.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: themeProvider.textPrimary,
                              ),
                            ),
                            Text(
                              'Rp ${_formatPrice(subtotal)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.primaryMain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      disposeControllers();
                      Navigator.pop(dialogContext);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: themeProvider.textPrimary,
                    ),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedProduct != null) {
                        setState(() {
                          _items.add({
                            'product': selectedProduct,
                            'product_id': selectedProduct!.id,
                            'quantity':
                                int.tryParse(quantityController.text) ?? 1,
                            'price':
                                int.tryParse(unitPriceController.text) ?? 0,
                          });
                        });
                        disposeControllers();
                        Navigator.pop(dialogContext);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.primaryMain,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
            );
          },
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
                    size: isMobile ? 16 : 20,
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
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ThemeProvider themeProvider,
    required bool isMobile,
    String? Function(String?)? validator,
    String? errorText,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isReadOnly = false,
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
              color: themeProvider.primaryMain,
            ),
            SizedBox(width: isMobile ? 6 : 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: themeProvider.textPrimary,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        SizedBox(height: isMobile ? 8 : 10),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: isReadOnly,
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontSize: isMobile ? 14 : 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: themeProvider.textSecondary,
              fontSize: isMobile ? 14 : 16,
            ),
            errorText: errorText,
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 12 : 16,
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
            fillColor:
                isReadOnly
                    ? themeProvider.backgroundColor.withOpacity(0.5)
                    : themeProvider.backgroundColor,
          ),
        ),
      ],
    );
  }

  Widget _buildModernDropdown<T>({
    required String label,
    required String hint,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    required ThemeProvider themeProvider,
    required bool isMobile,
    String? Function(T?)? validator,
    bool isLoading = false,
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
              color: themeProvider.primaryMain,
            ),
            SizedBox(width: isMobile ? 6 : 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: themeProvider.textPrimary,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            if (isLoading) ...[
              SizedBox(width: isMobile ? 6 : 8),
              SizedBox(
                width: isMobile ? 12 : 16,
                height: isMobile ? 12 : 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: themeProvider.primaryMain,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: isMobile ? 8 : 10),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: isLoading ? null : onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: themeProvider.textSecondary,
              fontSize: isMobile ? 14 : 16,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 12 : 16,
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
            filled: true,
            fillColor: themeProvider.backgroundColor,
          ),
          dropdownColor: themeProvider.surfaceColor,
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontSize: isMobile ? 14 : 16,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(ThemeProvider themeProvider, bool isMobile) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        isMobile ? 16 : 24,
        0,
        isMobile ? 16 : 24,
        isMobile ? 24 : 32,
      ),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeProvider.primaryMain,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child:
            _isLoading
                ? SizedBox(
                  height: isMobile ? 20 : 24,
                  width: isMobile ? 20 : 24,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : Text(
                  'Create Transaction',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _formatPaymentMethodText(String method) {
    switch (method) {
      case 'cash':
        return 'Cash';
      case 'transfer':
        return 'Bank Transfer';
      case 'e-wallet':
        return 'E-Wallet';
      case 'credit':
        return 'Credit';
      default:
        return method[0].toUpperCase() + method.substring(1);
    }
  }

  Future<void> _saveTransaction() async {
    setState(() {
      _fieldErrors.clear();
    });

    if (!_formKey.currentState!.validate()) return;

    if (_items.isEmpty) {
      await ValidationHandler.showErrorDialog(
        context: context,
        title: 'Validation Error',
        message: 'Please add at least one item to the purchase order.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Calculate total
      final total = _items.fold<double>(0, (sum, item) {
        final quantity = item['quantity'] as int;
        final price = item['price'] as int;
        return sum + (quantity * price).toDouble();
      });

      final items =
          _items.map((item) {
            final quantity = item['quantity'] as int;
            final price = item['price'] as int;
            final subtotal = quantity * price;
            return {
              'pos_produk_id': item['product_id'],
              'quantity': quantity,
              'harga_satuan': price,
              'subtotal': subtotal,
              'diskon': 0,
            };
          }).toList();

      final response = await OutgoingService.createOutgoingTransaction(
        posTokoId: _selectedStoreId!,
        posSupplierId: _selectedSupplierId!,
        invoice: _invoiceController.text.trim(),
        totalHarga: total,
        keterangan: _keteranganController.text.trim(),
        status: _selectedStatus,
        metodePembayaran: _selectedPaymentMethod,
        items: items,
      );

      if (!response['success']) {
        if (mounted) {
          await ValidationHandler.showErrorDialog(
            context: context,
            title: 'Failed',
            message: response['message'] ?? 'Failed to create purchase order',
          );
        }
        return;
      }

      if (mounted) {
        await ValidationHandler.showSuccessDialog(
          context: context,
          title: 'Success',
          message:
              response['message'] ??
              'Purchase order has been created successfully!',
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
            Navigator.pop(context, true); // Return to previous screen
          },
        );

        // Generate new invoice number for next transaction if user stays
        _generateInvoiceNumber();
        // Clear form
        setState(() {
          _items.clear();
          _selectedSupplierId = null;
          _keteranganController.clear();
        });
      }
    } catch (e) {
      debugPrint('Error creating purchase order: $e');
      if (mounted) {
        await ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'An error occurred: ${e.toString()}',
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
}

// Quick Add Product Dialog Widget
class _QuickAddProductDialog extends StatefulWidget {
  final VoidCallback onProductAdded;

  const _QuickAddProductDialog({
    Key? key,
    required this.onProductAdded,
  }) : super(key: key);

  @override
  State<_QuickAddProductDialog> createState() => _QuickAddProductDialogState();
}

class _QuickAddProductDialogState extends State<_QuickAddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _imeiController = TextEditingController();
  final _batteryHealthController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  
  bool _isLoading = false;
  bool _isLoadingBrands = false;
  bool _isLoadingColors = false;
  bool _isLoadingRams = false;
  bool _isLoadingStorages = false;
  String _productType = 'electronic';
  List<ProductBrand> _brands = [];
  List<ColorModel.PosWarnaModel> _colors = [];
  List<RamModel.PosRamModel> _rams = [];
  List<Storage> _storages = [];
  int? _selectedBrandId;
  int? _selectedColorId;
  int? _selectedRamId;
  int? _selectedStorageId;

  @override
  void initState() {
    super.initState();
    _loadBrands();
    _loadColors();
    _loadRams();
    _loadStorages();
  }

  Future<void> _loadBrands() async {
    setState(() => _isLoadingBrands = true);
    try {
      final response = await BrandService.getBrands(perPage: 100);
      if (response['success'] == true && mounted) {
        setState(() {
          _brands = (response['data'] as List)
              .map((json) => ProductBrand.fromJson(json))
              .toList();
          // Select first brand by default if available
          if (_brands.isNotEmpty) {
            _selectedBrandId = _brands.first.id;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading brands: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingBrands = false);
      }
    }
  }

  Future<void> _showAddBrandDialog() async {
    final brandNameController = TextEditingController();
    final themeProvider = context.read<ThemeProvider>();
    final scaffoldContext = context;
    
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: themeProvider.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Add Product Name',
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: brandNameController,
          autofocus: true,
          style: TextStyle(
            color: themeProvider.textPrimary,
          ),
          decoration: InputDecoration(
            labelText: 'Product Name',
            hintText: 'e.g. iPhone, Samsung, Charger...',
            hintStyle: TextStyle(
              color: themeProvider.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(null);
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: themeProvider.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final text = brandNameController.text.trim();
              if (text.isEmpty) {
                ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter product name'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.of(dialogContext).pop(text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.primaryMain,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    // Safely dispose controller after dialog is fully closed
    await Future.delayed(const Duration(milliseconds: 100));
    brandNameController.dispose();

    if (result != null && result.isNotEmpty && mounted) {
      try {
        final response = await BrandService.createBrand(nama: result);
        
        if (response['success'] == true) {
          // Reload brands
          await _loadBrands();
          
          // Find and select the newly created brand
          final newBrand = _brands.firstWhere(
            (b) => b.nama.toLowerCase() == result.toLowerCase(),
            orElse: () => _brands.first,
          );
          
          if (mounted) {
            setState(() {
              _selectedBrandId = newBrand.id;
            });
            
            ScaffoldMessenger.of(scaffoldContext).showSnackBar(
              const SnackBar(
                content: Text('Product name added successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ValidationHandler.showErrorDialog(
              context: scaffoldContext,
              title: 'Error',
              message: response['message'] ?? 'Failed to add product name',
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ValidationHandler.showErrorDialog(
            context: scaffoldContext,
            title: 'Error',
            message: 'An error occurred: ${e.toString()}',
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _imeiController.dispose();
    _batteryHealthController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadColors() async {
    setState(() => _isLoadingColors = true);
    try {
      final response = await ColorService.getColors(perPage: 100);
      if (response['success'] == true && mounted) {
        setState(() {
          _colors = (response['data'] as List)
              .map((json) => ColorModel.PosWarnaModel.fromJson(json))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading colors: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingColors = false);
      }
    }
  }

  Future<void> _loadRams() async {
    setState(() => _isLoadingRams = true);
    try {
      final response = await RamService.getRams(perPage: 100);
      if (response['success'] == true && mounted) {
        setState(() {
          _rams = (response['data'] as List)
              .map((json) => RamModel.PosRamModel.fromJson(json))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading rams: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingRams = false);
      }
    }
  }

  Future<void> _loadStorages() async {
    setState(() => _isLoadingStorages = true);
    try {
      final response = await StorageService.getStorages(perPage: 100);
      if (response['success'] == true && mounted) {
        setState(() {
          _storages = response['data'] as List<Storage>;
        });
      }
    } catch (e) {
      debugPrint('Error loading storages: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingStorages = false);
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBrandId == null) {
      ValidationHandler.showErrorDialog(
        context: context,
        title: 'Validation Error',
        message: 'Please select a product brand',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get selected brand name
      final selectedBrand = _brands.firstWhere((b) => b.id == _selectedBrandId);
      
      final response = await ProductService.createProduct(
        nama: selectedBrand.nama,
        merkId: _selectedBrandId!,
        productType: _productType,
        deskripsi: _descriptionController.text.trim(),
        hargaBeli: double.tryParse(_purchasePriceController.text) ?? 0,
        hargaJual: double.tryParse(_sellingPriceController.text) ?? 0,
        imei: _productType == 'electronic' ? _imeiController.text.trim() : 'N/A',
        warnaId: _productType == 'electronic' ? _selectedColorId : null,
        penyimpananId: _productType == 'electronic' ? _selectedStorageId : null,
        ramId: _productType == 'electronic' ? _selectedRamId : null,
        batteryHealth: _productType == 'electronic' ? _batteryHealthController.text.trim() : null,
        aksesoris: _productType == 'accessories' ? selectedBrand.nama : null,
      );

      if (!mounted) return;

      if (response.success) {
        widget.onProductAdded();
        
        // Ambil product yang baru dibuat
        final newProduct = response.data;
        
        if (newProduct != null) {
          Navigator.pop(context, newProduct); // Return product object
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product added successfully and added to transaction!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          Navigator.pop(context, null);
        }
      } else {
        ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: response.message ?? 'Failed to add product',
        );
      }
    } catch (e) {
      if (mounted) {
        ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'An error occurred: ${e.toString()}',
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

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 600,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeProvider.surfaceColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: themeProvider.borderColor.withOpacity(0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Add Product',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add a new product to your inventory',
                          style: TextStyle(
                            fontSize: 13,
                            color: themeProvider.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: themeProvider.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Product Type Tabs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: themeProvider.surfaceColor,
                border: Border(
                  bottom: BorderSide(
                    color: themeProvider.borderColor.withOpacity(0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTypeTab(
                      label: 'Electronic / HP',
                      icon: Icons.phone_android_rounded,
                      type: 'electronic',
                      themeProvider: themeProvider,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeTab(
                      label: 'Accessories',
                      icon: Icons.headphones_rounded,
                      type: 'accessories',
                      themeProvider: themeProvider,
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: Container(
                color: themeProvider.surfaceColor,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information Section
                      _buildSectionTitle('Basic Information', themeProvider),
                      const SizedBox(height: 16),
                      
                      // Product Name (Brand) Selection with +New button
                      _buildBrandDropdown(themeProvider),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Enter product description (optional)',
                        maxLines: 3,
                        themeProvider: themeProvider,
                      ),
                      const SizedBox(height: 24),

                      // Specifications (Electronic only)
                      if (_productType == 'electronic') ...[
                        _buildSectionTitle('Specifications', themeProvider),
                        const SizedBox(height: 16),
                        
                        // Color Dropdown
                        _buildColorDropdown(themeProvider),
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            // RAM Dropdown
                            Expanded(
                              child: _buildRamDropdown(themeProvider),
                            ),
                            const SizedBox(width: 12),
                            // Storage Dropdown
                            Expanded(
                              child: _buildStorageDropdown(themeProvider),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _batteryHealthController,
                                label: 'Battery Health',
                                hint: 'e.g. 85%',
                                themeProvider: themeProvider,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: _imeiController,
                                label: 'IMEI Number',
                                hint: 'Enter IMEI',
                                isRequired: true,
                                themeProvider: themeProvider,
                                validator: (value) {
                                  if (_productType == 'electronic') {
                                    if (value == null || value.isEmpty) {
                                      return 'IMEI required';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Pricing Information
                      _buildSectionTitle('Pricing Information', themeProvider),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _purchasePriceController,
                              label: 'Purchase Price',
                              hint: '0',
                              isRequired: true,
                              keyboardType: TextInputType.number,
                              themeProvider: themeProvider,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _sellingPriceController,
                              label: 'Selling Price',
                              hint: '0',
                              isRequired: true,
                              keyboardType: TextInputType.number,
                              themeProvider: themeProvider,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeProvider.surfaceColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border(
                  top: BorderSide(
                    color: themeProvider.borderColor.withOpacity(0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: themeProvider.borderColor,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: themeProvider.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeProvider.primaryMain,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Create Product',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeTab({
    required String label,
    required IconData icon,
    required String type,
    required ThemeProvider themeProvider,
  }) {
    final isSelected = _productType == type;
    
    return InkWell(
      onTap: () => setState(() => _productType = type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? themeProvider.primaryMain.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? themeProvider.primaryMain
                : themeProvider.borderColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected 
                  ? themeProvider.primaryMain
                  : themeProvider.textSecondary,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? themeProvider.primaryMain
                      : themeProvider.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeProvider themeProvider) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: themeProvider.textPrimary,
      ),
    );
  }

  Widget _buildBrandDropdown(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Product Name',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: themeProvider.textPrimary,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            if (_isLoadingBrands) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: themeProvider.borderColor.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<int>(
                    value: _selectedBrandId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      hintText: 'Select Product Name',
                      hintStyle: TextStyle(
                        color: themeProvider.textSecondary.withOpacity(0.6),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: themeProvider.backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    items: _brands.map((brand) {
                      return DropdownMenuItem<int>(
                        value: brand.id,
                        child: Text(
                          brand.nama,
                          style: TextStyle(
                            color: themeProvider.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: _isLoadingBrands
                        ? null
                        : (value) {
                            setState(() {
                              _selectedBrandId = value;
                            });
                          },
                    dropdownColor: themeProvider.surfaceColor,
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a product name';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoadingBrands ? null : _showAddBrandDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.primaryMain,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '+New',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ThemeProvider themeProvider,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: themeProvider.textPrimary,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: themeProvider.textSecondary.withOpacity(0.6),
              fontSize: 14,
            ),
            filled: true,
            fillColor: themeProvider.backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeProvider.borderColor.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeProvider.borderColor.withOpacity(0.3),
              ),
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
              borderSide: const BorderSide(
                color: Colors.red,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorDropdown(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Color',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: themeProvider.textPrimary,
              ),
            ),
            if (_isLoadingColors) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: themeProvider.borderColor.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<int>(
              value: _selectedColorId,
              isExpanded: true,
              decoration: InputDecoration(
                hintText: 'Select Color',
                hintStyle: TextStyle(
                  color: themeProvider.textSecondary.withOpacity(0.6),
                ),
                filled: true,
                fillColor: themeProvider.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: _colors.map((color) {
                return DropdownMenuItem<int>(
                  value: color.id,
                  child: Text(
                    color.warna,
                    style: TextStyle(
                      color: themeProvider.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
              onChanged: _isLoadingColors
                  ? null
                  : (value) => setState(() => _selectedColorId = value),
              dropdownColor: themeProvider.surfaceColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRamDropdown(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'RAM',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: themeProvider.textPrimary,
              ),
            ),
            if (_isLoadingRams) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: themeProvider.borderColor.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<int>(
              value: _selectedRamId,
              isExpanded: true,
              decoration: InputDecoration(
                hintText: 'Select RAM',
                hintStyle: TextStyle(
                  color: themeProvider.textSecondary.withOpacity(0.6),
                ),
                filled: true,
                fillColor: themeProvider.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: _rams.map((ram) {
                return DropdownMenuItem<int>(
                  value: ram.id,
                  child: Text(
                    '${ram.kapasitas} GB',
                    style: TextStyle(
                      color: themeProvider.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
              onChanged: _isLoadingRams
                  ? null
                  : (value) => setState(() => _selectedRamId = value),
              dropdownColor: themeProvider.surfaceColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStorageDropdown(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Storage',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: themeProvider.textPrimary,
              ),
            ),
            if (_isLoadingStorages) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: themeProvider.borderColor.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<int>(
              value: _selectedStorageId,
              isExpanded: true,
              decoration: InputDecoration(
                hintText: 'Select Storage',
                hintStyle: TextStyle(
                  color: themeProvider.textSecondary.withOpacity(0.6),
                ),
                filled: true,
                fillColor: themeProvider.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: _storages.map((storage) {
                return DropdownMenuItem<int>(
                  value: storage.id,
                  child: Text(
                    '${storage.kapasitas} GB',
                    style: TextStyle(
                      color: themeProvider.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
              onChanged: _isLoadingStorages
                  ? null
                  : (value) => setState(() => _selectedStorageId = value),
              dropdownColor: themeProvider.surfaceColor,
            ),
          ),
        ),
      ],
    );
  }
}
