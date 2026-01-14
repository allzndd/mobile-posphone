import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../config/theme_provider.dart';
import '../../../suppliers/services/supplier_service.dart';
import '../../../store/services/store_service.dart';
import '../../../produk/services/product_service.dart';
import '../../../suppliers/models/supplier.dart';
import '../../../store/models/store.dart';
import '../../../produk/models/product.dart';
import '../../../component/validation_handler.dart';
import '../../services/outgoing_service.dart';

class OutgoingTransactionEditScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const OutgoingTransactionEditScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<OutgoingTransactionEditScreen> createState() =>
      _OutgoingTransactionEditScreenState();
}

class _OutgoingTransactionEditScreenState
    extends State<OutgoingTransactionEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _notesController = TextEditingController();

  // Dropdown values
  int? _selectedSupplierId;
  int? _selectedStoreId;
  String _selectedPaymentMethod = 'Cash';
  String _selectedStatus = 'Pending';

  // Lists for dropdowns
  List<Supplier> _suppliers = [];
  List<Store> _stores = [];
  List<Product> _products = [];

  // Loading states
  bool _isLoadingSuppliers = false;
  bool _isLoadingStores = false;
  bool _isLoadingProducts = false;
  bool _isSaving = false;

  // Transaction items
  List<Map<String, dynamic>> _items = [];

  // Payment methods
  final List<String> _paymentMethods = [
    'Cash',
    'QRIS',
    'Debit Card',
    'Credit Card',
    'E-Wallet',
    'Bank Transfer',
  ];

  // Status options
  final List<String> _statuses = [
    'Pending',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadSuppliers(),
      _loadStores(),
      _loadProducts(),
    ]);

    // Load transaction data
    _loadTransactionData();
  }

  void _loadTransactionData() {
    setState(() {
      _selectedSupplierId = widget.transaction['pos_supplier_id'];
      _selectedStoreId = widget.transaction['pos_toko_id'];
      
      // Normalize payment method to match dropdown items
      String paymentMethod = widget.transaction['metode_pembayaran'] ?? 'Cash';
      // Capitalize first letter to match dropdown items
      if (paymentMethod.isNotEmpty) {
        paymentMethod = paymentMethod[0].toUpperCase() + paymentMethod.substring(1).toLowerCase();
      }
      // Handle specific cases
      if (paymentMethod == 'Qris') paymentMethod = 'QRIS';
      if (paymentMethod == 'E-wallet') paymentMethod = 'E-Wallet';
      // Verify the value exists in the list, otherwise default to Cash
      if (!_paymentMethods.contains(paymentMethod)) {
        paymentMethod = 'Cash';
      }
      _selectedPaymentMethod = paymentMethod;
      
      // Normalize status to match dropdown items
      String status = widget.transaction['status'] ?? 'Pending';
      // Capitalize first letter to match dropdown items
      if (status.isNotEmpty) {
        status = status[0].toUpperCase() + status.substring(1).toLowerCase();
      }
      // Verify the value exists in the list, otherwise default to Pending
      if (!_statuses.contains(status)) {
        status = 'Pending';
      }
      _selectedStatus = status;
      
      _notesController.text = widget.transaction['keterangan'] ?? '';

      // Load items
      if (widget.transaction['items'] != null) {
        _items = List<Map<String, dynamic>>.from(
          widget.transaction['items'].map((item) => {
                'product_id': item['pos_produk_id'],
                'product_name': item['product_name'] ?? 'Unknown Product',
                'quantity': item['quantity'] ?? 1,
                'price': (item['harga_satuan'] ?? 0).toDouble(),
                'discount': (item['diskon'] ?? 0).toDouble(),
                'subtotal': (item['subtotal'] ?? 0).toDouble(),
              }),
        );
      }
    });
  }

  Future<void> _loadSuppliers() async {
    setState(() => _isLoadingSuppliers = true);
    try {
      final response = await SupplierService.getSuppliers();
      if (response['success'] == true) {
        setState(() {
          _suppliers = (response['data'] as List)
              .map((json) => Supplier.fromJson(json))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'Failed to load suppliers: $e',
        );
      }
    } finally {
      setState(() => _isLoadingSuppliers = false);
    }
  }

  Future<void> _loadStores() async {
    setState(() => _isLoadingStores = true);
    try {
      final response = await StoreService.getStores();
      if (response['success'] == true) {
        setState(() {
          _stores = (response['data'] as List)
              .map((json) => Store.fromJson(json))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'Failed to load stores: $e',
        );
      }
    } finally {
      setState(() => _isLoadingStores = false);
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoadingProducts = true);
    try {
      final response = await ProductService.getAllProducts(perPage: 100);
      if (response.success && response.data != null) {
        setState(() => _products = response.data!);
      }
    } catch (e) {
      if (mounted) {
        ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'Failed to load products: $e',
        );
      }
    } finally {
      setState(() => _isLoadingProducts = false);
    }
  }

  void _addItem() async {
    if (_products.isEmpty) {
      ValidationHandler.showErrorDialog(
        context: context,
        title: 'Error',
        message: 'No products available. Please add products first.',
      );
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AddItemDialog(products: _products),
    );

    if (result != null) {
      setState(() {
        _items.add(result);
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _editItem(int index) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AddItemDialog(
        products: _products,
        item: _items[index],
      ),
    );

    if (result != null) {
      setState(() {
        _items[index] = result;
      });
    }
  }

  double _calculateTotal() {
    return _items.fold(0.0, (sum, item) => sum + item['subtotal']);
  }

  int _getTotalItems() {
    return _items.fold(0, (sum, item) => sum + item['quantity'] as int);
  }

  Future<void> _updateTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedStoreId == null) {
      ValidationHandler.showErrorDialog(
        context: context,
        title: 'Validation Error',
        message: 'Please select a store',
      );
      return;
    }

    if (_selectedSupplierId == null) {
      ValidationHandler.showErrorDialog(
        context: context,
        title: 'Validation Error',
        message: 'Please select a supplier',
      );
      return;
    }

    if (_items.isEmpty) {
      ValidationHandler.showErrorDialog(
        context: context,
        title: 'Validation Error',
        message: 'Please add at least one item',
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Call API to update transaction
      final response = await OutgoingService.updateOutgoingTransaction(
        id: widget.transaction['id'],
        posTokoId: _selectedStoreId!,
        posSupplierId: _selectedSupplierId!,
        totalHarga: _calculateTotal(),
        keterangan: _notesController.text.isEmpty ? null : _notesController.text,
        status: _selectedStatus,
        metodePembayaran: _selectedPaymentMethod,
        items: _items.map((item) => {
          'pos_produk_id': item['product_id'],
          'quantity': item['quantity'],
          'harga_satuan': item['price'],
          'diskon': item['discount'],
          'subtotal': item['subtotal'],
        }).toList(),
      );

      if (mounted) {
        if (response['success'] == true) {
          ValidationHandler.showSuccessDialog(
            context: context,
            title: 'Success',
            message: response['message'] ?? 'Purchase order updated successfully!',
            onPressed: () {
              Navigator.pop(context); // Close success dialog
              Navigator.pop(context, true); // Return to previous screen with result
            },
          );
        } else {
          ValidationHandler.showErrorDialog(
            context: context,
            title: 'Error',
            message: response['message'] ?? 'Failed to update purchase order',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'Failed to update purchase order: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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
          'Edit Purchase Order',
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: themeProvider.textPrimary),
        actions: [
          if (!_isSaving)
            TextButton(
              onPressed: _updateTransaction,
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

            // Basic Information Section
            SliverToBoxAdapter(
              child: _buildBasicInfoSection(themeProvider, isMobile),
            ),

            // Items Section
            SliverToBoxAdapter(
              child: _buildItemsSection(themeProvider, isMobile),
            ),

            // Summary Section
            SliverToBoxAdapter(
              child: _buildSummarySection(themeProvider, isMobile),
            ),

            // Submit Button
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
              Icons.edit_rounded,
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
                  'Edit Purchase Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Update purchase order information',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 12,
              vertical: isMobile ? 4 : 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.transaction['invoice'] ?? 'N/A',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: isMobile ? 10 : 12,
              ),
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
        title: 'Basic Information',
        icon: Icons.info_outline_rounded,
        children: [
          _buildModernDropdown<int?>(
            label: 'Supplier',
            value: _selectedSupplierId,
            items: _suppliers
                .map((supplier) => DropdownMenuItem<int>(
                      value: supplier.id,
                      child: Text(supplier.nama ?? ''),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() => _selectedSupplierId = value);
            },
            hint: _isLoadingSuppliers
                ? 'Loading suppliers...'
                : 'Select supplier',
            themeProvider: themeProvider,
            prefixIcon: Icons.business_rounded,
            isMobile: isMobile,
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildModernDropdown<int?>(
            label: 'Store',
            value: _selectedStoreId,
            items: _stores
                .map((store) => DropdownMenuItem<int>(
                      value: store.id,
                      child: Text(store.nama ?? ''),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() => _selectedStoreId = value);
            },
            hint: _isLoadingStores ? 'Loading stores...' : 'Select store',
            themeProvider: themeProvider,
            prefixIcon: Icons.store_outlined,
            isMobile: isMobile,
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildModernDropdown<String>(
            label: 'Payment Method',
            value: _selectedPaymentMethod,
            items: _paymentMethods
                .map((method) => DropdownMenuItem<String>(
                      value: method,
                      child: Text(method),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedPaymentMethod = value);
              }
            },
            hint: 'Select payment method',
            themeProvider: themeProvider,
            prefixIcon: Icons.payment_rounded,
            isMobile: isMobile,
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildModernDropdown<String>(
            label: 'Status',
            value: _selectedStatus,
            items: _statuses
                .map((status) => DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedStatus = value);
              }
            },
            hint: 'Select status',
            themeProvider: themeProvider,
            prefixIcon: Icons.check_circle_outline_rounded,
            isMobile: isMobile,
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildModernTextField(
            controller: _notesController,
            label: 'Notes (Optional)',
            hint: 'Enter notes',
            icon: Icons.notes_rounded,
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
        title: 'Purchase Items',
        icon: Icons.inventory_2_outlined,
        action: TextButton.icon(
          onPressed: _isLoadingProducts ? null : _addItem,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add Item'),
          style: TextButton.styleFrom(
            foregroundColor: themeProvider.primaryMain,
          ),
        ),
        children: _items.isEmpty
            ? [
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 24 : 32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: isMobile ? 48 : 64,
                          color: themeProvider.textSecondary.withOpacity(0.5),
                        ),
                        SizedBox(height: isMobile ? 12 : 16),
                        Text(
                          'No items added yet',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            color: themeProvider.textSecondary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Click "Add Item" to add products',
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 14,
                            color: themeProvider.textSecondary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]
            : _items
                .asMap()
                .entries
                .map((entry) => _buildItemRow(
                      item: entry.value,
                      index: entry.key,
                      themeProvider: themeProvider,
                      isMobile: isMobile,
                    ))
                .toList(),
        themeProvider: themeProvider,
        isMobile: isMobile,
      ),
    );
  }

  Widget _buildSummarySection(ThemeProvider themeProvider, bool isMobile) {
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
                  fontWeight: FontWeight.w600,
                  color: themeProvider.textPrimary,
                ),
              ),
              Text(
                '${_getTotalItems()} items',
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
                'Rp ${_formatPrice(_calculateTotal())}',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 22,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.primaryMain,
                ),
              ),
            ],
          ),
        ],
      ),
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
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _updateTransaction,
          style: ElevatedButton.styleFrom(
            backgroundColor: themeProvider.primaryMain,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: _isSaving
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Update Purchase Order',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required ThemeProvider themeProvider,
    required bool isMobile,
    Widget? action,
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
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textPrimary,
                    ),
                  ),
                ),
                if (action != null) action,
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
    int maxLines = 1,
    bool readOnly = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w600,
            color: themeProvider.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontSize: isMobile ? 13 : 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: themeProvider.textSecondary.withOpacity(0.5),
              fontSize: isMobile ? 13 : 14,
            ),
            prefixIcon: Icon(icon, color: themeProvider.primaryMain, size: 20),
            filled: true,
            fillColor: themeProvider.backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeProvider.borderColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeProvider.borderColor,
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
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 12 : 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required String hint,
    required ThemeProvider themeProvider,
    required bool isMobile,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w600,
            color: themeProvider.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: themeProvider.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: themeProvider.borderColor,
            ),
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: themeProvider.textSecondary.withOpacity(0.5),
                fontSize: isMobile ? 13 : 14,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: themeProvider.primaryMain, size: 20)
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(
                left: prefixIcon != null ? 0 : (isMobile ? 12 : 16),
                right: isMobile ? 12 : 16,
                top: isMobile ? 12 : 14,
                bottom: isMobile ? 12 : 14,
              ),
            ),
            style: TextStyle(
              color: themeProvider.textPrimary,
              fontSize: isMobile ? 13 : 14,
            ),
            dropdownColor: themeProvider.cardColor,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: themeProvider.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow({
    required Map<String, dynamic> item,
    required int index,
    required ThemeProvider themeProvider,
    required bool isMobile,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 12),
      child: Row(
        children: [
          // Item Number
          Container(
            width: isMobile ? 28 : 32,
            height: isMobile ? 28 : 32,
            decoration: BoxDecoration(
              color: themeProvider.primaryMain.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.primaryMain,
                ),
              ),
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),

          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['product_name'] ?? 'Unknown Product',
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: themeProvider.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${item['quantity']} x Rp ${_formatPrice(item['price'])}',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: themeProvider.textSecondary,
                      ),
                    ),
                    if ((item['discount'] ?? 0) > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Disc ${_formatPrice(item['discount'])}',
                          style: TextStyle(
                            fontSize: isMobile ? 9 : 10,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Subtotal
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rp ${_formatPrice(item['subtotal'])}',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.primaryMain,
                ),
              ),
            ],
          ),
          SizedBox(width: isMobile ? 8 : 12),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  size: isMobile ? 18 : 20,
                  color: themeProvider.primaryMain,
                ),
                onPressed: () => _editItem(index),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              SizedBox(width: isMobile ? 4 : 8),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: isMobile ? 18 : 20,
                  color: Colors.red,
                ),
                onPressed: () => _removeItem(index),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}

