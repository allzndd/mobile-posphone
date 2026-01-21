import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme_provider.dart';
import '../services/customer_report_service.dart';

class CustomerReportScreen extends StatefulWidget {
  const CustomerReportScreen({super.key});

  @override
  State<CustomerReportScreen> createState() => _CustomerReportScreenState();
}

class _CustomerReportScreenState extends State<CustomerReportScreen> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String? _error;

  // Data from API
  Map<String, dynamic> _summary = {};
  List<dynamic> _customerItems = [];

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
  String _selectedSort = 'name';
  bool _isGridView = false;

  final List<Map<String, String>> _sortOptions = [
    {'value': 'name', 'label': 'Name'},
    {'value': 'purchases', 'label': 'Most Purchases'},
    {'value': 'value', 'label': 'Highest Value'},
    {'value': 'recent', 'label': 'Recently Added'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData(isRefresh: true);
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
      debugPrint('🔄 Loading customer report data...');

      final results = await Future.wait([
        CustomerReportService.getCustomerSummary(
          search: _searchQuery.isNotEmpty ? _searchQuery : null,
          sortBy: _selectedSort,
        ),
        CustomerReportService.getCustomerItems(
          page: _currentPage,
          perPage: _perPage,
          search: _searchQuery.isNotEmpty ? _searchQuery : null,
          sortBy: _selectedSort,
        ),
      ]);

      if (mounted) {
        setState(() {
          if (results[0]['success'] == true) {
            _summary = results[0]['data'] ?? {};
          }

          if (results[1]['success'] == true) {
            final newItems = results[1]['data'] ?? [];
            
            if (isRefresh || _currentPage == 1) {
              _customerItems = newItems;
            } else {
              _customerItems.addAll(newItems);
            }
            
            final pagination = results[1]['pagination'];
            if (pagination != null) {
              _totalPages = pagination['last_page'] ?? 1;
              _hasMoreData = pagination['current_page'] < pagination['last_page'];
            }
          } else {
            _error = results[1]['message'];
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

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMoreData || _isLoading) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    try {
      final response = await CustomerReportService.getCustomerItems(
        page: _currentPage,
        perPage: _perPage,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        sortBy: _selectedSort,
      );

      if (mounted && response['success'] == true) {
        final newItems = response['data'] ?? [];
        setState(() {
          _customerItems.addAll(newItems);
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
          'Customer Report',
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: RefreshIndicator(
          onRefresh: () => _loadData(isRefresh: true),
          child: _isLoading && _customerItems.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildError(themeProvider)
                  : CustomScrollView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              _buildSearchAndSort(screenWidth < 600),
                              _buildTopSummaryCards(screenWidth < 600, isTablet, themeProvider),
                            ],
                          ),
                        ),
                        _buildCustomerItemsListSliver(isDesktop, isTablet),
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

  Widget _buildSearchAndSort(bool isMobile) {
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
              hintText: 'Search by name, email, phone, address...',
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
          // Sort dropdown
          DropdownButtonFormField<String>(
            value: _selectedSort,
            style: TextStyle(color: themeProvider.textPrimary),
            decoration: InputDecoration(
              labelText: 'Sort By',
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
            items: _sortOptions.map((option) {
              return DropdownMenuItem(
                value: option['value'],
                child: Text(
                  option['label']!,
                  style: TextStyle(color: themeProvider.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedSort = value ?? 'name');
              _loadData(isRefresh: true);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopSummaryCards(
    bool isMobile,
    bool isTablet,
    ThemeProvider themeProvider,
  ) {
    final totalCustomers = _summary['total_customers'] ?? 0;
    final totalPurchases = _summary['total_purchases'] ?? 0;
    final totalValue = _summary['total_value'] ?? 0.0;
    final averageValue = _summary['average_value'] ?? 0.0;

    final cards = [
      {
        'label': 'Total Pelanggan',
        'value': totalCustomers.toString(),
        'icon': Icons.people_rounded,
        'color': const Color(0xFF9333EA), // Purple
      },
      {
        'label': 'Total Pembelian',
        'value': totalPurchases.toString(),
        'icon': Icons.shopping_bag_rounded,
        'color': const Color(0xFF22C55E), // Green
      },
      {
        'label': 'Total Nilai',
        'value': _formatCurrencyCard(totalValue),
        'icon': Icons.account_balance_wallet_rounded,
        'color': const Color(0xFF3B82F6), // Blue
      },
      {
        'label': 'Rata-rata Nilai',
        'value': _formatCurrencyCard(averageValue),
        'icon': Icons.trending_up_rounded,
        'color': const Color(0xFFFF9800), // Orange
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 4 : 6,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = isMobile ? 2 : (isTablet ? 4 : 4);
          final crossAxisSpacing = isMobile ? 6.0 : 12.0;
          final mainAxisSpacing = isMobile ? 6.0 : 12.0;
          final childAspectRatio = isMobile ? 2.2 : 2.5;
          
          final availableWidth = constraints.maxWidth;
          final itemWidth = (availableWidth - (crossAxisSpacing * (crossAxisCount - 1))) / crossAxisCount;
          final itemHeight = itemWidth / childAspectRatio;
          final rows = (cards.length / crossAxisCount).ceil();
          final totalHeight = (itemHeight * rows) + (mainAxisSpacing * (rows - 1));
          
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
                return _buildSummaryCard(
                  cards[index],
                  themeProvider,
                  isMobile,
                );
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(card['icon'], color: color, size: isMobile ? 14 : 16),
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
        ],
      ),
    );
  }

  Widget _buildCustomerItemsListSliver(bool isDesktop, bool isTablet) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (_customerItems.isEmpty && !_isLoading) {
      return SliverFillRemaining(
        child: _buildEmptyState(),
      );
    }

    if (_isGridView) {
      int crossAxisCount = 2;
      if (isDesktop)
        crossAxisCount = 3;
      else if (isTablet)
        crossAxisCount = 2;

      return SliverPadding(
        padding: EdgeInsets.fromLTRB(
          isMobile ? 12 : 16,
          isMobile ? 12 : 16,
          isMobile ? 12 : 16,
          80,
        ),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: isMobile ? 8 : 12,
            mainAxisSpacing: isMobile ? 8 : 12,
            childAspectRatio: isMobile ? 0.85 : (isTablet ? 0.9 : 1.0),
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == _customerItems.length) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (index == _customerItems.length - 3 && !_isLoadingMore && _hasMoreData) {
                _loadMoreData();
              }
              
              return _buildCustomerItemGridCard(_customerItems[index], isMobile);
            },
            childCount: _customerItems.length + (_isLoadingMore ? 1 : 0),
          ),
        ),
      );
    } else {
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(
          isMobile ? 12 : 16,
          isMobile ? 12 : 16,
          isMobile ? 12 : 16,
          80,
        ),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == _customerItems.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              if (index == _customerItems.length - 3 && !_isLoadingMore && _hasMoreData) {
                _loadMoreData();
              }
              
              return _buildCustomerItemListCard(_customerItems[index], isMobile);
            },
            childCount: _customerItems.length + (_isLoadingMore ? 1 : 0),
          ),
        ),
      );
    }
  }

  Widget _buildCustomerItemGridCard(dynamic item, bool isMobile) {
    final themeProvider = context.watch<ThemeProvider>();
    final status = item['status'] ?? 'new';
    final statusColor = _getCustomerStatusColor(status);
    final totalPurchases = item['total_purchases'] ?? 0;

    return Card(
      color: themeProvider.surfaceColor,
      child: InkWell(
        onTap: () => _showCustomerDetail(item),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Name & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item['name'] ?? '-',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 13 : 14,
                        color: themeProvider.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Purchase Info
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Purchases',
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 11,
                            color: themeProvider.textTertiary,
                          ),
                        ),
                        Text(
                          '$totalPurchases',
                          style: TextStyle(
                            fontSize: isMobile ? 18 : 20,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      _getCustomerStatusIcon(status),
                      color: statusColor,
                      size: isMobile ? 24 : 28,
                    ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 6 : 8),
              // Value
              Text(
                'Value: ${_formatCurrency(item['total_value'] ?? 0)}',
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4CAF50),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Phone
              if (item['phone'] != null && item['phone'] != '-' && (item['phone'].toString().isNotEmpty ?? false))
                Text(
                  item['phone'],
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 11,
                    color: themeProvider.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerItemListCard(dynamic item, bool isMobile) {
    final themeProvider = context.watch<ThemeProvider>();
    final status = item['status'] ?? 'new';
    final statusColor = _getCustomerStatusColor(status);
    final totalPurchases = item['total_purchases'] ?? 0;

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      color: themeProvider.surfaceColor,
      child: InkWell(
        onTap: () => _showCustomerDetail(item),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Row(
            children: [
              // Icon with purchase indicator
              Container(
                width: isMobile ? 60 : 70,
                height: isMobile ? 60 : 70,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getCustomerStatusIcon(status),
                      color: statusColor,
                      size: isMobile ? 20 : 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalPurchases',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] ?? '-',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 14 : 16,
                        color: themeProvider.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isMobile ? 2 : 4),
                    // Phone
                    if (item['phone'] != null && item['phone'] != '-' && (item['phone'].toString().isNotEmpty ?? false))
                      Text(
                        item['phone'],
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          color: themeProvider.textTertiary,
                        ),
                      ),
                    SizedBox(height: isMobile ? 4 : 6),
                    Row(
                      children: [
                        Icon(
                          Icons.shopping_bag_rounded,
                          size: isMobile ? 12 : 14,
                          color: themeProvider.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '$totalPurchases purchases',
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
              // Value & Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatCurrency(item['total_value'] ?? 0),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4CAF50),
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
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      _getCustomerStatusText(status),
                      style: TextStyle(
                        fontSize: isMobile ? 9 : 10,
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

  void _showCustomerDetail(dynamic item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CustomerDetailSheet(item: item),
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
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final result = await CustomerReportService.exportCustomerReport(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        sortBy: _selectedSort,
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
              Icons.people_rounded,
              size: isMobile ? 80 : 100,
              color: themeProvider.textTertiary.withOpacity(0.5),
            ),
            SizedBox(height: isMobile ? 16 : 24),
            Text(
              'No Customer Data Found',
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
                  : 'No customer data available',
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

  Color _getCustomerStatusColor(String status) {
    switch (status) {
      case 'active':
        return const Color(0xFF22C55E); // Green
      case 'inactive':
        return const Color(0xFFFF9800); // Orange
      case 'dormant':
        return const Color(0xFFEF4444); // Red
      case 'new':
        return const Color(0xFF3B82F6); // Blue
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData _getCustomerStatusIcon(String status) {
    switch (status) {
      case 'active':
        return Icons.check_circle_rounded;
      case 'inactive':
        return Icons.warning_rounded;
      case 'dormant':
        return Icons.remove_circle_rounded;
      case 'new':
        return Icons.person_add_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  String _getCustomerStatusText(String status) {
    switch (status) {
      case 'active':
        return 'ACTIVE';
      case 'inactive':
        return 'INACTIVE';
      case 'dormant':
        return 'DORMANT';
      case 'new':
        return 'NEW';
      default:
        return 'N/A';
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

  String _formatCurrencyCard(dynamic value) {
    try {
      final number = value is String ? double.parse(value) : value.toDouble();
      final formatter = NumberFormat.decimalPattern('id_ID');
      return 'Rp\n${formatter.format(number.round())}';
    } catch (e) {
      return 'Rp\n0';
    }
  }
}

// Customer Detail Bottom Sheet
class _CustomerDetailSheet extends StatelessWidget {
  final dynamic item;

  const _CustomerDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final status = item['status'] ?? 'new';
    final statusColor = _getCustomerStatusColor(status);
    final totalPurchases = item['total_purchases'] ?? 0;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
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
                              'Customer Detail',
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
                      // Status Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isMobile ? 16 : 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              statusColor,
                              statusColor.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _getCustomerStatusIcon(status),
                              color: Colors.white,
                              size: isMobile ? 48 : 56,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '$totalPurchases',
                              style: TextStyle(
                                fontSize: isMobile ? 36 : 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _getCustomerStatusText(status).toUpperCase(),
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isMobile ? 16 : 20),

                      // Customer Info
                      _buildInfoSection(
                        themeProvider,
                        isMobile,
                        'Customer Information',
                        Icons.person_rounded,
                        themeProvider.primaryMain,
                      ),
                      SizedBox(height: isMobile ? 8 : 12),
                      _buildInfoCard(
                        themeProvider,
                        isMobile,
                        [
                          {'label': 'Name', 'value': item['name'] ?? '-'},
                          if (item['email'] != null && item['email'] != '-' && (item['email'].toString().isNotEmpty ?? false))
                            {'label': 'Email', 'value': item['email']},
                          if (item['phone'] != null && item['phone'] != '-' && (item['phone'].toString().isNotEmpty ?? false))
                            {'label': 'Phone', 'value': item['phone']},
                        ],
                      ),
                      SizedBox(height: isMobile ? 16 : 20),

                      // Purchase Info
                      _buildInfoSection(
                        themeProvider,
                        isMobile,
                        'Purchase Statistics',
                        Icons.shopping_cart_rounded,
                        const Color(0xFF4CAF50),
                      ),
                      SizedBox(height: isMobile ? 8 : 12),
                      _buildInfoCard(
                        themeProvider,
                        isMobile,
                        [
                          {'label': 'Total Purchases', 'value': '$totalPurchases times'},
                          {'label': 'Total Value', 'value': _formatCurrency(item['total_value'] ?? 0)},
                          {'label': 'Average Purchase', 'value': _formatCurrency(item['average_purchase'] ?? 0)},
                          if (item['last_purchase_date'] != null)
                            {'label': 'Last Purchase', 'value': _formatDate(item['last_purchase_date'])},
                        ],
                      ),
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

  Widget _buildInfoSection(
    ThemeProvider themeProvider,
    bool isMobile,
    String title,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: isMobile ? 18 : 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 15 : 16,
            fontWeight: FontWeight.bold,
            color: themeProvider.textPrimary,
          ),
        ),
      ],
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
        children: items
            .asMap()
            .entries
            .map((entry) {
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
                      padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 10),
                      child: Divider(color: themeProvider.borderColor, height: 1),
                    ),
                ],
              );
            })
            .toList(),
      ),
    );
  }

  Color _getCustomerStatusColor(String status) {
    switch (status) {
      case 'active':
        return const Color(0xFF22C55E);
      case 'inactive':
        return const Color(0xFFFF9800);
      case 'dormant':
        return const Color(0xFFEF4444);
      case 'new':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData _getCustomerStatusIcon(String status) {
    switch (status) {
      case 'active':
        return Icons.check_circle_rounded;
      case 'inactive':
        return Icons.warning_rounded;
      case 'dormant':
        return Icons.remove_circle_rounded;
      case 'new':
        return Icons.person_add_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  String _getCustomerStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Active Customer';
      case 'inactive':
        return 'Inactive Customer';
      case 'dormant':
        return 'Dormant Customer';
      case 'new':
        return 'New Customer';
      default:
        return 'Unknown';
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
