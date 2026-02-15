import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme_provider.dart';
import '../../../component/validation_handler.dart';
import '../../services/product_service.dart';
import '../../models/product.dart';
import '../../models/product_brand.dart';
import 'show.screen.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  String _sortBy = 'Terbaru';
  bool _isGridView = true;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  List<Product> _products = [];
  List<ProductBrand> _brands = [];
  int _currentPage = 1;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;
  final int _perPage = 20;

  // Search debounce
  Timer? _debounceTimer;

  void _debounceSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _loadProducts(isRefresh: true);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  final List<String> _sortOptions = [
    'Terbaru',
    'Nama A-Z',
    'Nama Z-A',
    'Harga Terendah',
    'Harga Tertinggi',
    'Stok Terbanyak',
  ];

  @override
  void initState() {
    super.initState();
    _loadBrands().then((_) => _loadProducts(isRefresh: true));
  }

  Future<void> _loadProducts({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _products.clear();
    }

    if (!_hasMoreData || _isLoading) return;

    setState(() {
      _isLoading = isRefresh || _currentPage == 1;
      _isLoadingMore = !isRefresh && _currentPage > 1;
      _hasError = false;
    });

    try {
      final sortBy = ProductService.convertSortOption(_sortBy);
      final merkId =
          _selectedCategory == 'Semua'
              ? null
              : _brands.firstWhere((b) => b.nama == _selectedCategory).id;

      final response = await ProductService.getAllProducts(
        nama: _searchQuery.isNotEmpty ? _searchQuery : null,
        merkId: merkId,
        sortBy: sortBy,
        page: _currentPage,
        perPage: _perPage,
      );

      if (response.success == true && response.data != null) {
        final List<Product> newProducts = response.data!;

        setState(() {
          if (isRefresh || _currentPage == 1) {
            _products = newProducts;
          } else {
            _products.addAll(newProducts);
          }

          _hasMoreData = response.pagination?.hasMorePages ?? false;
          _currentPage++;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = response.message ?? 'Gagal memuat produk';
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadBrands() async {
    try {
      final response = await ProductService.getProductBrands();
      if (response.success == true && response.data != null) {
        setState(() {
          _brands = response.data!;
        });
      }
    } catch (e) {
      debugPrint('Error loading brands: $e');
      // Set default brands if API fails
      setState(() {
        _brands = [
          ProductBrand(id: 1, nama: 'Apple'),
          ProductBrand(id: 2, nama: 'Samsung'),
          ProductBrand(id: 3, nama: 'Generic'),
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.surfaceColor,
        elevation: 0,
        title: Text(
          'All Products',
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
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadProducts(isRefresh: true),
        child: Column(
          children: [
            _buildSearchAndFilter(),
            _buildCategoryFilter(),
            _buildStatsBar(),
            Expanded(
              child: _isLoading && _products.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _buildProductList(isDesktop),
            ),
          ],
        ),
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
          // Search bar
          TextField(
            onChanged: (value) {
              setState(() => _searchQuery = value);
              _debounceSearch();
            },
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
            value: _sortBy,
            style: TextStyle(
              color: themeProvider.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: 'Sort by',
              labelStyle: TextStyle(
                color: themeProvider.textSecondary,
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
            items: _sortOptions.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(
                  option,
                  style: TextStyle(
                    color: themeProvider.textPrimary,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _sortBy = value ?? 'Terbaru');
              _loadProducts(isRefresh: true);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final themeProvider = context.watch<ThemeProvider>();
    final categories = ['Semua', ..._brands.map((b) => b.nama).toList()];
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      height: isMobile ? 45 : 50,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;

          return Container(
            margin: EdgeInsets.only(right: isMobile ? 6 : 8),
            child: FilterChip(
              label: Text(
                category,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: isSelected 
                      ? themeProvider.primaryMain
                      : themeProvider.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
                _loadProducts(isRefresh: true);
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

  Widget _buildStatsBar() {
    final themeProvider = context.watch<ThemeProvider>();
    final totalStock = _products.fold<int>(
      0,
      (sum, product) => sum + (product.totalStok ?? 0),
    );
    final outOfStock = _products.where((p) => (p.totalStok ?? 0) == 0).length;
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _buildStatItem(
              Icons.inventory,
              'Products',
              '${_products.length}',
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
              'Stock',
              '$totalStock',
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
              'Out',
              '$outOfStock',
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
        Icon(icon, color: color, size: isMobile ? 20 : 24),
        SizedBox(height: isMobile ? 2 : 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: themeProvider.textPrimary,
          ),
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

  Widget _buildProductList(bool isDesktop) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadProducts(isRefresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_isGridView) {
      int crossAxisCount = 2;
      if (isDesktop)
        crossAxisCount = 4;
      else if (isTablet) crossAxisCount = 3;

      return NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (!_isLoadingMore &&
              _hasMoreData &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _loadProducts();
          }
          return false;
        },
        child: GridView.builder(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 12 : 16,
            isMobile ? 12 : 16,
            isMobile ? 12 : 16,
            80, // Extra bottom padding for FAB
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: isMobile ? 8 : 12,
            mainAxisSpacing: isMobile ? 8 : 12,
            childAspectRatio: isMobile ? 0.75 : (isTablet ? 0.8 : 0.85),
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
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _loadProducts();
          }
          return false;
        },
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 12 : 16,
            isMobile ? 12 : 16,
            isMobile ? 12 : 16,
            80, // Extra bottom padding for FAB
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

  Widget _buildProductGridCard(Product product, bool isMobile) {
    final themeProvider = context.watch<ThemeProvider>();

    return Card(
      color: themeProvider.surfaceColor,
      child: InkWell(
        onTap: () => _showProductDetail(product),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 8 : 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: isMobile ? 50 : 60,
                decoration: BoxDecoration(
                  color: themeProvider.primaryMain.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.phone_android,
                    color: themeProvider.primaryMain,
                    size: isMobile ? 24 : 32,
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 6 : 8),
              Text(
                product.nama,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 12 : 14,
                  color: themeProvider.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                product.merk?.nama ?? 'Unknown',
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  color: themeProvider.primaryMain,
                ),
              ),
              const Spacer(),
              Text(
                product.formattedHargaJual,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: isMobile ? 12 : 14,
                ),
              ),
              SizedBox(height: isMobile ? 4 : 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Stock: ${product.totalStok ?? 0}',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
                        color: themeProvider.textSecondary,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 4 : 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: product.isAvailable ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.isAvailable ? 'Available' : 'Out',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 8 : 10,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 6 : 8),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => _deleteProduct(product),
                  icon: Icon(
                    Icons.delete,
                    size: isMobile ? 18 : 20,
                    color: Colors.red,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductListCard(Product product, bool isMobile) {
    final themeProvider = context.watch<ThemeProvider>();

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
              Container(
                width: isMobile ? 50 : 60,
                height: isMobile ? 50 : 60,
                decoration: BoxDecoration(
                  color: themeProvider.primaryMain.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.phone_android,
                  color: themeProvider.primaryMain,
                  size: isMobile ? 24 : 32,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.nama,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 14 : 16,
                        color: themeProvider.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${product.merk?.nama ?? 'Unknown'} • ${product.warna ?? 'No color'}',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: themeProvider.textSecondary,
                      ),
                    ),
                    SizedBox(height: isMobile ? 2 : 4),
                    Text(
                      product.formattedHargaJual,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: isMobile ? 14 : 16,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 6 : 8,
                      vertical: isMobile ? 3 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: product.isAvailable ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Stock: ${product.totalStok ?? 0}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 10 : 12,
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 8 : 12),
                  IconButton(
                    onPressed: () => _deleteProduct(product),
                    icon: Icon(
                      Icons.delete,
                      size: isMobile ? 20 : 22,
                      color: Colors.red,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProductDetail(Product product) {
    ProductDetailScreen.show(context, product);
  }

  Future<void> _deleteProduct(Product product) async {
    // Show confirmation dialog using context extension method
    final bool? shouldDelete = await context.showConfirmation(
      title: 'Delete Product',
      message: 'Are you sure you want to delete "${product.nama}"?\n\nThis action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
    );

    if (shouldDelete != true) return;

    try {
      final response = await ProductService.deleteProduct(product.id);
      
      if (response.success == true) {
        // Reload data to ensure we have latest from server
        await _loadProducts(isRefresh: true);

        if (mounted) {
          await ValidationHandler.showSuccessDialog(
            context: context,
            title: 'Success',
            message: 'Product deleted successfully',
          );
        }
      } else {
        if (mounted) {
          await ValidationHandler.showErrorDialog(
            context: context,
            title: 'Error',
            message: response.message ?? 'Failed to delete product',
          );
        }
      }
    } catch (e) {
      debugPrint('Error deleting product: $e');
      if (mounted) {
        await ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'Error deleting product: $e',
        );
      }
    }
  }

  // void _showProductDetail(Product product) {
  //   ProductDetailScreen.show(context, product);
  // }
}