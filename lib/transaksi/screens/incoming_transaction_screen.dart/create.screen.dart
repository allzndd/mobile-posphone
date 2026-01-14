import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme_provider.dart';
import '../../../component/validation_handler.dart';
import '../../../customers/services/customer_service.dart';
import '../../../customers/models/customer.dart';
import '../../../store/services/store_service.dart';
import '../../../store/models/store.dart';
import '../../../produk/services/product_service.dart';
import '../../../produk/models/product.dart';
import '../../../services/services/service_service.dart';
import '../../../services/models/service.dart';
import '../../services/incoming_service.dart';

class IncomingTransactionCreateScreen extends StatefulWidget {
  const IncomingTransactionCreateScreen({super.key});

  @override
  State<IncomingTransactionCreateScreen> createState() =>
      _IncomingTransactionCreateScreenState();
}

class _IncomingTransactionCreateScreenState
    extends State<IncomingTransactionCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _keteranganController = TextEditingController();
  final _invoiceController = TextEditingController();

  // Services
  final _customerService = CustomerService();

  bool _isLoading = false;
  bool _isLoadingCustomers = false;
  bool _isLoadingStores = false;
  bool _isLoadingProducts = false;
  bool _isLoadingServices = false;
  Map<String, String> _fieldErrors = {};

  // Dropdowns
  List<Customer> _customers = [];
  List<Store> _stores = [];
  List<Product> _products = [];
  List<Service> _services = [];

  int? _selectedCustomerId;
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
    _loadCustomers();
    _loadStores();
    _loadProducts();
    _loadServices();
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
      final response = await IncomingService.getIncomingTransactions(
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

          // Parse last invoice number (format: INV-YYYYMMDD-XXXX)
          final parts = lastInvoice.split('-');
          if (parts.length == 3) {
            final lastDate = parts[1];
            final lastNumber = int.tryParse(parts[2]) ?? 0;

            // If same date, increment. Otherwise start from 1
            if (lastDate == dateStr) {
              nextNumber = lastNumber + 1;
            }
          }
        }
      }

      // Generate invoice: INV-YYYYMMDD-XXXX
      final invoiceNumber =
          'INV-$dateStr-${nextNumber.toString().padLeft(4, '0')}';

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
      final invoiceNumber = 'INV-$dateStr-0001';

      if (mounted) {
        setState(() {
          _invoiceController.text = invoiceNumber;
        });
      }
    }
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoadingCustomers = true);
    try {
      final response = await _customerService.getCustomers();
      setState(() {
        _customers = response.customers ?? [];
      });
    } catch (e) {
      debugPrint('Error loading customers: $e');
    } finally {
      setState(() => _isLoadingCustomers = false);
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

  Future<void> _loadServices() async {
    setState(() => _isLoadingServices = true);
    try {
      final response = await ServiceService.getServices(perPage: 100);
      if (response['success'] == true) {
        setState(() {
          _services =
              (response['data'] as List)
                  .map((json) => Service.fromJson(json))
                  .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading services: $e');
    } finally {
      setState(() => _isLoadingServices = false);
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
              Icons.add_shopping_cart_rounded,
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
                  'Create a new incoming sales transaction',
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
            label: 'Customer',
            hint: 'Select customer (optional)',
            icon: Icons.person_rounded,
            value: _selectedCustomerId,
            items:
                _customers
                    .map(
                      (customer) => DropdownMenuItem<int>(
                        value: customer.id,
                        child: Text(customer.nama ?? ''),
                      ),
                    )
                    .toList(),
            onChanged: (value) => setState(() => _selectedCustomerId = value),
            isLoading: _isLoadingCustomers,
            themeProvider: themeProvider,
            isMobile: isMobile,
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
            hint: 'Enter transaction notes (optional)',
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
        icon: Icons.shopping_basket_rounded,
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
        ],
      ),
    );
  }

  void _showAddItemDialog(ThemeProvider themeProvider, bool isMobile) {
    String selectedType = 'product';
    Product? selectedProduct;
    Service? selectedService;
    final quantityController = TextEditingController(text: '1');
    final unitPriceController = TextEditingController();
    int subtotal = 0;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              void calculateSubtotal() {
                final qty = int.tryParse(quantityController.text) ?? 0;
                final price = int.tryParse(unitPriceController.text) ?? 0;
                setDialogState(() {
                  subtotal = qty * price;
                });
              }

              return AlertDialog(
                backgroundColor: themeProvider.surfaceColor,
                title: Text(
                  'Add Item',
                  style: TextStyle(color: themeProvider.textPrimary),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type Dropdown
                      Text(
                        'Type',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: themeProvider.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        value: selectedType,
                        items: const [
                          DropdownMenuItem(
                            value: 'product',
                            child: Text('Product'),
                          ),
                          DropdownMenuItem(
                            value: 'service',
                            child: Text('Service'),
                          ),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            selectedType = value!;
                            selectedProduct = null;
                            selectedService = null;
                            unitPriceController.clear();
                            subtotal = 0;
                          });
                        },
                        dropdownColor: themeProvider.surfaceColor,
                      ),
                      const SizedBox(height: 16),

                      // Item Dropdown
                      Text(
                        'Item',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: themeProvider.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (selectedType == 'product')
                        DropdownButtonFormField<Product>(
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
                          items:
                              _products
                                  .map(
                                    (product) => DropdownMenuItem<Product>(
                                      value: product,
                                      child: Text(product.nama ?? ''),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedProduct = value;
                              unitPriceController.text =
                                  (selectedProduct?.hargaJual ?? 0).toString();
                              calculateSubtotal();
                            });
                          },
                          dropdownColor: themeProvider.surfaceColor,
                        )
                      else
                        DropdownButtonFormField<Service>(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          value: selectedService,
                          hint: const Text('Select Service'),
                          items:
                              _services
                                  .map(
                                    (service) => DropdownMenuItem<Service>(
                                      value: service,
                                      child: Text(service.nama),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedService = value;
                              unitPriceController.text =
                                  (selectedService?.harga.toInt() ?? 0)
                                      .toString();
                              calculateSubtotal();
                            });
                          },
                          dropdownColor: themeProvider.surfaceColor,
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
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: themeProvider.textPrimary,
                    ),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if ((selectedType == 'product' &&
                              selectedProduct != null) ||
                          (selectedType == 'service' &&
                              selectedService != null)) {
                        setState(() {
                          _items.add({
                            'type': selectedType,
                            'product':
                                selectedType == 'product'
                                    ? selectedProduct
                                    : null,
                            'service':
                                selectedType == 'service'
                                    ? selectedService
                                    : null,
                            'product_id':
                                selectedType == 'product'
                                    ? selectedProduct!.id
                                    : null,
                            'service_id':
                                selectedType == 'service'
                                    ? selectedService!.id
                                    : null,
                            'quantity':
                                int.tryParse(quantityController.text) ?? 1,
                            'price':
                                int.tryParse(unitPriceController.text) ?? 0,
                          });
                        });
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.primaryMain,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add'),
                  ),
                ],
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
        message: 'Please add at least one item to the transaction.',
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
              'type': item['type'],
              'pos_produk_id': item['product_id'],
              'pos_service_id': item['service_id'],
              'quantity': quantity,
              'harga_satuan': price,
              'subtotal': subtotal,
            };
          }).toList();

      final response = await IncomingService.createIncomingTransaction(
        posTokoId: _selectedStoreId!,
        posPelangganId: _selectedCustomerId,
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
            message: response['message'] ?? 'Failed to create transaction',
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
              'Transaction has been created successfully!',
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
          _selectedCustomerId = null;
          _keteranganController.clear();
        });
      }
    } catch (e) {
      debugPrint('Error creating transaction: $e');
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
