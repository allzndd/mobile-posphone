import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import '../../component/validation_handler.dart';
import '../models/supplier.dart';
import '../services/supplier_service.dart';

class SupplierEditScreen extends StatefulWidget {
  final Supplier supplier;

  const SupplierEditScreen({super.key, required this.supplier});

  @override
  State<SupplierEditScreen> createState() => _SupplierEditScreenState();
}

class _SupplierEditScreenState extends State<SupplierEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  late final TextEditingController _nomorHpController;
  late final TextEditingController _emailController;
  late final TextEditingController _alamatController;
  late final TextEditingController _keteranganController;

  bool _isLoading = false;
  Map<String, String> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.supplier.nama);
    _nomorHpController = TextEditingController(
      text: widget.supplier.nomorHp ?? '',
    );
    _emailController = TextEditingController(text: widget.supplier.email ?? '');
    _alamatController = TextEditingController(
      text: widget.supplier.alamat ?? '',
    );
    _keteranganController = TextEditingController(
      text: widget.supplier.keterangan ?? '',
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nomorHpController.dispose();
    _emailController.dispose();
    _alamatController.dispose();
    _keteranganController.dispose();
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
          'Edit Supplier',
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: themeProvider.textPrimary),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _updateSupplier,
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

            // Supplier Information Section
            SliverToBoxAdapter(
              child: _buildSupplierInfoSection(themeProvider, isMobile),
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
                  'Edit Supplier',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Update supplier information and details',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
          // Supplier ID Badge
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
              '#${widget.supplier.id}',
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

  Widget _buildSupplierInfoSection(ThemeProvider themeProvider, bool isMobile) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        isMobile ? 16 : 24,
        0,
        isMobile ? 16 : 24,
        isMobile ? 16 : 24,
      ),
      child: _buildSectionCard(
        title: 'Supplier Information',
        icon: Icons.local_shipping_rounded,
        children: [
          _buildModernTextField(
            controller: _namaController,
            label: 'Supplier Name',
            hint: 'Enter supplier name',
            icon: Icons.business,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Supplier name is required';
              }
              if (value.trim().length < 3) {
                return 'Supplier name must be at least 3 characters';
              }
              return null;
            },
            errorText: _fieldErrors['nama'],
            themeProvider: themeProvider,
            isMobile: isMobile,
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildModernTextField(
            controller: _nomorHpController,
            label: 'Phone Number',
            hint: 'Enter phone number',
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                if (value.trim().length < 10) {
                  return 'Phone number must be at least 10 digits';
                }
              }
              return null;
            },
            errorText: _fieldErrors['nomor_hp'],
            themeProvider: themeProvider,
            isMobile: isMobile,
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildModernTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter email address',
            icon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Please enter a valid email address';
                }
              }
              return null;
            },
            errorText: _fieldErrors['email'],
            themeProvider: themeProvider,
            isMobile: isMobile,
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildModernTextField(
            controller: _alamatController,
            label: 'Address',
            hint: 'Enter complete supplier address',
            icon: Icons.location_on_rounded,
            maxLines: 3,
            errorText: _fieldErrors['alamat'],
            themeProvider: themeProvider,
            isMobile: isMobile,
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildModernTextField(
            controller: _keteranganController,
            label: 'Notes',
            hint: 'Enter additional notes or description',
            icon: Icons.note_rounded,
            maxLines: 3,
            errorText: _fieldErrors['keterangan'],
            themeProvider: themeProvider,
            isMobile: isMobile,
          ),
        ],
        themeProvider: themeProvider,
        isMobile: isMobile,
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

          // Section Content
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
          ],
        ),
        SizedBox(height: isMobile ? 8 : 10),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
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
            fillColor: themeProvider.backgroundColor,
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
        onPressed: _isLoading ? null : _updateSupplier,
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
                  'Update Supplier',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }

  Future<void> _updateSupplier() async {
    setState(() {
      _fieldErrors.clear();
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final supplierData = {
        'nama': _namaController.text.trim(),
        'nomor_hp': _nomorHpController.text.trim(),
        'email': _emailController.text.trim(),
        'alamat': _alamatController.text.trim(),
        'keterangan': _keteranganController.text.trim(),
      };

      final response = await SupplierService.updateSupplier(
        widget.supplier.id,
        supplierData,
      );

      if (response['success'] == true) {
        if (mounted) {
          await ValidationHandler.showSuccessDialog(
            context: context,
            title: 'Success',
            message:
                response['message'] ??
                'Supplier has been updated successfully!',
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.pop(context, true); // Return to previous screen
            },
          );
        }
      } else {
        if (mounted) {
          if (response['errors'] != null) {
            setState(() {
              _fieldErrors = Map<String, String>.from(
                response['errors'].map(
                  (key, value) => MapEntry(key, value.first),
                ),
              );
            });

            // Show error dialog for validation errors
            await ValidationHandler.showErrorDialog(
              context: context,
              title: 'Validation Error',
              message: 'Please check the form and correct any errors.',
            );
          } else {
            await ValidationHandler.showErrorDialog(
              context: context,
              title: 'Error',
              message:
                  response['message'] ??
                  'Failed to update supplier. Please try again.',
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        await ValidationHandler.showErrorDialog(
          context: context,
          title: 'Network Error',
          message:
              'Failed to connect to server. Please check your internet connection and try again.',
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
