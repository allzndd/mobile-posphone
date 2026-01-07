import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import '../../component/validation_handler.dart';
import '../services/customer_service.dart';
import '../models/customer.dart';

class CustomerEditScreen extends StatefulWidget {
  final int customerId;
  final Customer? initialCustomer;
  
  const CustomerEditScreen({
    super.key,
    required this.customerId,
    this.initialCustomer,
  });

  @override
  State<CustomerEditScreen> createState() => _CustomerEditScreenState();
}

class _CustomerEditScreenState extends State<CustomerEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _alamatController = TextEditingController();

  bool _isLoading = false;
  Map<String, String> _fieldErrors = {};
  Customer? _customer;

  @override
  void initState() {
    super.initState();
    // Use initial customer data if available
    if (widget.initialCustomer != null) {
      _customer = widget.initialCustomer!;
      _namaController.text = _customer!.nama;
      _emailController.text = _customer!.email ?? '';
      _phoneController.text = _customer!.nomorHp ?? '';
      _alamatController.text = _customer!.alamat ?? '';
    } else {
      _loadCustomerData();
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomerData() async {
    try {
      final result = await CustomerService().getCustomer(widget.customerId);
      
      if (result.success && result.data != null) {
        final customer = result.data!;
        setState(() {
          _customer = customer;
          _namaController.text = customer.nama;
          _emailController.text = customer.email ?? '';
          _phoneController.text = customer.nomorHp ?? '';
          _alamatController.text = customer.alamat ?? '';
        });
      } else {
        if (mounted) {
          ValidationHandler.showErrorSnackBar(
            context: context,
            message: result.message,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ValidationHandler.showErrorSnackBar(
          context: context,
          message: 'Failed to load customer data: $e',
        );
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
          'Edit Customer',
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontWeight: FontWeight.w600,
            ),
          ),
          iconTheme: IconThemeData(color: themeProvider.textPrimary),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _updateCustomer,
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

            // Customer Information Section
            SliverToBoxAdapter(
              child: _buildCustomerInfoSection(themeProvider, isMobile),
            ),

            // Contact Information Section
            SliverToBoxAdapter(
              child: _buildContactInfoSection(themeProvider, isMobile),
            ),

            // Update Button Section
            SliverToBoxAdapter(
              child: _buildUpdateButton(themeProvider, isMobile),
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
                  'Edit Customer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Update customer information and contact details',
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

  Widget _buildCustomerInfoSection(ThemeProvider themeProvider, bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 8 : 12,
      ),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeProvider.primaryMain.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: themeProvider.primaryMain,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Customer Information',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),

          // Nama Field
          _buildModernTextField(
            controller: _namaController,
            label: 'Customer Name *',
            hint: 'Enter customer full name',
            icon: Icons.person_outline,
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Customer name is required';
              }
              return null;
            },
            themeProvider: themeProvider,
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection(ThemeProvider themeProvider, bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 8 : 12,
      ),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.contact_phone_rounded,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),

          // Phone Field
          _buildModernTextField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: 'Enter phone number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (value.length < 10) {
                  return 'Phone number must be at least 10 digits';
                }
              }
              return null;
            },
            themeProvider: themeProvider,
            isMobile: isMobile,
          ),

          SizedBox(height: isMobile ? 16 : 20),

          // Email Field
          _buildModernTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'Enter email address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
              }
              return null;
            },
            themeProvider: themeProvider,
            isMobile: isMobile,
          ),

          SizedBox(height: isMobile ? 16 : 20),

          // Alamat Field
          _buildModernTextField(
            controller: _alamatController,
            label: 'Address',
            hint: 'Enter customer address',
            icon: Icons.location_on_outlined,
            keyboardType: TextInputType.multiline,
            maxLines: 3,
            validator: null,
            themeProvider: themeProvider,
            isMobile: isMobile,
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required ThemeProvider themeProvider,
    required bool isMobile,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w500,
            color: themeProvider.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontSize: isMobile ? 14 : 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: themeProvider.textSecondary.withOpacity(0.6),
              fontSize: isMobile ? 14 : 16,
            ),
            prefixIcon: Icon(
              icon,
              color: themeProvider.textSecondary,
              size: isMobile ? 20 : 24,
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
              borderSide: BorderSide(color: themeProvider.borderColor.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: themeProvider.primaryMain, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: themeProvider.surfaceColor,
          ),
        ),
        if (_fieldErrors.containsKey(controller.hashCode.toString())) ...[
          const SizedBox(height: 4),
          Text(
            _fieldErrors[controller.hashCode.toString()]!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUpdateButton(ThemeProvider themeProvider, bool isMobile) {
    return Container(
      margin: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: isMobile ? 48 : 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _updateCustomer,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.primaryMain,
                foregroundColor: Colors.white,
                elevation: _isLoading ? 0 : 8,
                shadowColor: themeProvider.primaryMain.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: themeProvider.textSecondary.withOpacity(0.3),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.7),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          'Update Customer',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
        ],
      ),
    );
  }

  Future<void> _updateCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _fieldErrors.clear();
    });

    try {
      final updatedCustomer = _customer!.copyWith(
        nama: _namaController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        nomorHp: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        alamat: _alamatController.text.trim().isEmpty ? null : _alamatController.text.trim(),
      );

      final result = await CustomerService().updateCustomer(widget.customerId, updatedCustomer);

      if (mounted) {
        if (result.success) {
          await ValidationHandler.showSuccessDialog(
            context: context,
            title: 'Success',
            message: result.message,
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.pop(context, true); // Return to previous screen
            },
          );
        } else {
          await ValidationHandler.showErrorDialog(
            context: context,
            title: 'Error',
            message: result.message,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceFirst('Exception: Error: Exception: ', '').replaceFirst('Exception: ', '');
        
        await ValidationHandler.showErrorDialog(
          context: context,
          title: 'Update Error',
          message: errorMessage,
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
