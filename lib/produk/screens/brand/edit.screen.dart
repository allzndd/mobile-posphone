import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../component/validation_handler.dart';
import '../../../config/theme_provider.dart';
import '../../services/brand_service.dart';

class EditBrandScreen extends StatefulWidget {
  final Map<String, dynamic> brand;

  const EditBrandScreen({super.key, required this.brand});

  @override
  State<EditBrandScreen> createState() => _EditBrandScreenState();
}

class _EditBrandScreenState extends State<EditBrandScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.brand['merk'] ?? widget.brand['nama'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateBrand() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final brandId = widget.brand['id'] as int;
      final brandMerk = _nameController.text.trim();
      final originalMerk = (widget.brand['merk'] ?? widget.brand['nama'] ?? '').trim();

      // Check if there are any changes
      if (brandMerk == originalMerk) {
        if (mounted) {
          await ValidationHandler.showSuccessDialog(
            context: context,
            title: 'Success',
            message: 'No changes made to brand',
          );
          Navigator.pop(context, widget.brand);
        }
        return;
      }

      final response = await BrandService.updateBrand(
        id: brandId,
        merk: brandMerk,
      );

      if (response['success'] == true) {
        if (mounted) {
          await ValidationHandler.showSuccessDialog(
            context: context,
            title: 'Success',
            message: response['message'] ?? 'Brand has been updated successfully!',
          );

          // Return the updated brand data to the previous screen
          Navigator.pop(context, response['data']);
        }
      } else {
        if (mounted) {
          await ValidationHandler.showErrorDialog(
            context: context,
            title: 'Error',
            message: response['message'] ?? 'Failed to update brand',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        await ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'Failed to update brand: $e',
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Edit Product Name',
          style: TextStyle(color: themeProvider.textPrimary),
        ),
        backgroundColor: themeProvider.surfaceColor,
        elevation: 0,
        iconTheme: IconThemeData(color: themeProvider.textPrimary),
        actions: [
          if (!_isLoading)
            TextButton.icon(
              onPressed: _updateBrand,
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
                                    'Edit Brand',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isMobile ? 18 : 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Update brand information',
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

                      // Product Name Information Card
                      _buildSection(
                        title: 'Product Name Information',
                        icon: Icons.business,
                        themeProvider: themeProvider,
                        isMobile: isMobile,
                        children: [
                          _buildFormField(
                            label: 'Product Name',
                            hint: 'Enter product name',
                            controller: _nameController,
                            themeProvider: themeProvider,
                            isMobile: isMobile,
                            icon: Icons.label_rounded,
                            isRequired: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Product name is required';
                              }
                              if (value.trim().length < 2) {
                                return 'Product name must be at least 2 characters';
                              }
                              if (value.trim().length > 50) {
                                return 'Product name must be less than 50 characters';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 20 : 24),

                      // Product Name Details Info Card
                      _buildSection(
                        title: 'Product Name Details',
                        icon: Icons.info_outline,
                        themeProvider: themeProvider,
                        isMobile: isMobile,
                        children: [
                          _buildDetailRow(
                            'Current URL:',
                            '${widget.brand['slug'] ?? '-'}',
                            themeProvider,
                            isMobile,
                          ),
                          SizedBox(height: isMobile ? 8 : 12),
                          _buildDetailRow(
                            'Total Products:',
                            '${(widget.brand['produk_count'] as int?) ?? 0} items',
                            themeProvider,
                            isMobile,
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 32 : 40),

                      // Update Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _updateBrand,
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
                                ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Updating Brand...',
                                      style: TextStyle(
                                        fontSize: isMobile ? 14 : 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                )
                                : Text(
                                  'Update Product Name',
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 16,
                                    fontWeight: FontWeight.w600,
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

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required ThemeProvider themeProvider,
    required bool isMobile,
    required IconData icon,
    bool isRequired = false,
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
          validator: validator,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _updateBrand(),
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

  Widget _buildDetailRow(
    String label,
    String value,
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 4 : 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isMobile ? 100 : 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 12 : 13,
                color: themeProvider.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isMobile ? 12 : 13,
                color: themeProvider.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      if (dateString.isEmpty) return '-';
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
