import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme_provider.dart';
import '../../store/models/store.dart';
import '../../customers/models/customer.dart';

class TransactionReceipt extends StatelessWidget {
  final String invoice;
  final DateTime date;
  final Store? store;
  final Customer? customer;
  final String status;
  final List<Map<String, dynamic>> items;
  final double totalHarga;
  final String metodePembayaran;
  final String? keterangan;
  final ThemeProvider themeProvider;

  TransactionReceipt({
    super.key,
    required this.invoice,
    required this.date,
    this.store,
    this.customer,
    required this.status,
    required this.items,
    required this.totalHarga,
    required this.metodePembayaran,
    this.keterangan,
    required this.themeProvider,
  }) {
    debugPrint('=== TransactionReceipt Constructor ===');
    debugPrint('Invoice: $invoice');
    debugPrint('Date: $date');
    debugPrint('Store: ${store?.nama ?? "null"}');
    debugPrint('Customer: ${customer?.nama ?? "null"}');
    debugPrint('Status: $status');
    debugPrint('Items count: ${items.length}');
    debugPrint('Total: $totalHarga');
    debugPrint('Payment: $metodePembayaran');
    debugPrint('Notes: ${keterangan ?? "null"}');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('=== TransactionReceipt Build Start ===');
    try {
      final screenWidth = MediaQuery.of(context).size.width;
      final isMobile = screenWidth < 600;
      debugPrint('Screen width: $screenWidth, isMobile: $isMobile');

      return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : screenWidth * 0.25,
        vertical: 24,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with action buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeProvider.primaryMain,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transaction Receipt',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // TODO: Implement print functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Print feature coming soon'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.print, color: Colors.white),
                        tooltip: 'Print',
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Receipt Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Builder(
                  builder: (context) {
                    debugPrint('Building receipt content...');
                    return _buildReceiptContent();
                  },
                ),
              ),
            ),

            // Bottom Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement share/save
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Save feature coming soon'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.save_alt),
                      label: const Text('Save'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check),
                      label: const Text('Done'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeProvider.primaryMain,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    } catch (e, stackTrace) {
      debugPrint('ERROR in TransactionReceipt build: $e');
      debugPrint('Stack trace: $stackTrace');
      return Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Error displaying receipt',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildReceiptContent() {
    debugPrint('_buildReceiptContent called');
    try {
      debugPrint('Building receipt container...');
      return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Column(
              children: [
                Text(
                  store?.nama ?? 'TOKO',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier New',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  store?.alamat ?? 'Alamat Toko',
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'Courier New',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16a34a),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'PENJUALAN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Courier New',
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          _buildDashedLine(),
          const SizedBox(height: 8),

          // Transaction Info
          _buildInfoRow('No Invoice:', invoice),
          _buildInfoRow('Tanggal:', DateFormat('dd/MM/yyyy HH:mm').format(date)),
          _buildInfoRow('Toko:', store?.nama ?? '-'),
          if (customer != null) _buildInfoRow('Pelanggan:', customer!.nama),
          _buildInfoRow('Status:', status.toUpperCase()),

          const SizedBox(height: 8),
          _buildDashedLine(),
          const SizedBox(height: 8),

          // Items
          ...items.map((item) => _buildItemRow(item)),

          const SizedBox(height: 8),
          _buildDashedLine(),
          const SizedBox(height: 8),

          // Totals
          _buildTotalRow('Subtotal:', _formatCurrency(totalHarga)),
          const SizedBox(height: 8),
          _buildSolidLine(),
          const SizedBox(height: 8),
          _buildTotalRow(
            'TOTAL:',
            _formatCurrency(totalHarga),
            isBold: true,
            fontSize: 14,
          ),
          const SizedBox(height: 8),
          _buildTotalRow(
            'Metode Bayar:',
            _formatPaymentMethod(metodePembayaran),
          ),

          // Notes
          if (keterangan != null && keterangan!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildDashedLine(),
            const SizedBox(height: 8),
            const Text(
              'Catatan:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                fontFamily: 'Courier New',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              keterangan!,
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'Courier New',
              ),
            ),
          ],

          const SizedBox(height: 12),
          _buildDashedLine(),
          const SizedBox(height: 8),

          // Footer
          Center(
            child: Column(
              children: [
                const Text(
                  '*** TERIMA KASIH ***',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'Courier New',
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Nota Penjualan / Sales Receipt',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'Courier New',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dicetak: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'Courier New',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    } catch (e, stackTrace) {
      debugPrint('ERROR in _buildReceiptContent: $e');
      debugPrint('Stack trace: $stackTrace');
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(height: 8),
            Text('Error: $e'),
          ],
        ),
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier New',
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'Courier New',
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(Map<String, dynamic> item) {
    final name = item['name'] as String;
    final quantity = item['quantity'] as int;
    final price = item['price'] as int;
    final subtotal = item['subtotal'] as int;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier New',
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$quantity x ${_formatCurrency(price.toDouble())}',
                style: const TextStyle(
                  fontSize: 10,
                  fontFamily: 'Courier New',
                ),
              ),
              Text(
                _formatCurrency(subtotal.toDouble()),
                style: const TextStyle(
                  fontSize: 10,
                  fontFamily: 'Courier New',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 11,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'Courier New',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'Courier New',
          ),
        ),
      ],
    );
  }

  Widget _buildDashedLine() {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: DashedLinePainter(),
    );
  }

  Widget _buildSolidLine() {
    return Container(
      height: 2,
      color: Colors.black,
    );
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'CASH';
      case 'transfer':
        return 'BANK TRANSFER';
      case 'e-wallet':
        return 'E-WALLET';
      case 'credit':
        return 'CREDIT';
      default:
        return method.toUpperCase().replaceAll('-', ' ');
    }
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    const dashWidth = 3;
    const dashSpace = 3;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
