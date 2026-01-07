import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import '../../component/validation_handler.dart';
import '../../layouts/screens/main_layout.dart';
import '../services/supplier_service.dart';
import '../models/supplier.dart';
import 'create.screen.dart';
import 'show.screen.dart';
import 'edit.screen.dart';

class SupplierIndexScreen extends StatefulWidget {
  const SupplierIndexScreen({super.key});

  @override
  State<SupplierIndexScreen> createState() => _SupplierIndexScreenState();
}

class _SupplierIndexScreenState extends State<SupplierIndexScreen>
    with TickerProviderStateMixin {
  Timer? _debounceTimer;
  String _searchQuery = '';
  bool _isLoading = false;
  List<Supplier> _suppliers = [];
  String? _error;
  int _currentPage = 1;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;
  final int _perPage = 20;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _loadSuppliers(isRefresh: true);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadSuppliers({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _suppliers.clear();
    }

    if (!_hasMoreData || _isLoading) return;

    setState(() {
      _isLoading = isRefresh || _currentPage == 1;
      _isLoadingMore = !isRefresh && _currentPage > 1;
      _error = null;
    });

    try {
      final response = await SupplierService.getSuppliers(
        page: _currentPage,
        perPage: _perPage,
        nama: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (response['success'] == true) {
        final List<dynamic> supplierData = response['data'] ?? [];
        final List<Supplier> newSuppliers =
            supplierData.map((json) => Supplier.fromJson(json)).toList();

        setState(() {
          if (isRefresh || _currentPage == 1) {
            _suppliers = newSuppliers;
          } else {
            _suppliers.addAll(newSuppliers);
          }

          // Check if has more data
          _hasMoreData = newSuppliers.length >= _perPage;
          if (_hasMoreData) _currentPage++;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load suppliers';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _debounceSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _loadSuppliers(isRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        // Navigate ke dashboard (index 0)
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder:
                  (context) =>
                      const MainLayout(title: 'Dashboard', selectedIndex: 0),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        body: RefreshIndicator(
          onRefresh: () => _loadSuppliers(isRefresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildModernHeader(isDesktop),
                  _buildStatsCards(isDesktop, isTablet),
                  _buildSearchSection(isDesktop),
                  _buildSuppliersContentContainer(isDesktop, isTablet),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: _buildModernFAB(themeProvider),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildModernHeader(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      margin: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: themeProvider.primaryMain,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: themeProvider.primaryMain.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 28 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isDesktop ? 12 : 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.local_shipping_rounded,
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
                        'Supplier Management',
                        style: TextStyle(
                          fontSize: isDesktop ? 24 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isDesktop ? 4 : 2),
                      Text(
                        'Manage your suppliers and vendor information',
                        style: TextStyle(
                          fontSize: isDesktop ? 14 : 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(bool isDesktop, bool isTablet) {
    final themeProvider = context.watch<ThemeProvider>();
    final activeSuppliers = _suppliers.length;
    final totalSearchResults =
        _searchQuery.isNotEmpty ? _suppliers.length : activeSuppliers;

    List<Map<String, dynamic>> stats = [
      {
        'title': 'Total Suppliers',
        'value': '$activeSuppliers',
        'icon': Icons.local_shipping_rounded,
        'color': Colors.blue,
        'subtitle': 'Active vendors',
      },
      {
        'title': 'Search Results',
        'value': '$totalSearchResults',
        'icon': Icons.search_rounded,
        'color': Colors.green,
        'subtitle':
            _searchQuery.isNotEmpty ? 'Found suppliers' : 'All suppliers',
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 20 : 16,
        vertical: 8,
      ),
      child:
          isDesktop
              ? Row(
                children:
                    stats
                        .map(
                          (stat) =>
                              Expanded(child: _buildStatCard(stat, isDesktop)),
                        )
                        .toList(),
              )
              : Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(stats[0], false)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildStatCard(stats[1], false)),
                    ],
                  ),
                ],
              ),
    );
  }

  Widget _buildSearchSection(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 20 : 16,
        vertical: 8,
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _currentPage = 1;
          });
          _debounceSearch();
        },
        style: TextStyle(color: themeProvider.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search suppliers by name...',
          hintStyle: TextStyle(
            color: themeProvider.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: Icon(Icons.search, color: themeProvider.textSecondary),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: themeProvider.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: themeProvider.borderColor.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: themeProvider.primaryMain, width: 2),
          ),
          filled: true,
          fillColor: themeProvider.surfaceColor,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    final themeProvider = context.watch<ThemeProvider>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(Icons.error_outline, size: 64, color: Colors.red),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            _error!,
            style: TextStyle(color: themeProvider.textSecondary, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () => _loadSuppliers(isRefresh: true),
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat, bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();
    final color = stat['color'] as Color;

    return Container(
      margin: EdgeInsets.only(
        right: isDesktop ? 16 : 0,
        bottom: isDesktop ? 0 : 8,
      ),
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isDesktop ? 10 : 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(stat['icon'], color: color, size: isDesktop ? 24 : 20),
          ),
          SizedBox(width: isDesktop ? 12 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stat['value'],
                  style: TextStyle(
                    fontSize: isDesktop ? 20 : 16,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textPrimary,
                  ),
                ),
                SizedBox(height: isDesktop ? 2 : 1),
                Text(
                  stat['title'],
                  style: TextStyle(
                    fontSize: isDesktop ? 12 : 10,
                    color: themeProvider.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (stat['subtitle'] != null) ...[
                  Text(
                    stat['subtitle'],
                    style: TextStyle(
                      fontSize: isDesktop ? 10 : 9,
                      color: themeProvider.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuppliersContentContainer(bool isDesktop, bool isTablet) {
    if (_isLoading && _suppliers.isEmpty) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.4,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.4,
        child: _buildErrorState(),
      );
    }

    if (_suppliers.isEmpty && !_isLoading) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.4,
        child: _buildEmptyState(),
      );
    }

    return _buildSuppliersListContainer(isDesktop, isTablet);
  }

  Widget _buildSuppliersListContainer(bool isDesktop, bool isTablet) {
    // Calculate height based on available screen space
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final availableHeight =
        screenHeight -
        keyboardHeight -
        400; // Approximate space for header, stats, search

    return Container(
      height: availableHeight > 200 ? availableHeight : 200,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          isDesktop ? 20 : 16,
          8,
          isDesktop ? 20 : 16,
          80, // Extra bottom padding for FAB clearance
        ),
        itemCount: _suppliers.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _suppliers.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _buildModernSupplierCard(_suppliers[index], isDesktop);
        },
      ),
    );
  }

  Widget _buildModernSupplierCard(Supplier supplier, bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (50)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: EdgeInsets.only(bottom: isDesktop ? 16 : 12),
              decoration: BoxDecoration(
                color: themeProvider.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showSupplierDetail(supplier),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: EdgeInsets.all(isDesktop ? 20 : 16),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'supplier-${supplier.id}',
                          child: Container(
                            width: isDesktop ? 60 : 50,
                            height: isDesktop ? 60 : 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  themeProvider.primaryMain.withOpacity(0.8),
                                  themeProvider.primaryMain,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: themeProvider.primaryMain.withOpacity(
                                    0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.local_shipping_rounded,
                              color: Colors.white,
                              size: isDesktop ? 28 : 24,
                            ),
                          ),
                        ),
                        SizedBox(width: isDesktop ? 16 : 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                supplier.nama,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isDesktop ? 18 : 16,
                                  color: themeProvider.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: isDesktop ? 4 : 2),
                              if (supplier.nomorHp != null &&
                                  supplier.nomorHp!.isNotEmpty) ...[
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone_rounded,
                                      size: isDesktop ? 16 : 14,
                                      color: themeProvider.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        supplier.nomorHp!,
                                        style: TextStyle(
                                          fontSize: isDesktop ? 14 : 12,
                                          color: themeProvider.textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (supplier.email != null &&
                                  supplier.email!.isNotEmpty) ...[
                                SizedBox(height: isDesktop ? 2 : 1),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.email_rounded,
                                      size: isDesktop ? 16 : 14,
                                      color: themeProvider.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        supplier.email!,
                                        style: TextStyle(
                                          fontSize: isDesktop ? 14 : 12,
                                          color: themeProvider.textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _deleteSupplier(supplier),
                          icon: Icon(
                            Icons.delete,
                            size: isDesktop ? 20 : 18,
                            color: Colors.red,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Delete Supplier',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSupplierDetail(Supplier supplier) {
    SupplierDetailScreen.show(context, supplier);
  }

  Widget _buildModernFAB(ThemeProvider themeProvider) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: FloatingActionButton.extended(
            onPressed: () => _navigateToCreate(),
            backgroundColor: themeProvider.primaryMain,
            elevation: 8,
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
            label: const Text(
              'Add Supplier',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final themeProvider = context.watch<ThemeProvider>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: themeProvider.primaryMain.withOpacity(0.1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(
            Icons.local_shipping_outlined,
            size: 64,
            color: themeProvider.primaryMain,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _searchQuery.isNotEmpty ? 'No suppliers found' : 'No suppliers yet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: themeProvider.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _searchQuery.isNotEmpty
              ? 'Try adjusting your search terms'
              : 'Get started by adding your first supplier',
          style: TextStyle(fontSize: 14, color: themeProvider.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        if (_searchQuery.isEmpty)
          ElevatedButton.icon(
            onPressed: () => _navigateToCreate(),
            icon: const Icon(Icons.add),
            label: const Text('Add First Supplier'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
      ],
    );
  }

  void _navigateToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SupplierCreateScreen()),
    );

    if (result != null && mounted) {
      await _loadSuppliers(isRefresh: true);
    }
  }

  void _navigateToEdit(Supplier supplier) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupplierEditScreen(supplier: supplier),
      ),
    );

    if (result != null && mounted) {
      await _loadSuppliers(isRefresh: true);
    }
  }

  Future<void> _deleteSupplier(Supplier supplier) async {
    // Show confirmation dialog using context extension method
    final bool? shouldDelete = await context.showConfirmation(
      title: 'Delete Supplier',
      message:
          'Are you sure you want to delete "${supplier.nama}"?\n\nThis action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
    );

    if (shouldDelete != true) return;

    try {
      final response = await SupplierService.deleteSupplier(supplier.id);

      if (response['success'] == true) {
        // Reload data to ensure we have latest from server
        await _loadSuppliers(isRefresh: true);

        if (mounted) {
          await ValidationHandler.showSuccessDialog(
            context: context,
            title: 'Success',
            message: 'Supplier deleted successfully',
          );
        }
      } else {
        if (mounted) {
          await ValidationHandler.showErrorDialog(
            context: context,
            title: 'Error',
            message: response['message'] ?? 'Failed to delete supplier',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        await ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'Error deleting supplier: $e',
        );
      }
    }
  }
}
