import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme_provider.dart';
import '../../models/stock_management.dart';
import 'edit.screen.dart';

class StockDetailScreen extends StatelessWidget {
  final ProdukStok stock;
  final Map<String, dynamic>? productData;
  final Map<String, dynamic>? storeData;

  const StockDetailScreen({
    super.key,
    required this.stock,
    this.productData,
    this.storeData,
  });

  static void show(
    BuildContext context, 
    ProdukStok stock, {
    Map<String, dynamic>? productData,
    Map<String, dynamic>? storeData,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width > 600 ? 40 : 16,
          vertical: 24,
        ),
        child: StockDetailScreen(
          stock: stock,
          productData: productData,
          storeData: storeData,
        ),
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
            // Header with Stock Icon
            _buildStockHeader(themeProvider, isMobile),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Information
                    _buildProductInfo(themeProvider, isMobile),

                    SizedBox(height: isMobile ? 16 : 20),

                    // Store Information
                    _buildStoreInfo(themeProvider, isMobile),

                    SizedBox(height: isMobile ? 16 : 20),

                    // Stock Details Section
                    _buildStockDetailsSection(themeProvider, isMobile),
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

  Widget _buildStockHeader(ThemeProvider themeProvider, bool isMobile) {
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
          // Stock Icon
          Container(
            width: isMobile ? 60 : 80,
            height: isMobile ? 60 : 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            ),
            child: Icon(
              Icons.inventory_2,
              color: Colors.white,
              size: isMobile ? 32 : 40,
            ),
          ),

          SizedBox(width: isMobile ? 12 : 16),

          // Stock Status Badge
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 12,
                  vertical: isMobile ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: _getStockStatusColor().withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _getStockStatusColor().withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStockStatusIcon(),
                      color: Colors.white,
                      size: isMobile ? 14 : 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      _getStockStatusText(),
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

  Widget _buildProductInfo(ThemeProvider themeProvider, bool isMobile) {
    final productName = productData?['nama'] ?? 'Unknown Product';
    final brandName = productData?['merk']?['nama'] ?? 'Unknown Brand';
    final warna = productData?['warna'];
    final penyimpanan = productData?['penyimpanan'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Product Information',
          Icons.shopping_bag,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                productName,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 8 : 10,
                      vertical: isMobile ? 4 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: themeProvider.primaryMain.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.business,
                          size: isMobile ? 10 : 12,
                          color: themeProvider.primaryMain,
                        ),
                        SizedBox(width: 4),
                        Text(
                          brandName,
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 12,
                            fontWeight: FontWeight.w500,
                            color: themeProvider.primaryMain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (warna != null || penyimpanan != null) ...[
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 8 : 10,
                        vertical: isMobile ? 4 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        [
                          if (warna != null) warna,
                          if (penyimpanan != null) '${penyimpanan}GB',
                        ].join(' • '),
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStoreInfo(ThemeProvider themeProvider, bool isMobile) {
    final storeName = storeData?['nama'] ?? 'Unknown Store';
    final storeAddress = storeData?['alamat'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Store Location',
          Icons.store,
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
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 10 : 12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.storefront,
                  color: Colors.green,
                  size: isMobile ? 20 : 24,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storeName,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.textPrimary,
                      ),
                    ),
                    if (storeAddress != null && storeAddress.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: isMobile ? 12 : 14,
                            color: themeProvider.textSecondary,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              storeAddress,
                              style: TextStyle(
                                fontSize: isMobile ? 11 : 12,
                                color: themeProvider.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStockDetailsSection(ThemeProvider themeProvider, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Stock Details',
          Icons.inventory,
          themeProvider,
          isMobile,
        ),
        SizedBox(height: isMobile ? 8 : 12),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 20 : 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getStockStatusColor().withOpacity(0.1),
                _getStockStatusColor().withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getStockStatusColor().withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: BoxDecoration(
                  color: _getStockStatusColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.format_list_numbered,
                  color: _getStockStatusColor(),
                  size: isMobile ? 24 : 28,
                ),
              ),
              SizedBox(width: isMobile ? 16 : 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Stock',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: themeProvider.textSecondary,
                      ),
                    ),
                    Text(
                      '${stock.stok} units',
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: _getStockStatusColor(),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _getStockDescription(),
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
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
                    color: themeProvider.borderColor,
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
              onPressed: () async {
                Navigator.pop(context); // Close detail modal
                
                // Navigate to edit screen with ProdukStok and data maps
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StockEditScreen(
                      stock: stock,
                      productData: productData,
                      storeData: storeData,
                    ),
                  ),
                );
                
                // If result is true, it means stock was updated successfully
                if (result == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Stock updated successfully!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.primaryMain,
                padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.edit,
                    size: isMobile ? 16 : 18,
                    color: Colors.white,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Widget _buildSectionTitle(
    String title,
    IconData icon,
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: isMobile ? 18 : 20,
          color: themeProvider.primaryMain,
        ),
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

  Widget _buildDetailItem(
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

  // Helper methods for stock status
  Color _getStockStatusColor() {
    if (stock.stok == 0) return Colors.red;
    if (stock.stok <= 5) return Colors.orange;
    if (stock.stok <= 20) return Colors.blue;
    return Colors.green;
  }

  IconData _getStockStatusIcon() {
    if (stock.stok == 0) return Icons.warning;
    if (stock.stok <= 5) return Icons.warning_amber;
    if (stock.stok <= 20) return Icons.info;
    return Icons.check_circle;
  }

  String _getStockStatusText() {
    if (stock.stok == 0) return 'Out of Stock';
    if (stock.stok <= 5) return 'Low Stock';
    if (stock.stok <= 20) return 'Normal Stock';
    return 'Good Stock';
  }

  String _getStockDescription() {
    if (stock.stok == 0) return 'No items available in stock';
    if (stock.stok <= 5) return 'Stock level is critically low';
    if (stock.stok <= 20) return 'Stock level is at normal range';
    return 'Stock level is healthy';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 30) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
