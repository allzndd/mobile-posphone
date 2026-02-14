import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense_transaction.dart';
import 'edit.screen.dart';

class ExpenseTransactionShowDialog extends StatelessWidget {
  final PosExpenseTransactionModel transaction;

  const ExpenseTransactionShowDialog({super.key, required this.transaction});

  String _formatCurrency(double? amount) {
    if (amount == null) return 'Rp 0';
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    try {
      final DateFormat formatter = DateFormat('dd MMM yyyy, HH:mm');
      return formatter.format(date);
    } catch (e) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final dialogWidth = isMobile ? screenWidth * 0.95 : 600.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 40,
        vertical: isMobile ? 20 : 40,
      ),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, theme, isMobile),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 20 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(
                      context,
                      theme,
                      isMobile,
                      'Transaction Details',
                      Icons.receipt_long_rounded,
                      [
                        _buildInfoRow('Invoice', transaction.invoice ?? '-'),
                        _buildInfoRow('Status', transaction.status ?? '-'),
                        _buildInfoRow(
                          'Category',
                          transaction.kategoriExpenseName ?? '-',
                        ),
                        _buildInfoRow(
                          'Amount',
                          _formatCurrency(transaction.totalHarga),
                        ),
                      ],
                    ),
                    SizedBox(height: isMobile ? 16 : 20),
                    _buildInfoCard(
                      context,
                      theme,
                      isMobile,
                      'Payment Information',
                      Icons.payment_rounded,
                      [
                        _buildInfoRow(
                          'Method',
                          transaction.metodePembayaran ?? '-',
                        ),
                        _buildInfoRow(
                          'Payment Status',
                          transaction.paymentStatus ?? '-',
                        ),
                        _buildInfoRow(
                          'Paid Amount',
                          _formatCurrency(transaction.paidAmount),
                        ),
                        if (transaction.dueDate != null)
                          _buildInfoRow(
                            'Due Date',
                            _formatDate(transaction.dueDate),
                          ),
                        if (transaction.paymentTerms != null)
                          _buildInfoRow(
                            'Payment Terms',
                            '${transaction.paymentTerms} days',
                          ),
                      ],
                    ),
                    if (transaction.keterangan != null &&
                        transaction.keterangan!.isNotEmpty) ...[
                      SizedBox(height: isMobile ? 16 : 20),
                      _buildInfoCard(
                        context,
                        theme,
                        isMobile,
                        'Description',
                        Icons.description_rounded,
                        [
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              transaction.keterangan!,
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (transaction.tokoName != null) ...[
                      SizedBox(height: isMobile ? 16 : 20),
                      _buildInfoCard(
                        context,
                        theme,
                        isMobile,
                        'Store Information',
                        Icons.store_rounded,
                        [_buildInfoRow('Store', transaction.tokoName!)],
                      ),
                    ],
                    SizedBox(height: isMobile ? 16 : 20),
                    _buildInfoCard(
                      context,
                      theme,
                      isMobile,
                      'Timestamps',
                      Icons.access_time_rounded,
                      [
                        _buildInfoRow(
                          'Created At',
                          _formatDate(transaction.createdAt),
                        ),
                        _buildInfoRow(
                          'Updated At',
                          _formatDate(transaction.updatedAt),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _buildActionButtons(context, theme, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
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
              Icons.receipt_long_rounded,
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
                  'Transaction Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.invoice ?? 'N/A',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    ThemeData theme,
    bool isMobile,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ThemeData theme,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
              label: const Text('Close'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
                side: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ExpenseTransactionEditScreen(
                          transactionId: transaction.id,
                        ),
                  ),
                );
                if (result == true && context.mounted) {
                  Navigator.pop(context, true);
                }
              },
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Edit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
