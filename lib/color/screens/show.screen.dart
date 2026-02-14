import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import '../models/color.dart' as ColorModel;
import 'edit.screen.dart';

class ColorShowScreen extends StatelessWidget {
  final ColorModel.Color color;

  const ColorShowScreen({super.key, required this.color});

  static void show(BuildContext context, ColorModel.Color color) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width > 600 ? 40 : 16,
          vertical: 24,
        ),
        child: ColorShowScreen(color: color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
        maxWidth: isMobile ? double.infinity : (isTablet ? 500 : 600),
      ),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Color Icon
            _buildColorHeader(themeProvider, isMobile),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Color Name & Title
                    _buildColorTitle(themeProvider, isMobile),

                    SizedBox(height: isMobile ? 16 : 20),

                    // Color Information Section
                    _buildColorInfoSection(themeProvider, isMobile),
                  ],
                ),
              ),
            ),

            // Action Buttons
            _buildActionButtons(context, themeProvider, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildColorHeader(ThemeProvider themeProvider, bool isMobile) {
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
      ),
      child: Row(
        children: [
          // Color Icon
          Container(
            width: isMobile ? 60 : 80,
            height: isMobile ? 60 : 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            ),
            child: Icon(
              Icons.palette_rounded,
              color: Colors.white,
              size: isMobile ? 32 : 40,
            ),
          ),

          SizedBox(width: isMobile ? 12 : 16),

          // Color Badge
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 12,
                  vertical: isMobile ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: isMobile ? 14 : 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: isMobile ? 10 : 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorTitle(ThemeProvider themeProvider, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          color.warna,
          style: TextStyle(
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: themeProvider.textPrimary,
            height: 1.2,
          ),
        ),
        SizedBox(height: isMobile ? 4 : 6),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 10,
            vertical: isMobile ? 4 : 6,
          ),
          decoration: BoxDecoration(
            color: themeProvider.primaryMain.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Color',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.w500,
              color: themeProvider.primaryMain,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorInfoSection(ThemeProvider themeProvider, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Color Information',
          Icons.info_outline_rounded,
          themeProvider,
          isMobile,
        ),
        SizedBox(height: isMobile ? 8 : 12),

        Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: themeProvider.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: themeProvider.textTertiary.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              _buildInfoItem(
                Icons.palette_rounded,
                'Color Name',
                color.warna,
                themeProvider,
                isMobile,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
    String title,
    IconData icon,
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    return Row(
      children: [
        Icon(icon, size: isMobile ? 18 : 20, color: themeProvider.primaryMain),
        SizedBox(width: isMobile ? 6 : 8),
        Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: themeProvider.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 6 : 8),
          decoration: BoxDecoration(
            color: themeProvider.primaryMain.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: isMobile ? 16 : 18,
            color: themeProvider.primaryMain,
          ),
        ),
        SizedBox(width: isMobile ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: themeProvider.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: themeProvider.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        border: Border(
          top: BorderSide(
            color: themeProvider.textTertiary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: themeProvider.textTertiary.withOpacity(0.3),
                  ),
                ),
              ),
              child: Text(
                'Close',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.textSecondary,
                ),
              ),
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ColorEditScreen(colorId: color.id),
                  ),
                ).then((result) {
                  if (result == true) {
                    // Reload parent screen
                    Navigator.pop(context, true);
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.primaryMain,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, size: isMobile ? 16 : 18),
                  SizedBox(width: isMobile ? 6 : 8),
                  Text(
                    'Edit',
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
    );
  }
}
