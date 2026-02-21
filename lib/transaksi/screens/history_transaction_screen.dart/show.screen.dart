import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme_provider.dart';

class HistoryTransactionShowScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const HistoryTransactionShowScreen({
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
            child: HistoryTransactionShowScreen(transaction: transaction),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final isIncoming = transaction['is_incoming'] == true;

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
            // Header
            _buildTransactionHeader(context, themeProvider, isMobile, isIncoming),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Transaction Invoice & Status
                    _buildTransactionTitle(themeProvider, isMobile, isIncoming),

                    SizedBox(height: isMobile ? 16 : 20),

                    // Transaction Information Section
                    _buildTransactionInfoSection(themeProvider, isMobile, isIncoming),

                    SizedBox(height: isMobile ? 16 : 20),

                    // Items Section
                    _buildItemsSection(themeProvider, isMobile),

                    SizedBox(height: isMobile ? 16 : 20),

                    // Summary
                    _buildSummarySection(themeProvider, isMobile, isIncoming),
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
    bool isIncoming,
  ) {
    final typeColor = isIncoming ? Colors.green : Colors.red;
    final typeLabel = isIncoming ? 'Incoming Transaction' : 'Outgoing Transaction';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            typeColor,
            typeColor.withOpacity(0.8),
          ],
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
              isIncoming
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
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
                  typeLabel,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Transaction Details',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            iconSize: isMobile ? 24 : 28,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTitle(
    ThemeProvider themeProvider,
    bool isMobile,
    bool isIncoming,
  ) {
    final status = transaction['status'] ?? 'Unknown';
    final statusColor = _getStatusColor(status);
    final typeColor = isIncoming ? Colors.green : Colors.red;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction['invoice'] ?? 'N/A',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                _formatDate(transaction['created_at'] ?? ''),
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: themeProvider.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: typeColor.withOpacity(0.3)),
              ),
              child: Text(
                transaction['type'] ?? '-',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.bold,
                  color: typeColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionInfoSection(
    ThemeProvider themeProvider,
    bool isMobile,
    bool isIncoming,
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
          isIncoming ? 'Customer' : 'Supplier',
          transaction['customer_name'] ?? '-',
          isIncoming ? Icons.person_rounded : Icons.local_shipping_rounded,
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

  Widget _buildSummarySection(
    ThemeProvider themeProvider,
    bool isMobile,
    bool isIncoming,
  ) {
    final items = transaction['items'] as List? ?? [];
    final totalPrice = transaction['total_harga'] ?? 0;
    final typeColor = isIncoming ? Colors.green : Colors.red;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            typeColor.withOpacity(0.1),
            typeColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: typeColor.withOpacity(0.3)),
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
                  color: typeColor,
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
        ],
      ),
    );
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
      case 'qris':
        return 'QRIS';
      case 'debit':
        return 'Debit';
      default:
        return method;
    }
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '-';
    
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      
      return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}
