import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme_provider.dart';
import '../services/sales_report_service.dart';

class SalesReportScreen extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  const SalesReportScreen({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String? _error;

  // Data from API
  Map<String, dynamic> _summary = {};
  List<dynamic> _transactions = [];
  List<dynamic> _topProducts = [];
  List<dynamic> _paymentMethods = [];

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _perPage = 20;

  // Search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Search debounce
  Timer? _debounceTimer;

  // Sort & Filter
  String _selectedPeriod = 'All';
  String _selectedStore = 'All Stores';
  String _selectedPaymentMethod = 'Semua';
  bool _isGridView = false;

  // Dynamic date range for period filter
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _periodOptions = [
    'Today',
    'This Week',
    'This Month',
    'This Year',
    'All',
    'Custom',
  ];

  List<String> _storeOptions = ['All Stores'];
  Map<String, String> _storeIdMap = {}; // Map store name to ID

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    _loadStores();
    _loadData(isRefresh: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
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
      final startDate = _startDate ?? widget.startDate;
      final endDate = _endDate ?? widget.endDate;
      
      debugPrint('🔄 Loading sales report data...');
      debugPrint('📅 Date range: $startDate - $endDate');

      final results = await Future.wait([
        SalesReportService.getSalesSummary(
          startDate: startDate,
          endDate: endDate,
          paymentMethod: _selectedPaymentMethod != 'Semua' ? _selectedPaymentMethod : null,
          storeId: _getStoreId(_selectedStore),
        ),
        SalesReportService.getSalesTransactions(
          startDate: startDate,
          endDate: endDate,
          page: _currentPage,
          perPage: _perPage,
          search: _searchQuery.isNotEmpty ? _searchQuery : null,
          paymentMethod: _selectedPaymentMethod != 'Semua' ? _selectedPaymentMethod : null,
          storeId: _getStoreId(_selectedStore),
        ),
        SalesReportService.getTopProducts(
          startDate: startDate,
          endDate: endDate,
          limit: 10,
        ),
        SalesReportService.getSalesByPaymentMethod(
          startDate: startDate,
          endDate: endDate,
        ),
      ]);

      debugPrint('📊 Summary response: ${results[0]}');
      debugPrint('💰 Transactions response: ${results[1]}');
      debugPrint('🏆 Top products response: ${results[2]}');
      debugPrint('💳 Payment methods response: ${results[3]}');

      if (mounted) {
        setState(() {
          if (results[0]['success'] == true) {
            _summary = results[0]['data'] ?? {};
            debugPrint('✅ Summary loaded: $_summary');
          } else {
            debugPrint('❌ Summary failed: ${results[0]['message']}');
          }

          if (results[1]['success'] == true) {
            final newTransactions = results[1]['data'] ?? [];
            
            if (isRefresh || _currentPage == 1) {
              _transactions = newTransactions;
            } else {
              _transactions.addAll(newTransactions);
            }
            
            debugPrint('✅ Transactions loaded: ${_transactions.length} items');
            final pagination = results[1]['pagination'];
            if (pagination != null) {
              _totalPages = pagination['last_page'] ?? 1;
              _hasMoreData = pagination['current_page'] < pagination['last_page'];
            }
          } else {
            debugPrint('❌ Transactions failed: ${results[1]['message']}');
            _error = results[1]['message'];
          }

          if (results[2]['success'] == true) {
            _topProducts = results[2]['data'] ?? [];
            debugPrint('✅ Top products loaded: ${_topProducts.length} items');
          } else {
            debugPrint('❌ Top products failed: ${results[2]['message']}');
          }

          if (results[3]['success'] == true) {
            _paymentMethods = results[3]['data'] ?? [];
            debugPrint('✅ Payment methods loaded: ${_paymentMethods.length} items');
          } else {
            debugPrint('❌ Payment methods failed: ${results[3]['message']}');
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

  Future<void> _onPageChanged(int page) async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _currentPage = page;
    });
    await _loadData();
  }

  String? _getStoreId(String storeName) {
    if (storeName == 'All Stores') return null;
    return _storeIdMap[storeName];
  }

  Future<void> _loadStores() async {
    try {
      final result = await SalesReportService.getStores();
      if (result['success'] == true && mounted) {
        final stores = result['data'] ?? [];
        setState(() {
          _storeOptions = ['All Stores'];
          _storeIdMap.clear();
          for (var store in stores) {
            final storeName = store['nama']?.toString() ?? '';
            final storeId = store['id']?.toString() ?? '';
            if (storeName.isNotEmpty) {
              _storeOptions.add(storeName);
              _storeIdMap[storeName] = storeId;
            }
          }
        });
        debugPrint('✅ Stores loaded: ${_storeOptions.length - 1} stores');
      }
    } catch (e) {
      debugPrint('❌ Error loading stores: $e');
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMoreData || _isLoading) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    try {
      final startDate = _startDate ?? widget.startDate;
      final endDate = _endDate ?? widget.endDate;
      
      final response = await SalesReportService.getSalesTransactions(
        startDate: startDate,
        endDate: endDate,
        page: _currentPage,
        perPage: _perPage,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        paymentMethod: _selectedPaymentMethod != 'Semua' ? _selectedPaymentMethod : null,
        storeId: _getStoreId(_selectedStore),
      );

      if (mounted && response['success'] == true) {
        final newTransactions = response['data'] ?? [];
        setState(() {
          _transactions.addAll(newTransactions);
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

  void _applyPeriodFilter(String period) {
    DateTime endDate = DateTime.now();

    switch (period) {
      case 'Today':
        setState(() {
          _startDate = DateTime(endDate.year, endDate.month, endDate.day);
          _endDate = endDate;
        });
        break;
      case 'This Week':
        final startOfWeek = endDate.subtract(Duration(days: endDate.weekday - 1));
        setState(() {
          _startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
          _endDate = endDate;
        });
        break;
      case 'This Month':
        setState(() {
          _startDate = DateTime(endDate.year, endDate.month, 1);
          _endDate = endDate;
        });
        break;
      case 'This Year':
        setState(() {
          _startDate = DateTime(endDate.year, 1, 1);
          _endDate = endDate;
        });
        break;
      case 'All':
        setState(() {
          _startDate = DateTime(2020, 1, 1);
          _endDate = endDate;
        });
        break;
      case 'Custom':
        _showCustomDatePicker();
        return;
      default:
        setState(() {
          _startDate = DateTime(2020, 1, 1);
          _endDate = endDate;
        });
    }

    // Reload data with new date range
    _loadData(isRefresh: true);
  }

  Future<void> _showCustomDatePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate ?? widget.startDate,
        end: _endDate ?? widget.endDate,
      ),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadData(isRefresh: true);
    } else {
      // Revert to previous selection if cancelled
      setState(() {
        _selectedPeriod = 'All';
      });
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
      appBar: AppBar(
        backgroundColor: themeProvider.surfaceColor,
        elevation: 0,
        title: Text(
          'Sales Report',
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: themeProvider.textPrimary),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: _exportReport,
            tooltip: 'Export Report',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadData(isRefresh: true),
        child: Column(
          children: [
            _buildSearchAndFilter(screenWidth < 600),
            _buildPaymentFilter(screenWidth < 600),
            _buildTopSummaryCards(screenWidth < 600, isTablet, themeProvider),
            Expanded(
              child: _isLoading && _transactions.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildError(themeProvider)
                      : _buildTransactionList(isDesktop, isTablet),
            ),
          ],
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
              Icon(Icons.error_outline, size: 48, color: themeProvider.errorMain),
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

  Widget _buildSearchAndFilter(bool isMobile) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            onChanged: _onSearch,
            style: TextStyle(color: themeProvider.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search by invoice or customer...',
              hintStyle: TextStyle(color: themeProvider.textSecondary),
              prefixIcon: Icon(
                Icons.search,
                color: themeProvider.textSecondary,
              ),
              suffixIcon:
                  _searchQuery.isNotEmpty
                      ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: themeProvider.textSecondary,
                        ),
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: themeProvider.surfaceColor,
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          // Period filter dropdown
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedPeriod,
                  style: TextStyle(color: themeProvider.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Period',
                    labelStyle: TextStyle(color: themeProvider.textSecondary),
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
                  items: _periodOptions.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(
                        option,
                        style: TextStyle(color: themeProvider.textPrimary),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedPeriod = value ?? 'All');
                    _applyPeriodFilter(value ?? 'All');
                  },
                ),
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStore,
                  style: TextStyle(color: themeProvider.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Store',
                    labelStyle: TextStyle(color: themeProvider.textSecondary),
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
                  items: _storeOptions.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(
                        option,
                        style: TextStyle(color: themeProvider.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedStore = value ?? 'All Stores');
                    _loadData(isRefresh: true);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentFilter(bool isMobile) {
    final themeProvider = context.watch<ThemeProvider>();
    final paymentOptions = [
      'Semua',
      ..._paymentMethods.map((p) => p['payment_method'].toString()).toSet(),
    ];

    return Container(
      height: isMobile ? 45 : 50,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: paymentOptions.length,
        itemBuilder: (context, index) {
          final method = paymentOptions.elementAt(index);
          final isSelected = _selectedPaymentMethod == method;

          return Container(
            margin: EdgeInsets.only(right: isMobile ? 6 : 8),
            child: FilterChip(
              label: Text(
                method,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color:
                      isSelected
                          ? themeProvider.primaryMain
                          : themeProvider.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedPaymentMethod = method);
                _loadData(isRefresh: true);
              },
              backgroundColor: themeProvider.surfaceColor,
              selectedColor: themeProvider.primaryMain.withOpacity(0.2),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopSummaryCards(
    bool isMobile,
    bool isTablet,
    ThemeProvider themeProvider,
  ) {
    final totalTransactions = _summary['total_transactions'] ?? 0;
    final totalSales = _summary['total_sales'] ?? 0;
    final totalItemsSold = _summary['total_items_sold'] ?? 0;
    final averageTransaction = _summary['average_transaction'] ?? 0;

    final cards = [
      {
        'label': 'Total Transactions',
        'value': totalTransactions.toString(),
        'icon': Icons.shopping_bag_rounded,
        'color': const Color(0xFF9333EA), // Purple
      },
      {
        'label': 'Total Sales',
        'value': _formatCurrency(totalSales),
        'icon': Icons.attach_money_rounded,
        'color': const Color(0xFF22C55E), // Green
      },
      {
        'label': 'Total Items Sold',
        'value': totalItemsSold.toString(),
        'icon': Icons.inventory_2_rounded,
        'color': const Color(0xFF3B82F6), // Blue
      },
      {
        'label': 'Average Transaction',
        'value': _formatCurrency(averageTransaction),
        'icon': Icons.show_chart_rounded,
        'color': const Color(0xFFEF4444), // Red/Orange
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 6 : 8,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile ? 2 : (isTablet ? 4 : 4),
          childAspectRatio: isMobile ? 1.5 : 2.0,
          crossAxisSpacing: isMobile ? 8 : 12,
          mainAxisSpacing: isMobile ? 8 : 12,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return _buildTopSummaryCard(
            cards[index],
            themeProvider,
            isMobile,
          );
        },
      ),
    );
  }

  Widget _buildTopSummaryCard(
    Map<String, dynamic> card,
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    final color = card['color'] as Color;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  card['label'],
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: themeProvider.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(card['icon'], color: color, size: isMobile ? 18 : 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            card['value'],
            style: TextStyle(
              fontSize: isMobile ? 18 : 24,
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

  Widget _buildStatsBar(bool isMobile) {
    final themeProvider = context.watch<ThemeProvider>();
    final totalSales = _summary['total_sales'] ?? 0;
    final totalTransactions = _summary['total_transactions'] ?? 0;
    final totalProfit = _summary['total_profit'] ?? 0;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 6 : 8,
      ),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _buildStatItem(
              Icons.shopping_cart_rounded,
              'Sales',
              _formatCurrencyShort(totalSales),
              Colors.green,
              isMobile,
            ),
          ),
          Container(
            width: 1,
            height: isMobile ? 30 : 35,
            color: themeProvider.borderColor,
          ),
          Expanded(
            child: _buildStatItem(
              Icons.receipt_long_rounded,
              'Transactions',
              '$totalTransactions',
              Colors.blue,
              isMobile,
            ),
          ),
          Container(
            width: 1,
            height: isMobile ? 30 : 35,
            color: themeProvider.borderColor,
          ),
          Expanded(
            child: _buildStatItem(
              Icons.account_balance_wallet_rounded,
              'Profit',
              _formatCurrencyShort(totalProfit),
              Colors.purple,
              isMobile,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
    bool isMobile,
  ) {
    final themeProvider = context.watch<ThemeProvider>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: isMobile ? 20 : 24),
        SizedBox(height: isMobile ? 2 : 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: themeProvider.textPrimary,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 10 : 12,
            color: themeProvider.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(
    bool isDesktop,
    bool isTablet,
    ThemeProvider themeProvider,
  ) {
    final totalSales = _summary['total_sales'] ?? 0;
    final totalTransactions = _summary['total_transactions'] ?? 0;
    final averageTransaction = _summary['average_transaction'] ?? 0;
    final totalProfit = _summary['total_profit'] ?? 0;

    final cards = [
      {
        'label': 'Total Sales',
        'value': _formatCurrency(totalSales),
        'icon': Icons.shopping_cart_rounded,
        'color': const Color(0xFF4CAF50),
        'change': _summary['sales_growth'],
      },
      {
        'label': 'Transactions',
        'value': totalTransactions.toString(),
        'icon': Icons.receipt_long_rounded,
        'color': const Color(0xFF2196F3),
        'change': _summary['transaction_growth'],
      },
      {
        'label': 'Average/Trx',
        'value': _formatCurrency(averageTransaction),
        'icon': Icons.trending_up_rounded,
        'color': const Color(0xFFFF9800),
      },
      {
        'label': 'Total Profit',
        'value': _formatCurrency(totalProfit),
        'icon': Icons.account_balance_wallet_rounded,
        'color': const Color(0xFF9C27B0),
        'change': _summary['profit_growth'],
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 16,
        vertical: 8,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 2),
          childAspectRatio: isDesktop ? 1.5 : 1.3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return _buildSummaryCard(cards[index], themeProvider);
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    Map<String, dynamic> card,
    ThemeProvider themeProvider,
  ) {
    final color = card['color'] as Color;
    final change = card['change'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(card['icon'], color: color, size: 24),
              ),
              if (change != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (change >= 0 ? Colors.green : Colors.red)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        change >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: change >= 0 ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${change.abs()}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: change >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card['value'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                card['label'],
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
  }

  Widget _buildTopProductsSection(bool isDesktop, ThemeProvider themeProvider) {
    if (_topProducts.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 16,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Selling Products',
                style: TextStyle(
                  fontSize: isDesktop ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: themeProvider.primaryMain.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_topProducts.length} Products',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: themeProvider.primaryMain,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _topProducts.length,
              itemBuilder: (context, index) {
                final product = _topProducts[index];
                return _buildTopProductCard(product, index, themeProvider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductCard(
    dynamic product,
    int index,
    ThemeProvider themeProvider,
  ) {
    final colors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFC0C0C0), // Silver
      const Color(0xFFCD7F32), // Bronze
      themeProvider.primaryMain,
      themeProvider.secondaryMain,
    ];

    final color =
        index < colors.length ? colors[index] : themeProvider.primaryMain;

    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '#${index + 1}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              Icon(Icons.star_rounded, color: color, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product['product_name'] ?? '-',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: themeProvider.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sold',
                    style: TextStyle(
                      fontSize: 11,
                      color: themeProvider.textTertiary,
                    ),
                  ),
                  Text(
                    '${product['total_quantity'] ?? 0}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textPrimary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Revenue',
                    style: TextStyle(
                      fontSize: 11,
                      color: themeProvider.textTertiary,
                    ),
                  ),
                  Text(
                    _formatCurrencyShort(product['total_revenue'] ?? 0),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsSection(
    bool isDesktop,
    ThemeProvider themeProvider,
  ) {
    if (_paymentMethods.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 16,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Methods',
            style: TextStyle(
              fontSize: isDesktop ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 4 : 2,
              childAspectRatio: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _paymentMethods.length,
            itemBuilder: (context, index) {
              final method = _paymentMethods[index];
              return _buildPaymentMethodCard(method, themeProvider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(dynamic method, ThemeProvider themeProvider) {
    final icons = {
      'cash': Icons.money_rounded,
      'debit': Icons.credit_card_rounded,
      'credit': Icons.credit_card_rounded,
      'transfer': Icons.account_balance_rounded,
      'ewallet': Icons.account_balance_wallet_rounded,
    };

    final colors = {
      'cash': const Color(0xFF4CAF50),
      'debit': const Color(0xFF2196F3),
      'credit': const Color(0xFFFF9800),
      'transfer': const Color(0xFF9C27B0),
      'ewallet': const Color(0xFFE91E63),
    };

    final methodType = (method['payment_method'] ?? 'cash').toLowerCase();
    final icon = icons[methodType] ?? Icons.payment_rounded;
    final color = colors[methodType] ?? themeProvider.primaryMain;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
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
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  method['payment_method'] ?? '-',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: themeProvider.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            _formatCurrency(method['total_amount'] ?? 0),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(bool isDesktop, bool isTablet) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (_transactions.isEmpty && !_isLoading) {
      return _buildEmptyState();
    }

    if (_isGridView) {
      int crossAxisCount = 2;
      if (isDesktop)
        crossAxisCount = 3;
      else if (isTablet)
        crossAxisCount = 2;

      return NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (!_isLoadingMore &&
              _hasMoreData &&
              scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 200) {
            _loadMoreData();
          }
          return false;
        },
        child: GridView.builder(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 12 : 16,
            isMobile ? 12 : 16,
            isMobile ? 12 : 16,
            80,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: isMobile ? 8 : 12,
            mainAxisSpacing: isMobile ? 8 : 12,
            childAspectRatio: isMobile ? 0.85 : (isTablet ? 0.9 : 1.0),
          ),
          itemCount: _transactions.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _transactions.length) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildTransactionGridCard(_transactions[index], isMobile);
          },
        ),
      );
    } else {
      return NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (!_isLoadingMore &&
              _hasMoreData &&
              scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 200) {
            _loadMoreData();
          }
          return false;
        },
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 12 : 16,
            isMobile ? 12 : 16,
            isMobile ? 12 : 16,
            80,
          ),
          itemCount: _transactions.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _transactions.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return _buildTransactionListCard(_transactions[index], isMobile);
          },
        ),
      );
    }
  }

  Widget _buildTransactionGridCard(dynamic transaction, bool isMobile) {
    final themeProvider = context.watch<ThemeProvider>();
    final status = transaction['payment']?['status'] ?? 'paid';
    final statusColor = _getStatusColor(status);

    return Card(
      color: themeProvider.surfaceColor,
      child: InkWell(
        onTap: () => _showTransactionDetail(transaction),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Invoice & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      transaction['invoice_number'] ?? '-',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 13 : 14,
                        color: themeProvider.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 6 : 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: isMobile ? 9 : 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 6 : 8),
              // Customer
              Text(
                transaction['customer']?['name'] ?? 'Walk-in Customer',
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  color: themeProvider.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              // Amount
              Text(
                _formatCurrency(transaction['total_price'] ?? 0),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4CAF50),
                  fontSize: isMobile ? 15 : 16,
                ),
              ),
              SizedBox(height: isMobile ? 6 : 8),
              // Date & Payment Method
              Row(
                children: [
                  Icon(
                    Icons.date_range,
                    size: isMobile ? 12 : 14,
                    color: themeProvider.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _formatDateTime(transaction['created_at']),
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 11,
                        color: themeProvider.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 2 : 4),
              Row(
                children: [
                  Icon(
                    Icons.payment,
                    size: isMobile ? 12 : 14,
                    color: themeProvider.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      transaction['payment']?['payment_method'] ?? '-',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 11,
                        color: themeProvider.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildTransactionListCard(dynamic transaction, bool isMobile) {
    final themeProvider = context.watch<ThemeProvider>();
    final status = transaction['payment']?['status'] ?? 'paid';
    final statusColor = _getStatusColor(status);

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      color: themeProvider.surfaceColor,
      child: InkWell(
        onTap: () => _showTransactionDetail(transaction),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Row(
            children: [
              // Icon
              Container(
                width: isMobile ? 50 : 60,
                height: isMobile ? 50 : 60,
                decoration: BoxDecoration(
                  color: themeProvider.primaryMain.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: themeProvider.primaryMain,
                  size: isMobile ? 24 : 28,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction['invoice_number'] ?? '-',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 14 : 16,
                        color: themeProvider.textPrimary,
                      ),
                    ),
                    SizedBox(height: isMobile ? 2 : 4),
                    Text(
                      transaction['customer']?['name'] ?? 'Walk-in Customer',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: themeProvider.textSecondary,
                      ),
                    ),
                    SizedBox(height: isMobile ? 4 : 6),
                    Row(
                      children: [
                        Icon(
                          Icons.payment,
                          size: isMobile ? 14 : 16,
                          color: themeProvider.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          transaction['payment']?['payment_method'] ?? '-',
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 12,
                            color: themeProvider.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.date_range,
                          size: isMobile ? 14 : 16,
                          color: themeProvider.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(transaction['created_at']),
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 12,
                            color: themeProvider.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Amount & Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatCurrency(transaction['total_price'] ?? 0),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4CAF50),
                      fontSize: isMobile ? 15 : 16,
                    ),
                  ),
                  SizedBox(height: isMobile ? 4 : 6),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 8 : 10,
                      vertical: isMobile ? 4 : 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
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

  void _showTransactionDetail(dynamic transaction) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TransactionDetailSheet(
        transaction: transaction,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
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
              Icons.receipt_long_rounded,
              size: isMobile ? 80 : 100,
              color: themeProvider.textTertiary.withOpacity(0.5),
            ),
            SizedBox(height: isMobile ? 16 : 24),
            Text(
              'No Transactions Found',
              style: TextStyle(
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.textPrimary,
              ),
            ),
            SizedBox(height: isMobile ? 8 : 12),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Try adjusting your search criteria'
                  : 'No sales data available for this period',
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

  void _exportReport() {
    showDialog(
      context: context,
      builder: (context) {
        final themeProvider = context.read<ThemeProvider>();
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
      final startDate = _startDate ?? widget.startDate;
      final endDate = _endDate ?? widget.endDate;
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final result = await SalesReportService.exportSalesReport(
        startDate: startDate,
        endDate: endDate,
        period: _selectedPeriod.toLowerCase().replaceAll(' ', ''),
        paymentMethod: _selectedPaymentMethod != 'Semua' ? _selectedPaymentMethod : null,
        storeId: _getStoreId(_selectedStore),
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
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
        Navigator.pop(context); // Close loading dialog
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'lunas':
        return const Color(0xFF4CAF50);
      case 'pending':
        return const Color(0xFFFF9800);
      case 'cancelled':
      case 'batal':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
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

  String _formatCurrencyShort(dynamic value) {
    try {
      final number = value is String ? double.parse(value) : value.toDouble();
      if (number >= 1000000) {
        return 'Rp ${(number / 1000000).toStringAsFixed(1)}M';
      } else if (number >= 1000) {
        return 'Rp ${(number / 1000).toStringAsFixed(1)}K';
      }
      return 'Rp ${number.toStringAsFixed(0)}';
    } catch (e) {
      return 'Rp 0';
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return '-';
    try {
      final date =
          dateTime is DateTime ? dateTime : DateTime.parse(dateTime.toString());
      return DateFormat('dd/MM/yy HH:mm').format(date);
    } catch (e) {
      return '-';
    }
  }
}

// Transaction Detail Bottom Sheet
class _TransactionDetailSheet extends StatelessWidget {
  final dynamic transaction;

  const _TransactionDetailSheet({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final screenHeight = MediaQuery.of(context).size.height;

    final status = transaction['payment']?['status'] ?? 'paid';
    final statusColor = _getStatusColor(status);
    final items = transaction['items'] ?? [];

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: themeProvider.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header with drag handle
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
                            icon: Icon(Icons.close, color: themeProvider.textSecondary),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Invoice Card
                      _buildInvoiceCard(themeProvider, isMobile, statusColor, status),
                      SizedBox(height: isMobile ? 12 : 16),

                      // Customer & Store Info
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              themeProvider,
                              isMobile,
                              'Customer',
                              transaction['customer']?['name'] ?? 'Walk-in Customer',
                              Icons.person_rounded,
                              themeProvider.primaryMain,
                            ),
                          ),
                          SizedBox(width: isMobile ? 8 : 12),
                          Expanded(
                            child: _buildInfoCard(
                              themeProvider,
                              isMobile,
                              'Store',
                              transaction['toko']?['nama'] ?? '-',
                              Icons.store_rounded,
                              themeProvider.secondaryMain,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 12 : 16),

                      // Payment Info Card
                      _buildPaymentInfoCard(themeProvider, isMobile),
                      SizedBox(height: isMobile ? 12 : 16),

                      // Items Section
                      _buildItemsSection(themeProvider, isMobile, items),
                      SizedBox(height: isMobile ? 12 : 16),

                      // Summary Card
                      _buildSummaryCard(themeProvider, isMobile),
                      const SizedBox(height: 20),
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

  Widget _buildInvoiceCard(
    ThemeProvider themeProvider,
    bool isMobile,
    Color statusColor,
    String status,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeProvider.primaryMain,
            themeProvider.primaryMain.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: themeProvider.primaryMain.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice Number',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction['invoice_number'] ?? '-',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 10 : 12,
                  vertical: isMobile ? 5 : 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 10 : 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: isMobile ? 13 : 14,
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(width: 6),
              Text(
                _formatDateTime(transaction['created_at']),
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    ThemeProvider themeProvider,
    bool isMobile,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: isMobile ? 16 : 18),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 11,
                    color: themeProvider.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              fontWeight: FontWeight.w600,
              color: themeProvider.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard(ThemeProvider themeProvider, bool isMobile) {
    final paymentMethod = transaction['payment']?['payment_method'] ?? '-';
    final paymentIcons = {
      'cash': Icons.money_rounded,
      'transfer': Icons.account_balance_rounded,
      'debit': Icons.credit_card_rounded,
      'credit': Icons.credit_card_rounded,
    };

    final icon = paymentIcons[paymentMethod.toLowerCase()] ?? Icons.payment;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 14),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF9C27B0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF9C27B0),
              size: isMobile ? 18 : 20,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: isMobile ? 10 : 11,
                  color: themeProvider.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                paymentMethod.toUpperCase(),
                style: TextStyle(
                  fontSize: isMobile ? 14 : 15,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(
    ThemeProvider themeProvider,
    bool isMobile,
    List<dynamic> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Items',
              style: TextStyle(
                fontSize: isMobile ? 15 : 16,
                fontWeight: FontWeight.bold,
                color: themeProvider.textPrimary,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 10,
                vertical: isMobile ? 3 : 4,
              ),
              decoration: BoxDecoration(
                color: themeProvider.primaryMain.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${items.length} ${items.length == 1 ? 'Item' : 'Items'}',
                style: TextStyle(
                  fontSize: isMobile ? 10 : 11,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.primaryMain,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 10 : 12),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _buildItemCard(themeProvider, isMobile, item, index);
        }).toList(),
      ],
    );
  }

  Widget _buildItemCard(
    ThemeProvider themeProvider,
    bool isMobile,
    dynamic item,
    int index,
  ) {
    final productName = item['produk']?['nama'] ?? item['product_name'] ?? '-';
    final quantity = item['quantity'] ?? item['jumlah'] ?? 0;
    final price = item['harga_satuan'] ?? item['price'] ?? 0;
    final subtotal = item['subtotal'] ?? (quantity * price);

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 6 : 8),
      padding: EdgeInsets.all(isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Row(
        children: [
          // Item Number Badge
          Container(
            width: isMobile ? 28 : 32,
            height: isMobile ? 28 : 32,
            decoration: BoxDecoration(
              color: themeProvider.primaryMain.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.primaryMain,
                ),
              ),
            ),
          ),
          SizedBox(width: isMobile ? 10 : 12),
          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: themeProvider.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isMobile ? 3 : 4),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 5 : 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: themeProvider.borderColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Qty: $quantity',
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 11,
                          color: themeProvider.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '×',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 11,
                        color: themeProvider.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatCurrency(price),
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 11,
                        color: themeProvider.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Subtotal
          Text(
            _formatCurrency(subtotal),
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeProvider themeProvider, bool isMobile) {
    final totalPrice = transaction['total_price'] ?? 0;

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: themeProvider.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  color: themeProvider.textSecondary,
                ),
              ),
              Text(
                _formatCurrency(totalPrice),
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  color: themeProvider.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tax',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  color: themeProvider.textSecondary,
                ),
              ),
              Text(
                'Rp 0',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  color: themeProvider.textPrimary,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 12),
            child: Divider(color: themeProvider.borderColor, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: isMobile ? 15 : 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                ),
              ),
              Text(
                _formatCurrency(totalPrice),
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'lunas':
        return const Color(0xFF4CAF50);
      case 'pending':
        return const Color(0xFFFF9800);
      case 'cancelled':
      case 'batal':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
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

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return '-';
    try {
      final date =
          dateTime is DateTime ? dateTime : DateTime.parse(dateTime.toString());
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return '-';
    }
  }
}
