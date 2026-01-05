import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme_provider.dart';
import '../../models/product.dart';
import 'edit.screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  static void show(BuildContext context, Product product) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width > 600 ? 40 : 16,
          vertical: 24,
        ),
        child: ProductDetailScreen(product: product),
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
            // Header with Product Image/Icon
            _buildProductHeader(themeProvider, isMobile),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name & Brand
                    _buildProductTitle(themeProvider, isMobile),

                    SizedBox(height: isMobile ? 16 : 20),

                    // Specifications Section
                    _buildSpecificationSection(themeProvider, isMobile),

                    SizedBox(height: isMobile ? 16 : 20),

                    // Pricing Section
                    _buildPricingSection(themeProvider, isMobile),

                    SizedBox(height: isMobile ? 16 : 20),

                    // Stock & Availability Section
                    _buildStockSection(themeProvider, isMobile),

                    if (product.imei != null || product.aksesoris != null) ...[
                      SizedBox(height: isMobile ? 16 : 20),
                      _buildAdditionalInfoSection(themeProvider, isMobile),
                    ],
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

  Widget _buildProductHeader(ThemeProvider themeProvider, bool isMobile) {
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
          // Product Icon/Image
          Container(
            width: isMobile ? 60 : 80,
            height: isMobile ? 60 : 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            ),
            child: Icon(
              Icons.phone_android,
              color: Colors.white,
              size: isMobile ? 32 : 40,
            ),
          ),

          SizedBox(width: isMobile ? 12 : 16),

          // Stock Badge
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 12,
                  vertical: isMobile ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: product.isAvailable
                      ? Colors.green.withOpacity(0.9)
                      : Colors.red.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (product.isAvailable ? Colors.green : Colors.red)
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      product.isAvailable ? Icons.check_circle : Icons.warning,
                      color: Colors.white,
                      size: isMobile ? 14 : 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      product.isAvailable ? 'Available' : 'Out of Stock',
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

  Widget _buildProductTitle(ThemeProvider themeProvider, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.nama,
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
            product.merk?.nama ?? 'Unknown Brand',
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

  Widget _buildSpecificationSection(ThemeProvider themeProvider, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Specifications',
          Icons.settings,
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
              if (product.warna != null)
                _buildSpecItem(
                  Icons.palette,
                  'Color',
                  product.warna!,
                  themeProvider,
                  isMobile,
                ),

              if (product.penyimpanan != null) ...[
                if (product.warna != null) SizedBox(height: isMobile ? 8 : 12),
                _buildSpecItem(
                  Icons.storage,
                  'Storage',
                  '${product.penyimpanan}GB',
                  themeProvider,
                  isMobile,
                ),
              ],

              if (product.batteryHealth != null) ...[
                if (product.penyimpanan != null || product.warna != null)
                  SizedBox(height: isMobile ? 8 : 12),
                _buildSpecItem(
                  Icons.battery_full,
                  'Battery Health',
                  '${product.batteryHealth}%',
                  themeProvider,
                  isMobile,
                  valueColor: _getBatteryHealthColor(product.batteryHealth),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPricingSection(ThemeProvider themeProvider, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Pricing',
          Icons.attach_money,
          themeProvider,
          isMobile,
        ),
        SizedBox(height: isMobile ? 8 : 12),

        Row(
          children: [
            Expanded(
              child: _buildPriceCard(
                'Buy Price',
                product.formattedHargaBeli,
                Icons.shopping_cart,
                Colors.orange,
                themeProvider,
                isMobile,
              ),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Expanded(
              child: _buildPriceCard(
                'Sell Price',
                product.formattedHargaJual,
                Icons.sell,
                Colors.green,
                themeProvider,
                isMobile,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStockSection(ThemeProvider themeProvider, bool isMobile) {
    final stockCount = product.totalStok ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Stock Information',
          Icons.inventory,
          themeProvider,
          isMobile,
        ),
        SizedBox(height: isMobile ? 8 : 12),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getStockColor(stockCount).withOpacity(0.1),
                _getStockColor(stockCount).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getStockColor(stockCount).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 10),
                decoration: BoxDecoration(
                  color: _getStockColor(stockCount).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getStockIcon(stockCount),
                  color: _getStockColor(stockCount),
                  size: isMobile ? 20 : 24,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Stock',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: themeProvider.textSecondary,
                      ),
                    ),
                    Text(
                      '$stockCount units',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: _getStockColor(stockCount),
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

  Widget _buildAdditionalInfoSection(ThemeProvider themeProvider, bool isMobile) {
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
              if (product.imei != null)
                _buildSpecItem(
                  Icons.qr_code,
                  'IMEI',
                  product.imei!,
                  themeProvider,
                  isMobile,
                ),

              if (product.aksesoris != null) ...[
                if (product.imei != null) SizedBox(height: isMobile ? 8 : 12),
                _buildSpecItem(
                  Icons.headphones,
                  'Accessories',
                  product.aksesoris!,
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
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProductScreen(product: product),
                  ),
                );
                // If result is true, it means product was updated successfully
                // The parent screen should refresh the product list
                if (result == true) {
                  // You can add a callback here if needed
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

  Widget _buildSpecItem(
    IconData icon,
    String label,
    String value,
    ThemeProvider themeProvider,
    bool isMobile, {
    Color? valueColor,
  }) {
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
              color: valueColor ?? themeProvider.textPrimary,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCard(
    String title,
    String price,
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
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: isMobile ? 20 : 24,
          ),
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
            price,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getBatteryHealthColor(String? batteryHealth) {
    if (batteryHealth == null) return Colors.grey;
    final health = int.tryParse(batteryHealth) ?? 0;
    if (health >= 80) return Colors.green;
    if (health >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getStockColor(int stock) {
    if (stock == 0) return Colors.red;
    if (stock <= 5) return Colors.orange;
    return Colors.green;
  }

  IconData _getStockIcon(int stock) {
    if (stock == 0) return Icons.inventory_2;
    if (stock <= 5) return Icons.warning;
    return Icons.check_circle;
  }
}
