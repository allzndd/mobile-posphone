import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/theme_provider.dart';

class ProdukScreen extends StatefulWidget {
  const ProdukScreen({super.key});

  @override
  State<ProdukScreen> createState() => _ProdukScreenState();
}

class _ProdukScreenState extends State<ProdukScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  String _sortBy = 'Terbaru';
  bool _isGridView = false;

  final List<String> _categories = [
    'Semua',
    'Smartphone',
    'Aksesoris',
    'Audio',
    'Charger',
    'Case',
  ];

  final List<String> _sortOptions = [
    'Terbaru',
    'Nama A-Z',
    'Nama Z-A',
    'Harga Terendah',
    'Harga Tertinggi',
    'Stok Terbanyak',
  ];

  // Sample product data
  final List<Map<String, dynamic>> _products = [
    {
      'id': 1,
      'name': 'iPhone 15 Pro Max',
      'category': 'Smartphone',
      'price': 21999000,
      'stock': 15,
      'sold': 45,
      'image': 'https://via.placeholder.com/150',
      'status': 'Tersedia',
    },
    {
      'id': 2,
      'name': 'Samsung Galaxy S24 Ultra',
      'category': 'Smartphone',
      'price': 19999000,
      'stock': 8,
      'sold': 32,
      'image': 'https://via.placeholder.com/150',
      'status': 'Tersedia',
    },
    {
      'id': 3,
      'name': 'AirPods Pro 2nd Gen',
      'category': 'Audio',
      'price': 3799000,
      'stock': 25,
      'sold': 89,
      'image': 'https://via.placeholder.com/150',
      'status': 'Tersedia',
    },
    {
      'id': 4,
      'name': 'Case iPhone Clear',
      'category': 'Case',
      'price': 299000,
      'stock': 50,
      'sold': 120,
      'image': 'https://via.placeholder.com/150',
      'status': 'Tersedia',
    },
    {
      'id': 5,
      'name': 'Fast Charger 65W',
      'category': 'Charger',
      'price': 499000,
      'stock': 0,
      'sold': 67,
      'image': 'https://via.placeholder.com/150',
      'status': 'Habis',
    },
    {
      'id': 6,
      'name': 'Screen Protector Premium',
      'category': 'Aksesoris',
      'price': 149000,
      'stock': 100,
      'sold': 234,
      'image': 'https://via.placeholder.com/150',
      'status': 'Tersedia',
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

  List<Map<String, dynamic>> get _filteredProducts {
    var filtered =
        _products.where((product) {
          final matchesSearch = product['name']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
          final matchesCategory =
              _selectedCategory == 'Semua' ||
              product['category'] == _selectedCategory;
          return matchesSearch && matchesCategory;
        }).toList();

    // Sorting
    switch (_sortBy) {
      case 'Nama A-Z':
        filtered.sort((a, b) => a['name'].compareTo(b['name']));
        break;
      case 'Nama Z-A':
        filtered.sort((a, b) => b['name'].compareTo(a['name']));
        break;
      case 'Harga Terendah':
        filtered.sort((a, b) => a['price'].compareTo(b['price']));
        break;
      case 'Harga Tertinggi':
        filtered.sort((a, b) => b['price'].compareTo(a['price']));
        break;
      case 'Stok Terbanyak':
        filtered.sort((a, b) => b['stock'].compareTo(a['stock']));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(isDesktop)),
          SliverToBoxAdapter(child: _buildSearchAndFilter(isDesktop)),
          SliverToBoxAdapter(child: _buildCategoryTabs(isDesktop)),
          SliverToBoxAdapter(child: _buildStatsBar(isDesktop)),
          _buildProductListSliver(isDesktop, isTablet),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
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
              Icons.inventory_2_rounded,
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
                  'Manajemen Produk',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 24 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_products.length} produk terdaftar',
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
              icon: Icons.file_download_outlined,
              label: 'Export',
              onTap: () {},
            ),
            const SizedBox(width: 8),
            _buildHeaderAction(
              icon: Icons.print_outlined,
              label: 'Print',
              onTap: () {},
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

  Widget _buildSearchAndFilter(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      color: themeProvider.surfaceColor,
      child:
          isDesktop
              ? Row(
                children: [
                  Expanded(child: _buildSearchBar()),
                  const SizedBox(width: 16),
                  _buildSortDropdown(),
                  const SizedBox(width: 16),
                  _buildViewToggle(),
                ],
              )
              : Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildSortDropdown()),
                      const SizedBox(width: 12),
                      _buildViewToggle(),
                    ],
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
          hintText: 'Cari produk...',
          hintStyle: TextStyle(color: themeProvider.textTertiary),
          prefixIcon: Icon(
            Icons.search,
            color: context.read<ThemeProvider>().primaryMain,
          ),
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

  Widget _buildSortDropdown() {
    final themeProvider = context.watch<ThemeProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: DropdownButton<String>(
        value: _sortBy,
        icon: Icon(
          Icons.arrow_drop_down,
          color: context.read<ThemeProvider>().primaryMain,
        ),
        underline: const SizedBox(),
        isExpanded: false,
        style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        onChanged: (value) => setState(() => _sortBy = value!),
        items:
            _sortOptions.map((option) {
              return DropdownMenuItem(value: option, child: Text(option));
            }).toList(),
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
        children: [
          _buildViewButton(Icons.list_rounded, false),
          _buildViewButton(Icons.grid_view_rounded, true),
        ],
      ),
    );
  }

  Widget _buildViewButton(IconData icon, bool isGrid) {
    final themeProvider = context.watch<ThemeProvider>();
    final isActive = _isGridView == isGrid;
    return Material(
      color:
          isActive
              ? context.read<ThemeProvider>().primaryMain
              : Colors.transparent,
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

  Widget _buildCategoryTabs(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      height: isDesktop ? 60 : 56,
      color: themeProvider.surfaceColor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            child: Material(
              color:
                  isSelected
                      ? context.read<ThemeProvider>().primaryMain
                      : themeProvider.cardColor,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => setState(() => _selectedCategory = category),
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

  Widget _buildStatsBar(bool isDesktop) {
    final totalStock = _products.fold<int>(
      0,
      (sum, p) => sum + (p['stock'] as int),
    );
    final totalSold = _products.fold<int>(
      0,
      (sum, p) => sum + (p['sold'] as int),
    );
    final outOfStock = _products.where((p) => p['stock'] == 0).length;

    return Container(
      margin: EdgeInsets.all(isDesktop ? 24 : 16),
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryLight.withOpacity(0.2),
            AppTheme.secondaryLight.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryLight.withOpacity(0.3)),
      ),
      child:
          isDesktop
              ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    Icons.inventory_rounded,
                    'Total Produk',
                    '${_products.length}',
                    AppTheme.primaryMain,
                  ),
                  _buildStatDivider(),
                  _buildStatItem(
                    Icons.shopping_bag_outlined,
                    'Terjual',
                    '$totalSold',
                    AppTheme.successColor,
                  ),
                  _buildStatDivider(),
                  _buildStatItem(
                    Icons.warehouse_outlined,
                    'Total Stok',
                    '$totalStock',
                    AppTheme.accentOrange,
                  ),
                  _buildStatDivider(),
                  _buildStatItem(
                    Icons.warning_amber_rounded,
                    'Stok Habis',
                    '$outOfStock',
                    AppTheme.errorColor,
                  ),
                ],
              )
              : Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          Icons.inventory_rounded,
                          'Produk',
                          '${_products.length}',
                          AppTheme.primaryMain,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatItem(
                          Icons.shopping_bag_outlined,
                          'Terjual',
                          '$totalSold',
                          AppTheme.successColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          Icons.warehouse_outlined,
                          'Stok',
                          '$totalStock',
                          AppTheme.accentOrange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatItem(
                          Icons.warning_amber_rounded,
                          'Habis',
                          '$outOfStock',
                          AppTheme.errorColor,
                        ),
                      ),
                    ],
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
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final themeProvider = context.watch<ThemeProvider>();
        final isCompact = constraints.maxWidth < 150;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isCompact ? 6 : 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: isCompact ? 16 : 20),
            ),
            SizedBox(width: isCompact ? 8 : 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: isCompact ? 10 : 12,
                      color: themeProvider.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: isCompact ? 14 : 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 40, width: 1, color: AppTheme.borderLight);
  }

  Widget _buildProductList(bool isDesktop, bool isTablet) {
    final themeProvider = context.watch<ThemeProvider>();
    final products = _filteredProducts;

    if (products.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 80,
                color: themeProvider.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'Tidak ada produk ditemukan',
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
            (context, index) => _buildProductGridCard(products[index]),
            childCount: products.length,
          ),
        ),
      );
    } else {
      return SliverPadding(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildProductListCard(products[index]),
            childCount: products.length,
          ),
        ),
      );
    }
  }

  Widget _buildProductListSliver(bool isDesktop, bool isTablet) {
    return _buildProductList(isDesktop, isTablet);
  }

  Widget _buildProductGridCard(Map<String, dynamic> product) {
    final themeProvider = context.watch<ThemeProvider>();

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
          onTap: () => _showProductDetail(product),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: themeProvider.cardColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.phone_android,
                          size: 60,
                          color: context
                              .read<ThemeProvider>()
                              .primaryMain
                              .withOpacity(0.3),
                        ),
                      ),
                    ),
                    // Status Badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              product['stock'] > 0
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product['status'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Product Info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product['category'],
                        style: TextStyle(
                          fontSize: 11,
                          color: themeProvider.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Rp ${_formatPrice(product['price'])}',
                              style: TextStyle(
                                color:
                                    context.read<ThemeProvider>().primaryMain,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Stok: ${product['stock']}',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.accentOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductListCard(Map<String, dynamic> product) {
    final themeProvider = context.watch<ThemeProvider>();

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
          onTap: () => _showProductDetail(product),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Product Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: themeProvider.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.phone_android,
                      size: 40,
                      color: context
                          .read<ThemeProvider>()
                          .primaryMain
                          .withOpacity(0.3),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product['category'],
                        style: TextStyle(
                          fontSize: 13,
                          color: themeProvider.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: 16,
                            color: AppTheme.primaryMain,
                          ),
                          Text(
                            'Rp ${_formatPrice(product['price'])}',
                            style: TextStyle(
                              color: context.read<ThemeProvider>().primaryMain,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 16,
                            color: AppTheme.accentOrange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Stok: ${product['stock']}',
                            style: TextStyle(
                              fontSize: 13,
                              color: themeProvider.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status & Action
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            product['stock'] > 0
                                ? AppTheme.successColor.withOpacity(0.1)
                                : AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product['status'],
                        style: TextStyle(
                          color:
                              product['stock'] > 0
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: themeProvider.textTertiary,
                      ),
                      onPressed: () => _showProductOptions(product),
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

  Widget _buildFAB() {
    final themeProvider = context.watch<ThemeProvider>();

    return FloatingActionButton.extended(
      onPressed: _showAddProductDialog,
      backgroundColor: themeProvider.primaryMain,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'Tambah Produk',
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

  void _showProductDetail(Map<String, dynamic> product) {
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
                    color: context
                        .read<ThemeProvider>()
                        .primaryMain
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: context.read<ThemeProvider>().primaryMain,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Detail Produk'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Nama', product['name']),
                  _buildDetailRow('Kategori', product['category']),
                  _buildDetailRow(
                    'Harga',
                    'Rp ${_formatPrice(product['price'])}',
                  ),
                  _buildDetailRow('Stok', '${product['stock']} unit'),
                  _buildDetailRow('Terjual', '${product['sold']} unit'),
                  _buildDetailRow('Status', product['status']),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showEditProductDialog(product);
                },
                child: const Text('Edit'),
              ),
            ],
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
            width: 80,
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

  void _showProductOptions(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                _buildOptionItem(
                  icon: Icons.edit_outlined,
                  label: 'Edit Produk',
                  color: AppTheme.primaryMain,
                  onTap: () {
                    Navigator.pop(context);
                    _showEditProductDialog(product);
                  },
                ),
                _buildOptionItem(
                  icon: Icons.delete_outline,
                  label: 'Hapus Produk',
                  color: AppTheme.errorColor,
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete(product);
                  },
                ),
                _buildOptionItem(
                  icon: Icons.share_outlined,
                  label: 'Bagikan',
                  color: AppTheme.accentOrange,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.read<ThemeProvider>().textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddProductDialog() {
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
                    gradient: LinearGradient(
                      colors: [
                        context.read<ThemeProvider>().primaryMain,
                        context.read<ThemeProvider>().primaryDark,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Text('Tambah Produk Baru'),
              ],
            ),
            content: const Text('Form tambah produk akan ditampilkan di sini'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  void _showEditProductDialog(Map<String, dynamic> product) {
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
                    color: AppTheme.accentOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.edit, color: AppTheme.accentOrange),
                ),
                const SizedBox(width: 12),
                const Text('Edit Produk'),
              ],
            ),
            content: Text('Form edit untuk: ${product['name']}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  void _confirmDelete(Map<String, dynamic> product) {
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
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: AppTheme.errorColor,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Konfirmasi Hapus'),
              ],
            ),
            content: Text(
              'Apakah Anda yakin ingin menghapus "${product['name']}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _products.removeWhere((p) => p['id'] == product['id']);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product['name']} berhasil dihapus'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }
}
