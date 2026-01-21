import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme_provider.dart';
import '../services/stock_report_service.dart';

class StockReportScreen extends StatefulWidget {
  const StockReportScreen({super.key});

  @override
  State<StockReportScreen> createState() => _StockReportScreenState();
}

class _StockReportScreenState extends State<StockReportScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String? _error;

  // Data from API
  Map<String, dynamic> _summary = {};
  List<dynamic> _stockItems = [];
  List<dynamic> _categories = [];

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
  String _selectedStore = 'All Stores';
  String _selectedFilter = 'All';
  bool _isGridView = false;

  final List<String> _filterOptions = [
    'All',
    'Low Stock',
    'Out of Stock',
  ];

  List<String> _storeOptions = ['All Stores'];
  Map<String, String> _storeIdMap = {}; // Map store name to ID

  @override
  void initState() {
    super.initState();
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
      debugPrint('🔄 Loading stock report data...');
      debugPrint('🔍 Selected Filter: $_selectedFilter');
      debugPrint('🏪 Selected Store: $_selectedStore');
      debugPrint('📝 Search Query: $_searchQuery');

      final results = await Future.wait([
        StockReportService.getStockSummary(
          storeId: _getStoreId(_selectedStore),
          stockFilter: _selectedFilter,
        ),
        StockReportService.getStockItems(
          page: _currentPage,
          perPage: _perPage,
          search: _searchQuery.isNotEmpty ? _searchQuery : null,
          storeId: _getStoreId(_selectedStore),
          stockFilter: _selectedFilter,
        ),
        StockReportService.getStockByCategory(
          storeId: _getStoreId(_selectedStore),
          stockFilter: _selectedFilter,
        ),
      ]);

      debugPrint('📊 Summary response: ${results[0]}');
      debugPrint('📦 Stock items response: ${results[1]}');
      debugPrint('📁 Categories response: ${results[2]}');

      if (mounted) {
        setState(() {
          if (results[0]['success'] == true) {
            _summary = results[0]['data'] ?? {};
            debugPrint('✅ Summary loaded: $_summary');
          } else {
            debugPrint('❌ Summary failed: ${results[0]['message']}');
          }

          if (results[1]['success'] == true) {
            final newItems = results[1]['data'] ?? [];
            
            if (isRefresh || _currentPage == 1) {
              _stockItems = newItems;
            } else {
              _stockItems.addAll(newItems);
            }
            
            debugPrint('✅ Stock items loaded: ${_stockItems.length} items');
            final pagination = results[1]['pagination'];
            if (pagination != null) {
              _totalPages = pagination['last_page'] ?? 1;
              _hasMoreData = pagination['current_page'] < pagination['last_page'];
            }
          } else {
            debugPrint('❌ Stock items failed: ${results[1]['message']}');
            _error = results[1]['message'];
          }

          if (results[2]['success'] == true) {
            _categories = results[2]['data'] ?? [];
            debugPrint('✅ Categories loaded: ${_categories.length} items');
          } else {
            debugPrint('❌ Categories failed: ${results[2]['message']}');
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

  String? _getStoreId(String storeName) {
    if (storeName == 'All Stores') return null;
    return _storeIdMap[storeName];
  }

  Future<void> _loadStores() async {
    try {
      final result = await StockReportService.getStores();
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
      final response = await StockReportService.getStockItems(
        page: _currentPage,
        perPage: _perPage,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        storeId: _getStoreId(_selectedStore),
        stockFilter: _selectedFilter,
      );

      if (mounted && response['success'] == true) {
        final newItems = response['data'] ?? [];
        setState(() {
          _stockItems.addAll(newItems);
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
      appBar: AppBar(
        backgroundColor: themeProvider.surfaceColor,
        elevation: 0,
        title: Text(
          'Stock Report',
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
        child: _isLoading && _stockItems.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError(themeProvider)
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            _buildSearchAndFilters(screenWidth < 600),
                            _buildFilterChips(screenWidth < 600),
                            _buildTopSummaryCards(screenWidth < 600, isTablet, themeProvider),
                          ],
                        ),
                      ),
                      _buildStockItemsListSliver(isDesktop, isTablet),
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

  Widget _buildSearchAndFilters(bool isMobile) {
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
              hintText: 'Search by product name, IMEI, description...',
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
          // Store filter dropdown
          DropdownButtonFormField<String>(
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
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isMobile) {
    final themeProvider = context.watch<ThemeProvider>();

    return SizedBox(
      height: isMobile ? 45 : 50,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _filterOptions.length,
          itemBuilder: (context, index) {
            final filter = _filterOptions[index];
            final isSelected = _selectedFilter == filter;

            return Container(
              margin: EdgeInsets.only(right: isMobile ? 6 : 8),
              child: FilterChip(
                label: Text(
                  filter,
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
                  setState(() => _selectedFilter = filter);
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
      ),
    );
  }

  Widget _buildTopSummaryCards(
    bool isMobile,
    bool isTablet,
    ThemeProvider themeProvider,
  ) {
    final totalProducts = _summary['total_products'] ?? 0;
    final totalStock = _summary['total_stock'] ?? 0;
    final lowStockCount = _summary['low_stock_count'] ?? 0;
    final outOfStockCount = _summary['out_of_stock_count'] ?? 0;

    final cards = [
      {
        'label': 'Total Products',
        'value': totalProducts.toString(),
        'icon': Icons.inventory_2_rounded,
        'color': const Color(0xFF9333EA), // Purple
      },
      {
        'label': 'Total Stock',
        'value': totalStock.toString(),
        'icon': Icons.warehouse_rounded,
        'color': const Color(0xFF22C55E), // Green
      },
      {
        'label': 'Low Stock',
        'value': lowStockCount.toString(),
        'icon': Icons.warning_rounded,
        'color': const Color(0xFFFF9800), // Orange
      },
      {
        'label': 'Out of Stock',
        'value': outOfStockCount.toString(),
        'icon': Icons.remove_shopping_cart_rounded,
        'color': const Color(0xFFEF4444), // Red
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 6 : 8,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = isMobile ? 2 : (isTablet ? 4 : 4);
          final crossAxisSpacing = isMobile ? 8.0 : 12.0;
          final mainAxisSpacing = isMobile ? 8.0 : 12.0;
          final childAspectRatio = isMobile ? 1.5 : 2.0;
          
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
                return _buildTopSummaryCard(
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

  Widget _buildStockItemsList(bool isDesktop, bool isTablet) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (_stockItems.isEmpty && !_isLoading) {
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
          itemCount: _stockItems.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _stockItems.length) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildStockItemGridCard(_stockItems[index], isMobile);
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
          itemCount: _stockItems.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _stockItems.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return _buildStockItemListCard(_stockItems[index], isMobile);
          },
        ),
      );
    }
  }

  Widget _buildStockItemGridCard(dynamic item, bool isMobile) {
    final themeProvider = context.watch<ThemeProvider>();
    final status = item['status'] ?? 'high_stock';
    final stockColor = _getStockStatusColor(status);
    final stock = item['stock'] ?? 0;

    return Card(
      color: themeProvider.surfaceColor,
      child: InkWell(
        onTap: () => _showStockDetail(item),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Name & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item['product']?['name'] ?? '-',
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
                      color: stockColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 6 : 8),
              // IMEI (hide if empty)
              if (item['product']?['sku'] != null && item['product']?['sku'] != '-' && (item['product']?['sku'].toString().isNotEmpty ?? false))
                Text(
                  'IMEI: ${item['product']?['sku']}',
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 11,
                    color: themeProvider.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (item['product']?['sku'] != null && item['product']?['sku'] != '-' && (item['product']?['sku'].toString().isNotEmpty ?? false))
                const SizedBox(height: 4),
              // Category (hide if empty)
              if (item['product']?['category'] != null && item['product']?['category'] != '-' && (item['product']?['category'].toString().isNotEmpty ?? false))
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 6 : 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: themeProvider.borderColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item['product']?['category'],
                    style: TextStyle(
                      fontSize: isMobile ? 9 : 10,
                      color: themeProvider.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const Spacer(),
              // Stock Info
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 10),
                decoration: BoxDecoration(
                  color: stockColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: stockColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stock',
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 11,
                            color: themeProvider.textTertiary,
                          ),
                        ),
                        Text(
                          '$stock',
                          style: TextStyle(
                            fontSize: isMobile ? 18 : 20,
                            fontWeight: FontWeight.bold,
                            color: stockColor,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      _getStockStatusIcon(status),
                      color: stockColor,
                      size: isMobile ? 24 : 28,
                    ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 6 : 8),
              // Value
              Text(
                'Value: ${_formatCurrency(item['value'] ?? 0)}',
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4CAF50),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Store (hide if empty)
              if (item['store']?['name'] != null && item['store']?['name'] != '-' && (item['store']?['name'].toString().isNotEmpty ?? false))
                Text(
                  item['store']?['name'],
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

  Widget _buildStockItemListCard(dynamic item, bool isMobile) {
    final themeProvider = context.watch<ThemeProvider>();
    final status = item['status'] ?? 'high_stock';
    final stockColor = _getStockStatusColor(status);
    final stock = item['stock'] ?? 0;

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      color: themeProvider.surfaceColor,
      child: InkWell(
        onTap: () => _showStockDetail(item),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Row(
            children: [
              // Icon with stock indicator
              Container(
                width: isMobile ? 60 : 70,
                height: isMobile ? 60 : 70,
                decoration: BoxDecoration(
                  color: stockColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: stockColor.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getStockStatusIcon(status),
                      color: stockColor,
                      size: isMobile ? 20 : 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$stock',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: stockColor,
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
                      item['product']?['name'] ?? '-',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 14 : 16,
                        color: themeProvider.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isMobile ? 2 : 4),
                    // IMEI (hide if empty)
                    if (item['product']?['sku'] != null && item['product']?['sku'] != '-' && (item['product']?['sku'].toString().isNotEmpty ?? false))
                      Text(
                        'IMEI: ${item['product']?['sku']}',
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          color: themeProvider.textTertiary,
                        ),
                      ),
                    SizedBox(height: isMobile ? 4 : 6),
                    Row(
                      children: [
                        // Category (hide if empty)
                        if (item['product']?['category'] != null && item['product']?['category'] != '-' && (item['product']?['category'].toString().isNotEmpty ?? false))
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 6 : 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: themeProvider.borderColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item['product']?['category'],
                              style: TextStyle(
                                fontSize: isMobile ? 9 : 10,
                                color: themeProvider.textSecondary,
                              ),
                            ),
                          ),
                        if (item['product']?['category'] != null && item['product']?['category'] != '-' && (item['product']?['category'].toString().isNotEmpty ?? false))
                          const SizedBox(width: 8),
                        Icon(
                          Icons.store_rounded,
                          size: isMobile ? 12 : 14,
                          color: themeProvider.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item['store']?['name'] ?? '',
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
                    _formatCurrency(item['value'] ?? 0),
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
                      color: stockColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: stockColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      _getStockStatusText(status),
                      style: TextStyle(
                        fontSize: isMobile ? 9 : 10,
                        fontWeight: FontWeight.bold,
                        color: stockColor,
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

  Widget _buildStockItemsListSliver(bool isDesktop, bool isTablet) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (_stockItems.isEmpty && !_isLoading) {
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
              if (index == _stockItems.length) {
                return const Center(child: CircularProgressIndicator());
              }
              
              // Load more when near end
              if (index == _stockItems.length - 3 && !_isLoadingMore && _hasMoreData) {
                _loadMoreData();
              }
              
              return _buildStockItemGridCard(_stockItems[index], isMobile);
            },
            childCount: _stockItems.length + (_isLoadingMore ? 1 : 0),
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
              if (index == _stockItems.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              // Load more when near end
              if (index == _stockItems.length - 3 && !_isLoadingMore && _hasMoreData) {
                _loadMoreData();
              }
              
              return _buildStockItemListCard(_stockItems[index], isMobile);
            },
            childCount: _stockItems.length + (_isLoadingMore ? 1 : 0),
          ),
        ),
      );
    }
  }

  void _showStockDetail(dynamic item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _StockDetailSheet(item: item),
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
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final result = await StockReportService.exportStockReport(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        storeId: _getStoreId(_selectedStore),
        stockFilter: _selectedFilter,
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
              Icons.inventory_2_rounded,
              size: isMobile ? 80 : 100,
              color: themeProvider.textTertiary.withOpacity(0.5),
            ),
            SizedBox(height: isMobile ? 16 : 24),
            Text(
              'No Stock Data Found',
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
                  : 'No stock data available',
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

  Color _getStockStatusColor(String status) {
    switch (status) {
      case 'out_of_stock':
        return const Color(0xFFEF4444); // Red
      case 'low_stock':
        return const Color(0xFFFF9800); // Orange
      case 'medium_stock':
        return const Color(0xFF3B82F6); // Blue
      case 'high_stock':
        return const Color(0xFF22C55E); // Green
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData _getStockStatusIcon(String status) {
    switch (status) {
      case 'out_of_stock':
        return Icons.remove_shopping_cart_rounded;
      case 'low_stock':
        return Icons.warning_rounded;
      case 'medium_stock':
        return Icons.inventory_rounded;
      case 'high_stock':
        return Icons.check_circle_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  String _getStockStatusText(String status) {
    switch (status) {
      case 'out_of_stock':
        return 'OUT';
      case 'low_stock':
        return 'LOW';
      case 'medium_stock':
        return 'MEDIUM';
      case 'high_stock':
        return 'GOOD';
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
}

// Stock Detail Bottom Sheet
class _StockDetailSheet extends StatelessWidget {
  final dynamic item;

  const _StockDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final status = item['status'] ?? 'high_stock';
    final stockColor = _getStockStatusColor(status);
    final stock = item['stock'] ?? 0;

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
                              'Stock Detail',
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
                      // Stock Status Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isMobile ? 16 : 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              stockColor,
                              stockColor.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: stockColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _getStockStatusIcon(status),
                              color: Colors.white,
                              size: isMobile ? 48 : 56,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '$stock',
                              style: TextStyle(
                                fontSize: isMobile ? 36 : 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _getStockStatusText(status).toUpperCase(),
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

                      // Product Info
                      _buildInfoSection(
                        themeProvider,
                        isMobile,
                        'Product Information',
                        Icons.inventory_2_rounded,
                        themeProvider.primaryMain,
                      ),
                      SizedBox(height: isMobile ? 8 : 12),
                      _buildInfoCard(
                        themeProvider,
                        isMobile,
                        [
                          {'label': 'Name', 'value': item['product']?['name'] ?? '-'},
                          if (item['product']?['sku'] != null && item['product']?['sku'] != '-' && (item['product']?['sku'].toString().isNotEmpty ?? false))
                            {'label': 'IMEI', 'value': item['product']?['sku']},
                        ],
                      ),
                      SizedBox(height: isMobile ? 16 : 20),

                      // Price & Value Info
                      _buildInfoSection(
                        themeProvider,
                        isMobile,
                        'Price & Value',
                        Icons.account_balance_wallet_rounded,
                        const Color(0xFF4CAF50),
                      ),
                      SizedBox(height: isMobile ? 8 : 12),
                      _buildInfoCard(
                        themeProvider,
                        isMobile,
                        [
                          {'label': 'Unit Price', 'value': _formatCurrency(item['product']?['price'] ?? 0)},
                          {'label': 'Stock Quantity', 'value': '$stock units'},
                          {'label': 'Total Value', 'value': _formatCurrency(item['value'] ?? 0)},
                        ],
                      ),
                      SizedBox(height: isMobile ? 16 : 20),

                      // Store Info
                      _buildInfoSection(
                        themeProvider,
                        isMobile,
                        'Store Location',
                        Icons.store_rounded,
                        themeProvider.secondaryMain,
                      ),
                      SizedBox(height: isMobile ? 8 : 12),
                      _buildInfoCard(
                        themeProvider,
                        isMobile,
                        [
                          {'label': 'Store', 'value': item['store']?['name'] ?? '-'},
                          {'label': 'Min Stock', 'value': '${item['min_stock'] ?? 5} units'},
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

  Color _getStockStatusColor(String status) {
    switch (status) {
      case 'out_of_stock':
        return const Color(0xFFEF4444); // Red
      case 'low_stock':
        return const Color(0xFFFF9800); // Orange
      case 'medium_stock':
        return const Color(0xFF3B82F6); // Blue
      case 'high_stock':
        return const Color(0xFF22C55E); // Green
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData _getStockStatusIcon(String status) {
    switch (status) {
      case 'out_of_stock':
        return Icons.remove_shopping_cart_rounded;
      case 'low_stock':
        return Icons.warning_rounded;
      case 'medium_stock':
        return Icons.inventory_rounded;
      case 'high_stock':
        return Icons.check_circle_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  String _getStockStatusText(String status) {
    switch (status) {
      case 'out_of_stock':
        return 'Out of Stock';
      case 'low_stock':
        return 'Low Stock';
      case 'medium_stock':
        return 'Medium Stock';
      case 'high_stock':
        return 'High Stock';
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
}
