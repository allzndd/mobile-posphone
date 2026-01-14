import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme_provider.dart';
import '../../../component/validation_handler.dart';
import '../../services/incoming_service.dart';
import 'edit.screen.dart';

class IncomingTransactionShowScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const IncomingTransactionShowScreen({
    super.key,
    required this.transaction,
  });

  static void show(BuildContext context, Map<String, dynamic> transaction) {
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
            child: IncomingTransactionShowScreen(transaction: transaction),
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
        maxWidth: isMobile ? double.infinity : (isTablet ? 600 : 700),
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
            // Header with Transaction Icon
            _buildTransactionHeader(context, themeProvider, isMobile),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Transaction Invoice & Status
                    _buildTransactionTitle(themeProvider, isMobile),

                    SizedBox(height: isMobile ? 16 : 20),

                    // Transaction Information Section
                    _buildTransactionInfoSection(themeProvider, isMobile),

                    SizedBox(height: isMobile ? 16 : 20),

                    // Items Section
                    _buildItemsSection(themeProvider, isMobile),

                    SizedBox(height: isMobile ? 16 : 20),

                    // Summary
                    _buildSummarySection(themeProvider, isMobile),
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

  Widget _buildTransactionHeader(
    BuildContext context,
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    final status = transaction['status'] ?? 'Unknown';
    final Color statusColor = _getStatusColor(status);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor,
            statusColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
              Icons.receipt_long_rounded,
              color: Colors.white,
              size: isMobile ? 28 : 36,
            ),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transaction Details',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  transaction['invoice'] ?? 'No Invoice',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTitle(ThemeProvider themeProvider, bool isMobile) {
    final status = transaction['status'] ?? 'Unknown';
    final Color statusColor = _getStatusColor(status);

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: statusColor,
            size: isMobile ? 20 : 24,
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: themeProvider.textSecondary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionInfoSection(
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
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
        _buildInfoRow(
          'Customer',
          transaction['customer_name'] ?? 'Walk-in Customer',
          Icons.person_rounded,
          themeProvider,
          isMobile,
        ),
        SizedBox(height: isMobile ? 12 : 16),
        _buildInfoRow(
          'Store',
          transaction['toko_name'] ?? '-',
          Icons.store_rounded,
          themeProvider,
          isMobile,
        ),
        SizedBox(height: isMobile ? 12 : 16),
        _buildInfoRow(
          'Payment Method',
          _formatPaymentMethod(transaction['metode_pembayaran'] ?? '-'),
          Icons.payment_rounded,
          themeProvider,
          isMobile,
        ),
        if (transaction['keterangan'] != null &&
            transaction['keterangan'].toString().isNotEmpty) ...[
          SizedBox(height: isMobile ? 12 : 16),
          _buildInfoRow(
            'Notes',
            transaction['keterangan'],
            Icons.note_rounded,
            themeProvider,
            isMobile,
          ),
        ],
      ],
    );
  }

  Widget _buildItemsSection(ThemeProvider themeProvider, bool isMobile) {
    final items = transaction['items'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items (${items.length})',
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: themeProvider.textPrimary,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        if (items.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: isMobile ? 20 : 24),
              child: Text(
                'No items',
                style: TextStyle(
                  color: themeProvider.textSecondary,
                  fontSize: isMobile ? 14 : 16,
                ),
              ),
            ),
          )
        else
          ...items
              .map((item) => _buildItemCard(item, themeProvider, isMobile))
              .toList(),
      ],
    );
  }

  Widget _buildItemCard(
    Map<String, dynamic> item,
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    final productName = item['produk_nama'] ?? item['product_name'] ?? 'Unknown Product';
    final quantity = item['quantity'] ?? 0;
    final price = item['harga_satuan'] ?? 0;
    final subtotal = item['subtotal'] ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: themeProvider.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 8 : 10),
            decoration: BoxDecoration(
              color: themeProvider.primaryMain.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              color: themeProvider.primaryMain,
              size: isMobile ? 20 : 24,
            ),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 14 : 16,
                    color: themeProvider.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Rp ${_formatPrice(price)} × $quantity',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: themeProvider.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Rp ${_formatPrice(subtotal)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 14 : 16,
              color: themeProvider.primaryMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(ThemeProvider themeProvider, bool isMobile) {
    final items = transaction['items'] as List? ?? [];
    final totalPrice = transaction['total_harga'] ?? 0;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeProvider.primaryMain.withOpacity(0.1),
            themeProvider.primaryMain.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.primaryMain.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Items:',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: themeProvider.textSecondary,
                ),
              ),
              Text(
                '${items.length}',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Divider(color: themeProvider.borderColor),
          SizedBox(height: isMobile ? 12 : 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand Total:',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                ),
              ),
              Text(
                'Rp ${_formatPrice(totalPrice)}',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 22,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.primaryMain,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: themeProvider.backgroundColor,
        border: Border(
          top: BorderSide(
            color: themeProvider.borderColor.withOpacity(0.3),
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
              onPressed: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IncomingTransactionEditScreen(
                      transaction: transaction,
                    ),
                  ),
                );
                if (result == true && context.mounted) {
                  Navigator.pop(context, true);
                }
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

  Future<void> _deleteTransaction(BuildContext context) async {
    try {
      final response = await IncomingService.deleteIncomingTransaction(
        transaction['id'],
      );

      if (!context.mounted) return;

      if (response['success'] == true) {
        await ValidationHandler.showSuccessDialog(
          context: context,
          title: 'Success',
          message: 'Transaction deleted successfully',
          onPressed: () {
            Navigator.pop(context); // Close success dialog
            Navigator.pop(context, true); // Close detail dialog and return true
          },
        );
      } else {
        await ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: response['message'] ?? 'Failed to delete transaction',
        );
      }
    } catch (e) {
      if (context.mounted) {
        await ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'Error deleting transaction: $e',
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    final statusLower = status.toLowerCase();
    switch (statusLower) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    return Row(
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
                  fontSize: isMobile ? 11 : 12,
                  color: themeProvider.textSecondary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String _formatPaymentMethod(String method) {
    final methodLower = method.toLowerCase();
    switch (methodLower) {
      case 'cash':
        return 'Cash';
      case 'transfer':
        return 'Bank Transfer';
      case 'e-wallet':
      case 'e_wallet':
        return 'E-Wallet';
      case 'credit':
        return 'Credit';
      default:
        return method;
    }
  }
}
