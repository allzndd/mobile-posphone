import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme_provider.dart';
import '../../../component/validation_handler.dart';
import '../../services/expense_transaction_service.dart';
import '../../../expense_category/services/expense_category_service.dart';
import '../../../expense_category/models/expense_category.dart';
import '../../../store/services/store_service.dart';
import '../../../store/models/store.dart';

class ExpenseTransactionCreateScreen extends StatefulWidget {
  const ExpenseTransactionCreateScreen({super.key});

  @override
  State<ExpenseTransactionCreateScreen> createState() =>
      _ExpenseTransactionCreateScreenState();
}

class _ExpenseTransactionCreateScreenState
    extends State<ExpenseTransactionCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceController = TextEditingController();
  final _totalHargaController = TextEditingController();
  final _keteranganController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingCategories = true;
  bool _isLoadingStores = true;
  Map<String, String> _fieldErrors = {};

  List<ExpenseCategory> _categories = [];
  List<Store> _stores = [];
  int? _selectedCategoryId;
  int? _selectedStoreId;
  String? _selectedPaymentMethod;
  String? _selectedStatus;

  final List<String> _paymentMethods = [
    'Cash',
    'Transfer',
    'Credit Card',
    'Debit Card',
    'E-Wallet',
  ];

  final List<String> _statusOptions = ['Pending', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _generateDefaultInvoice();
    _loadCategories();
    _loadStores();
  }

  void _generateDefaultInvoice() {
    final now = DateTime.now();
    final dateStr =
        now.year.toString() +
        now.month.toString().padLeft(2, '0') +
        now.day.toString().padLeft(2, '0');
    final timeStr =
        now.hour.toString().padLeft(2, '0') +
        now.minute.toString().padLeft(2, '0') +
        now.second.toString().padLeft(2, '0');
    final defaultInvoice = 'EXP-$dateStr-$timeStr';
    _invoiceController.text = defaultInvoice;
  }

  @override
  void dispose() {
    _invoiceController.dispose();
    _totalHargaController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await ExpenseCategoryService.getExpenseCategories(
        page: 1,
        perPage: 100,
      );

      if (response['success'] == true) {
        final List<dynamic> categoryData = response['data'] ?? [];
        setState(() {
          _categories =
              categoryData
                  .map((json) => ExpenseCategory.fromJson(json))
                  .toList();
          _isLoadingCategories = false;
        });
      } else {
        setState(() => _isLoadingCategories = false);
      }
    } catch (e) {
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _loadStores() async {
    try {
      final response = await StoreService.getStores(page: 1, perPage: 100);

      if (response['success'] == true) {
        final List<dynamic> storeData = response['data'] ?? [];
        setState(() {
          _stores = storeData.map((json) => Store.fromJson(json)).toList();
          _isLoadingStores = false;
        });
      } else {
        setState(() => _isLoadingStores = false);
      }
    } catch (e) {
      setState(() => _isLoadingStores = false);
    }
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState?.validate() != true) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedStoreId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a store'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a status'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _fieldErrors = {};
    });

    try {
      final totalHarga = double.tryParse(_totalHargaController.text) ?? 0.0;
      final invoice = _invoiceController.text.trim();

      print('🔍 [CREATE] Sending data:');
      print('  - Category ID: $_selectedCategoryId');
      print('  - Store ID: $_selectedStoreId');
      print(
        '  - Invoice: ${invoice.isNotEmpty ? invoice : "null (auto-generate)"}',
      );
      print('  - Total Harga: $totalHarga');
      print('  - Status: ${_selectedStatus?.toLowerCase()}');
      print('  - Payment Method: $_selectedPaymentMethod');
      print('  - Keterangan: ${_keteranganController.text}');

      final response = await ExpenseTransactionService.createExpenseTransaction(
        posKategoriExpenseId: _selectedCategoryId!,
        totalHarga: totalHarga,
        keterangan:
            _keteranganController.text.isNotEmpty
                ? _keteranganController.text
                : null,
        metodePembayaran: _selectedPaymentMethod,
        posTokoId: _selectedStoreId,
        invoice: invoice.isNotEmpty ? invoice : null,
        status: _selectedStatus?.toLowerCase(),
      );

      print('📦 [CREATE] Response received: $response');

      if (!mounted) return;

      if (response['success'] == true) {
        await ValidationHandler.showSuccessDialog(
          context: context,
          title: 'Success',
          message: response['message'] ?? 'Transaction created successfully',
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.pop(context, true);
          },
        );
      } else {
        print('❌ [CREATE] Failed: ${response['message']}');

        if (response['errors'] != null) {
          print('📋 [CREATE] Field Errors: ${response['errors']}');

          setState(() {
            _fieldErrors = Map<String, String>.from(
              response['errors'].map(
                (key, value) => MapEntry(
                  key,
                  value is List ? value.first : value.toString(),
                ),
              ),
            );
          });

          // Show detailed error message
          String errorMessage =
              'Please check the form and correct any errors:\n';
          response['errors'].forEach((key, value) {
            final message = value is List ? value.first : value.toString();
            errorMessage += '\n• $key: $message';
          });

          await ValidationHandler.showErrorDialog(
            context: context,
            title: 'Validation Error',
            message: errorMessage,
          );
        } else {
          await ValidationHandler.showErrorDialog(
            context: context,
            title: 'Error',
            message: response['message'] ?? 'Failed to create transaction',
          );
        }
      }
    } catch (e, stackTrace) {
      print('❌ [CREATE] Exception: $e');
      print('📍 [CREATE] Stack trace: $stackTrace');

      if (mounted) {
        await ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'An unexpected error occurred: $e',
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

    if (_isLoadingCategories || _isLoadingStores) {
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
        ),
        body: Center(
          child: CircularProgressIndicator(color: themeProvider.primaryMain),
        ),
      );
    }

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
            SliverToBoxAdapter(
              child: _buildHeaderCard(themeProvider, isMobile),
            ),
            SliverToBoxAdapter(
              child: _buildTransactionInfoSection(themeProvider, isMobile),
            ),
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
              Icons.add_circle_outline_rounded,
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
                const SizedBox(height: 4),
                Text(
                  'Create a new expense transaction',
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

  Widget _buildTransactionInfoSection(
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 8),
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: themeProvider.primaryMain,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Transaction Information',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),

          // Invoice Number Field
          Text(
            'Invoice Number (Optional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: themeProvider.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _invoiceController,
            style: TextStyle(color: themeProvider.textPrimary),
            decoration: InputDecoration(
              hintText: 'Leave empty for auto-generate',
              hintStyle: TextStyle(color: themeProvider.textTertiary),
              prefixIcon: Icon(
                Icons.receipt_outlined,
                color: themeProvider.primaryMain,
              ),
              filled: true,
              fillColor: themeProvider.backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.textTertiary.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.textTertiary.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.primaryMain,
                  width: 2,
                ),
              ),
            ),
          ),

          SizedBox(height: isMobile ? 16 : 20),

          // Store Dropdown
          RichText(
            text: TextSpan(
              text: 'Store ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: themeProvider.textPrimary,
              ),
              children: const [
                TextSpan(
                  text: '*',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: _selectedStoreId,
            decoration: InputDecoration(
              hintText: 'Select store',
              hintStyle: TextStyle(color: themeProvider.textTertiary),
              prefixIcon: Icon(
                Icons.store_rounded,
                color: themeProvider.primaryMain,
              ),
              filled: true,
              fillColor: themeProvider.backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.textTertiary.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.textTertiary.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.primaryMain,
                  width: 2,
                ),
              ),
            ),
            items:
                _stores.map((store) {
                  return DropdownMenuItem<int>(
                    value: store.id,
                    child: Text(store.nama ?? 'Unknown'),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() => _selectedStoreId = value);
            },
          ),

          SizedBox(height: isMobile ? 16 : 20),

          // Category Dropdown
          RichText(
            text: TextSpan(
              text: 'Expense Category ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: themeProvider.textPrimary,
              ),
              children: const [
                TextSpan(
                  text: '*',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: _selectedCategoryId,
            decoration: InputDecoration(
              hintText: 'Select category',
              hintStyle: TextStyle(color: themeProvider.textTertiary),
              prefixIcon: Icon(
                Icons.category_rounded,
                color: themeProvider.primaryMain,
              ),
              filled: true,
              fillColor: themeProvider.backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.textTertiary.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.textTertiary.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.primaryMain,
                  width: 2,
                ),
              ),
            ),
            items:
                _categories.map((category) {
                  return DropdownMenuItem<int>(
                    value: category.id,
                    child: Text(category.nama ?? 'Unknown'),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() => _selectedCategoryId = value);
            },
          ),

          SizedBox(height: isMobile ? 16 : 20),

          // Total Amount Field
          RichText(
            text: TextSpan(
              text: 'Total Amount ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: themeProvider.textPrimary,
              ),
              children: const [
                TextSpan(
                  text: '*',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _totalHargaController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: themeProvider.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter amount',
              hintStyle: TextStyle(color: themeProvider.textTertiary),
              prefixIcon: Icon(
                Icons.attach_money_rounded,
                color: themeProvider.primaryMain,
              ),
              filled: true,
              fillColor: themeProvider.backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.textTertiary.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.textTertiary.withOpacity(0.2),
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
                borderSide: const BorderSide(color: Colors.red),
              ),
              errorText: _fieldErrors['total_harga'],
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Amount is required';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),

          SizedBox(height: isMobile ? 16 : 20),

          // Status Dropdown
          RichText(
            text: TextSpan(
              text: 'Status ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: themeProvider.textPrimary,
              ),
              children: const [
                TextSpan(
                  text: '*',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: InputDecoration(
              hintText: 'Select status',
              hintStyle: TextStyle(color: themeProvider.textTertiary),
              prefixIcon: Icon(
                Icons.flag_rounded,
                color: themeProvider.primaryMain,
              ),
              filled: true,
              fillColor: themeProvider.backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.textTertiary.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.textTertiary.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.primaryMain,
                  width: 2,
                ),
              ),
            ),
            items:
                _statusOptions.map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() => _selectedStatus = value);
            },
          ),

          SizedBox(height: isMobile ? 16 : 20),

          // Payment Method Dropdown
          Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: themeProvider.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedPaymentMethod,
            decoration: InputDecoration(
              hintText: 'Select payment method',
              hintStyle: TextStyle(color: themeProvider.textTertiary),
              prefixIcon: Icon(
                Icons.payment_rounded,
                color: themeProvider.primaryMain,
              ),
              filled: true,
              fillColor: themeProvider.backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.textTertiary.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.textTertiary.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.primaryMain,
                  width: 2,
                ),
              ),
            ),
            items:
                _paymentMethods.map((method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() => _selectedPaymentMethod = value);
            },
          ),

          SizedBox(height: isMobile ? 16 : 20),

          // Description Field
          Text(
            'Description',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: themeProvider.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _keteranganController,
            maxLines: 3,
            style: TextStyle(color: themeProvider.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter description (optional)',
              hintStyle: TextStyle(color: themeProvider.textTertiary),
              filled: true,
              fillColor: themeProvider.backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.textTertiary.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.textTertiary.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.primaryMain,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ThemeProvider themeProvider, bool isMobile) {
    return Container(
      margin: EdgeInsets.all(isMobile ? 16 : 24),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeProvider.primaryMain,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child:
            _isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.save_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Create Transaction',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
