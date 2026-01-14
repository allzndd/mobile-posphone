import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme_provider.dart';
import '../services/product_report_service.dart';

class ProductReportScreen extends StatefulWidget {
  const ProductReportScreen({super.key});

  @override
  State<ProductReportScreen> createState() => _ProductReportScreenState();
}

class _ProductReportScreenState extends State<ProductReportScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String? _error;

  // Data from API
  Map<String, dynamic> _summary = {};
  List<dynamic> _products = [];

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
  String _selectedStockStatus = 'Semua';
  bool _isGridView = false;

  final List<String> _stockStatusOptions = [
    'Semua',
    'Out of Stock',
    'Low Stock',
    'In Stock',
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
      debugPrint('🔄 Loading product report data...');

      final results = await Future.wait([
        ProductReportService.getProductSummary(
          search: _searchQuery.isNotEmpty ? _searchQuery : null,
          stockStatus: _selectedStockStatus != 'Semua' ? _selectedStockStatus : null,
          storeId: _getStoreId(_selectedStore),
        ),
        ProductReportService.getProducts(
          page: _currentPage,
          perPage: _perPage,
          search: _searchQuery.isNotEmpty ? _searchQuery : null,
          stockStatus: _selectedStockStatus != 'Semua' ? _selectedStockStatus : null,
          storeId: _getStoreId(_selectedStore),
        ),
      ]);

      debugPrint('📊 Summary response: ${results[0]}');
      debugPrint('📦 Products response: ${results[1]}');

      if (mounted) {
        setState(() {
          if (results[0]['success'] == true) {
            _summary = results[0]['data'] ?? {};
            debugPrint('✅ Summary loaded: $_summary');
          } else {
            debugPrint('❌ Summary failed: ${results[0]['message']}');
          }

          if (results[1]['success'] == true) {
            final newProducts = results[1]['data'] ?? [];
            
            if (isRefresh || _currentPage == 1) {
              _products = newProducts;
            } else {
              _products.addAll(newProducts);
            }
            
            debugPrint('✅ Products loaded: ${_products.length} items');
            final pagination = results[1]['pagination'];
            if (pagination != null) {
              _totalPages = pagination['last_page'] ?? 1;
              _hasMoreData = pagination['current_page'] < pagination['last_page'];
            }
          } else {
            debugPrint('❌ Products failed: ${results[1]['message']}');
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

  String? _getStoreId(String storeName) {
    if (storeName == 'All Stores') return null;
    return _storeIdMap[storeName];
  }

  Future<void> _loadStores() async {
    try {
      final result = await ProductReportService.getStores();
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
      final response = await ProductReportService.getProducts(
        page: _currentPage,
        perPage: _perPage,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        stockStatus: _selectedStockStatus != 'Semua' ? _selectedStockStatus : null,
        storeId: _getStoreId(_selectedStore),
      );

      if (mounted && response['success'] == true) {
        final newProducts = response['data'] ?? [];
        setState(() {
          _products.addAll(newProducts);
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
          'Product Report',
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
            _buildStockStatusFilter(screenWidth < 600),
            _buildTopSummaryCards(screenWidth < 600, isTablet, themeProvider),
            Expanded(
              child: _isLoading && _products.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildError(themeProvider)
                      : _buildProductList(isDesktop, isTablet),
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
              hintText: 'Search by product name or code...',
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

  Widget _buildStockStatusFilter(bool isMobile) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      height: isMobile ? 45 : 50,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _stockStatusOptions.length,
        itemBuilder: (context, index) {
          final status = _stockStatusOptions[index];
          final isSelected = _selectedStockStatus == status;

          return Container(
            margin: EdgeInsets.only(right: isMobile ? 6 : 8),
            child: FilterChip(
              label: Text(
                status,
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
                setState(() => _selectedStockStatus = status);
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
    final totalProducts = _summary['total_products'] ?? 0;
    final totalStock = _summary['total_stock'] ?? 0;
    final totalValue = _summary['total_value'] ?? 0;

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
        'icon': Icons.local_shipping_rounded,
        'color': const Color(0xFF22C55E), // Green
      },
      {
        'label': 'Total Stock Value',
        'value': _formatCurrency(totalValue),
        'icon': Icons.attach_money_rounded,
        'color': const Color(0xFF3B82F6), // Blue
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
          crossAxisCount: isMobile ? 2 : (isTablet ? 3 : 3),
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

  Widget _buildProductList(bool isDesktop, bool isTablet) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (_products.isEmpty && !_isLoading) {
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
          itemCount: _products.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _products.length) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildProductGridCard(_products[index], isMobile);
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
          itemCount: _products.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _products.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return _buildProductListCard(_products[index], isMobile);
          },
        ),
      );
    }
  }

  Widget _buildProductGridCard(dynamic product, bool isMobile) {
    final themeProvider = context.watch<ThemeProvider>();
    final totalStok = product['total_stok'] ?? 0;
    final stockColor = _getStockColor(totalStok);

    return Card(
      color: themeProvider.surfaceColor,
      child: InkWell(
        onTap: () => _showProductDetail(product),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Stock Badge (pojok kanan atas)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 6 : 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: stockColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStockStatus(totalStok),
                      style: TextStyle(
                        fontSize: isMobile ? 9 : 10,
                        fontWeight: FontWeight.bold,
                        color: stockColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 6 : 8),
              // Product Name
              Text(
                product['nama'] ?? '-',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isMobile ? 4 : 6),
              // Brand
              Text(
                product['merk']?['nama'] ?? '-',
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  color: themeProvider.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              // Price
              Text(
                _formatCurrency(product['harga_jual'] ?? 0),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4CAF50),
                  fontSize: isMobile ? 15 : 16,
                ),
              ),
              SizedBox(height: isMobile ? 6 : 8),
              // Stock Info
              Row(
                children: [
                  Icon(
                    Icons.inventory_2,
                    size: isMobile ? 12 : 14,
                    color: themeProvider.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Stock: $totalStok',
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

  Widget _buildProductListCard(dynamic product, bool isMobile) {
    final themeProvider = context.watch<ThemeProvider>();
    final totalStok = product['total_stok'] ?? 0;
    final stockColor = _getStockColor(totalStok);

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      color: themeProvider.surfaceColor,
      child: InkWell(
        onTap: () => _showProductDetail(product),
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
                  Icons.inventory_2_rounded,
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
                      product['nama'] ?? '-',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 14 : 16,
                        color: themeProvider.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isMobile ? 2 : 4),
                    Text(
                      product['kode'] ?? '-',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: themeProvider.textSecondary,
                      ),
                    ),
                    SizedBox(height: isMobile ? 4 : 6),
                    Row(
                      children: [
                        Icon(
                          Icons.store,
                          size: isMobile ? 14 : 16,
                          color: themeProvider.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product['merk']?['nama'] ?? '-',
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 12,
                            color: themeProvider.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.inventory_2,
                          size: isMobile ? 14 : 16,
                          color: themeProvider.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Stock: $totalStok',
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
              // Price & Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatCurrency(product['harga_jual'] ?? 0),
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
                      color: stockColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStockStatus(totalStok),
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 11,
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

  void _showProductDetail(dynamic product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductDetailSheet(
        product: product,
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
              Icons.inventory_2_rounded,
              size: isMobile ? 80 : 100,
              color: themeProvider.textTertiary.withOpacity(0.5),
            ),
            SizedBox(height: isMobile ? 16 : 24),
            Text(
              'No Products Found',
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
                  : 'No products available',
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

      final result = await ProductReportService.exportProductReport(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        stockStatus: _selectedStockStatus != 'Semua' ? _selectedStockStatus : null,
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

  Color _getStockColor(int stock) {
    if (stock == 0) {
      return const Color(0xFFF44336); // Red - Out of Stock
    } else if (stock <= 10) {
      return const Color(0xFFFF9800); // Orange - Low Stock
    } else {
      return const Color(0xFF4CAF50); // Green - In Stock
    }
  }

  String _getStockStatus(int stock) {
    if (stock == 0) {
      return 'Out of Stock';
    } else if (stock <= 10) {
      return 'Low Stock';
    } else {
      return 'In Stock';
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

// Product Detail Bottom Sheet
class _ProductDetailSheet extends StatelessWidget {
  final dynamic product;

  const _ProductDetailSheet({required this.product});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final totalStok = product['total_stok'] ?? 0;
    final stockColor = _getStockColor(totalStok);
    final stokList = product['stok'] ?? [];

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
                              'Product Detail',
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
                      // Product Info Card
                      _buildProductInfoCard(themeProvider, isMobile, stockColor),
                      SizedBox(height: isMobile ? 12 : 16),

                      // Brand Info
                      _buildInfoCard(
                        themeProvider,
                        isMobile,
                        'Brand',
                        product['merk']?['nama'] ?? '-',
                        Icons.store_rounded,
                        themeProvider.secondaryMain,
                      ),
                      SizedBox(height: isMobile ? 12 : 16),

                      // Price Card
                      _buildPriceCard(themeProvider, isMobile),
                      SizedBox(height: isMobile ? 12 : 16),

                      // Stock per Store Section
                      _buildStockSection(themeProvider, isMobile, stokList),
                      SizedBox(height: isMobile ? 12 : 16),

                      // Total Stock Summary
                      _buildTotalStockCard(themeProvider, isMobile, totalStok, stockColor),
                      SizedBox(height: isMobile ? 12 : 16),

                      // Total Value Card
                      _buildTotalValueCard(themeProvider, isMobile, totalStok),
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

  Widget _buildProductInfoCard(
    ThemeProvider themeProvider,
    bool isMobile,
    Color stockColor,
  ) {
    final totalStok = product['total_stok'] ?? 0;

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
                      'Product Name',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['nama'] ?? '-',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                  color: stockColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStockStatus(totalStok),
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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

  Widget _buildPriceCard(ThemeProvider themeProvider, bool isMobile) {
    final harga = product['harga_jual'] ?? product['harga_beli'] ?? 0;

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
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.attach_money_rounded,
              color: const Color(0xFF4CAF50),
              size: isMobile ? 18 : 20,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Price',
                style: TextStyle(
                  fontSize: isMobile ? 10 : 11,
                  color: themeProvider.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatCurrency(harga),
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

  Widget _buildStockSection(
    ThemeProvider themeProvider,
    bool isMobile,
    List<dynamic> stokList,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Stock per Store',
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
                '${stokList.length} ${stokList.length == 1 ? 'Store' : 'Stores'}',
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
        if (stokList.isEmpty)
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: themeProvider.surfaceColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: themeProvider.borderColor),
            ),
            child: Center(
              child: Text(
                'No stock information available',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  color: themeProvider.textSecondary,
                ),
              ),
            ),
          )
        else
          ...stokList.asMap().entries.map((entry) {
            final index = entry.key;
            final stok = entry.value;
            return _buildStockCard(themeProvider, isMobile, stok, index);
          }).toList(),
      ],
    );
  }

  Widget _buildStockCard(
    ThemeProvider themeProvider,
    bool isMobile,
    dynamic stok,
    int index,
  ) {
    final storeName = stok['toko']?['nama'] ?? 'Unknown Store';
    final stockAmount = stok['stok'] != null ? int.parse(stok['stok'].toString()) : 0;
    final stockColor = _getStockColor(stockAmount);

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
          // Store Icon
          Container(
            width: isMobile ? 32 : 36,
            height: isMobile ? 32 : 36,
            decoration: BoxDecoration(
              color: themeProvider.primaryMain.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.store_rounded,
                color: themeProvider.primaryMain,
                size: isMobile ? 16 : 18,
              ),
            ),
          ),
          SizedBox(width: isMobile ? 10 : 12),
          // Store Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeName,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: themeProvider.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isMobile ? 2 : 3),
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2,
                      size: isMobile ? 12 : 14,
                      color: themeProvider.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Stock: $stockAmount',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: themeProvider.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Stock Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 10,
              vertical: isMobile ? 4 : 5,
            ),
            decoration: BoxDecoration(
              color: stockColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getStockStatus(stockAmount),
              style: TextStyle(
                fontSize: isMobile ? 9 : 10,
                fontWeight: FontWeight.bold,
                color: stockColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalStockCard(
    ThemeProvider themeProvider,
    bool isMobile,
    int totalStok,
    Color stockColor,
  ) {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: stockColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2_rounded,
                  color: stockColor,
                  size: isMobile ? 20 : 24,
                ),
              ),
              SizedBox(width: isMobile ? 10 : 12),
              Text(
                'Total Stock',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            '$totalStok',
            style: TextStyle(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: stockColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalValueCard(
    ThemeProvider themeProvider,
    bool isMobile,
    int totalStok,
  ) {
    final harga = product['harga_jual'] ?? product['harga_beli'] ?? 0;
    final totalValue = totalStok * (harga is String ? double.parse(harga) : harga.toDouble());

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CAF50),
            const Color(0xFF4CAF50).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.attach_money_rounded,
                  color: Colors.white,
                  size: isMobile ? 20 : 24,
                ),
              ),
              SizedBox(width: isMobile ? 10 : 12),
              Text(
                'Total Nilai Stok',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Text(
            _formatCurrency(totalValue),
            style: TextStyle(
              fontSize: isMobile ? 16 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStockColor(int stock) {
    if (stock == 0) {
      return const Color(0xFFF44336); // Red - Out of Stock
    } else if (stock <= 10) {
      return const Color(0xFFFF9800); // Orange - Low Stock
    } else {
      return const Color(0xFF4CAF50); // Green - In Stock
    }
  }

  String _getStockStatus(int stock) {
    if (stock == 0) {
      return 'Out of Stock';
    } else if (stock <= 10) {
      return 'Low Stock';
    } else {
      return 'In Stock';
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
