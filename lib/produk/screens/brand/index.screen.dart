import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme_provider.dart';
import '../../../component/validation_handler.dart';
import '../../services/brand_service.dart';
import 'create.screen.dart';
import 'edit.screen.dart';
import 'show.screen.dart';

class IndexBrandScreen extends StatefulWidget {
  const IndexBrandScreen({super.key});

  @override
  State<IndexBrandScreen> createState() => _IndexBrandScreenState();
}

class _IndexBrandScreenState extends State<IndexBrandScreen> {
  String _searchQuery = '';
  bool _isLoading = false;
  List<Map<String, dynamic>> _brands = [];
  int _currentPage = 1;
  int _perPage = 10;
  int _totalPages = 1;
  int _totalItems = 0;
  final ScrollController _scrollController = ScrollController();
  final List<int> _perPageOptions = [10, 25, 50, 100];

  @override
  void initState() {
    super.initState();
    _loadBrands(isRefresh: true);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadBrands({bool isRefresh = false, int? page}) async {
    if (page != null) {
      _currentPage = page;
    } else if (isRefresh) {
      _currentPage = 1;
    }

    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      final response = await BrandService.getBrands(
        page: _currentPage,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        perPage: _perPage,
      );

      if (response['success'] == true && mounted) {
        final List<dynamic> brandData = response['data'] ?? [];
        final int totalItems = response['pagination']?['total'] ?? brandData.length;
        final int lastPage = response['pagination']?['last_page'] ?? 1;
        final int currentPage = response['pagination']?['current_page'] ?? _currentPage;

        setState(() {
          _brands = List<Map<String, dynamic>>.from(brandData);
          _totalItems = totalItems;
          _totalPages = lastPage > 0 ? lastPage : 1;
          _currentPage = currentPage;
        });

        // Scroll to top when changing page
        if (page != null && _scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      } else {
        if (mounted) {
          await ValidationHandler.showErrorDialog(
            context: context,
            title: 'Error',
            message: response['message'] ?? 'Failed to load brands',
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading brands: $e');
      if (mounted) {
        await ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'Failed to load brands: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> get _filteredBrands {
    // Since we already filter on server side, just return the brands
    return _brands;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    
    // Debounce search to avoid too many API calls
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _loadBrands(isRefresh: true);
    });
  }

  Timer? _debounceTimer;

  void _goToPage(int page) {
    if (page >= 1 && page <= _totalPages && page != _currentPage) {
      _loadBrands(page: page);
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      _goToPage(_currentPage + 1);
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      _goToPage(_currentPage - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        key: const ValueKey('brand_index_appbar'),
        backgroundColor: themeProvider.surfaceColor,
        elevation: 0,
        title: Text(
          'Product Names',
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: themeProvider.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: '', // Disable tooltip to prevent rendering issues
              )
            : null,
        iconTheme: IconThemeData(color: themeProvider.textPrimary),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadBrands(isRefresh: true),
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildSearchBar(),
              _buildStatsBar(),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                _buildBrandList(),
              if (!_isLoading && _brands.isNotEmpty)
                _buildPaginationControls(
                  MediaQuery.of(context).size.width >= 600,
                ),
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreate(),
        backgroundColor: themeProvider.primaryMain,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          MediaQuery.of(context).size.width < 600 ? 'Add' : 'Add Product Name',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSearchBar() {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: TextField(
        onChanged: _onSearchChanged,
        style: TextStyle(
          color: themeProvider.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search product names...',
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: themeProvider.surfaceColor,
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    final themeProvider = context.watch<ThemeProvider>();
    final filteredBrands = _filteredBrands;
    final totalProducts = filteredBrands.fold<int>(
      0,
      (sum, brand) => sum + ((brand['produk_count'] as int?) ?? 0),
    );
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
              Icons.branding_watermark,
              'Names',
              '${filteredBrands.length}',
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
              Icons.inventory,
              'Products',
              '$totalProducts',
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

  Widget _buildBrandList() {
    final brands = _filteredBrands;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (brands.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.branding_watermark_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty
                    ? 'No product names found'
                    : 'No product names match your search',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 12 : 16,
        isMobile ? 12 : 16,
        isMobile ? 12 : 16,
        isMobile ? 12 : 16,
      ),
      child: Column(
        children: brands
            .map((brand) => _buildBrandCard(brand, isMobile))
            .toList(),
      ),
    );
  }

  Widget _buildBrandCard(Map<String, dynamic> brand, bool isMobile) {
    final themeProvider = context.watch<ThemeProvider>();

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      color: themeProvider.surfaceColor,
      child: InkWell(
        onTap: () => _navigateToShow(brand),
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.branding_watermark,
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
                      brand['merk'] ?? brand['nama'] ?? 'N/A',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 16 : 18,
                        color: themeProvider.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isMobile ? 2 : 4),
                    Text(
                      '${(brand['produk_count'] as int?) ?? 0} products',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: themeProvider.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showDeleteConfirmation(brand),
                icon: Icon(
                  Icons.delete,
                  size: isMobile ? 18 : 20,
                  color: Colors.red,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation methods
  void _navigateToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateBrandScreen()),
    );

    if (result != null && mounted) {
      // Reload data to ensure we have latest from server
      await _loadBrands(isRefresh: true);
    }
  }

  void _navigateToEdit(Map<String, dynamic> brand) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditBrandScreen(brand: brand)),
    );

    if (result != null && mounted) {
      // Instead of trying to update the specific item, just reload all data
      // This ensures we have the latest data from server
      await _loadBrands(isRefresh: true);
    }
  }

  void _navigateToShow(Map<String, dynamic> brand) {
    ShowBrandScreen.show(context, brand);
  }

  void _showDeleteConfirmation(Map<String, dynamic> brand) async {
    // Create snapshot of brand data to avoid changes during dialog
    final brandSnapshot = Map<String, dynamic>.from(brand);
    final produkCount = (brandSnapshot['produk_count'] as int?) ?? 0;
    final brandMerk = brandSnapshot['merk'] ?? brandSnapshot['nama'] ?? '';
    final brandId = brandSnapshot['id'];
    
    if (produkCount > 0) {
      // Show info dialog for product names with products
      final confirmed = await context.showConfirmation(
        title: 'Cannot Delete Product Name', 
        message: 'Product Name "$brandMerk" has $produkCount products. You cannot delete it.',
        confirmText: 'OK',
        confirmColor: Colors.red,
      );
    } else {
      // Show delete confirmation dialog
      final confirmed = await context.showConfirmation(
        title: 'Delete Product Name',
        message: 'Are you sure you want to delete "$brandMerk"?\n\nThis action cannot be undone.',
        confirmText: 'Delete',
        cancelText: 'Cancel',
        confirmColor: Colors.red,
      );

      if (confirmed == true) {
        _deleteBrand(brandId);
      }
    }
  }

  Future<void> _deleteBrand(int id) async {
    try {
      final response = await BrandService.deleteBrand(id);
      
      if (response['success'] == true) {
        if (mounted) {
          await ValidationHandler.showSuccessDialog(
            context: context,
            title: 'Success',
            message: response['message'] ?? 'Brand berhasil dihapus!',
          );
        }
        
        // Reload data after showing success dialog to avoid UI flicker
        await _loadBrands(isRefresh: true);
      } else {
        if (mounted) {
          await ValidationHandler.showErrorDialog(
            context: context,
            title: 'Error',
            message: response['message'] ?? 'Gagal menghapus brand',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        await ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'Error menghapus brand: $e',
        );
      }
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

  Widget _buildPaginationControls(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: themeProvider.textTertiary.withOpacity(0.1)),
        ),
      ),
      child: Column(
        children: [
          // Rows per page selector
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Pagination info
                Flexible(
                  child: Text(
                    'Showing ${_brands.isEmpty ? 0 : ((_currentPage - 1) * _perPage) + 1} - ${(_currentPage * _perPage) > _totalItems ? _totalItems : (_currentPage * _perPage)} of $_totalItems items',
                    style: TextStyle(
                      color: themeProvider.textSecondary,
                      fontSize: isDesktop ? 14 : 12,
                    ),
                  ),
                ),
                // Rows per page dropdown
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Rows:',
                      style: TextStyle(
                        color: themeProvider.textSecondary,
                        fontSize: isDesktop ? 14 : 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: themeProvider.borderColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<int>(
                        value: _perPage,
                        underline: const SizedBox(),
                        isDense: true,
                        style: TextStyle(
                          color: themeProvider.textPrimary,
                          fontSize: isDesktop ? 14 : 12,
                        ),
                        items: _perPageOptions.map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          if (newValue != null && newValue != _perPage) {
                            setState(() {
                              _perPage = newValue;
                              _currentPage = 1; // Reset to first page
                            });
                            _loadBrands(isRefresh: true);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Pagination controls with horizontal scroll for mobile
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                // Previous button
                IconButton(
                  onPressed: _currentPage > 1 ? _previousPage : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                  color: themeProvider.primaryMain,
                  disabledColor: themeProvider.textTertiary.withOpacity(0.3),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        _currentPage > 1
                            ? themeProvider.primaryMain.withOpacity(0.1)
                            : themeProvider.textTertiary.withOpacity(0.05),
                  ),
                ),

                const SizedBox(width: 12),

                // Page numbers
                ..._buildPageNumbers(isDesktop),

                const SizedBox(width: 12),

                // Next button
                IconButton(
                  onPressed: _currentPage < _totalPages ? _nextPage : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                  color: themeProvider.primaryMain,
                  disabledColor: themeProvider.textTertiary.withOpacity(0.3),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        _currentPage < _totalPages
                            ? themeProvider.primaryMain.withOpacity(0.1)
                            : themeProvider.textTertiary.withOpacity(0.05),
                  ),
                ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();
    List<Widget> pageButtons = [];

    // Show fewer page numbers on mobile to prevent overflow
    final maxPages = isDesktop ? 10 : 5;
    final halfPages = maxPages ~/ 2;
    
    int startPage = _currentPage - halfPages;
    int endPage = _currentPage + (halfPages - 1);

    if (startPage < 1) {
      startPage = 1;
      endPage = _totalPages < maxPages ? _totalPages : maxPages;
    }

    if (endPage > _totalPages) {
      endPage = _totalPages;
      startPage = _totalPages - (maxPages - 1) > 0 ? _totalPages - (maxPages - 1) : 1;
    }

    // First page
    if (startPage > 1) {
      pageButtons.add(_buildPageButton(1, isDesktop));
      if (startPage > 2) {
        pageButtons.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '...',
              style: TextStyle(color: themeProvider.textSecondary),
            ),
          ),
        );
      }
    }

    // Page numbers
    for (int i = startPage; i <= endPage; i++) {
      pageButtons.add(_buildPageButton(i, isDesktop));
    }

    // Last page
    if (endPage < _totalPages) {
      if (endPage < _totalPages - 1) {
        pageButtons.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '...',
              style: TextStyle(color: themeProvider.textSecondary),
            ),
          ),
        );
      }
      pageButtons.add(_buildPageButton(_totalPages, isDesktop));
    }

    return pageButtons;
  }

  Widget _buildPageButton(int page, bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();
    final isCurrentPage = page == _currentPage;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () => _goToPage(page),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 16 : 12,
            vertical: isDesktop ? 12 : 8,
          ),
          decoration: BoxDecoration(
            color:
                isCurrentPage
                    ? themeProvider.primaryMain
                    : themeProvider.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  isCurrentPage
                      ? themeProvider.primaryMain
                      : themeProvider.textTertiary.withOpacity(0.2),
            ),
          ),
          child: Text(
            page.toString(),
            style: TextStyle(
              color: isCurrentPage ? Colors.white : themeProvider.textPrimary,
              fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
              fontSize: isDesktop ? 14 : 12,
            ),
          ),
        ),
      ),
    );
  }
}
