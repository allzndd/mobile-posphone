import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../config/theme_provider.dart';
import 'show.screen.dart';
import '../../services/stock_history_service.dart';
import '../../models/stock_history.dart';

class StockHistoryIndexScreen extends StatefulWidget {
  const StockHistoryIndexScreen({super.key});

  @override
  State<StockHistoryIndexScreen> createState() =>
      _StockHistoryIndexScreenState();
}

class _StockHistoryIndexScreenState extends State<StockHistoryIndexScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchTimer;
  String _searchQuery = '';
  String _selectedStore = 'All';
  String _selectedType = 'All';
  DateTimeRange? _selectedDateRange;
  bool _isLoading = false;
  List<StockLog> _historyData = [];
  List<Store> _stores = [];
  Map<String, dynamic>? _summary;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  final List<String> _typeOptions = ['All', 'masuk', 'keluar', 'adjustment'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistoryData();
    _loadStores();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadHistoryData() async {
    setState(() => _isLoading = true);
    try {
      // Build date range parameters
      String? startDate, endDate;
      if (_selectedDateRange != null) {
        startDate = _selectedDateRange!.start.toIso8601String().split('T')[0];
        endDate = _selectedDateRange!.end.toIso8601String().split('T')[0];
      }

      // Call API to get stock history
      final storeId = _getSelectedStoreId();
      final typeFilter = _selectedType != 'All' ? _selectedType : null;
      final searchFilter = _searchQuery.isNotEmpty ? _searchQuery : null;
      
      debugPrint('Stock History Filters: search="$searchFilter", store="$_selectedStore" (ID: $storeId), type="$typeFilter"');
      
      final result = await StockHistoryService.getStockHistory(
        page: _currentPage,
        perPage: 50,
        search: searchFilter,
        storeId: storeId,
        type: typeFilter,
        startDate: startDate,
        endDate: endDate,
      );

      debugPrint('Stock History API Response: $result');

      if (result['success'] == true) {
        final dynamic responseData = result['data'];

        // Handle both array and paginated response
        List<dynamic> historyData = [];
        if (responseData is List) {
          historyData = responseData;
        } else if (responseData is Map && responseData['data'] is List) {
          historyData = responseData['data'];
          // Handle pagination meta
          if (responseData['meta'] != null) {
            final meta = responseData['meta'];
            _hasMore = meta['current_page'] < meta['last_page'];
          }
        }

        debugPrint('History data count: ${historyData.length}');

        // Convert to StockLog models
        if (_currentPage == 1) {
          _historyData.clear();
        }
        
        for (var json in historyData) {
          try {
            _historyData.add(StockLog.fromJson(json));
          } catch (e) {
            debugPrint('Error parsing stock log: $e');
          }
        }

        _error = null;
      } else {
        final errorMsg = result['message'] ?? 'Failed to load stock history';
        debugPrint('API Error: $errorMsg');
        _error = errorMsg;
        
        // If authentication error, navigate to login
        if (errorMsg.toLowerCase().contains('unauthenticated') || 
            errorMsg.toLowerCase().contains('unauthorized')) {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
            return;
          }
        }
        
        if (_currentPage == 1) {
          _historyData.clear();
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Exception loading history data: $e');
      debugPrint('Stack trace: $stackTrace');
      _error = 'Error loading data: $e';
      if (_currentPage == 1) {
        _historyData.clear();
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStores() async {
    try {
      final result = await StockHistoryService.getStores();
      
      if (result['success'] == true) {
        final List<dynamic> storesData = result['data'] ?? [];
        _stores = storesData.map((json) => Store.fromJson(json)).toList();
      } else {
        debugPrint('Failed to load stores: ${result['message']}');
        _stores = [];
      }
    } catch (e) {
      debugPrint('Error loading stores: $e');
      _stores = [];
    }
  }

  String? _getSelectedStoreId() {
    if (_selectedStore == 'All') {
      return null;
    }
    
    // Find store by name and return its ID
    final store = _stores.firstWhere(
      (store) => store.nama == _selectedStore,
      orElse: () => Store(id: 0, nama: '', alamat: ''),
    );
    
    return store.id != 0 ? store.id.toString() : null;
  }

  void _onSearchChanged(String value) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadHistoryData();
      }
    });
  }

  List<StockLog> get _filteredHistoryData {
    // API already handles filtering, so just return the data
    return _historyData;
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
          'Stock History',
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
          tabs: const [Tab(text: 'History'), Tab(text: 'Summary')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildHistoryTab(), _buildSummaryTab()],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _currentPage = 1;
          _error = null;
        });
        await Future.wait([
          _loadHistoryData(),
          _loadStores(),
        ]);
      },
      child: Column(
        children: [
          _buildFilters(),
          
          // Error display
          if (_error != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _error = null);
                      _loadHistoryData();
                    },
                    child: Text('Retry', style: TextStyle(color: Colors.red.shade600)),
                  ),
                ],
              ),
            ),
            
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildHistoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    final filtered = _filteredHistoryData;
    final totalStockIn = filtered
        .where((h) => h.tipe == 'masuk')
        .fold<int>(0, (sum, h) => sum + h.perubahan.abs());
    final totalStockOut = filtered
        .where((h) => h.tipe == 'keluar')
        .fold<int>(0, (sum, h) => sum + h.perubahan.abs());
    final totalAdjustments =
        filtered.where((h) => h.tipe == 'adjustment').length;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _currentPage = 1;
          _error = null;
        });
        await Future.wait([
          _loadHistoryData(),
          _loadStores(),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          children: [
            _buildSummaryCard(
              'Total Entries',
              '${filtered.length}',
              Icons.list,
              Colors.blue,
              isMobile,
            ),
            _buildSummaryCard(
              'Stock In',
              '$totalStockIn',
              Icons.add_circle,
              Colors.green,
              isMobile,
            ),
            _buildSummaryCard(
              'Stock Out',
              '$totalStockOut',
              Icons.remove_circle,
              Colors.red,
              isMobile,
            ),
            _buildSummaryCard(
              'Adjustments',
              '$totalAdjustments',
              Icons.edit,
              Colors.orange,
              isMobile,
            ),
            SizedBox(height: isMobile ? 12 : 16),
            _buildDateRangeSummary(isMobile),
          ],
        ),
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

  Widget _buildDateRangeSummary(bool isMobile) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Period',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.textPrimary,
            ),
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            _selectedDateRange == null
                ? 'All time'
                : '${_formatDate(_selectedDateRange!.start.toIso8601String())} - ${_formatDate(_selectedDateRange!.end.toIso8601String())}',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: themeProvider.textSecondary,
            ),
          ),
          SizedBox(height: isMobile ? 10 : 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectDateRange,
              child: Text(
                'Change Date Range',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final themeProvider = context.watch<ThemeProvider>();
    final storeOptions = [
      'All',
      ..._stores.map((store) => store.nama).toList(),
    ];
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        children: [
          if (isMobile)
            // Mobile layout - stacked vertically
            Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _currentPage = 1;
                    });
                    _onSearchChanged(value);
                  },
                  style: TextStyle(color: themeProvider.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    hintStyle: TextStyle(color: themeProvider.textSecondary),
                    prefixIcon: Icon(
                      Icons.search,
                      color: themeProvider.textSecondary,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: themeProvider.textSecondary,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _currentPage = 1;
                              });
                              _loadHistoryData();
                            },
                          )
                        : null,
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
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStore,
                        style: TextStyle(color: themeProvider.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Store',
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
                        items:
                            storeOptions.map<DropdownMenuItem<String>>((store) {
                              return DropdownMenuItem<String>(
                                value: store,
                                child: Text(
                                  store,
                                  style: TextStyle(
                                    color: themeProvider.textPrimary,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged:
                            (value) {
                              setState(() {
                                _selectedStore = value ?? 'All';
                                _currentPage = 1;
                              });
                              _loadHistoryData();
                            },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedType,
                        style: TextStyle(color: themeProvider.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Type',
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
                        items:
                            _typeOptions.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type == 'All' ? 'All' : type.toUpperCase(),
                                  style: TextStyle(
                                    color: themeProvider.textPrimary,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged:
                            (value) {
                              setState(() {
                                _selectedType = value ?? 'All';
                                _currentPage = 1;
                              });
                              _loadHistoryData();
                            },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _selectDateRange,
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _selectedDateRange == null
                          ? 'Select Date Range'
                          : 'Date Range Selected',
                      style: TextStyle(color: themeProvider.primaryMain),
                    ),
                  ),
                ),
              ],
            )
          else
            // Desktop layout
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            _currentPage = 1;
                          });
                          _onSearchChanged(value);
                        },
                        style: TextStyle(color: themeProvider.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: TextStyle(
                            color: themeProvider.textSecondary,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: themeProvider.textSecondary,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: themeProvider.textSecondary,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                      _currentPage = 1;
                                    });
                                    _loadHistoryData();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: themeProvider.surfaceColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStore,
                        style: TextStyle(color: themeProvider.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Store',
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
                        items:
                            storeOptions.map<DropdownMenuItem<String>>((store) {
                              return DropdownMenuItem<String>(
                                value: store,
                                child: Text(
                                  store,
                                  style: TextStyle(
                                    color: themeProvider.textPrimary,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged:
                            (value) {
                              setState(() {
                                _selectedStore = value ?? 'All';
                                _currentPage = 1;
                              });
                              _loadHistoryData();
                            },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedType,
                        style: TextStyle(color: themeProvider.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Type',
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
                        items:
                            _typeOptions.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type == 'All'
                                      ? 'All Types'
                                      : type.toUpperCase(),
                                  style: TextStyle(
                                    color: themeProvider.textPrimary,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged:
                            (value) {
                              setState(() {
                                _selectedType = value ?? 'All';
                                _currentPage = 1;
                              });
                              _loadHistoryData();
                            },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectDateRange,
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          _selectedDateRange == null
                              ? 'Date Range'
                              : 'Selected',
                          style: TextStyle(color: themeProvider.primaryMain),
                        ),
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

  Widget _buildHistoryList() {
    final themeProvider = context.watch<ThemeProvider>();
    final historyItems = _filteredHistoryData;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (historyItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: themeProvider.textSecondary),
            const SizedBox(height: 16),
            Text(
              _error != null ? 'Failed to load data' : 
              _isLoading ? 'Loading...' :
              'No stock history records found',
              style: TextStyle(
                fontSize: 18,
                color: themeProvider.textSecondary,
              ),
            ),
            if (_searchQuery.isNotEmpty || _selectedStore != 'All' || 
                _selectedType != 'All' || _selectedDateRange != null) ...[
              const SizedBox(height: 8),
              Text(
                'Try adjusting your filters',
                style: TextStyle(
                  fontSize: 14,
                  color: themeProvider.textSecondary,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      itemCount: historyItems.length,
      itemBuilder:
          (context, index) => _buildHistoryCard(historyItems[index], isMobile),
    );
  }

  Widget _buildHistoryCard(StockLog history, bool isMobile) {
    final themeProvider = context.watch<ThemeProvider>();
    final change = history.perubahan;
    final type = history.tipe;

    Color typeColor = Colors.blue;
    IconData typeIcon = Icons.swap_horiz;

    switch (type) {
      case 'masuk':
        typeColor = Colors.green;
        typeIcon = Icons.add_circle;
        break;
      case 'keluar':
        typeColor = Colors.red;
        typeIcon = Icons.remove_circle;
        break;
      case 'adjustment':
        typeColor = Colors.orange;
        typeIcon = Icons.edit;
        break;
    }

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      color: themeProvider.surfaceColor,
      child: InkWell(
        onTap: () => _showHistoryDetail(history),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: isMobile ? 35 : 40,
                    height: isMobile ? 35 : 40,
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      typeIcon,
                      color: typeColor,
                      size: isMobile ? 18 : 20,
                    ),
                  ),
                  SizedBox(width: isMobile ? 10 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          history.produk?.nama ?? 'Unknown Product',
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
                          '${history.produk?.merk?.nama ?? 'Unknown Brand'} • ${history.toko?.nama ?? 'Unknown Store'}',
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 14,
                            color: themeProvider.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        change >= 0 ? '+$change' : '$change',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: typeColor,
                        ),
                      ),
                      Text(
                        _formatDateTime(history.createdAt.toIso8601String()),
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 12,
                          color: themeProvider.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 6 : 8),
              if (isMobile)
                // Mobile layout - more compact
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${history.stokSebelum} → ${history.stokSesudah}',
                      style: TextStyle(
                        fontSize: 12,
                        color: themeProvider.textSecondary,
                      ),
                    ),
                    if (history.keterangan != null &&
                        history.keterangan!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        history.keterangan!,
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: themeProvider.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                )
              else
                // Desktop layout
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Before: ${history.stokSebelum} → After: ${history.stokSesudah}',
                          style: TextStyle(
                            fontSize: 14,
                            color: themeProvider.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (history.keterangan != null &&
                        history.keterangan!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        history.keterangan!,
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: themeProvider.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHistoryDetail(StockLog history) {
    StockHistoryDetailScreen.show(context, history.toJson());
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _currentPage = 1;
      });
      _loadHistoryData();
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
