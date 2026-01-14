import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import '../../component/validation_handler.dart';
import '../../layouts/screens/main_layout.dart';
import '../services/trade_in_service.dart';
import '../models/trade_in.dart';
import 'create.screen.dart';
import 'show.screen.dart';
import 'edit.screen.dart';

class TradeInIndexScreen extends StatefulWidget {
  const TradeInIndexScreen({super.key});

  @override
  State<TradeInIndexScreen> createState() => _TradeInIndexScreenState();
}

class _TradeInIndexScreenState extends State<TradeInIndexScreen>
    with TickerProviderStateMixin {
  Timer? _debounceTimer;
  String _searchQuery = '';
  bool _isLoading = false;
  List<TradeIn> _tradeIns = [];
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
    _loadTradeIns(isRefresh: true);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadTradeIns({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _tradeIns.clear();
    }

    if (!_hasMoreData || _isLoading) return;

    setState(() {
      _isLoading = isRefresh || _currentPage == 1;
      _isLoadingMore = !isRefresh && _currentPage > 1;
      _error = null;
    });

    try {
      final response = await TradeInService.getTradeIns(
        page: _currentPage,
        perPage: _perPage,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (response['success'] == true) {
        final List<dynamic> tradeInData = response['data'] ?? [];
        final List<TradeIn> newTradeIns =
            tradeInData.map((json) => TradeIn.fromJson(json)).toList();

        setState(() {
          if (isRefresh || _currentPage == 1) {
            _tradeIns = newTradeIns;
          } else {
            _tradeIns.addAll(newTradeIns);
          }

          // Check if has more data
          _hasMoreData = newTradeIns.length >= _perPage;
          if (_hasMoreData) _currentPage++;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load trade-in data';
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
      _loadTradeIns(isRefresh: true);
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
          onRefresh: () => _loadTradeIns(isRefresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildModernHeader(isDesktop),
                  _buildStatsCards(isDesktop, isTablet),
                  _buildSearchSection(isDesktop),
                  _buildTradeInsContentContainer(isDesktop, isTablet),
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
                    Icons.swap_horiz_rounded,
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
                        'Trade-In Management',
                        style: TextStyle(
                          fontSize: isDesktop ? 24 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isDesktop ? 4 : 2),
                      Text(
                        'Manage handphone trade-in transactions',
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
    final totalTransaksi = _tradeIns.length;
    final totalNilaiMasuk = _tradeIns.fold<int>(
      0,
      (sum, item) => sum + (item.produkMasukHarga ?? 0),
    );
    final totalNilaiKeluar = _tradeIns.fold<int>(
      0,
      (sum, item) => sum + (item.produkKeluarHarga ?? 0),
    );

    List<Map<String, dynamic>> stats = [
      {
        'title': 'Total Transactions',
        'value': '$totalTransaksi',
        'icon': Icons.swap_horiz_rounded,
        'color': Colors.blue,
        'subtitle': 'Trade-in transactions',
      },
      {
        'title': 'Trade-In Value',
        'value': 'Rp ${_formatCurrency(totalNilaiMasuk)}',
        'icon': Icons.call_received_rounded,
        'color': Colors.green,
        'subtitle': 'Total incoming value',
      },
      {
        'title': 'Sales Value',
        'value': 'Rp ${_formatCurrency(totalNilaiKeluar)}',
        'icon': Icons.call_made_rounded,
        'color': Colors.orange,
        'subtitle': 'Total outgoing value',
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
                  const SizedBox(height: 8),
                  _buildStatCard(stats[2], false),
                ],
              ),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat, bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();
    final color = stat['color'] as Color;

    return Container(
      margin: EdgeInsets.only(
        right: isDesktop ? 16 : 0,
        bottom: isDesktop ? 0 : 0,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
              ],
            ),
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
          hintText: 'Search customer, incoming product, or outgoing product...',
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
          onPressed: () => _loadTradeIns(isRefresh: true),
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildTradeInsContentContainer(bool isDesktop, bool isTablet) {
    if (_isLoading && _tradeIns.isEmpty) {
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

    if (_tradeIns.isEmpty && !_isLoading) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.4,
        child: _buildEmptyState(),
      );
    }

    return _buildTradeInsListContainer(isDesktop, isTablet);
  }

  Widget _buildTradeInsListContainer(bool isDesktop, bool isTablet) {
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
        itemCount: _tradeIns.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _tradeIns.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _buildModernTradeInCard(_tradeIns[index], isDesktop);
        },
      ),
    );
  }

  Widget _buildModernTradeInCard(TradeIn tradeIn, bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
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
                  onTap: () => _showTradeInDetail(tradeIn),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: EdgeInsets.all(isDesktop ? 20 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with customer and store info
                        Row(
                          children: [
                            Hero(
                              tag: 'trade-in-${tradeIn.id}',
                              child: Container(
                                width: isDesktop ? 60 : 50,
                                height: isDesktop ? 60 : 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      themeProvider.primaryMain.withOpacity(
                                        0.8,
                                      ),
                                      themeProvider.primaryMain,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: themeProvider.primaryMain
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.swap_horiz_rounded,
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
                                    tradeIn.pelangganNama ?? '-',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isDesktop ? 18 : 16,
                                      color: themeProvider.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: isDesktop ? 4 : 2),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.store_rounded,
                                        size: isDesktop ? 16 : 14,
                                        color: themeProvider.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          tradeIn.tokoBranchNama ?? '-',
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
                              ),
                            ),
                            IconButton(
                              onPressed: () => _deleteTradeIn(tradeIn),
                              icon: Icon(
                                Icons.delete,
                                size: isDesktop ? 20 : 18,
                                color: Colors.red,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Delete Trade-In',
                            ),
                          ],
                        ),
                        SizedBox(height: isDesktop ? 16 : 12),
                        // Trade in details
                        Container(
                          padding: EdgeInsets.all(isDesktop ? 12 : 10),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.call_received_rounded,
                                color: Colors.green,
                                size: isDesktop ? 20 : 18,
                              ),
                              SizedBox(width: isDesktop ? 8 : 6),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Product IN',
                                      style: TextStyle(
                                        fontSize: isDesktop ? 11 : 10,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${tradeIn.produkMasukNama ?? '-'} - ${tradeIn.produkMasukMerk ?? '-'}',
                                      style: TextStyle(
                                        fontSize: isDesktop ? 14 : 12,
                                        fontWeight: FontWeight.bold,
                                        color: themeProvider.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Rp ${_formatCurrency(tradeIn.produkMasukHarga ?? 0)}',
                                      style: TextStyle(
                                        fontSize: isDesktop ? 13 : 11,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isDesktop ? 8 : 6),
                        Container(
                          padding: EdgeInsets.all(isDesktop ? 12 : 10),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.call_made_rounded,
                                color: Colors.orange,
                                size: isDesktop ? 20 : 18,
                              ),
                              SizedBox(width: isDesktop ? 8 : 6),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Product OUT',
                                      style: TextStyle(
                                        fontSize: isDesktop ? 11 : 10,
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      tradeIn.produkKeluarNama ?? '-',
                                      style: TextStyle(
                                        fontSize: isDesktop ? 14 : 12,
                                        fontWeight: FontWeight.bold,
                                        color: themeProvider.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Rp ${_formatCurrency(tradeIn.produkKeluarHarga ?? 0)}',
                                      style: TextStyle(
                                        fontSize: isDesktop ? 13 : 11,
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isDesktop ? 12 : 10),
                        // Footer with price difference and date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: themeProvider.primaryMain.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.trending_up_rounded,
                                    size: isDesktop ? 16 : 14,
                                    color: themeProvider.primaryMain,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Difference: Rp ${_formatCurrency(tradeIn.selisihHarga ?? 0)}',
                                    style: TextStyle(
                                      fontSize: isDesktop ? 12 : 11,
                                      fontWeight: FontWeight.bold,
                                      color: themeProvider.primaryMain,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _formatDateTime(
                                tradeIn.createdAt ?? DateTime.now(),
                              ),
                              style: TextStyle(
                                fontSize: isDesktop ? 11 : 10,
                                color: themeProvider.textTertiary,
                              ),
                            ),
                          ],
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

  void _showTradeInDetail(TradeIn tradeIn) async {
    final result = await showDialog(
      context: context,
      builder: (context) => TradeInShowScreen(tradeIn: tradeIn),
    );

    if (result == true && mounted) {
      await _loadTradeIns(isRefresh: true);
    }
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
            icon: const Icon(
              Icons.add_shopping_cart_rounded,
              color: Colors.white,
              size: 24,
            ),
            label: const Text(
              'Add Trade-In',
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
            Icons.swap_horiz_rounded,
            size: 64,
            color: themeProvider.primaryMain,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _searchQuery.isNotEmpty
              ? 'No trade-in found'
              : 'No trade-in transactions yet',
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
              : 'Get started by adding your first trade-in transaction',
          style: TextStyle(fontSize: 14, color: themeProvider.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        if (_searchQuery.isEmpty)
          ElevatedButton.icon(
            onPressed: () => _navigateToCreate(),
            icon: const Icon(Icons.add),
            label: const Text('Add First Trade-In'),
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
      MaterialPageRoute(builder: (context) => const TradeInCreateScreen()),
    );

    if (result != null && mounted) {
      await _loadTradeIns(isRefresh: true);
    }
  }

  void _navigateToEdit(TradeIn tradeIn) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TradeInEditScreen(tradeIn: tradeIn),
      ),
    );

    if (result != null && mounted) {
      await _loadTradeIns(isRefresh: true);
    }
  }

  Future<void> _deleteTradeIn(TradeIn tradeIn) async {
    // Show confirmation dialog using context extension method
    final bool? shouldDelete = await context.showConfirmation(
      title: 'Delete Trade-In',
      message:
          'Are you sure you want to delete the trade-in transaction for "${tradeIn.pelangganNama ?? 'Unknown'}"?\n\nThis action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
    );

    if (shouldDelete != true) return;

    try {
      final response = await TradeInService.deleteTradeIn(tradeIn.id);

      if (response['success'] == true) {
        // Reload data to ensure we have latest from server
        await _loadTradeIns(isRefresh: true);

        if (mounted) {
          await ValidationHandler.showSuccessDialog(
            context: context,
            title: 'Success',
            message: 'Trade-in successfully deleted',
          );
        }
      } else {
        if (mounted) {
          await ValidationHandler.showErrorDialog(
            context: context,
            title: 'Error',
            message: response['message'] ?? 'Failed to delete trade-in',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        await ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'Error menghapus trade-in: $e',
        );
      }
    }
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
