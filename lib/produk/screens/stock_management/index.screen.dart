import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme_provider.dart';
import '../../models/stock_management.dart';
import '../../services/management_service.dart';
import 'edit.screen.dart';
import 'show.screen.dart';

class StockIndexScreen extends StatefulWidget {
  const StockIndexScreen({super.key});

  @override
  State<StockIndexScreen> createState() => _StockIndexScreenState();
}

class _StockIndexScreenState extends State<StockIndexScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedStore = 'All';
  String _selectedStatus = 'All';
  final ScrollController _scrollController = ScrollController();
  
  // Local state management
  List<ProdukStok> _stocks = [];
  Map<int, Map<String, dynamic>> _productsMap = {};
  Map<int, Map<String, dynamic>> _storesMap = {};
  bool _isLoading = false;
  String? _error;
  
  // Summary stats
  int _totalProducts = 0;
  int _totalStock = 0;
  int _lowStockCount = 0;
  int _outOfStockCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
    
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Call API to get stocks
      final result = await StockService.getStocks(
        page: 1,
        perPage: 100,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      
      // Debug: print response
      debugPrint('Stock API Response: $result');
      
      if (result['success'] == true) {
        final dynamic responseData = result['data'];
        
        // Handle both array and paginated response
        List<dynamic> stocksData = [];
        if (responseData is List) {
          stocksData = responseData;
        } else if (responseData is Map && responseData['data'] is List) {
          stocksData = responseData['data'];
        }
        
        debugPrint('Stocks data count: ${stocksData.length}');
        
        // Convert to ProdukStok models
        _stocks = [];
        for (var json in stocksData) {
          try {
            // Skip if product data is null
            if (json['produk'] == null) {
              debugPrint('Skipping stock ${json['id']}: product is null');
              continue;
            }
            _stocks.add(ProdukStok.fromJson(json));
          } catch (e) {
            debugPrint('Error parsing stock: $e');
          }
        }
        
        // Build products and stores maps from stock data
        _productsMap.clear();
        _storesMap.clear();
        
        for (var stockData in stocksData) {
          // Add product to map if exists
          if (stockData['produk'] != null) {
            final produkId = stockData['pos_produk_id'] ?? stockData['posProdukId'];
            if (produkId != null) {
              _productsMap[produkId] = stockData['produk'];
            }
          }
          
          // Add store to map if exists
          if (stockData['toko'] != null) {
            final tokoId = stockData['pos_toko_id'] ?? stockData['posTokoId'];
            if (tokoId != null) {
              _storesMap[tokoId] = stockData['toko'];
            }
          }
        }
        
        // Calculate summary stats
        _totalProducts = _stocks.length;
        _totalStock = _stocks.fold(0, (sum, stock) => sum + stock.stok);
        _lowStockCount = _stocks.where((s) => s.stok > 0 && s.stok <= 5).length;
        _outOfStockCount = _stocks.where((s) => s.stok == 0).length;
        
        _error = null;
      } else {
        final errorMsg = result['message'] ?? 'Failed to load stocks';
        debugPrint('API Error: $errorMsg');
        _error = errorMsg;
        _stocks = [];
        _totalProducts = 0;
        _totalStock = 0;
        _lowStockCount = 0;
        _outOfStockCount = 0;
      }
    } catch (e, stackTrace) {
      debugPrint('Exception loading data: $e');
      debugPrint('Stack trace: $stackTrace');
      _error = 'Error loading data: $e';
      _stocks = [];
      _totalProducts = 0;
      _totalStock = 0;
      _lowStockCount = 0;
      _outOfStockCount = 0;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // TODO: Implement pagination
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    _applyFilters();
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedStatus = filter;
    });
    _applyFilters();
  }

  void _applyFilters() {
    // TODO: Implement filtering logic
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.surfaceColor,
        elevation: 0,
        title: Text(
          'Stock Management',
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: themeProvider.textPrimary),
        bottom: TabBar(
          controller: _tabController,
          labelColor: themeProvider.textPrimary,
          unselectedLabelColor: themeProvider.textSecondary,
          indicatorColor: themeProvider.primaryMain,
          tabs: const [
            Tab(text: 'Stock List'),
            Tab(text: 'Summary'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStockListTab(),
          _buildSummaryTab(),
        ],
      ),
    );
  }

  Widget _buildStockListTab() {
    return RefreshIndicator(
      onRefresh: () => _loadData(),
      child: Column(
        children: [
          _buildSearchAndFilter(),
          _buildStockStats(),
          Expanded(
            child: _isLoading && _stocks.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _buildStockList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return RefreshIndicator(
      onRefresh: () => _loadData(),
      child: _isLoading && _stocks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _stocks.isEmpty
              ? const Center(
                  child: Text('No summary data available'),
                )
              : _buildSummaryContent(),
    );
  }

  Widget _buildSummaryContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        children: [
          _buildSummaryCard(
            'Total Products',
            '$_totalProducts',
            Icons.inventory,
            Colors.blue,
            isMobile,
          ),
          _buildSummaryCard(
            'Total Stock',
            '$_totalStock',
            Icons.warehouse,
            Colors.green,
            isMobile,
          ),
          _buildSummaryCard(
            'Low Stock',
            '$_lowStockCount',
            Icons.warning,
            Colors.orange,
            isMobile,
          ),
          _buildSummaryCard(
            'Out of Stock',
            '$_outOfStockCount',
            Icons.error,
            Colors.red,
            isMobile,
          ),
          const SizedBox(height: 20),
          _buildHealthIndicator(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isMobile,
  ) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? 50 : 60,
            height: isMobile ? 50 : 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: isMobile ? 24 : 32),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isMobile ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textPrimary,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: themeProvider.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthIndicator() {
    final themeProvider = context.watch<ThemeProvider>();
    
    // Calculate health percentage: (stocks not out - low stocks) / total * 100
    final healthyStock = _totalProducts - _outOfStockCount - _lowStockCount;
    final healthPercentage = _totalProducts > 0 
        ? (healthyStock / _totalProducts * 100).clamp(0, 100)
        : 0.0;
    
    Color healthColor = Colors.red;
    String healthText = 'Poor';
    
    if (healthPercentage >= 80) {
      healthColor = Colors.green;
      healthText = 'Excellent';
    } else if (healthPercentage >= 60) {
      healthColor = Colors.blue;
      healthText = 'Good';
    } else if (healthPercentage >= 40) {
      healthColor = Colors.orange;
      healthText = 'Fair';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Column(
        children: [
          Text(
            'Stock Health',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: themeProvider.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: healthPercentage / 100,
                    strokeWidth: 8,
                    backgroundColor: themeProvider.borderColor,
                    valueColor: AlwaysStoppedAnimation<Color>(healthColor),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${healthPercentage.toInt()}%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: healthColor,
                      ),
                    ),
                    Text(
                      healthText,
                      style: TextStyle(
                        fontSize: 14,
                        color: themeProvider.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        children: [
          if (isMobile)
            Column(
              children: [
                TextField(
                  onChanged: _onSearchChanged,
                  style: TextStyle(
                    color: themeProvider.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    hintStyle: TextStyle(
                      color: themeProvider.textSecondary,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: themeProvider.textSecondary,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: themeProvider.surfaceColor,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  style: TextStyle(
                    color: themeProvider.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Stock Status',
                    labelStyle: TextStyle(
                      color: themeProvider.textSecondary,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: themeProvider.surfaceColor,
                  ),
                  dropdownColor: themeProvider.surfaceColor,
                  items: [
                    DropdownMenuItem(
                      value: 'All', 
                      child: Text(
                        'All',
                        style: TextStyle(
                          color: themeProvider.textPrimary,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'in_stock', 
                      child: Text(
                        'In Stock',
                        style: TextStyle(
                          color: themeProvider.textPrimary,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'low_stock', 
                      child: Text(
                        'Low Stock',
                        style: TextStyle(
                          color: themeProvider.textPrimary,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'out_of_stock', 
                      child: Text(
                        'Out of Stock',
                        style: TextStyle(
                          color: themeProvider.textPrimary,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) => _onFilterChanged(value ?? 'All'),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    onChanged: _onSearchChanged,
                    style: TextStyle(
                      color: themeProvider.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search stocks...',
                      hintStyle: TextStyle(
                        color: themeProvider.textSecondary,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: themeProvider.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: themeProvider.surfaceColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    style: TextStyle(
                      color: themeProvider.textPrimary,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Status',
                      labelStyle: TextStyle(
                        color: themeProvider.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: themeProvider.surfaceColor,
                    ),
                    dropdownColor: themeProvider.surfaceColor,
                    items: [
                      DropdownMenuItem(
                        value: 'All', 
                        child: Text(
                          'All',
                          style: TextStyle(
                            color: themeProvider.textPrimary,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'in_stock', 
                        child: Text(
                          'In Stock',
                          style: TextStyle(
                            color: themeProvider.textPrimary,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'low_stock', 
                        child: Text(
                          'Low Stock',
                          style: TextStyle(
                            color: themeProvider.textPrimary,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'out_of_stock', 
                        child: Text(
                          'Out of Stock',
                          style: TextStyle(
                            color: themeProvider.textPrimary,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) => _onFilterChanged(value ?? 'All'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStockStats() {
    final themeProvider = context.watch<ThemeProvider>();
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

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
        children: [
          Expanded(
            child: _buildStatItem(
              Icons.inventory,
              'Items',
              '$_totalProducts',
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
              Icons.warehouse,
              'Total',
              '$_totalStock',
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
              Icons.warning,
              'Low',
              '$_lowStockCount',
              Colors.orange,
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
              Icons.error,
              'Empty',
              '$_outOfStockCount',
              Colors.red,
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
        Icon(icon, color: color, size: isMobile ? 18 : 20),
        SizedBox(height: isMobile ? 2 : 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: themeProvider.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 9 : 10,
            color: themeProvider.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStockList() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _loadData(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_stocks.isEmpty && !_isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No stock items found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 12 : 16,
        0,
        isMobile ? 12 : 16,
        80,
      ),
      itemCount: _stocks.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _stocks.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final stock = _stocks[index];
        return _buildStockCard(stock, isMobile);
      },
    );
  }

  Widget _buildStockCard(ProdukStok stock, bool isMobile) {
    final themeProvider = context.watch<ThemeProvider>();
    
    // Skip rendering if product data is null
    final productData = _productsMap[stock.posProdukId];
    if (productData == null) {
      return const SizedBox.shrink();
    }
    
    Color statusColor = _getStatusColor(stock);
    String statusText = _getStockStatus(stock);
    String displayName = _getDisplayName(stock);
    String specs = _getProductSpecs(stock);
    final storeData = _storesMap[stock.posTokoId];

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      color: themeProvider.surfaceColor,
      child: InkWell(
        onTap: () => _showStockDetail(stock),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Row(
            children: [
              Container(
                width: isMobile ? 40 : 50,
                height: isMobile ? 40 : 50,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getStatusIcon(stock),
                  color: statusColor,
                  size: isMobile ? 20 : 24,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 14 : 16,
                        color: themeProvider.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isMobile ? 2 : 4),
                    if (specs.isNotEmpty) ...[
                      Text(
                        specs,
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 14,
                          color: themeProvider.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                    ],
                    if (storeData != null)
                      Text(
                        'Store: ${storeData['nama']}',
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 12,
                          color: themeProvider.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${stock.stok}',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 6 : 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 9 : 10,
                        fontWeight: FontWeight.w500,
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

  Color _getStatusColor(ProdukStok stock) {
    if (stock.stok == 0) return Colors.red;
    if (stock.stok <= 5) return Colors.orange;
    return Colors.green;
  }

  IconData _getStatusIcon(ProdukStok stock) {
    if (stock.stok == 0) return Icons.remove_shopping_cart;
    if (stock.stok <= 5) return Icons.warning;
    return Icons.check_circle;
  }
  
  String _getStockStatus(ProdukStok stock) {
    if (stock.stok == 0) return 'Out of Stock';
    if (stock.stok <= 5) return 'Low Stock';
    return 'In Stock';
  }
  
  String _getDisplayName(ProdukStok stock) {
    final product = _productsMap[stock.posProdukId];
    if (product != null) {
      // Product name already includes brand name, use it directly
      return product['nama'] ?? 'Unknown Product';
    }
    return 'Unknown Product';
  }
  
  String _getProductSpecs(ProdukStok stock) {
    final product = _productsMap[stock.posProdukId];
    if (product != null) {
      List<String> specs = [];
      if (product['warna'] != null) specs.add(product['warna']);
      if (product['penyimpanan'] != null) specs.add('${product['penyimpanan']}GB');
      return specs.join(' • ');
    }
    return '';
  }

  void _showStockDetail(ProdukStok stock) {
    // Get product and store data
    final productData = _productsMap[stock.posProdukId];
    final storeData = _storesMap[stock.posTokoId];

    // Show the detail screen
    StockDetailScreen.show(
      context,
      stock,
      productData: productData,
      storeData: storeData,
    );
  }

  void _navigateToEdit(ProdukStok stock) async {
    final productData = _productsMap[stock.posProdukId];
    final storeData = _storesMap[stock.posTokoId];
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockEditScreen(
          stock: stock,
          productData: productData,
          storeData: storeData,
        ),
      ),
    );

    if (result != null && mounted) {
      await _loadData();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}