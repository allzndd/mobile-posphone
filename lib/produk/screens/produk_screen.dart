import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import '../../layouts/screens/main_layout.dart';
import '../services/product_service.dart';
import '../services/management_service.dart';
import '../services/stock_history_service.dart';
import 'all_product/index.screen.dart';
import 'brand/index.screen.dart';
import 'stock_management/index.screen.dart';
import 'stock_history/index.screen.dart';

class ProdukScreen extends StatefulWidget {
  const ProdukScreen({super.key});

  @override
  State<ProdukScreen> createState() => _ProdukScreenState();
}

class _ProdukScreenState extends State<ProdukScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Real API data
  Map<String, dynamic> _statistics = {
    'totalProducts': 0,
    'totalBrands': 0,
    'lowStock': 0,
    'outOfStock': 0,
    'totalHistoryEntries': 0,
  };
  
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load all data concurrently
      final results = await Future.wait([
        _loadProductData(),
        _loadBrandData(),
        _loadStockData(),
        _loadHistoryData(),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load data: $e';
      });
    }
  }

  Future<void> _loadProductData() async {
    try {
      final response = await ProductService.getAllProducts(
        page: 1,
        perPage: 1, // We just need count, not actual products
      );
      
      if (response.success == true) {
        setState(() {
          _statistics['totalProducts'] = response.pagination?.total ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error loading product data: $e');
    }
  }

  Future<void> _loadBrandData() async {
    try {
      final response = await ProductService.getProductBrands();
      
      if (response.success == true && response.data != null) {
        setState(() {
          _statistics['totalBrands'] = response.data!.length;
        });
      }
    } catch (e) {
      debugPrint('Error loading brand data: $e');
    }
  }

  Future<void> _loadStockData() async {
    try {
      final response = await StockService.getStocks(
        page: 1,
        perPage: 100, // Get enough to calculate low/out of stock
      );
      
      if (response['success'] == true) {
        final List<dynamic> stockData = response['data'] ?? [];
        
        int lowStock = 0;
        int outOfStock = 0;
        
        for (var stock in stockData) {
          final stok = stock['stok'] ?? 0;
          if (stok == 0) {
            outOfStock++;
          } else if (stok <= 5) {
            lowStock++;
          }
        }
        
        setState(() {
          _statistics['lowStock'] = lowStock;
          _statistics['outOfStock'] = outOfStock;
        });
      }
    } catch (e) {
      debugPrint('Error loading stock data: $e');
    }
  }

  Future<void> _loadHistoryData() async {
    try {
      final response = await StockHistoryService.getStockHistory(
        page: 1,
        perPage: 1, // We just need count
      );
      
      if (response['success'] == true) {
        int totalEntries = 0;
        
        if (response['meta'] != null && response['meta']['total'] != null) {
          totalEntries = response['meta']['total'];
        } else if (response['data'] is List) {
          totalEntries = (response['data'] as List).length;
        }
        
        setState(() {
          _statistics['totalHistoryEntries'] = totalEntries;
        });
      }
    } catch (e) {
      debugPrint('Error loading history data: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;
    final isMobile = screenSize.width < 640;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        // Navigate ke dashboard (index 0)
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MainLayout(
                title: 'Dashboard',
                selectedIndex: 0,
              ),
            ),
          );
        }
      },
      child: Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadStatistics,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                // Modern Header dengan gradient dan stats
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(20),
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
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.dashboard_rounded,
                                  color: Colors.white,
                                  size: isMobile ? 24 : 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Product Management',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: isMobile ? 20 : 24,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Kelola seluruh produk dengan mudah',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: isMobile ? 13 : 15,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Statistics Row
                          if (_isLoading)
                            Container(
                              height: 80,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          else if (_error != null)
                            Container(
                              height: 80,
                              child: Center(
                                child: Text(
                                  'Error loading data',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                          else
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        'Products',
                                        _statistics['totalProducts'].toString(),
                                        Icons.inventory_2_outlined,
                                        Colors.white.withOpacity(0.95),
                                        isMobile,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildStatCard(
                                        'Names',
                                        _statistics['totalBrands'].toString(),
                                        Icons.business_outlined,
                                        Colors.white.withOpacity(0.95),
                                        isMobile,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        'Low Stock',
                                        _statistics['lowStock'].toString(),
                                        Icons.warning_amber_outlined,
                                        Colors.orange.shade100,
                                        isMobile,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildStatCard(
                                        'Out Stock',
                                        _statistics['outOfStock'].toString(),
                                        Icons.error_outline,
                                        Colors.red.shade100,
                                        isMobile,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Menu Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getCrossAxisCount(screenSize),
                      crossAxisSpacing: isMobile ? 12 : 16,
                      mainAxisSpacing: isMobile ? 12 : 16,
                      childAspectRatio:
                          isMobile ? 0.95 : (isTablet ? 1.1 : 1.0),
                    ),
                    delegate: SliverChildListDelegate([
                      _buildModernMenuCard(
                        context,
                        title: 'All Products',
                        subtitle: 'View & manage products',
                        icon: Icons.inventory_2_rounded,
                        gradient: [Colors.blue.shade400, Colors.blue.shade600],
                        count: _statistics['totalProducts'],
                        isMobile: isMobile,
                        onTap:
                            () => _navigateWithAnimation(
                              const AllProductsScreen(),
                            ),
                      ),
                      _buildModernMenuCard(
                        context,
                        title: 'Product Name',
                        subtitle: 'Manage product names',
                        icon: Icons.business_rounded,
                        gradient: [
                          Colors.orange.shade400,
                          Colors.orange.shade600,
                        ],
                        count: _statistics['totalBrands'],
                        isMobile: isMobile,
                        onTap:
                            () => _navigateWithAnimation(
                              const IndexBrandScreen(),
                            ),
                      ),
                      _buildModernMenuCard(
                        context,
                        title: 'Stock Management',
                        subtitle: 'Manage stock levels',
                        icon: Icons.assessment_rounded,
                        gradient: [
                          Colors.purple.shade400,
                          Colors.purple.shade600,
                        ],
                        count: _statistics['lowStock'],
                        isMobile: isMobile,
                        onTap:
                            () => _navigateWithAnimation(
                              const StockIndexScreen(),
                            ),
                      ),
                      _buildModernMenuCard(
                        context,
                        title: 'Stock History',
                        subtitle: 'View stock movements',
                        icon: Icons.history_rounded,
                        gradient: [Colors.teal.shade400, Colors.teal.shade600],
                        count: _statistics['totalHistoryEntries'] ?? 0,
                        isMobile: isMobile,
                        onTap:
                            () => _navigateWithAnimation(
                              const StockHistoryIndexScreen(),
                            ),
                      ),
                    ]),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            ),
          ),
        ),
      ),
    ),
    ),
    );
  }

  int _getCrossAxisCount(Size screenSize) {
    if (screenSize.width > 1200) return 4; // Desktop
    if (screenSize.width > 900) return 3; // Tablet landscape
    return 2; // Mobile and tablet portrait
  }

  void _navigateWithAnimation(Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
            ),
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color cardColor,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: isMobile ? 16 : 20, color: Colors.grey.shade700),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required int count,
    required bool isMobile,
    required VoidCallback onTap,
  }) {
    final themeProvider = context.watch<ThemeProvider>();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(isMobile ? 20 : 24),
                  decoration: BoxDecoration(
                    color: themeProvider.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: themeProvider.borderColor.withOpacity(0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: gradient[0].withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color:
                            themeProvider.isDarkMode
                                ? Colors.black.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon with gradient background
                      Container(
                        width: isMobile ? 48 : 56,
                        height: isMobile ? 48 : 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: gradient,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: gradient[0].withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: isMobile ? 24 : 28,
                        ),
                      ),

                      SizedBox(height: isMobile ? 12 : 16),

                      // Title
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textPrimary,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Subtitle
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          color: themeProvider.textSecondary,
                          height: 1.3,
                        ),
                      ),

                      SizedBox(height: isMobile ? 12 : 16),

                      // Count badge and arrow
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 8 : 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: gradient[0].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                count.toString(),
                                style: TextStyle(
                                  fontSize: isMobile ? 11 : 12,
                                  fontWeight: FontWeight.bold,
                                  color: gradient[1],
                                ),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: isMobile ? 14 : 16,
                            color: themeProvider.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
