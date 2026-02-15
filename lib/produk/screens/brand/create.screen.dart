import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../component/validation_handler.dart';
import '../../../config/theme_provider.dart';
import '../../services/brand_service.dart';
import '../../models/product_brand.dart';

class CreateBrandScreen extends StatefulWidget {
  const CreateBrandScreen({super.key});

  @override
  State<CreateBrandScreen> createState() => _CreateBrandScreenState();
}

class _CreateBrandScreenState extends State<CreateBrandScreen> {
  final _formKey = GlobalKey<FormState>();
  final _merkController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingBrands = false;
  
  List<ProductBrand> _brands = [];
  String? _selectedBrand;
  bool _isNewBrand = false;

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  @override
  void dispose() {
    _merkController.dispose();
    _nameController.dispose();
    super.dispose();
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

  Future<void> _saveBrand() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validation: Check if brand is selected or new brand is entered
    if (!_isNewBrand && (_selectedBrand == null || _selectedBrand!.isEmpty)) {
      ValidationHandler.showErrorDialog(
        context: context,
        title: 'Validation Error',
        message: 'Please select a brand or add a new one',
      );
      return;
    }
    
    if (_isNewBrand && _merkController.text.trim().isEmpty) {
      ValidationHandler.showErrorDialog(
        context: context,
        title: 'Validation Error',
        message: 'Please enter a brand name',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final brandMerk = _isNewBrand ? _merkController.text.trim() : _selectedBrand!;
      final brandNama = _nameController.text.trim();

      final response = await BrandService.createBrand(
        merk: brandMerk,
        nama: brandNama,
      );

      if (response['success'] == true) {
        if (mounted) {
          await ValidationHandler.showSuccessDialog(
            context: context,
            title: 'Success',
            message: response['message'] ?? 'Product Name has been created successfully!',
          );

          // Return the new brand data to the previous screen
          Navigator.pop(context, response['data']);
        }
      } else {
        if (mounted) {
          // Show validation errors if any
          if (response['errors'] != null) {
            final errors = response['errors'] as Map<String, dynamic>;
            final errorMessages = errors.values
                .expand((errorList) => errorList as List)
                .join('\n');
            
            await ValidationHandler.showErrorDialog(
              context: context,
              title: 'Validation Error',
              message: errorMessages,
            );
          } else {
            await ValidationHandler.showErrorDialog(
              context: context,
              title: 'Error',
              message: response['message'] ?? 'Failed to create product name',
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        await ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'Failed to create product name: $e',
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
              Icons.branding_watermark,
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
                  'New Product Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Create a new product name',
                  style: TextStyle(
                    color: Colors.white70,
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

  Widget _buildBrandInfoSection(ThemeProvider themeProvider, bool isMobile) {
    // Get unique brand names
    final existingBrands = _brands
        .map((b) => b.merk)
        .whereType<String>()
        .where((m) => m.isNotEmpty)
        .toSet()
        .toList();
    
    return _buildSectionCard(
      title: 'Product Name Information',
      icon: Icons.info_outline,
      themeProvider: themeProvider,
      isMobile: isMobile,
      children: [
        // Brand Field with Add New Button
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.business_rounded,
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
                const Spacer(),
                // Add New Button
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isNewBrand = !_isNewBrand;
                      if (_isNewBrand) {
                        _selectedBrand = null;
                      } else {
                        _merkController.clear();
                      }
                    });
                  },
                  icon: Icon(
                    _isNewBrand ? Icons.list : Icons.add,
                    size: isMobile ? 16 : 18,
                  ),
                  label: Text(
                    _isNewBrand ? 'Use existing' : 'Add New',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: themeProvider.primaryMain,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 6 : 8),
            
            // Show dropdown or text field based on _isNewBrand
            if (_isNewBrand)
              TextFormField(
                controller: _merkController,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: themeProvider.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g., Samsung, Apple, Xiaomi',
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
                  filled: true,
                  fillColor: themeProvider.backgroundColor,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: isMobile ? 12 : 16,
                  ),
                ),
              )
            else
              DropdownButtonFormField<String>(
                value: _selectedBrand,
                isExpanded: true,
                menuMaxHeight: 300, // Enable scrolling for long list
                decoration: InputDecoration(
                  hintText: '-- Select Brand --',
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
                  filled: true,
                  fillColor: themeProvider.backgroundColor,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: isMobile ? 12 : 16,
                  ),
                ),
                items: existingBrands.map((brand) {
                  return DropdownMenuItem<String>(
                    value: brand,
                    child: Text(
                      brand,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: themeProvider.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: _isLoadingBrands
                    ? null
                    : (value) {
                        setState(() {
                          _selectedBrand = value;
                        });
                      },
                dropdownColor: themeProvider.surfaceColor,
              ),
            
            SizedBox(height: isMobile ? 4 : 6),
            Text(
              'Select an existing brand or add a new one',
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: themeProvider.textSecondary,
              ),
            ),
          ],
        ),

        SizedBox(height: isMobile ? 16 : 20),

        // Product Name Field
        _buildFormField(
          label: 'Product Name',
          hint: 'e.g., Apple, Samsung, Xiaomi',
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

        SizedBox(height: isMobile ? 16 : 20),

        // Info Container
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                themeProvider.primaryMain.withOpacity(0.05),
                themeProvider.primaryMain.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: themeProvider.primaryMain.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeProvider.primaryMain.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb_rounded,
                  color: themeProvider.primaryMain,
                  size: isMobile ? 16 : 18,
                ),
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Smart URL Generation',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.primaryMain,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Product name will be automatically converted to URL-friendly format.',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 13,
                        height: 1.4,
                        color: themeProvider.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
        onPressed: _isLoading ? null : _saveBrand,
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
                    'Creating Product Name...',
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
                    'Create Product Name',
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

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required ThemeProvider themeProvider,
    required bool isMobile,
    required IconData icon,
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
          maxLines: maxLines,
          validator: validator,
          onFieldSubmitted: (_) => _saveBrand(),
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.watch<ThemeProvider>().surfaceColor,
        elevation: 0,
        title: Text(
          'Create Product Name',
          style: TextStyle(
            color: context.watch<ThemeProvider>().textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: context.watch<ThemeProvider>().textPrimary),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveBrand,
              child: Text(
                'Save',
                style: TextStyle(
                  color: context.watch<ThemeProvider>().primaryMain,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              _buildHeaderCard(context.watch<ThemeProvider>(), MediaQuery.of(context).size.width < 600),

              SizedBox(height: MediaQuery.of(context).size.width < 600 ? 16 : 24),

              // Brand Information Section
              _buildBrandInfoSection(context.watch<ThemeProvider>(), MediaQuery.of(context).size.width < 600),

              SizedBox(height: MediaQuery.of(context).size.width < 600 ? 32 : 48),

              // Submit Button
              _buildSubmitButton(context.watch<ThemeProvider>(), MediaQuery.of(context).size.width < 600),

              SizedBox(height: MediaQuery.of(context).size.width < 600 ? 16 : 24),
            ],
          ),
        ),
      ),
    );
  }
}
