import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme_provider.dart';
import '../models/trade_in.dart';
import 'edit.screen.dart';

class TradeInShowScreen extends StatelessWidget {
  final TradeIn tradeIn;

  const TradeInShowScreen({super.key, required this.tradeIn});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Dialog(
      backgroundColor: themeProvider.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: isMobile ? screenWidth * 0.9 : 600,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                color: themeProvider.primaryMain,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Trade-In Details',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoSection(
                      'Customer Information',
                      [
                        _InfoRow('Customer Name', tradeIn.pelangganNama ?? '-'),
                        _InfoRow('Store Branch', tradeIn.tokoBranchNama ?? '-'),
                      ],
                      themeProvider,
                      isMobile,
                    ),
                    SizedBox(height: isMobile ? 20 : 24),
                    _buildInfoSection(
                      'Trade-In Product (Incoming)',
                      [
                        _InfoRow(
                          'Product Name',
                          tradeIn.produkMasukNama ?? '-',
                        ),
                        _InfoRow('Brand', tradeIn.produkMasukMerk ?? '-'),
                        _InfoRow(
                          'Condition',
                          tradeIn.produkMasukKondisi ?? '-',
                        ),
                        if (tradeIn.color != null && tradeIn.color!.isNotEmpty)
                          _InfoRow('Color', tradeIn.color ?? '-'),
                        if (tradeIn.storage != null &&
                            tradeIn.storage!.isNotEmpty)
                          _InfoRow('Storage', tradeIn.storage ?? '-'),
                        if (tradeIn.batteryHealth != null &&
                            tradeIn.batteryHealth!.isNotEmpty)
                          _InfoRow(
                            'Battery Health',
                            tradeIn.batteryHealth ?? '-',
                          ),
                        if (tradeIn.imei != null && tradeIn.imei!.isNotEmpty)
                          _InfoRow('IMEI', tradeIn.imei ?? '-'),
                        if (tradeIn.accessories != null &&
                            tradeIn.accessories!.isNotEmpty)
                          _InfoRow('Accessories', tradeIn.accessories ?? '-'),
                        _InfoRow(
                          'Purchase Price',
                          'Rp ${_formatCurrency(tradeIn.produkMasukHarga ?? 0)}',
                        ),
                      ],
                      themeProvider,
                      isMobile,
                    ),
                    SizedBox(height: isMobile ? 20 : 24),
                    _buildInfoSection(
                      'New Product (Outgoing)',
                      [
                        _InfoRow(
                          'Product Name',
                          tradeIn.produkKeluarNama ?? '-',
                        ),
                        _InfoRow('Brand', tradeIn.produkKeluarMerk ?? '-'),
                        _InfoRow(
                          'Price',
                          'Rp ${_formatCurrency(tradeIn.produkKeluarHarga ?? 0)}',
                        ),
                        if (tradeIn.diskonPersen != null &&
                            tradeIn.diskonPersen! > 0)
                          _InfoRow('Discount', '${tradeIn.diskonPersen}%'),
                        if (tradeIn.diskonAmount != null &&
                            tradeIn.diskonAmount! > 0)
                          _InfoRow(
                            'Discount Amount',
                            'Rp ${_formatCurrency(tradeIn.diskonAmount ?? 0)}',
                          ),
                        if (tradeIn.netAmount != null)
                          _InfoRow(
                            'Net Amount',
                            'Rp ${_formatCurrency(tradeIn.netAmount ?? 0)}',
                          ),
                      ],
                      themeProvider,
                      isMobile,
                    ),
                    SizedBox(height: isMobile ? 20 : 24),
                    _buildPriceDifferenceCard(themeProvider, isMobile),
                    SizedBox(height: isMobile ? 20 : 24),
                    _buildInfoSection(
                      'Transaction Information',
                      [
                        if (tradeIn.paymentMethod != null &&
                            tradeIn.paymentMethod!.isNotEmpty)
                          _InfoRow(
                            'Payment Method',
                            tradeIn.paymentMethod ?? '-',
                          ),
                        if (tradeIn.transaksiPenjualanInvoice != null)
                          _InfoRow(
                            'Sales Invoice',
                            tradeIn.transaksiPenjualanInvoice ?? '-',
                          ),
                        if (tradeIn.transaksiPembelianInvoice != null)
                          _InfoRow(
                            'Purchase Invoice',
                            tradeIn.transaksiPembelianInvoice ?? '-',
                          ),
                        if (tradeIn.catatan != null &&
                            tradeIn.catatan!.isNotEmpty)
                          _InfoRow('Notes', tradeIn.catatan ?? '-'),
                      ],
                      themeProvider,
                      isMobile,
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                color: themeProvider.backgroundColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 12 : 14,
                        ),
                        side: BorderSide(color: themeProvider.borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    TradeInEditScreen(tradeIn: tradeIn),
                          ),
                        );
                        if (result == true && context.mounted) {
                          Navigator.pop(context, true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeProvider.primaryMain,
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 12 : 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
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
  }

  Widget _buildInfoSection(
    String title,
    List<_InfoRow> rows,
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: themeProvider.textPrimary,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: themeProvider.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: themeProvider.borderColor),
          ),
          child: Column(
            children:
                rows
                    .asMap()
                    .entries
                    .map(
                      (entry) => Column(
                        children: [
                          if (entry.key > 0) const Divider(height: 24),
                          _buildInfoRow(
                            entry.value.label,
                            entry.value.value,
                            themeProvider,
                            isMobile,
                          ),
                        ],
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              color: themeProvider.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              fontWeight: FontWeight.w600,
              color: themeProvider.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceDifferenceCard(ThemeProvider themeProvider, bool isMobile) {
    final selisihHarga = tradeIn.selisihHarga ?? 0;
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color:
            selisihHarga >= 0
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              selisihHarga >= 0
                  ? Colors.green.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price Difference',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.textPrimary,
                ),
              ),
              Text(
                'Rp ${_formatCurrency(selisihHarga)}',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: selisihHarga >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            selisihHarga >= 0
                ? 'Customer pays the difference'
                : 'Store pays the difference',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.w500,
              color: themeProvider.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    return amount.abs().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

class _InfoRow {
  final String label;
  final String value;

  _InfoRow(this.label, this.value);
}
