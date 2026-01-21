import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme_provider.dart';
import '../../config/app_theme.dart';
import '../models/admin_user_model.dart';
import '../services/user_management_service.dart';
import 'edit.screen.dart';

class ShowAdminScreen extends StatefulWidget {
  final AdminUserModel admin;

  const ShowAdminScreen({super.key, required this.admin});

  static Future<bool?> show(BuildContext context, AdminUserModel admin) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width > 600 ? 40 : 16,
          vertical: 24,
        ),
        child: ShowAdminScreen(admin: admin),
      ),
    );
  }

  @override
  State<ShowAdminScreen> createState() => _ShowAdminScreenState();
}

class _ShowAdminScreenState extends State<ShowAdminScreen> {
  Future<void> _editAdmin() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAdminScreen(admin: widget.admin),
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context, true); // Return true to refresh list
    }
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
            // Header with Admin Icon
            _buildAdminHeader(themeProvider, isMobile),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Admin Name & Title
                    _buildAdminTitle(themeProvider, isMobile),

                    SizedBox(height: isMobile ? 16 : 20),

                    // Admin Information Section
                    _buildAdminInfoSection(themeProvider, isMobile),
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

  Widget _buildAdminHeader(ThemeProvider themeProvider, bool isMobile) {
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
          // Admin Icon
          Container(
            width: isMobile ? 60 : 80,
            height: isMobile ? 60 : 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            ),
            child: Center(
              child: Text(
                widget.admin.nama.isNotEmpty
                    ? widget.admin.nama.substring(0, 1).toUpperCase()
                    : 'A',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SizedBox(width: isMobile ? 12 : 16),

          // Admin Badge
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 12,
                  vertical: isMobile ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: isMobile ? 14 : 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Admin',
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

  Widget _buildAdminTitle(ThemeProvider themeProvider, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.admin.nama,
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
            'System Administrator',
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

  Widget _buildAdminInfoSection(ThemeProvider themeProvider, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Admin Information',
          Icons.person_rounded,
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
              color: themeProvider.borderColor.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              _buildInfoItem(
                Icons.email,
                'Email',
                widget.admin.email,
                themeProvider,
                isMobile,
              ),
              if (widget.admin.storeName != null) ...[
                SizedBox(height: isMobile ? 12 : 16),
                _buildInfoItem(
                  Icons.store,
                  'Store',
                  widget.admin.storeName!,
                  themeProvider,
                  isMobile,
                ),
              ],
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
            color: themeProvider.borderColor.withOpacity(0.3),
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
                    color: themeProvider.borderColor.withOpacity(0.3),
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
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _editAdmin,
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

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }
}
