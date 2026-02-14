import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import '../../component/validation_handler.dart';
import '../services/color_service.dart';

class ColorCreateScreen extends StatefulWidget {
  const ColorCreateScreen({super.key});

  @override
  State<ColorCreateScreen> createState() => _ColorCreateScreenState();
}

class _ColorCreateScreenState extends State<ColorCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();

  bool _isLoading = false;
  Map<String, String> _fieldErrors = {};

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }


  Future<void> _saveColor() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      _isLoading = true;
      _fieldErrors = {};
    });

    try {
      final response = await ColorService.createColor(
        warna: _namaController.text,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        await ValidationHandler.showSuccessDialog(
          context: context,
          title: 'Success',
          message: response['message'] ?? 'Color created successfully',
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
            Navigator.pop(context, true); // Return to previous screen
          },
        );
      } else {
        if (response['errors'] != null) {
          setState(() {
            _fieldErrors = Map<String, String>.from(
              response['errors'].map(
                (key, value) => MapEntry(key, value is List ? value.first : value.toString()),
              ),
            );
          });
          
          await ValidationHandler.showErrorDialog(
            context: context,
            title: 'Validation Error',
            message: 'Please check the form and correct any errors.',
          );
        } else {
          await ValidationHandler.showErrorDialog(
            context: context,
            title: 'Error',
            message: response['message'] ?? 'Failed to create color',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
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

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.surfaceColor,
        elevation: 0,
        title: Text(
          'Create Color',
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: themeProvider.textPrimary),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveColor,
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
              child: _buildColorInfoSection(themeProvider, isMobile),
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
                  'New Color',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create a new color',
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

  Widget _buildColorInfoSection(ThemeProvider themeProvider, bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 8,
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
              Icon(
                Icons.info_outline_rounded,
                color: themeProvider.primaryMain,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Color Information',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          
          // Color Name Field
          RichText(
            text: TextSpan(
              text: 'Color Name ',
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
            controller: _namaController,
            style: TextStyle(color: themeProvider.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter color name',
              hintStyle: TextStyle(color: themeProvider.textTertiary),
              prefixIcon: Icon(
                Icons.palette_rounded,
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
              errorText: _fieldErrors['warna'],
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Color name is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ThemeProvider themeProvider, bool isMobile) {
    return Container(
      margin: EdgeInsets.all(isMobile ? 16 : 24),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveColor,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeProvider.primaryMain,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
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
                    'Create Color',
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
