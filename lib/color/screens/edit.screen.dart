import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import '../models/color.dart' as ColorModel;
import '../services/color_service.dart';
import '../../component/validation_handler.dart';

class ColorEditScreen extends StatefulWidget {
  final int colorId;

  const ColorEditScreen({super.key, required this.colorId});

  @override
  State<ColorEditScreen> createState() => _ColorEditScreenState();
}

class _ColorEditScreenState extends State<ColorEditScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late AnimationController _animationController;
  bool _isLoading = false;
  bool _isLoadingData = true;
  String? _errorMessage;
  ColorModel.Color? _color;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadColorData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadColorData() async {
    try {
      final result = await ColorService.getColorById(widget.colorId);

      if (mounted) {
        if (result['success']) {
          final color = ColorModel.Color.fromJson(result['data']);
          setState(() {
            _color = color;
            _nameController.text = color.warna;
            _isLoadingData = false;
          });
          _animationController.forward();
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Failed to load color data';
            _isLoadingData = false;
          });
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred. Please try again.';
          _isLoadingData = false;
        });
      }
    }
  }

  Future<void> _updateColor() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Color name cannot be empty');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ColorService.updateColor(
        id: widget.colorId,
        warna: _nameController.text.trim(),
      );

      if (mounted) {
        if (result['success']) {
          if (mounted) {
            await ValidationHandler.showSuccessDialog(
              context: context,
              title: 'Success',
              message: 'Color updated successfully',
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.pop(context, true); // Return to previous screen
              },
            );
          }
        } else {
          setState(() => _errorMessage = result['message'] ?? 'Failed to update color');
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() => _errorMessage = 'An error occurred. Please try again.');
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

    if (_isLoadingData) {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        appBar: _buildAppBar(themeProvider, isMobile),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(themeProvider.primaryMain),
          ),
        ),
      );
    }

    if (_color == null) {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        appBar: _buildAppBar(themeProvider, isMobile),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: isMobile ? 48 : 56,
                color: Colors.red,
              ),
              SizedBox(height: isMobile ? 16 : 24),
              Text(
                _errorMessage ?? 'Failed to load color',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  color: themeProvider.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 24 : 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.primaryMain,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : 32,
                    vertical: isMobile ? 12 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                  ),
                ),
                child: Text(
                  'Go Back',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: _buildAppBar(themeProvider, isMobile),
      body: SafeArea(
        child: FadeTransition(
          opacity: _animationController,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeaderSection(themeProvider, isMobile),
                SizedBox(height: isMobile ? 24 : 32),

                // Form Section
                Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  decoration: BoxDecoration(
                    color: themeProvider.surfaceColor,
                    borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                    border: Border.all(
                      color: themeProvider.textTertiary.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Color Name Field
                      _buildFormField(
                        label: 'Color Name',
                        controller: _nameController,
                        hint: 'Enter color name',
                        icon: Icons.palette_rounded,
                        themeProvider: themeProvider,
                        isMobile: isMobile,
                      ),

                      SizedBox(height: isMobile ? 20 : 24),

                      // Error Message
                      if (_errorMessage != null) ...[
                        Container(
                          padding: EdgeInsets.all(isMobile ? 12 : 16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: isMobile ? 18 : 20,
                              ),
                              SizedBox(width: isMobile ? 12 : 16),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: isMobile ? 14 : 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isMobile ? 16 : 20),
                      ],

                      // Update Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateColor,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeProvider.primaryMain,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                themeProvider.primaryMain.withOpacity(0.5),
                            padding: EdgeInsets.symmetric(
                              vertical: isMobile ? 14 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(isMobile ? 10 : 12),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: isMobile ? 20 : 24,
                                  width: isMobile ? 20 : 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.update,
                                      size: isMobile ? 18 : 20,
                                    ),
                                    SizedBox(width: isMobile ? 8 : 10),
                                    Text(
                                      'Update Color',
                                      style: TextStyle(
                                        fontSize: isMobile ? 14 : 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isMobile ? 24 : 32),

                // Help Text
                _buildHelpText(themeProvider, isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeProvider themeProvider, bool isMobile) {
    return AppBar(
      backgroundColor: themeProvider.primaryMain,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Edit Color',
        style: TextStyle(
          fontSize: isMobile ? 18 : 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildHeaderSection(ThemeProvider themeProvider, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Edit Color',
          style: TextStyle(
            fontSize: isMobile ? 28 : 32,
            fontWeight: FontWeight.bold,
            color: themeProvider.textPrimary,
          ),
        ),
        SizedBox(height: isMobile ? 8 : 12),
        Text(
          'Update the color information',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: themeProvider.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required ThemeProvider themeProvider,
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: isMobile ? 18 : 20, color: themeProvider.primaryMain),
            SizedBox(width: isMobile ? 6 : 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: themeProvider.textPrimary,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 8 : 10),
        TextField(
          controller: controller,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: themeProvider.textTertiary.withOpacity(0.6),
              fontSize: isMobile ? 14 : 15,
            ),
            prefixIcon: Icon(
              icon,
              color: themeProvider.primaryMain.withOpacity(0.5),
              size: isMobile ? 18 : 20,
            ),
            filled: true,
            fillColor: themeProvider.backgroundColor.withOpacity(0.5),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 12 : 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
              borderSide: BorderSide(
                color: themeProvider.textTertiary.withOpacity(0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
              borderSide: BorderSide(
                color: themeProvider.textTertiary.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
              borderSide: BorderSide(
                color: themeProvider.primaryMain,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
              borderSide: BorderSide(
                color: themeProvider.textTertiary.withOpacity(0.1),
              ),
            ),
          ),
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: themeProvider.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildHelpText(ThemeProvider themeProvider, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: themeProvider.primaryMain.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeProvider.primaryMain.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: isMobile ? 18 : 20,
            color: themeProvider.primaryMain,
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Text(
              'Update the color name to reflect any changes',
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: themeProvider.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
