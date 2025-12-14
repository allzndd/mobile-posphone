import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/theme_provider.dart';

class StokScreen extends StatefulWidget {
  const StokScreen({super.key});

  @override
  State<StokScreen> createState() => _StokScreenState();
}

class _StokScreenState extends State<StokScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _filterCategory = 'Semua';
  String _filterStatus = 'Semua';
  String _sortBy = 'Nama A-Z';
  bool _isGridView = false;

  final List<String> _categoryOptions = [
    'Semua',
    'Smartphone',
    'Tablet',
    'Aksesoris',
    'Audio',
    'Smartwatch',
    'Laptop',
  ];

  final List<String> _statusOptions = [
    'Semua',
    'Stok Aman',
    'Stok Menipis',
    'Stok Habis',
    'Overstock',
  ];

  final List<String> _sortOptions = [
    'Nama A-Z',
    'Nama Z-A',
    'Stok Terbanyak',
    'Stok Tersedikit',
    'Harga Tertinggi',
    'Harga Terendah',
  ];

  // Sample stock data
  final List<Map<String, dynamic>> _stockItems = [
    {
      'id': 'PRD001',
      'name': 'iPhone 15 Pro Max',
      'category': 'Smartphone',
      'currentStock': 25,
      'minStock': 10,
      'maxStock': 50,
      'price': 21999000,
      'location': 'Rak A-1',
      'supplier': 'PT Elektronik Jaya',
      'lastRestock': '2025-12-01',
      'status': 'Stok Aman',
      'color': AppTheme.successColor,
    },
    {
      'id': 'PRD002',
      'name': 'Samsung S24 Ultra',
      'category': 'Smartphone',
      'currentStock': 8,
      'minStock': 10,
      'maxStock': 40,
      'price': 19999000,
      'location': 'Rak A-2',
      'supplier': 'PT Elektronik Jaya',
      'lastRestock': '2025-11-28',
      'status': 'Stok Menipis',
      'color': AppTheme.warningColor,
    },
    {
      'id': 'PRD003',
      'name': 'AirPods Pro 2nd Gen',
      'category': 'Audio',
      'currentStock': 0,
      'minStock': 15,
      'maxStock': 60,
      'price': 3799000,
      'location': 'Rak C-3',
      'supplier': 'CV Aksesoris Handphone',
      'lastRestock': '2025-11-20',
      'status': 'Stok Habis',
      'color': AppTheme.errorColor,
    },
    {
      'id': 'PRD004',
      'name': 'iPad Pro 12.9"',
      'category': 'Tablet',
      'currentStock': 45,
      'minStock': 8,
      'maxStock': 30,
      'price': 18999000,
      'location': 'Rak B-1',
      'supplier': 'PT Elektronik Jaya',
      'lastRestock': '2025-12-03',
      'status': 'Overstock',
      'color': AppTheme.accentPurple,
    },
    {
      'id': 'PRD005',
      'name': 'Apple Watch Series 9',
      'category': 'Smartwatch',
      'currentStock': 18,
      'minStock': 12,
      'maxStock': 35,
      'price': 6999000,
      'location': 'Rak D-2',
      'supplier': 'UD Audio Premium',
      'lastRestock': '2025-11-30',
      'status': 'Stok Aman',
      'color': AppTheme.successColor,
    },
    {
      'id': 'PRD006',
      'name': 'Fast Charger 65W',
      'category': 'Aksesoris',
      'currentStock': 3,
      'minStock': 20,
      'maxStock': 100,
      'price': 499000,
      'location': 'Rak E-5',
      'supplier': 'PT Charger Solution',
      'lastRestock': '2025-11-15',
      'status': 'Stok Menipis',
      'color': AppTheme.warningColor,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredStock {
    return _stockItems.where((item) {
        final matchesSearch =
            item['name'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            item['id'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
        final matchesCategory =
            _filterCategory == 'Semua' || item['category'] == _filterCategory;
        final matchesStatus =
            _filterStatus == 'Semua' || item['status'] == _filterStatus;
        return matchesSearch && matchesCategory && matchesStatus;
      }).toList()
      ..sort((a, b) {
        switch (_sortBy) {
          case 'Nama A-Z':
            return a['name'].toString().compareTo(b['name'].toString());
          case 'Nama Z-A':
            return b['name'].toString().compareTo(a['name'].toString());
          case 'Stok Terbanyak':
            return (b['currentStock'] as int).compareTo(
              a['currentStock'] as int,
            );
          case 'Stok Tersedikit':
            return (a['currentStock'] as int).compareTo(
              b['currentStock'] as int,
            );
          case 'Harga Tertinggi':
            return (b['price'] as int).compareTo(a['price'] as int);
          case 'Harga Terendah':
            return (a['price'] as int).compareTo(b['price'] as int);
          default:
            return 0;
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;

    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(isDesktop)),
          SliverToBoxAdapter(child: _buildStatsCards(isDesktop)),
          SliverToBoxAdapter(child: _buildSearchAndSort(isDesktop)),
          SliverToBoxAdapter(child: _buildCategoryTabs(isDesktop)),
          SliverToBoxAdapter(child: _buildStatusTabs(isDesktop)),
          _buildStockList(isDesktop, isTablet),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [themeProvider.primaryMain, themeProvider.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: themeProvider.primaryMain.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isDesktop ? 12 : 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.analytics_rounded,
              color: Colors.white,
              size: isDesktop ? 28 : 24,
            ),
          ),
          SizedBox(width: isDesktop ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manajemen Stok',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 24 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Monitor & kelola inventori produk',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isDesktop ? 14 : 12,
                  ),
                ),
              ],
            ),
          ),
          if (isDesktop) ...[
            _buildHeaderAction(
              icon: Icons.add_box,
              label: 'Stok Masuk',
              onTap: () => _showStockIn(),
            ),
            const SizedBox(width: 8),
            _buildHeaderAction(
              icon: Icons.remove_circle_outline,
              label: 'Stok Keluar',
              onTap: () => _showStockOut(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();
    final totalItems = _stockItems.length;
    final totalStock = _stockItems.fold<int>(
      0,
      (sum, item) => sum + (item['currentStock'] as int),
    );
    final lowStock =
        _stockItems.where((item) => item['status'] == 'Stok Menipis').length;
    final outOfStock =
        _stockItems.where((item) => item['status'] == 'Stok Habis').length;

    return Container(
      margin: EdgeInsets.all(isDesktop ? 24 : 12),
      child:
          isDesktop
              ? Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Produk',
                      '$totalItems',
                      Icons.inventory_2_outlined,
                      themeProvider.primaryMain,
                      isDesktop,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Total Stok',
                      '$totalStock Unit',
                      Icons.widgets_outlined,
                      themeProvider.secondaryMain,
                      isDesktop,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Stok Menipis',
                      '$lowStock Produk',
                      Icons.warning_amber,
                      AppTheme.warningColor,
                      isDesktop,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Stok Habis',
                      '$outOfStock Produk',
                      Icons.inventory,
                      AppTheme.errorColor,
                      isDesktop,
                    ),
                  ),
                ],
              )
              : Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Produk',
                          '$totalItems',
                          Icons.inventory_2_outlined,
                          themeProvider.primaryMain,
                          isDesktop,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Total Stok',
                          '$totalStock',
                          Icons.widgets_outlined,
                          themeProvider.secondaryMain,
                          isDesktop,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Menipis',
                          '$lowStock',
                          Icons.warning_amber,
                          AppTheme.warningColor,
                          isDesktop,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          'Habis',
                          '$outOfStock',
                          Icons.inventory,
                          AppTheme.errorColor,
                          isDesktop,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDesktop,
  ) {
    final themeProvider = context.watch<ThemeProvider>();
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 12),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Icon(Icons.trending_up, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isDesktop ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: themeProvider.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndSort(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 12),
      color: themeProvider.surfaceColor,
      child:
          isDesktop
              ? Row(
                children: [
                  Expanded(child: _buildSearchBar()),
                  const SizedBox(width: 16),
                  _buildSortFilter(),
                  const SizedBox(width: 16),
                  _buildViewToggle(),
                ],
              )
              : Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildSortFilter()),
                      const SizedBox(width: 10),
                      _buildViewToggle(),
                    ],
                  ),
                ],
              ),
    );
  }

  Widget _buildCategoryTabs(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      height: isDesktop ? 60 : 50,
      color: themeProvider.surfaceColor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 12),
        itemCount: _categoryOptions.length,
        itemBuilder: (context, index) {
          final category = _categoryOptions[index];
          final isSelected = _filterCategory == category;
          return Padding(
            padding: EdgeInsets.only(
              right: 8,
              top: isDesktop ? 8 : 6,
              bottom: isDesktop ? 8 : 6,
            ),
            child: Material(
              color:
                  isSelected
                      ? themeProvider.secondaryMain
                      : themeProvider.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => setState(() => _filterCategory = category),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 20 : 16,
                    vertical: isDesktop ? 10 : 8,
                  ),
                  child: Center(
                    child: Text(
                      category,
                      style: TextStyle(
                        color:
                            isSelected
                                ? Colors.white
                                : themeProvider.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: isDesktop ? 14 : 13,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusTabs(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      height: isDesktop ? 60 : 50,
      color: themeProvider.backgroundColor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 12),
        itemCount: _statusOptions.length,
        itemBuilder: (context, index) {
          final status = _statusOptions[index];
          final isSelected = _filterStatus == status;

          // Determine color based on status
          Color getStatusColor() {
            switch (status) {
              case 'Stok Aman':
                return AppTheme.successColor;
              case 'Stok Menipis':
                return AppTheme.warningColor;
              case 'Stok Habis':
                return AppTheme.errorColor;
              case 'Overstock':
                return AppTheme.accentPurple;
              default:
                return AppTheme.primaryMain;
            }
          }

          final statusColor = getStatusColor();

          return Padding(
            padding: EdgeInsets.only(
              right: 8,
              top: isDesktop ? 8 : 6,
              bottom: isDesktop ? 8 : 6,
            ),
            child: Material(
              color: isSelected ? statusColor : themeProvider.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => setState(() => _filterStatus = status),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 20 : 16,
                    vertical: isDesktop ? 10 : 8,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (status != 'Semua') ...[
                          Icon(
                            _getStatusIcon(status),
                            color: isSelected ? Colors.white : statusColor,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          status,
                          style: TextStyle(
                            color:
                                isSelected
                                    ? Colors.white
                                    : themeProvider.textSecondary,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: isDesktop ? 14 : 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Stok Aman':
        return Icons.check_circle;
      case 'Stok Menipis':
        return Icons.warning_amber;
      case 'Stok Habis':
        return Icons.cancel;
      case 'Overstock':
        return Icons.trending_up;
      default:
        return Icons.circle;
    }
  }

  // Widget _buildFilterSection(bool isDesktop) {
  //   // This method is no longer used, kept for compatibility
  //   return const SizedBox.shrink();
  // }

  // Widget _buildCategoryFilter() {
  //   // This method is no longer used, kept for compatibility
  //   return const SizedBox.shrink();
  // }

  // Widget _buildStatusFilter() {
  //   // This method is no longer used, kept for compatibility
  //   return const SizedBox.shrink();
  // }

  Widget _buildSortFilter() {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sort, color: themeProvider.primaryMain, size: 20),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _sortBy,
            icon: Icon(Icons.arrow_drop_down, color: themeProvider.primaryMain),
            underline: const SizedBox(),
            style: TextStyle(color: themeProvider.textPrimary, fontSize: 14),
            onChanged: (value) => setState(() => _sortBy = value!),
            dropdownColor: themeProvider.surfaceColor,
            items:
                _sortOptions.map((option) {
                  return DropdownMenuItem(value: option, child: Text(option));
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Cari produk atau kode...',
          hintStyle: TextStyle(color: themeProvider.textTertiary),
          prefixIcon: Icon(Icons.search, color: themeProvider.primaryMain),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: themeProvider.textTertiary),
                    onPressed: () => setState(() => _searchQuery = ''),
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    final themeProvider = context.watch<ThemeProvider>();
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewButton(Icons.view_list_rounded, false),
          _buildViewButton(Icons.grid_view_rounded, true),
        ],
      ),
    );
  }

  Widget _buildViewButton(IconData icon, bool isGrid) {
    final themeProvider = context.watch<ThemeProvider>();
    final isActive = _isGridView == isGrid;
    return Material(
      color: isActive ? themeProvider.primaryMain : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => setState(() => _isGridView = isGrid),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: isActive ? Colors.white : themeProvider.textTertiary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildStockList(bool isDesktop, bool isTablet) {
    final items = _filteredStock;
    final themeProvider = context.watch<ThemeProvider>();

    if (items.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 80,
                color: themeProvider.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'Tidak ada stok',
                style: TextStyle(
                  fontSize: 18,
                  color: themeProvider.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isGridView) {
      final crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);
      return SliverPadding(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildStockGridCard(items[index], isDesktop),
            childCount: items.length,
          ),
        ),
      );
    } else {
      return SliverPadding(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildStockCard(items[index], isDesktop),
            childCount: items.length,
          ),
        ),
      );
    }
  }

  Widget _buildStockCard(Map<String, dynamic> item, bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();
    final stockPercentage =
        (item['currentStock'] / item['maxStock'] * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showStockDetail(item),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 20 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: item['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.inventory_2,
                        color: item['color'],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isDesktop ? 16 : 15,
                              color: themeProvider.textPrimary,
                            ),
                          ),
                          Text(
                            '${item['id']} • ${item['category']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: themeProvider.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: item['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['status'],
                        style: TextStyle(
                          color: item['color'],
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stok Tersedia',
                            style: TextStyle(
                              fontSize: 11,
                              color: themeProvider.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item['currentStock']} Unit',
                            style: TextStyle(
                              fontSize: isDesktop ? 20 : 18,
                              fontWeight: FontWeight.bold,
                              color: item['color'],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppTheme.borderLight,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Min / Max',
                            style: TextStyle(
                              fontSize: 11,
                              color: themeProvider.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item['minStock']} / ${item['maxStock']}',
                            style: TextStyle(
                              fontSize: isDesktop ? 16 : 14,
                              fontWeight: FontWeight.w600,
                              color: themeProvider.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kapasitas Stok',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                        Text(
                          '$stockPercentage%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: item['color'],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: stockPercentage / 100,
                        backgroundColor: AppTheme.borderLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          item['color'],
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      Icons.location_on_outlined,
                      item['location'],
                    ),
                    _buildInfoChip(
                      Icons.attach_money,
                      'Rp ${_formatPrice(item['price'])}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStockGridCard(Map<String, dynamic> item, bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();
    final stockPercentage =
        (item['currentStock'] / item['maxStock'] * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showStockDetail(item),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.inventory_2,
                        color: item['color'],
                        size: 20,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: item['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['status'].toString().replaceAll('Stok ', ''),
                        style: TextStyle(
                          color: item['color'],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: themeProvider.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item['category'],
                  style: TextStyle(
                    fontSize: 11,
                    color: themeProvider.textTertiary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${item['currentStock']} Unit',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: item['color'],
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: stockPercentage / 100,
                    backgroundColor: themeProvider.borderColor,
                    valueColor: AlwaysStoppedAnimation<Color>(item['color']),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$stockPercentage% Terisi',
                  style: TextStyle(
                    fontSize: 10,
                    color: themeProvider.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    final themeProvider = context.watch<ThemeProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: themeProvider.textTertiary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: themeProvider.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    final themeProvider = context.watch<ThemeProvider>();

    return FloatingActionButton.extended(
      onPressed: () => _showStockOptions(),
      backgroundColor: themeProvider.primaryMain,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'Kelola Stok',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _showStockDetail(Map<String, dynamic> item) {
    final themeProvider = context.read<ThemeProvider>();
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: item['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.inventory_2,
                            color: item['color'],
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: themeProvider.textPrimary,
                                ),
                              ),
                              Text(
                                item['id'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: themeProvider.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow('Kategori', item['category']),
                    _buildDetailRow('Status', item['status']),
                    _buildDetailRow('Lokasi', item['location']),
                    _buildDetailRow('Supplier', item['supplier']),
                    _buildDetailRow(
                      'Harga',
                      'Rp ${_formatPrice(item['price'])}',
                    ),
                    _buildDetailRow('Restock Terakhir', item['lastRestock']),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: item['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${item['currentStock']}',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: item['color'],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Stok Saat Ini',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: themeProvider.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: themeProvider.surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${item['minStock']} - ${item['maxStock']}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Min - Max',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: themeProvider.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showStockOut();
                            },
                            icon: const Icon(Icons.remove_circle_outline),
                            label: const Text('Kurangi'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showStockIn();
                            },
                            icon: const Icon(Icons.add_box),
                            label: const Text('Tambah'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeProvider.primaryMain,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final themeProvider = context.watch<ThemeProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: themeProvider.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: themeProvider.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStockOptions() {
    final themeProvider = context.read<ThemeProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: themeProvider.surfaceColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: themeProvider.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add_box,
                        color: AppTheme.successColor,
                        size: 24,
                      ),
                    ),
                    title: const Text(
                      'Stok Masuk',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Tambah stok produk'),
                    onTap: () {
                      Navigator.pop(context);
                      _showStockIn();
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.remove_circle_outline,
                        color: AppTheme.errorColor,
                        size: 24,
                      ),
                    ),
                    title: const Text(
                      'Stok Keluar',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Kurangi stok produk'),
                    onTap: () {
                      Navigator.pop(context);
                      _showStockOut();
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
    );
  }

  void _showStockIn() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.add_box,
                    color: AppTheme.successColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Stok Masuk'),
              ],
            ),
            content: const Text('Form tambah stok akan ditampilkan di sini'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                ),
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  void _showStockOut() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.remove_circle_outline,
                    color: AppTheme.errorColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Stok Keluar'),
              ],
            ),
            content: const Text('Form kurangi stok akan ditampilkan di sini'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }
}
