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

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    setState(() => _isLoading = true);
    try {
      final response = await BrandService.getBrands(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        perPage: 50, // Load more items for better UX
      );

      if (response['success'] == true && mounted) {
        setState(() {
          _brands = List<Map<String, dynamic>>.from(response['data']);
        });
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
      _loadBrands();
    });
  }

  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
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
          'Product Brands',
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: themeProvider.textPrimary),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadBrands(),
        child: Column(
          children: [
            _buildSearchBar(),
            _buildStatsBar(),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildBrandList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreate(),
        backgroundColor: themeProvider.primaryMain,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          MediaQuery.of(context).size.width < 600 ? 'Add' : 'Add Brand',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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
          hintText: 'Search brands...',
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
              'Brands',
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
              Colors.blue,
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
      return Center(
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
                  ? 'No brands found'
                  : 'No brands match your search',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 12 : 16,
        isMobile ? 12 : 16,
        isMobile ? 12 : 16,
        80, // Extra bottom padding for FAB
      ),
      itemCount: brands.length,
      itemBuilder: (context, index) => _buildBrandCard(brands[index], isMobile),
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
                      brand['nama'],
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
      await _loadBrands();
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
      await _loadBrands();
    }
  }

  void _navigateToShow(Map<String, dynamic> brand) {
    ShowBrandScreen.show(context, brand);
  }

  void _showDeleteConfirmation(Map<String, dynamic> brand) async {
    // Create snapshot of brand data to avoid changes during dialog
    final brandSnapshot = Map<String, dynamic>.from(brand);
    final produkCount = (brandSnapshot['produk_count'] as int?) ?? 0;
    final brandName = brandSnapshot['nama'] ?? '';
    final brandId = brandSnapshot['id'];
    
    if (produkCount > 0) {
      // Show info dialog for brands with products
      final confirmed = await context.showConfirmation(
        title: 'Cannot Delete Brand', 
        message: 'Brand "$brandName" has $produkCount products. You cannot delete it.',
        confirmText: 'OK',
        confirmColor: Colors.blue,
      );
    } else {
      // Show delete confirmation dialog
      final confirmed = await context.showConfirmation(
        title: 'Delete Brand',
        message: 'Are you sure you want to delete "$brandName"?\n\nThis action cannot be undone.',
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
        await _loadBrands();
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
}
