import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme_provider.dart';
import '../services/financial_report_service.dart';

class FinancialReportScreen extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const FinancialReportScreen({super.key, this.startDate, this.endDate});

  @override
  State<FinancialReportScreen> createState() => _FinancialReportScreenState();
}

class _FinancialReportScreenState extends State<FinancialReportScreen> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String? _error;

  // Data from API
  Map<String, dynamic> _summary = {};
  List<dynamic> _transactionItems = [];
  Map<String, dynamic> _cashFlow = {};
  List<dynamic> _paymentMethods = [];
  List<dynamic> _balancePerOutlet = [];
  List<dynamic> _detailPerItem = [];
  Map<String, dynamic> _operatingExpenses = {};

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _perPage = 20;

  // Search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Search debounce
  Timer? _debounceTimer;

  // Filter
  String _selectedPeriod = 'month';
  String? _selectedType; // null = all, 'revenue', 'expense'
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  // Detail Per Item Filters
  String _detailPeriod = 'month';
  String? _detailStoreId;
  String? _detailProductName;
  DateTime? _detailCustomStartDate;
  DateTime? _detailCustomEndDate;
  List<dynamic> _stores = [];
  List<dynamic> _productNames = [];

  final List<Map<String, String>> _periodOptions = [
    {'value': 'week', 'label': 'This Week'},
    {'value': 'month', 'label': 'This Month'},
    {'value': 'year', 'label': 'This Year'},
    {'value': 'custom', 'label': 'Custom Period'},
  ];

  final List<Map<String, String?>> _typeOptions = [
    {'value': null, 'label': 'All Transactions'},
    {'value': 'revenue', 'label': 'Revenue Only'},
    {'value': 'expense', 'label': 'Expense Only'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.startDate != null && widget.endDate != null) {
      _selectedPeriod = 'custom';
      _customStartDate = widget.startDate;
      _customEndDate = widget.endDate;
    }
    _loadStoresAndProducts();
    _loadData(isRefresh: true);
  }

  Future<void> _loadStoresAndProducts() async {
    try {
      // Untuk sementara kita bisa hardcode atau nanti buat API endpoint
      // Tapi lebih baik ambil dari balance_per_outlet yang sudah ada
      setState(() {
        // Stores akan di-load dari balance_per_outlet
        // Products akan di-load dari detail_per_item
      });
    } catch (e) {
      debugPrint('Error loading stores and products: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _debounceSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _loadData(isRefresh: true);
    });
  }

  Future<void> _loadData({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasMoreData = true;
    }

    if (!_hasMoreData && !isRefresh) return;

    setState(() {
      _isLoading = isRefresh || _currentPage == 1;
      _isLoadingMore = !isRefresh && _currentPage > 1;
      _error = null;
    });

    try {
      debugPrint('🔄 Loading financial report data...');

      String? startDate;
      String? endDate;

      if (_selectedPeriod == 'custom' &&
          _customStartDate != null &&
          _customEndDate != null) {
        startDate = DateFormat('yyyy-MM-dd').format(_customStartDate!);
        endDate = DateFormat('yyyy-MM-dd').format(_customEndDate!);
      }

      // Fetch all data in parallel
      final results = await Future.wait([
        // Main financial items
        FinancialReportService.getFinancialItems(
          page: _currentPage,
          perPage: _perPage,
          period: _selectedPeriod,
          startDate: startDate,
          endDate: endDate,
          search: _searchQuery.isNotEmpty ? _searchQuery : null,
          type: _selectedType,
        ),
        // Detail per item
        _loadDetailPerItem(),
        // Operating expenses
        FinancialReportService.getOperatingExpenses(
          period: _selectedPeriod,
          startDate: startDate,
          endDate: endDate,
        ),
      ]);

      if (mounted) {
        setState(() {
          // Process main response
          if (results[0]['success'] == true) {
            final newItems = results[0]['data'] ?? [];

            if (isRefresh || _currentPage == 1) {
              _transactionItems = newItems;
            } else {
              _transactionItems.addAll(newItems);
            }

            // Extract all sections from single response for data consistency
            final summaryData = results[0]['summary'] ?? {};
            _summary = {
              'revenue': summaryData['revenue'] ?? 0,
              'hpp': summaryData['hpp'] ?? 0,
              'gross_profit': summaryData['gross_profit'] ?? 0,
              'gross_margin': summaryData['gross_margin'] ?? 0.0,
              'operating_expenses': summaryData['operating_expenses'] ?? 0,
              'net_profit': summaryData['net_profit'] ?? 0,
              'net_margin': summaryData['net_margin'] ?? 0.0,
              'transaction_count': summaryData['transaction_count'] ?? 0,
            };

            _cashFlow = results[0]['cash_flow'] ?? {};
            _paymentMethods = results[0]['payment_methods'] ?? [];
            _balancePerOutlet = results[0]['balance_per_outlet'] ?? [];

            debugPrint('📦 Balance Per Outlet Data: $_balancePerOutlet');

            // Populate stores from balance_per_outlet
            if (_balancePerOutlet.isNotEmpty) {
              _stores =
                  _balancePerOutlet
                      .map(
                        (outlet) => {
                          'id': outlet['toko_id'] ?? 0,
                          'nama': outlet['toko_name'] ?? 'Unknown',
                        },
                      )
                      .toList();
              debugPrint('🏪 Stores loaded: $_stores');
            } else {
              debugPrint(
                '⚠️ Balance Per Outlet is empty, stores not populated',
              );
            }

            final pagination = results[0]['pagination'];
            if (pagination != null) {
              _totalPages = pagination['last_page'] ?? 1;
              _hasMoreData =
                  pagination['current_page'] < pagination['last_page'];
            }
          } else {
            _error = results[0]['message'];
          }

          // Process detail per item
          if (results[1]['success'] == true) {
            _detailPerItem = results[1]['data'] ?? [];

            // Populate unique product names from detail per item
            if (_detailPerItem.isNotEmpty) {
              final uniqueProducts = <String>{};
              for (var item in _detailPerItem) {
                final productName = item['product_name'];
                if (productName != null && productName != 'Unknown') {
                  uniqueProducts.add(productName);
                }
              }
              _productNames =
                  uniqueProducts.map((name) => {'nama': name}).toList();
            }

            debugPrint(
              '✅ Detail Per Item loaded: ${_detailPerItem.length} items',
            );
          } else {
            debugPrint('❌ Detail Per Item failed: ${results[1]['message']}');
          }

          // Process operating expenses
          if (results[2]['success'] == true) {
            _operatingExpenses = results[2]['data'] ?? {};
            debugPrint('✅ Operating Expenses loaded');
          } else {
            debugPrint('❌ Operating Expenses failed: ${results[2]['message']}');
          }

          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      debugPrint('💥 ERROR loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          _error = 'Failed to load data: $e';
        });
      }
    }
  }

  Future<void> _onSearch(String value) async {
    setState(() {
      _searchQuery = value;
      _currentPage = 1;
    });
    _debounceSearch();
  }

  Future<Map<String, dynamic>> _loadDetailPerItem() async {
    String? startDate;
    String? endDate;

    if (_detailPeriod == 'custom' &&
        _detailCustomStartDate != null &&
        _detailCustomEndDate != null) {
      startDate = DateFormat('yyyy-MM-dd').format(_detailCustomStartDate!);
      endDate = DateFormat('yyyy-MM-dd').format(_detailCustomEndDate!);
    }

    return await FinancialReportService.getDetailPerItem(
      period: _detailPeriod,
      startDate: startDate,
      endDate: endDate,
      storeId: _detailStoreId,
      productName: _detailProductName,
    );
  }

  Future<void> _refreshDetailPerItem() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _loadDetailPerItem();

      if (mounted) {
        setState(() {
          if (result['success'] == true) {
            _detailPerItem = result['data'] ?? [];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error refreshing detail per item: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMoreData || _isLoading) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    try {
      String? startDate;
      String? endDate;

      if (_selectedPeriod == 'custom' &&
          _customStartDate != null &&
          _customEndDate != null) {
        startDate = DateFormat('yyyy-MM-dd').format(_customStartDate!);
        endDate = DateFormat('yyyy-MM-dd').format(_customEndDate!);
      }

      final response = await FinancialReportService.getFinancialItems(
        page: _currentPage,
        perPage: _perPage,
        period: _selectedPeriod,
        startDate: startDate,
        endDate: endDate,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        type: _selectedType,
      );

      if (mounted && response['success'] == true) {
        final newItems = response['data'] ?? [];
        setState(() {
          _transactionItems.addAll(newItems);
          final pagination = response['pagination'];
          if (pagination != null) {
            _hasMoreData = pagination['current_page'] < pagination['last_page'];
            _totalPages = pagination['last_page'] ?? 1;
          } else {
            _hasMoreData = false;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading more data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: themeProvider.surfaceColor,
        elevation: 0,
        title: Text(
          'Financial Report',
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: themeProvider.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: _exportReport,
            tooltip: 'Export Report',
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: RefreshIndicator(
          onRefresh: () => _loadData(isRefresh: true),
          child:
              _isLoading && _transactionItems.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? _buildError(themeProvider)
                  : CustomScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            _buildTopSummaryCards(
                              screenWidth < 600,
                              isTablet,
                              themeProvider,
                            ),
                            const SizedBox(height: 16),
                            _buildCashFlowSection(
                              screenWidth < 600,
                              isTablet,
                              themeProvider,
                            ),
                            const SizedBox(height: 16),
                            _buildPaymentMethodSection(
                              screenWidth < 600,
                              isTablet,
                              themeProvider,
                            ),
                            const SizedBox(height: 16),
                            _buildBalancePerOutletSection(
                              screenWidth < 600,
                              isTablet,
                              themeProvider,
                            ),
                            const SizedBox(height: 16),
                            _buildDetailPerItemSection(
                              screenWidth < 600,
                              isTablet,
                              themeProvider,
                            ),
                            const SizedBox(height: 16),
                            _buildOperatingExpensesSection(
                              screenWidth < 600,
                              isTablet,
                              themeProvider,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildError(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: themeProvider.errorMain,
              ),
              const SizedBox(height: 12),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? 'Unknown error',
                style: TextStyle(
                  fontSize: 12,
                  color: themeProvider.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _loadData(isRefresh: true),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.primaryMain,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(bool isMobile) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        children: [
          // Period dropdown
          DropdownButtonFormField<String>(
            value: _selectedPeriod,
            style: TextStyle(color: themeProvider.textPrimary),
            decoration: InputDecoration(
              labelText: 'Period',
              labelStyle: TextStyle(color: themeProvider.textSecondary),
              prefixIcon: Icon(
                Icons.date_range,
                color: themeProvider.primaryMain,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isMobile ? 8 : 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: themeProvider.surfaceColor,
            ),
            dropdownColor: themeProvider.surfaceColor,
            items:
                _periodOptions.map((option) {
                  return DropdownMenuItem(
                    value: option['value'],
                    child: Text(
                      option['label']!,
                      style: TextStyle(color: themeProvider.textPrimary),
                    ),
                  );
                }).toList(),
            onChanged: (value) async {
              setState(() => _selectedPeriod = value ?? 'month');

              if (value == 'custom') {
                await _selectCustomPeriod();
              } else {
                _loadData(isRefresh: true);
              }
            },
          ),
          SizedBox(height: isMobile ? 8 : 12),
          // Type filter
          DropdownButtonFormField<String?>(
            value: _selectedType,
            style: TextStyle(color: themeProvider.textPrimary),
            decoration: InputDecoration(
              labelText: 'Transaction Type',
              labelStyle: TextStyle(color: themeProvider.textSecondary),
              prefixIcon: Icon(
                Icons.filter_list,
                color: themeProvider.primaryMain,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isMobile ? 8 : 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: themeProvider.surfaceColor,
            ),
            dropdownColor: themeProvider.surfaceColor,
            items:
                _typeOptions.map((option) {
                  return DropdownMenuItem(
                    value: option['value'],
                    child: Text(
                      option['label']!,
                      style: TextStyle(color: themeProvider.textPrimary),
                    ),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() => _selectedType = value);
              _loadData(isRefresh: true);
            },
          ),
          if (_selectedPeriod == 'custom' &&
              _customStartDate != null &&
              _customEndDate != null) ...[
            SizedBox(height: isMobile ? 8 : 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeProvider.primaryMain.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: themeProvider.primaryMain.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: themeProvider.primaryMain,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Period: ${DateFormat('dd MMM yyyy').format(_customStartDate!)} - ${DateFormat('dd MMM yyyy').format(_customEndDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: themeProvider.primaryMain,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _selectCustomPeriod,
                    child: Text('Change', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectCustomPeriod() async {
    final themeProvider = context.read<ThemeProvider>();

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start:
            _customStartDate ??
            DateTime.now().subtract(const Duration(days: 30)),
        end: _customEndDate ?? DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: themeProvider.primaryMain,
              onPrimary: Colors.white,
              surface: themeProvider.surfaceColor,
              onSurface: themeProvider.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customStartDate = picked.start;
        _customEndDate = picked.end;
      });
      _loadData(isRefresh: true);
    }
  }

  Future<void> _selectDetailCustomPeriod() async {
    final themeProvider = context.read<ThemeProvider>();

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start:
            _detailCustomStartDate ??
            DateTime.now().subtract(const Duration(days: 30)),
        end: _detailCustomEndDate ?? DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: themeProvider.primaryMain,
              onPrimary: Colors.white,
              surface: themeProvider.surfaceColor,
              onSurface: themeProvider.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _detailCustomStartDate = picked.start;
        _detailCustomEndDate = picked.end;
      });
      _refreshDetailPerItem();
    }
  }

  Widget _buildSearchBar(bool isMobile) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 4 : 8,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearch,
        style: TextStyle(color: themeProvider.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search by code, customer, supplier...',
          hintStyle: TextStyle(color: themeProvider.textSecondary),
          prefixIcon: Icon(Icons.search, color: themeProvider.textSecondary),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: themeProvider.textSecondary),
                    onPressed: () {
                      _searchController.clear();
                      _onSearch('');
                    },
                  )
                  : null,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isMobile ? 10 : 12,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: themeProvider.surfaceColor,
        ),
      ),
    );
  }

  Widget _buildTopSummaryCards(
    bool isMobile,
    bool isTablet,
    ThemeProvider themeProvider,
  ) {
    final revenue = _summary['revenue'] ?? 0.0;
    final hpp = _summary['hpp'] ?? 0.0;
    final grossProfit = _summary['gross_profit'] ?? 0.0;
    final grossMargin = _summary['gross_margin'] ?? 0.0;
    final operatingExpenses = _summary['operating_expenses'] ?? 0.0;
    final netProfit = _summary['net_profit'] ?? 0.0;
    final netMargin = _summary['net_margin'] ?? 0.0;
    final transactionCount = _summary['transaction_count'] ?? 0;

    final cards = [
      {
        'label': 'Revenue (Pendapatan)',
        'value': _formatCurrencyCard(revenue),
        'subtitle': '$transactionCount transaksi',
        'icon': Icons.trending_up_rounded,
        'color': const Color(0xFF3B82F6), // Blue
      },
      {
        'label': 'HPP / COGS',
        'value': _formatCurrencyCard(hpp),
        'subtitle': 'Harga Pokok Penjualan',
        'icon': Icons.shopping_cart_rounded,
        'color': const Color(0xFFFF9800), // Orange
      },
      {
        'label': 'Gross Profit (Laba Kotor)',
        'value': _formatCurrencyCard(grossProfit),
        'subtitle': 'Margin ${grossMargin.toStringAsFixed(2)}%',
        'icon': Icons.account_balance_wallet_rounded,
        'color': const Color(0xFF22C55E), // Green
      },
      {
        'label': 'Operating Expenses',
        'value': _formatCurrencyCard(operatingExpenses),
        'subtitle': 'Biaya Operasional',
        'icon': Icons.payment_rounded,
        'color': const Color(0xFFEF4444), // Red
      },
      {
        'label': 'Net Profit (Laba Bersih)',
        'value': _formatCurrencyCard(netProfit),
        'subtitle': 'Margin ${netMargin.toStringAsFixed(2)}%',
        'icon': Icons.savings_rounded,
        'color': const Color(0xFF9333EA), // Purple
      },
      {
        'label': 'Net Profit Margin',
        'value': '${netMargin.toStringAsFixed(2)}%',
        'subtitle': 'Efisiensi Usaha',
        'icon': Icons.analytics_rounded,
        'color': const Color(0xFF6366F1), // Indigo
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 4 : 6,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 3);
          final crossAxisSpacing = isMobile ? 6.0 : 12.0;
          final mainAxisSpacing = isMobile ? 6.0 : 12.0;
          final childAspectRatio = isMobile ? 1.8 : 2.2;

          final availableWidth = constraints.maxWidth;
          final itemWidth =
              (availableWidth - (crossAxisSpacing * (crossAxisCount - 1))) /
              crossAxisCount;
          final itemHeight = itemWidth / childAspectRatio;
          final rows = (cards.length / crossAxisCount).ceil();
          final totalHeight =
              (itemHeight * rows) + (mainAxisSpacing * (rows - 1));

          return SizedBox(
            height: totalHeight,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: crossAxisSpacing,
                mainAxisSpacing: mainAxisSpacing,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return _buildSummaryCard(cards[index], themeProvider, isMobile);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    Map<String, dynamic> card,
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    final color = card['color'] as Color;
    final subtitle = card['subtitle'] as String?;

    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: themeProvider.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  card['label'],
                  style: TextStyle(
                    fontSize: isMobile ? 9 : 11,
                    color: themeProvider.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  card['icon'],
                  color: color,
                  size: isMobile ? 14 : 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            card['value'],
            style: TextStyle(
              fontSize: isMobile ? 14 : 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.textPrimary,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: isMobile ? 8 : 9,
                color: themeProvider.textTertiary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionListSliver_REMOVED(bool isDesktop, bool isTablet) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (_transactionItems.isEmpty && !_isLoading) {
      return SliverFillRemaining(child: _buildEmptyState());
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 12 : 16,
        isMobile ? 12 : 16,
        isMobile ? 12 : 16,
        80,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == _transactionItems.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (index == _transactionItems.length - 3 &&
              !_isLoadingMore &&
              _hasMoreData) {
            _loadMoreData();
          }

          return _buildTransactionCard(_transactionItems[index], isMobile);
        }, childCount: _transactionItems.length + (_isLoadingMore ? 1 : 0)),
      ),
    );
  }

  Widget _buildTransactionCard(dynamic item, bool isMobile) {
    final themeProvider = context.watch<ThemeProvider>();
    final type = item['type'] ?? 'revenue';
    final isRevenue = type == 'revenue';
    final color = isRevenue ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    final icon =
        isRevenue ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      color: themeProvider.surfaceColor,
      child: InkWell(
        onTap: () => _showTransactionDetail(item),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Row(
            children: [
              // Icon indicator
              Container(
                width: isMobile ? 50 : 60,
                height: isMobile ? 50 : 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Icon(icon, color: color, size: isMobile ? 24 : 28),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['code'] ?? '-',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 14 : 16,
                        color: themeProvider.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isMobile ? 2 : 4),
                    Text(
                      item['partner_name'] ?? '-',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: themeProvider.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isMobile ? 4 : 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: isMobile ? 12 : 14,
                          color: themeProvider.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(item['date']),
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 11,
                            color: themeProvider.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Amount & Type
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatCurrency(item['amount'] ?? 0),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: isMobile ? 14 : 15,
                    ),
                  ),
                  SizedBox(height: isMobile ? 4 : 6),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 8 : 10,
                      vertical: isMobile ? 4 : 5,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Text(
                      item['type_label'] ?? '-',
                      style: TextStyle(
                        fontSize: isMobile ? 9 : 10,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransactionDetail(dynamic item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TransactionDetailSheet(item: item),
    );
  }

  void _exportReport() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Export Report'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.green),
                title: const Text('Export as Excel'),
                onTap: () {
                  Navigator.pop(context);
                  _doExport();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _doExport() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      String? startDate;
      String? endDate;

      if (_selectedPeriod == 'custom' &&
          _customStartDate != null &&
          _customEndDate != null) {
        startDate = DateFormat('yyyy-MM-dd').format(_customStartDate!);
        endDate = DateFormat('yyyy-MM-dd').format(_customEndDate!);
      }

      final result = await FinancialReportService.exportFinancialReport(
        period: _selectedPeriod,
        startDate: startDate,
        endDate: endDate,
      );

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['success'] == true
                  ? 'Report exported successfully! File saved to Downloads.'
                  : result['message'] ?? 'Failed to export report',
            ),
            backgroundColor:
                result['success'] == true ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 24 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: isMobile ? 80 : 100,
              color: themeProvider.textTertiary.withOpacity(0.5),
            ),
            SizedBox(height: isMobile ? 16 : 24),
            Text(
              'No Transaction Data Found',
              style: TextStyle(
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.textPrimary,
              ),
            ),
            SizedBox(height: isMobile ? 8 : 12),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Try adjusting your search or filter'
                  : 'No transaction data available for selected period',
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                color: themeProvider.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(dynamic value) {
    try {
      final number = value is String ? double.parse(value) : value.toDouble();
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      return formatter.format(number);
    } catch (e) {
      return 'Rp 0';
    }
  }

  String _formatCurrencyCard(dynamic value) {
    try {
      final number = value is String ? double.parse(value) : value.toDouble();
      final formatter = NumberFormat.decimalPattern('id_ID');
      return 'Rp\n${formatter.format(number.round())}';
    } catch (e) {
      return 'Rp\n0';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  // ========== CASH FLOW SECTION ==========
  Widget _buildCashFlowSection(
    bool isMobile,
    bool isTablet,
    ThemeProvider themeProvider,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cash Flow',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = isMobile ? 2 : (isTablet ? 4 : 4);
              final childAspectRatio = isMobile ? 1.3 : (isTablet ? 1.5 : 1.7);

              return GridView.count(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildCashFlowCard(
                    'Cash In',
                    _cashFlow['cash_in'] ?? 0,
                    Icons.arrow_downward,
                    Colors.green,
                    themeProvider,
                  ),
                  _buildCashFlowCard(
                    'Cash Out',
                    _cashFlow['cash_out'] ?? 0,
                    Icons.arrow_upward,
                    Colors.red,
                    themeProvider,
                  ),
                  _buildCashFlowCard(
                    'Free Cash Flow',
                    _cashFlow['free_cash_flow'] ?? 0,
                    Icons.account_balance_wallet,
                    Colors.green,
                    themeProvider,
                  ),
                  _buildCashFlowCard(
                    'Piutang',
                    _cashFlow['piutang'] ?? 0,
                    Icons.receipt_long,
                    Colors.orange,
                    themeProvider,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCashFlowCard(
    String title,
    dynamic value,
    IconData icon,
    Color color,
    ThemeProvider themeProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: themeProvider.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(value),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ========== PAYMENT METHOD SECTION ==========
  Widget _buildPaymentMethodSection(
    bool isMobile,
    bool isTablet,
    ThemeProvider themeProvider,
  ) {
    if (_paymentMethods.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeProvider.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: themeProvider.borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children:
                  _paymentMethods.map((method) {
                    final methodName = method['method'] ?? 'Unknown';
                    final total = method['total'] ?? 0;
                    final percentage = method['percentage'] ?? 0.0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                methodName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: themeProvider.textPrimary,
                                ),
                              ),
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: themeProvider.primaryMain,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: percentage / 100,
                                    minHeight: 8,
                                    backgroundColor: themeProvider.borderColor,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      themeProvider.primaryMain,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _formatCurrency(total),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: themeProvider.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ========== BALANCE PER OUTLET SECTION ==========
  Widget _buildBalancePerOutletSection(
    bool isMobile,
    bool isTablet,
    ThemeProvider themeProvider,
  ) {
    if (_balancePerOutlet.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cash Balance per Outlet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: themeProvider.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: themeProvider.borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeProvider.primaryMain.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Toko',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Cash In',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.textPrimary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cash Out',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.textPrimary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Balance',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.textPrimary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                // Rows
                ..._balancePerOutlet.map((outlet) {
                  final tokoName = outlet['toko_name'] ?? 'Unknown';
                  final cashIn = outlet['cash_in'] ?? 0;
                  final cashOut = outlet['cash_out'] ?? 0;
                  final balance = outlet['balance'] ?? 0;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: themeProvider.borderColor,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            tokoName,
                            style: TextStyle(
                              fontSize: 13,
                              color: themeProvider.textPrimary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _formatCurrency(cashIn),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _formatCurrency(cashOut),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _formatCurrency(balance),
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  balance >= 0
                                      ? Colors.green[700]
                                      : Colors.red[700],
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== DETAIL PER ITEM SECTION ==========
  Widget _buildDetailPerItemSection(
    bool isMobile,
    bool isTablet,
    ThemeProvider themeProvider,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Per Item',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // Filter Section
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: themeProvider.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: themeProvider.borderColor, width: 1),
            ),
            child: Column(
              children: [
                // Period Dropdown
                DropdownButtonFormField<String>(
                  value: _detailPeriod,
                  style: TextStyle(color: themeProvider.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Period',
                    labelStyle: TextStyle(color: themeProvider.textSecondary),
                    prefixIcon: Icon(
                      Icons.date_range,
                      color: themeProvider.primaryMain,
                      size: 20,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: themeProvider.backgroundColor,
                  ),
                  dropdownColor: themeProvider.surfaceColor,
                  items: [
                    DropdownMenuItem(
                      value: 'week',
                      child: Text(
                        'This Week',
                        style: TextStyle(
                          color: themeProvider.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'month',
                      child: Text(
                        'This Month',
                        style: TextStyle(
                          color: themeProvider.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'year',
                      child: Text(
                        'This Year',
                        style: TextStyle(
                          color: themeProvider.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'custom',
                      child: Text(
                        'Custom',
                        style: TextStyle(
                          color: themeProvider.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) async {
                    setState(() => _detailPeriod = value ?? 'month');
                    if (value == 'custom') {
                      await _selectDetailCustomPeriod();
                    } else {
                      _refreshDetailPerItem();
                    }
                  },
                ),
                const SizedBox(height: 12),
                // Store Dropdown
                DropdownButtonFormField<String?>(
                  value: _detailStoreId,
                  style: TextStyle(color: themeProvider.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Store',
                    labelStyle: TextStyle(color: themeProvider.textSecondary),
                    prefixIcon: Icon(
                      Icons.store,
                      color: themeProvider.primaryMain,
                      size: 20,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: themeProvider.backgroundColor,
                  ),
                  dropdownColor: themeProvider.surfaceColor,
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(
                        'All Stores',
                        style: TextStyle(
                          color: themeProvider.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    ..._stores.map((store) {
                      return DropdownMenuItem(
                        value: store['id'].toString(),
                        child: Text(
                          store['nama'] ?? 'Unknown',
                          style: TextStyle(
                            color: themeProvider.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() => _detailStoreId = value);
                    _refreshDetailPerItem();
                  },
                ),
                const SizedBox(height: 12),
                // Product Name Dropdown
                DropdownButtonFormField<String?>(
                  value: _detailProductName,
                  style: TextStyle(color: themeProvider.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    labelStyle: TextStyle(color: themeProvider.textSecondary),
                    prefixIcon: Icon(
                      Icons.category,
                      color: themeProvider.primaryMain,
                      size: 20,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: themeProvider.backgroundColor,
                  ),
                  dropdownColor: themeProvider.surfaceColor,
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(
                        'All Products',
                        style: TextStyle(
                          color: themeProvider.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    ..._productNames.map((product) {
                      final productMap = product as Map<String, dynamic>;
                      return DropdownMenuItem(
                        value: productMap['nama'] as String?,
                        child: Text(
                          productMap['nama']?.toString() ?? 'Unknown',
                          style: TextStyle(
                            color: themeProvider.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() => _detailProductName = value);
                    _refreshDetailPerItem();
                  },
                ),
                if (_detailPeriod == 'custom' &&
                    _detailCustomStartDate != null &&
                    _detailCustomEndDate != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeProvider.primaryMain.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: themeProvider.primaryMain.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: themeProvider.primaryMain,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Period: ${DateFormat('dd MMM yyyy').format(_detailCustomStartDate!)} - ${DateFormat('dd MMM yyyy').format(_detailCustomEndDate!)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: themeProvider.primaryMain,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _selectDetailCustomPeriod,
                          child: const Text(
                            'Change',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Data Section
          if (_detailPerItem.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: themeProvider.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: themeProvider.borderColor, width: 1),
              ),
              child: Center(
                child: Text(
                  'No transaction items data available',
                  style: TextStyle(
                    fontSize: 14,
                    color: themeProvider.textSecondary,
                  ),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: themeProvider.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: themeProvider.borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children:
                    _detailPerItem.map((item) {
                      final invoice = item['invoice'] ?? '-';
                      final productName = item['product_name'] ?? 'Unknown';
                      final productType = item['type'] ?? 'Electronic';
                      final qty = item['qty'] ?? 0;

                      // Parse string values to numbers
                      final revenue =
                          double.tryParse(item['revenue']?.toString() ?? '0') ??
                          0.0;
                      final hpp =
                          double.tryParse(item['hpp']?.toString() ?? '0') ??
                          0.0;
                      final grossProfit =
                          double.tryParse(
                            item['gross_profit']?.toString() ?? '0',
                          ) ??
                          0.0;
                      final margin =
                          item['margin'] is num
                              ? item['margin'].toDouble()
                              : (double.tryParse(
                                    item['margin']?.toString() ?? '0',
                                  ) ??
                                  0.0);

                      // Product type color mapping
                      Color typeColor;
                      Color typeColorDark;
                      switch (productType.toLowerCase()) {
                        case 'electronic':
                          typeColor = Colors.blue;
                          typeColorDark = Colors.blue[700]!;
                          break;
                        case 'accessory':
                          typeColor = Colors.green;
                          typeColorDark = Colors.green[700]!;
                          break;
                        case 'service':
                          typeColor = Colors.purple;
                          typeColorDark = Colors.purple[700]!;
                          break;
                        default:
                          typeColor = Colors.grey;
                          typeColorDark = Colors.grey[700]!;
                      }

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: themeProvider.borderColor,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header: Invoice + Type Badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    invoice,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: themeProvider.textPrimary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: typeColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: typeColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    productType,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: typeColorDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Product Name
                            Text(
                              productName,
                              style: TextStyle(
                                fontSize: 13,
                                color: themeProvider.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Qty Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Qty',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: themeProvider.textTertiary,
                                  ),
                                ),
                                Text(
                                  '$qty',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: themeProvider.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Revenue Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Revenue',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: themeProvider.textTertiary,
                                  ),
                                ),
                                Text(
                                  _formatCurrency(revenue),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // HPP Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'HPP',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: themeProvider.textTertiary,
                                  ),
                                ),
                                Text(
                                  _formatCurrency(hpp),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Gross Profit Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Gross Profit',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: themeProvider.textTertiary,
                                  ),
                                ),
                                Text(
                                  _formatCurrency(grossProfit),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        grossProfit >= 0
                                            ? Colors.green[700]
                                            : Colors.red[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Margin Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Margin %',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: themeProvider.textTertiary,
                                  ),
                                ),
                                Text(
                                  '${margin.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        margin >= 0
                                            ? Colors.green[700]
                                            : Colors.red[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // ========== OPERATING EXPENSES SECTION ==========
  Widget _buildOperatingExpensesSection(
    bool isMobile,
    bool isTablet,
    ThemeProvider themeProvider,
  ) {
    final breakdown = _operatingExpenses['breakdown'] as List<dynamic>? ?? [];
    final recentExpenses =
        _operatingExpenses['recent_expenses'] as List<dynamic>? ?? [];
    final totalExpenses = _operatingExpenses['total_expenses'] ?? 0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Operating Expenses Detail',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breakdown by Type
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeProvider.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: themeProvider.borderColor,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Breakdown by Type',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (breakdown.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'No expenses data available',
                              style: TextStyle(
                                fontSize: 12,
                                color: themeProvider.textSecondary,
                              ),
                            ),
                          ),
                        )
                      else
                        ...breakdown.map((item) {
                          final category = item['category'] ?? 'Unknown';
                          final amount = item['amount'] ?? 0;
                          final percentage = item['percentage'] ?? 0.0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      category,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: themeProvider.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${percentage.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: themeProvider.errorMain,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatCurrency(amount),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: themeProvider.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Recent Expenses
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeProvider.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: themeProvider.borderColor,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Expenses',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (recentExpenses.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'No expenses data available',
                              style: TextStyle(
                                fontSize: 12,
                                color: themeProvider.textSecondary,
                              ),
                            ),
                          ),
                        )
                      else
                        ...recentExpenses.map((expense) {
                          final date = expense['date'] ?? '-';
                          final expenseType = expense['expense_type'] ?? 'N/A';
                          final description = expense['description'] ?? '';
                          final amount = expense['amount'] ?? 0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        expenseType,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: themeProvider.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      _formatCurrency(amount),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: themeProvider.errorMain,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                if (description.isNotEmpty)
                                  Text(
                                    description,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: themeProvider.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const SizedBox(height: 2),
                                Text(
                                  date,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: themeProvider.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Transaction Detail Bottom Sheet
class _TransactionDetailSheet extends StatelessWidget {
  final dynamic item;

  const _TransactionDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final type = item['type'] ?? 'revenue';
    final isRevenue = type == 'revenue';
    final color = isRevenue ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: themeProvider.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: themeProvider.borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Transaction Detail',
                              style: TextStyle(
                                fontSize: isMobile ? 18 : 20,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: themeProvider.textSecondary,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: themeProvider.borderColor, height: 1),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  child: Column(
                    children: [
                      // Amount Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isMobile ? 20 : 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              item['type_label'] ?? '-',
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatCurrency(item['amount'] ?? 0),
                              style: TextStyle(
                                fontSize: isMobile ? 28 : 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isMobile ? 16 : 20),

                      // Transaction Info
                      _buildInfoCard(themeProvider, isMobile, [
                        {
                          'label': 'Transaction Code',
                          'value': item['code'] ?? '-',
                        },
                        {
                          'label': 'Partner',
                          'value': item['partner_name'] ?? '-',
                        },
                        {'label': 'Date', 'value': _formatDate(item['date'])},
                        if (item['time'] != null)
                          {'label': 'Time', 'value': item['time']},
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(
    ThemeProvider themeProvider,
    bool isMobile,
    List<Map<String, String>> items,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Column(
        children:
            items.asMap().entries.map((entry) {
              final isLast = entry.key == items.length - 1;
              final item = entry.value;
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['label'] ?? '',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 13,
                          color: themeProvider.textSecondary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item['value'] ?? '-',
                          style: TextStyle(
                            fontSize: isMobile ? 13 : 14,
                            fontWeight: FontWeight.w600,
                            color: themeProvider.textPrimary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  if (!isLast)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 8 : 10,
                      ),
                      child: Divider(
                        color: themeProvider.borderColor,
                        height: 1,
                      ),
                    ),
                ],
              );
            }).toList(),
      ),
    );
  }

  String _formatCurrency(dynamic value) {
    try {
      final number = value is String ? double.parse(value) : value.toDouble();
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      return formatter.format(number);
    } catch (e) {
      return 'Rp 0';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
