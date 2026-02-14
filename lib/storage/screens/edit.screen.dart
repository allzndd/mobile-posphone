import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import '../../component/validation_handler.dart';
import '../services/storage_service.dart';
import '../models/storage.dart';

class StorageEditScreen extends StatefulWidget {
  final Storage storage;

  const StorageEditScreen({super.key, required this.storage});

  @override
  State<StorageEditScreen> createState() => _StorageEditScreenState();
}

class _StorageEditScreenState extends State<StorageEditScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _fieldErrors = {};
  bool _isLoading = false;
  bool _isInitialLoading = true;

  late TextEditingController _kapasitasController;
  late Storage _currentStorage;

  @override
  void initState() {
    super.initState();
    _currentStorage = widget.storage;
    _initializeControllers();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();

    _loadStorageData();
  }

  void _initializeControllers() {
    _kapasitasController = TextEditingController(
      text: _currentStorage.kapasitas,
    );
  }

  Future<void> _loadStorageData() async {
    try {
      final response = await StorageService.getStorageById(_currentStorage.id);

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _currentStorage = Storage.fromJson(response['data']);
          _kapasitasController.text = _currentStorage.kapasitas;
          _isInitialLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isInitialLoading = false);
        await ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'Failed to load storage data: $e',
        );
      }
    }
  }

  @override
  void dispose() {
    _kapasitasController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    setState(() => _fieldErrors.clear());

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await StorageService.updateStorage(
        id: _currentStorage.id,
        idOwner: _currentStorage.idOwner,
        kapasitas: _kapasitasController.text.trim(),
        idGlobal: _currentStorage.idGlobal,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        await ValidationHandler.showSuccessDialog(
          context: context,
          title: 'Success',
          message: 'Storage updated successfully',
        );

        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        if (response['errors'] != null && response['errors'] is Map) {
          setState(() {
            response['errors'].forEach((field, errors) {
              if (errors is List && errors.isNotEmpty) {
                _fieldErrors[field] = errors.first.toString();
              }
            });
          });

          if (_fieldErrors.isNotEmpty) {
            await ValidationHandler.showErrorDialog(
              context: context,
              title: 'Validation Error',
              message: 'Please check the form and correct any errors.',
            );
          } else {
            await ValidationHandler.showErrorDialog(
              context: context,
              title: 'Error',
              message: response['message'] ?? 'Failed to update storage',
            );
          }
        } else {
          await ValidationHandler.showErrorDialog(
            context: context,
            title: 'Error',
            message: response['message'] ?? 'Failed to update storage',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        await ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'Error updating storage: $e',
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
    final isDesktop = screenWidth > 900;

    if (_isInitialLoading) {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        appBar: AppBar(
          backgroundColor: themeProvider.surfaceColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: themeProvider.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Edit Storage',
            style: TextStyle(
              color: themeProvider.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Storage',
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (!_isLoading)
            TextButton.icon(
              onPressed: _submitForm,
              icon: Icon(Icons.check_rounded, color: themeProvider.primaryMain),
              label: Text(
                'Save',
                style: TextStyle(color: themeProvider.primaryMain),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: themeProvider.primaryMain,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildHeaderCard(isDesktop),
                  _buildFormSection(isDesktop),
                  _buildSubmitButton(context.watch<ThemeProvider>()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      margin: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeProvider.primaryMain,
            themeProvider.primaryMain.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: themeProvider.primaryMain.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 28 : 24),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isDesktop ? 14 : 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.storage_rounded,
                color: Colors.white,
                size: isDesktop ? 32 : 28,
              ),
            ),
            SizedBox(width: isDesktop ? 20 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Update Storage',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isDesktop ? 28 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isDesktop ? 8 : 6),
                  Text(
                    _currentStorage.kapasitas,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: isDesktop ? 15 : 13,
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

  Widget _buildFormSection(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      margin: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 28 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Penyimpanan Details',
              style: TextStyle(
                fontSize: isDesktop ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: themeProvider.textPrimary,
              ),
            ),
            SizedBox(height: isDesktop ? 24 : 20),
            _buildFormField(
              label: 'Capacity',
              isRequired: true,
              controller: _kapasitasController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Capacity is required';
                }
                return null;
              },
              hintText: 'e.g., 5000 units, 100 sqm, 50 racks',
              icon: Icons.straighten_rounded,
              isDesktop: isDesktop,
              themeProvider: themeProvider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required bool isRequired,
    required TextEditingController controller,
    String? Function(String?)? validator,
    String hintText = '',
    IconData? icon,
    int maxLines = 1,
    required bool isDesktop,
    required ThemeProvider themeProvider,
  }) {
    final hasError = _fieldErrors.containsKey(
      label.toLowerCase().replaceAll(' ', '_'),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: themeProvider.textPrimary,
              fontSize: isDesktop ? 14 : 13,
              fontWeight: FontWeight.w600,
            ),
            children: [
              if (isRequired)
                TextSpan(text: ' *', style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
        SizedBox(height: isDesktop ? 10 : 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          minLines: maxLines == 1 ? 1 : maxLines,
          style: TextStyle(color: themeProvider.textPrimary),
          validator: validator,
          onChanged: (value) {
            String fieldKey = label.toLowerCase().replaceAll(' ', '_');
            if (_fieldErrors.containsKey(fieldKey)) {
              setState(() => _fieldErrors.remove(fieldKey));
            }
          },
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: themeProvider.textTertiary),
            prefixIcon:
                icon != null
                    ? Icon(icon, color: themeProvider.textSecondary, size: 20)
                    : null,
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
                color:
                    hasError
                        ? Colors.red.withOpacity(0.5)
                        : themeProvider.textTertiary.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red : themeProvider.primaryMain,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 16 : 14,
              vertical: isDesktop ? 14 : 12,
            ),
            errorText: _fieldErrors[label.toLowerCase().replaceAll(' ', '_')],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeProvider.primaryMain,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
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
                  children: const [
                    Icon(Icons.save_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Update Storage',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
