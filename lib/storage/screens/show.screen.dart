import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import '../models/storage.dart';
import 'edit.screen.dart';

class StorageShowScreen extends StatelessWidget {
  final Storage storage;

  const StorageShowScreen({super.key, required this.storage});

  static void show(BuildContext context, Storage storage) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 600 ? 40 : 16,
              vertical: 24,
            ),
            child: StorageShowScreen(storage: storage),
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
            _buildStorageHeader(themeProvider, isMobile),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_buildStorageInfo(themeProvider, isMobile)],
                ),
              ),
            ),
            _buildActionButtons(context, themeProvider, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageHeader(ThemeProvider themeProvider, bool isMobile) {
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
          Container(
            padding: EdgeInsets.all(isMobile ? 10 : 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.storage_rounded,
              color: Colors.white,
              size: isMobile ? 24 : 28,
            ),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Storage Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  storage.kapasitas,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isMobile ? 13 : 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageInfo(ThemeProvider themeProvider, bool isMobile) {
    final items = [
      {
        'icon': Icons.straighten_rounded,
        'label': 'Capacity',
        'value': storage.kapasitas,
      },
      if (storage.idGlobal != null && storage.idGlobal!.isNotEmpty)
        {
          'icon': Icons.tag_rounded,
          'label': 'Storage ID',
          'value': storage.idGlobal!,
        },
      {
        'icon': Icons.person_rounded,
        'label': 'Owner ID',
        'value': storage.idOwner.toString(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Information',
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: themeProvider.textPrimary,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        ...items.map(
          (item) => Padding(
            padding: EdgeInsets.only(bottom: isMobile ? 12 : 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 8 : 10),
                  decoration: BoxDecoration(
                    color: themeProvider.primaryMain.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: themeProvider.primaryMain,
                    size: isMobile ? 16 : 18,
                  ),
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          color: themeProvider.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        item['value'] as String,
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
            ),
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
                    builder: (context) => StorageEditScreen(storage: storage),
                  ),
                ).then((result) {
                  if (result == true) {
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
