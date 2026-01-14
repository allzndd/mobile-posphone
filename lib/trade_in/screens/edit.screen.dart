import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import '../../component/validation_handler.dart';
import '../models/trade_in.dart';
import '../services/trade_in_service.dart';

class TradeInEditScreen extends StatefulWidget {
  final TradeIn tradeIn;

  const TradeInEditScreen({super.key, required this.tradeIn});

  @override
  State<TradeInEditScreen> createState() => _TradeInEditScreenState();
}

class _TradeInEditScreenState extends State<TradeInEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  late TextEditingController _pelangganNamaController;
  late TextEditingController _tokoBranchNamaController;
  late TextEditingController _produkMasukNamaController;
  late TextEditingController _produkMasukMerkController;
  late TextEditingController _produkMasukKondisiController;
  late TextEditingController _produkMasukHargaController;
  late TextEditingController _produkKeluarNamaController;
  late TextEditingController _produkKeluarMerkController;
  late TextEditingController _produkKeluarHargaController;
  late TextEditingController _catatanController;

  bool _isLoading = false;
  Map<String, String> _fieldErrors = {};
  int _selisihHarga = 0;

  @override
  void initState() {
    super.initState();
    _pelangganNamaController = TextEditingController(
      text: widget.tradeIn.pelangganNama ?? '',
    );
    _tokoBranchNamaController = TextEditingController(
      text: widget.tradeIn.tokoBranchNama ?? '',
    );
    _produkMasukNamaController = TextEditingController(
      text: widget.tradeIn.produkMasukNama ?? '',
    );
    _produkMasukMerkController = TextEditingController(
      text: widget.tradeIn.produkMasukMerk ?? '',
    );
    _produkMasukKondisiController = TextEditingController(
      text: widget.tradeIn.produkMasukKondisi ?? '',
    );
    _produkMasukHargaController = TextEditingController(
      text: widget.tradeIn.produkMasukHarga?.toString() ?? '',
    );
    _produkKeluarNamaController = TextEditingController(
      text: widget.tradeIn.produkKeluarNama ?? '',
    );
    _produkKeluarMerkController = TextEditingController(
      text: widget.tradeIn.produkKeluarMerk ?? '',
    );
    _produkKeluarHargaController = TextEditingController(
      text: widget.tradeIn.produkKeluarHarga?.toString() ?? '',
    );
    _catatanController = TextEditingController(
      text: widget.tradeIn.catatan ?? '',
    );
    _selisihHarga = widget.tradeIn.selisihHarga ?? 0;
  }

  @override
  void dispose() {
    _pelangganNamaController.dispose();
    _tokoBranchNamaController.dispose();
    _produkMasukNamaController.dispose();
    _produkMasukMerkController.dispose();
    _produkMasukKondisiController.dispose();
    _produkMasukHargaController.dispose();
    _produkKeluarNamaController.dispose();
    _produkKeluarMerkController.dispose();
    _produkKeluarHargaController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  void _calculateSelisih() {
    final hargaMasuk =
        int.tryParse(
          _produkMasukHargaController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;
    final hargaKeluar =
        int.tryParse(
          _produkKeluarHargaController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;

    setState(() {
      _selisihHarga = hargaKeluar - hargaMasuk;
    });
  }

  Future<void> _updateTradeIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _fieldErrors = {};
    });

    try {
      final data = {
        'pelanggan_nama': _pelangganNamaController.text.trim(),
        'toko_branch_nama': _tokoBranchNamaController.text.trim(),
        'produk_masuk_nama': _produkMasukNamaController.text.trim(),
        'produk_masuk_merk': _produkMasukMerkController.text.trim(),
        'produk_masuk_kondisi': _produkMasukKondisiController.text.trim(),
        'produk_masuk_harga': int.parse(
          _produkMasukHargaController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ),
        'produk_keluar_nama': _produkKeluarNamaController.text.trim(),
        'produk_keluar_merk': _produkKeluarMerkController.text.trim(),
        'produk_keluar_harga': int.parse(
          _produkKeluarHargaController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ),
        'catatan': _catatanController.text.trim(),
      };

      final response = await TradeInService.updateTradeIn(
        widget.tradeIn.id!,
        data,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        await ValidationHandler.showSuccessDialog(
          context: context,
          title: 'Success',
          message: 'Trade-in updated successfully',
        );
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        if (response['errors'] != null) {
          setState(() {
            _fieldErrors = Map<String, String>.from(
              (response['errors'] as Map).map(
                (key, value) => MapEntry(
                  key.toString(),
                  (value is List ? value.first : value).toString(),
                ),
              ),
            );
          });
        }
        await ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: response['message'] ?? 'Failed to update trade-in',
        );
      }
    } catch (e) {
      if (mounted) {
        await ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'Error updating trade-in: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.surfaceColor,
        elevation: 0,
        title: Text(
          'Edit Trade-In',
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: themeProvider.textPrimary),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _updateTradeIn,
              child: Text(
                'Save',
                style: TextStyle(
                  color: themeProvider.primaryMain,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                'Customer Name',
                _pelangganNamaController,
                'Enter customer name',
                themeProvider,
                isMobile,
                fieldKey: 'pelanggan_nama',
                isRequired: false,
              ),
              SizedBox(height: isMobile ? 16 : 20),
              _buildTextField(
                'Store Branch',
                _tokoBranchNamaController,
                'Enter store branch',
                themeProvider,
                isMobile,
                fieldKey: 'toko_branch_nama',
              ),
              SizedBox(height: isMobile ? 20 : 24),
              Text(
                'Trade-In Product (Incoming)',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                ),
              ),
              SizedBox(height: isMobile ? 12 : 16),
              _buildTextField(
                'Product Name',
                _produkMasukNamaController,
                'Enter product name',
                themeProvider,
                isMobile,
                fieldKey: 'produk_masuk_nama',
              ),
              SizedBox(height: isMobile ? 16 : 20),
              _buildTextField(
                'Brand',
                _produkMasukMerkController,
                'Enter brand',
                themeProvider,
                isMobile,
                fieldKey: 'produk_masuk_merk',
              ),
              SizedBox(height: isMobile ? 16 : 20),
              _buildTextField(
                'Condition',
                _produkMasukKondisiController,
                'Enter condition (e.g. Good, Fair)',
                themeProvider,
                isMobile,
                fieldKey: 'produk_masuk_kondisi',
              ),
              SizedBox(height: isMobile ? 16 : 20),
              _buildTextField(
                'Trade-In Value',
                _produkMasukHargaController,
                'Enter trade-in value',
                themeProvider,
                isMobile,
                fieldKey: 'produk_masuk_harga',
                isNumber: true,
                onChanged: () => _calculateSelisih(),
              ),
              SizedBox(height: isMobile ? 20 : 24),
              Text(
                'New Product (Outgoing)',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                ),
              ),
              SizedBox(height: isMobile ? 12 : 16),
              _buildTextField(
                'Product Name',
                _produkKeluarNamaController,
                'Enter product name',
                themeProvider,
                isMobile,
                fieldKey: 'produk_keluar_nama',
              ),
              SizedBox(height: isMobile ? 16 : 20),
              _buildTextField(
                'Brand',
                _produkKeluarMerkController,
                'Enter brand',
                themeProvider,
                isMobile,
                fieldKey: 'produk_keluar_merk',
              ),
              SizedBox(height: isMobile ? 16 : 20),
              _buildTextField(
                'Price',
                _produkKeluarHargaController,
                'Enter price',
                themeProvider,
                isMobile,
                fieldKey: 'produk_keluar_harga',
                isNumber: true,
                onChanged: () => _calculateSelisih(),
              ),
              SizedBox(height: isMobile ? 20 : 24),
              _buildPriceDifferenceCard(themeProvider, isMobile),
              SizedBox(height: isMobile ? 20 : 24),
              _buildTextField(
                'Notes (Optional)',
                _catatanController,
                'Enter notes',
                themeProvider,
                isMobile,
                fieldKey: 'catatan',
                maxLines: 3,
                isRequired: false,
              ),
              SizedBox(height: isMobile ? 24 : 32),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _updateTradeIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.primaryMain,
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 14 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Update Trade-In',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint,
    ThemeProvider themeProvider,
    bool isMobile, {
    String? fieldKey,
    bool isNumber = false,
    bool isRequired = true,
    int maxLines = 1,
    VoidCallback? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: themeProvider.textPrimary,
            ),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          style: TextStyle(color: themeProvider.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: themeProvider.textSecondary),
            filled: true,
            fillColor: themeProvider.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: themeProvider.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: themeProvider.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeProvider.primaryMain,
                width: 2,
              ),
            ),
            errorText: fieldKey != null ? _fieldErrors[fieldKey] : null,
          ),
          validator:
              isRequired
                  ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '$label is required';
                    }
                    if (isNumber) {
                      final numValue = int.tryParse(
                        value.replaceAll(RegExp(r'[^0-9]'), ''),
                      );
                      if (numValue == null || numValue <= 0) {
                        return '$label must be a valid number';
                      }
                    }
                    return null;
                  }
                  : null,
          onChanged: onChanged != null ? (_) => onChanged() : null,
        ),
      ],
    );
  }

  Widget _buildPriceDifferenceCard(ThemeProvider themeProvider, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color:
            _selisihHarga >= 0
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _selisihHarga >= 0
                  ? Colors.green.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
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
                'Rp ${_formatCurrency(_selisihHarga)}',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: _selisihHarga >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _selisihHarga >= 0
                ? 'Customer pays the difference'
                : 'Store pays the difference',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
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
