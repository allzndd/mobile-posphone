import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme_provider.dart';

class StockHistoryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> history;

  const StockHistoryDetailScreen({super.key, required this.history});

  static void show(BuildContext context, Map<String, dynamic> history) {
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
            child: StockHistoryDetailScreen(history: history),
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
            // Header with Stock Movement Info
            _buildHistoryHeader(themeProvider, isMobile),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Information
                    _buildProductSection(themeProvider, isMobile),

                    SizedBox(height: isMobile ? 16 : 20),

                    // Stock Changes Section
                    _buildStockChangeSection(themeProvider, isMobile),

                    SizedBox(height: isMobile ? 16 : 20),

                    // Store & User Information
                    _buildStoreUserSection(themeProvider, isMobile),

                    SizedBox(height: isMobile ? 16 : 20),

                    // Reference & Description Section
                    _buildReferenceSection(themeProvider, isMobile),
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

  Widget _buildHistoryHeader(ThemeProvider themeProvider, bool isMobile) {
    final type = history['tipe']?.toString() ?? 'unknown';
    final change = (history['perubahan'] as num?)?.toInt() ?? 0;

    IconData typeIcon = Icons.swap_horiz;
    String typeTitle = 'Stock Movement';

    switch (type) {
      case 'masuk':
        typeIcon = Icons.add_circle;
        typeTitle = 'Stock In';
        break;
      case 'keluar':
        typeIcon = Icons.remove_circle;
        typeTitle = 'Stock Out';
        break;
      case 'adjustment':
        typeIcon = Icons.edit;
        typeTitle = 'Stock Adjustment';
        break;
    }

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
          // Type Icon
          Container(
            width: isMobile ? 60 : 80,
            height: isMobile ? 60 : 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            ),
            child: Icon(
              typeIcon,
              color: Colors.white,
              size: isMobile ? 32 : 40,
            ),
          ),

          SizedBox(width: isMobile ? 12 : 16),

          // Title and Change Amount
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${change >= 0 ? '+' : ''}$change units',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Date Badge
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
              _formatDate(history['created_at'] ?? DateTime.now().toIso8601String()),
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

  Widget _buildProductSection(ThemeProvider themeProvider, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Product Information',
          Icons.inventory_2,
          themeProvider,
          isMobile,
        ),
        SizedBox(height: isMobile ? 8 : 12),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 16 : 20),
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
                Icons.phone_android,
                'Product Name',
                history['produk']?['nama'] ?? 'Unknown Product',
                themeProvider,
                isMobile,
              ),
              SizedBox(height: isMobile ? 12 : 16),
              _buildInfoItem(
                Icons.business,
                'Brand',
                history['produk']?['merk']?['nama'] ?? 'Unknown Brand',
                themeProvider,
                isMobile,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStockChangeSection(ThemeProvider themeProvider, bool isMobile) {
    final stockBefore = history['stok_sebelum'] ?? 0;
    final stockAfter = history['stok_sesudah'] ?? 0;
    final change = history['perubahan'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Stock Changes',
          Icons.trending_up,
          themeProvider,
          isMobile,
        ),
        SizedBox(height: isMobile ? 8 : 12),

        Row(
          children: [
            Expanded(
              child: _buildStockCard(
                'Before',
                stockBefore.toString(),
                Icons.remove_circle_outline,
                Colors.orange,
                themeProvider,
                isMobile,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12),
              width: isMobile ? 30 : 40,
              height: 2,
              decoration: BoxDecoration(
                color: themeProvider.borderColor,
                borderRadius: BorderRadius.circular(1),
              ),
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  Container(
                    width: isMobile ? 6 : 8,
                    height: isMobile ? 6 : 8,
                    decoration: BoxDecoration(
                      color: themeProvider.primaryMain,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildStockCard(
                'After',
                stockAfter.toString(),
                Icons.add_circle_outline,
                Colors.green,
                themeProvider,
                isMobile,
              ),
            ),
          ],
        ),

        SizedBox(height: isMobile ? 12 : 16),

        // Change Summary
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getChangeColor(change).withOpacity(0.1),
                _getChangeColor(change).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getChangeColor(change).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 10),
                decoration: BoxDecoration(
                  color: _getChangeColor(change).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getChangeIcon(change),
                  color: _getChangeColor(change),
                  size: isMobile ? 20 : 24,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Change',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: themeProvider.textSecondary,
                      ),
                    ),
                    Text(
                      '${change >= 0 ? '+' : ''}$change units',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: _getChangeColor(change),
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

  Widget _buildStoreUserSection(ThemeProvider themeProvider, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Store & User Information',
          Icons.store,
          themeProvider,
          isMobile,
        ),
        SizedBox(height: isMobile ? 8 : 12),

        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Store',
                history['toko']?['nama'] ?? 'Unknown Store',
                Icons.store,
                Colors.blue,
                themeProvider,
                isMobile,
              ),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Expanded(
              child: _buildInfoCard(
                'User',
                history['pengguna']?['name'] ?? 'Unknown User',
                Icons.person,
                Colors.purple,
                themeProvider,
                isMobile,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReferenceSection(ThemeProvider themeProvider, bool isMobile) {
    final reference = history['referensi'] ?? 'No reference';
    final description = history['keterangan'] ?? 'No description';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Additional Information',
          Icons.info_outline,
          themeProvider,
          isMobile,
        ),
        SizedBox(height: isMobile ? 8 : 12),

        Container(
          width: double.infinity,
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
              if (reference.isNotEmpty && reference != 'No reference') ...[
                _buildInfoItem(
                  Icons.link,
                  'Reference',
                  reference,
                  themeProvider,
                  isMobile,
                ),
                if (description.isNotEmpty && description != 'No description')
                  SizedBox(height: isMobile ? 12 : 16),
              ],
              if (description.isNotEmpty && description != 'No description')
                _buildInfoItem(
                  Icons.description,
                  'Description',
                  description,
                  themeProvider,
                  isMobile,
                ),
              if ((reference.isEmpty || reference == 'No reference') &&
                  (description.isEmpty || description == 'No description'))
                Text(
                  'No additional information available',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: themeProvider.textSecondary,
                    fontStyle: FontStyle.italic,
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
      child: SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: themeProvider.borderColor),
            ),
          ),
          child: Text(
            'Close',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: themeProvider.textPrimary,
            ),
          ),
        ),
      ),
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
        SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.w600,
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
      children: [
        Icon(
          icon,
          size: isMobile ? 16 : 18,
          color: themeProvider.textSecondary,
        ),
        SizedBox(width: isMobile ? 8 : 12),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: isMobile ? 12 : 14,
            color: themeProvider.textSecondary,
          ),
        ),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.w500,
              color: themeProvider.textPrimary,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildStockCard(
    String title,
    String value,
    IconData icon,
    Color color,
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: isMobile ? 20 : 24),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 10 : 12,
              color: themeProvider.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: isMobile ? 20 : 24),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 10 : 12,
              color: themeProvider.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getChangeColor(int change) {
    if (change > 0) return Colors.green;
    if (change < 0) return Colors.red;
    return Colors.blue;
  }

  IconData _getChangeIcon(int change) {
    if (change > 0) return Icons.trending_up;
    if (change < 0) return Icons.trending_down;
    return Icons.trending_flat;
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