// Add Item Dialog
class _AddItemDialog extends StatefulWidget {
  final List<Product> products;
  final Map<String, dynamic>? item;

  const _AddItemDialog({
    required this.products,
    this.item,
  });

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  int? _selectedProductId;
  String _selectedProductName = '';
  double _productPrice = 0.0;
  final _quantityController = TextEditingController(text: '1');
  final _discountController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _selectedProductId = widget.item!['product_id'];
      _selectedProductName = widget.item!['product_name'] ?? '';
      _productPrice = widget.item!['price'] ?? 0.0;
      _quantityController.text = widget.item!['quantity'].toString();
      _discountController.text = widget.item!['discount'].toString();
    }
  }

  double _calculateSubtotal() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    return (_productPrice * quantity) - discount;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: themeProvider.primaryMain.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: themeProvider.primaryMain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.item != null ? 'Edit Item' : 'Add Item',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Product Dropdown
            Text(
              'Product',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: themeProvider.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: themeProvider.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: themeProvider.borderColor),
              ),
              child: DropdownButtonFormField<int>(
                value: _selectedProductId,
                items: widget.products.map((product) {
                  return DropdownMenuItem<int>(
                    value: product.id,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product.nama ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: themeProvider.textPrimary,
                          ),
                        ),
                        Text(
                          'Rp ${_formatPrice((product.hargaBeli ?? 0).toDouble())}',
                          style: TextStyle(
                            fontSize: 12,
                            color: themeProvider.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    final product = widget.products.firstWhere(
                      (p) => p.id == value,
                    );
                    setState(() {
                      _selectedProductId = value;
                      _selectedProductName = product.nama ?? '';
                      _productPrice = (product.hargaBeli ?? 0).toDouble();
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Select product',
                  hintStyle: TextStyle(
                    color: themeProvider.textSecondary.withOpacity(0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.inventory_2_outlined,
                    color: themeProvider.primaryMain,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 14,
                  ),
                ),
                style: TextStyle(
                  color: themeProvider.textPrimary,
                  fontSize: 14,
                ),
                dropdownColor: themeProvider.cardColor,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: themeProvider.textSecondary,
                ),
              ),
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
              controller: _quantityController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) => setState(() {}),
              style: TextStyle(
                color: themeProvider.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Enter quantity',
                hintStyle: TextStyle(
                  color: themeProvider.textSecondary.withOpacity(0.5),
                ),
                prefixIcon: Icon(
                  Icons.format_list_numbered_rounded,
                  color: themeProvider.primaryMain,
                  size: 20,
                ),
                filled: true,
                fillColor: themeProvider.backgroundColor,
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Discount
            Text(
              'Discount (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: themeProvider.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _discountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) => setState(() {}),
              style: TextStyle(
                color: themeProvider.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Enter discount amount',
                hintStyle: TextStyle(
                  color: themeProvider.textSecondary.withOpacity(0.5),
                ),
                prefixIcon: Icon(
                  Icons.discount_outlined,
                  color: themeProvider.primaryMain,
                  size: 20,
                ),
                filled: true,
                fillColor: themeProvider.backgroundColor,
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Subtotal
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeProvider.primaryMain.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: themeProvider.textPrimary,
                    ),
                  ),
                  Text(
                    'Rp ${_formatPrice(_calculateSubtotal())}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.primaryMain,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: themeProvider.borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedProductId == null
                        ? null
                        : () {
                            final quantity =
                                int.tryParse(_quantityController.text) ?? 0;
                            if (quantity <= 0) {
                              ValidationHandler.showErrorDialog(
                                context: context,
                                title: 'Validation Error',
                                message: 'Quantity must be greater than 0',
                              );
                              return;
                            }

                            final discount =
                                double.tryParse(_discountController.text) ??
                                    0.0;

                            Navigator.pop(context, {
                              'product_id': _selectedProductId,
                              'product_name': _selectedProductName,
                              'quantity': quantity,
                              'price': _productPrice,
                              'discount': discount,
                              'subtotal': _calculateSubtotal(),
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.primaryMain,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      widget.item != null ? 'Update' : 'Add',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _discountController.dispose();
    super.dispose();
  }
}
