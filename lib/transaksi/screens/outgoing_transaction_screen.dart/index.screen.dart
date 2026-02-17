import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme_provider.dart';
import '../../../component/validation_handler.dart';
import '../../../layouts/screens/main_layout.dart';
import '../../services/outgoing_service.dart';
import 'show.screen.dart';
import 'create.screen.dart';

class OutgoingTransactionIndexScreen extends StatefulWidget {
  const OutgoingTransactionIndexScreen({super.key});

  @override
  State<OutgoingTransactionIndexScreen> createState() =>
      _OutgoingTransactionIndexScreenState();
}

class _OutgoingTransactionIndexScreenState
    extends State<OutgoingTransactionIndexScreen>
    with TickerProviderStateMixin {
  Timer? _debounceTimer;
  String _searchQuery = '';
  bool _isLoading = false;
  List<Map<String, dynamic>> _transactions = [];
  String? _error;
  int _currentPage = 1;
  int _perPage = 10;
  int _totalPages = 1;
  int _totalItems = 0;
  final ScrollController _scrollController = ScrollController();
  final List<int> _perPageOptions = [10, 25, 50, 100];
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String _filterStatus = 'All';
  String _filterPeriod = 'Today';

  final List<String> _statusOptions = [
    'All',
    'Completed',
    'Pending',
    'Cancelled',
  ];

  final List<String> _periodOptions = [
    'Today',
    'This Week',
    'This Month',
    'All',
  ];

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
    _loadTransactions(isRefresh: true);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions({bool isRefresh = false, int? page}) async {
    if (page != null) {
      _currentPage = page;
    } else if (isRefresh) {
      _currentPage = 1;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await OutgoingService.getOutgoingTransactions(
        page: _currentPage,
        perPage: _perPage,
        status: _filterStatus != 'All' ? _filterStatus : null,
        invoice: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (response['success'] == true) {
        final List<dynamic> outgoingList = response['data'] ?? [];
        final List<Map<String, dynamic>> newTransactions =
            outgoingList.map((outgoing) {
          // Helper function to safely convert to int
          int _toInt(dynamic value) {
            if (value == null) return 0;
            if (value is int) return value;
            if (value is double) return value.toInt();
            if (value is String) return int.tryParse(value) ?? 0;
            return 0;
          }

          return {
            'id': outgoing.id,
            'invoice': outgoing.invoice ?? 'N/A',
            'total_harga': _toInt(outgoing.totalHarga),
            'status': outgoing.status ?? 'Pending',
            'metode_pembayaran': outgoing.metodePembayaran ?? 'Cash',
            'created_at': outgoing.createdAt?.toString() ?? '',
            'supplier_name': outgoing.supplier?.nama ?? 'Unknown Supplier',
            'toko_name': outgoing.store?.nama ?? 'Unknown Store',
            'items_count': outgoing.items?.length ?? 0,
            'keterangan': outgoing.keterangan,
            'pos_supplier_id': outgoing.posSupplierId,
            'pos_toko_id': outgoing.posTokoId,
            'items': outgoing.items
                    ?.map((item) => {
                          'pos_produk_id': item.posProdukId,
                          'product_name': item.product?.nama ?? 'Unknown',
                          'quantity': item.quantity,
                          'harga_satuan': _toInt(item.hargaSatuan),
                          'diskon': _toInt(item.diskon),
                          'subtotal': _toInt(item.subtotal),
                        })
                    .toList() ??
                [],
          };
        }).toList();

        setState(() {
          _transactions = newTransactions;

          final pagination = response['pagination'];
          if (pagination != null) {
            _totalItems = pagination['total'] ?? 0;
            _totalPages = pagination['last_page'] ?? 1;
            _currentPage = pagination['current_page'] ?? _currentPage;
          } else {
            _totalItems = newTransactions.length;
            _totalPages = 1;
          }
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
        setState(() {
          _error = response['message'] ?? 'Failed to load transactions';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading data: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= _totalPages && page != _currentPage) {
      _loadTransactions(page: page);
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

  void _debounceSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _loadTransactions(isRefresh: true);
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
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MainLayout(
                title: 'Outgoing Transaction',
                selectedIndex: 5,
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        body: RefreshIndicator(
          onRefresh: () => _loadTransactions(isRefresh: true),
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildModernHeader(isDesktop),
                _buildStatsCards(isDesktop, isTablet),
                _buildFilterSection(isDesktop),
                _buildTransactionsContentContainer(isDesktop, isTablet),
                if (!_isLoading && _transactions.isNotEmpty)
                  _buildPaginationControls(isDesktop),
                const SizedBox(height: 80), // Space for FAB
              ],
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
                  padding: EdgeInsets.all(isDesktop ? 14 : 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                    size: isDesktop ? 32 : 28,
                  ),
                ),
                SizedBox(width: isDesktop ? 16 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Outgoing Transactions',
                        style: TextStyle(
                          fontSize: isDesktop ? 28 : 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage purchase orders and supplier transactions',
                        style: TextStyle(
                          fontSize: isDesktop ? 14 : 12,
                          color: Colors.white.withOpacity(0.9),
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
    final totalTransaksi = _transactions.length;
    final totalPengeluaran = _transactions
        .where((t) => (t['status'] ?? '').toLowerCase() == 'completed')
        .fold<int>(0, (sum, t) => sum + (t['total_harga'] as int? ?? 0));
    final transaksiPending = _transactions
        .where((t) => (t['status'] ?? '').toLowerCase() == 'pending')
        .length;
    final transaksiSelesai = _transactions
        .where((t) => (t['status'] ?? '').toLowerCase() == 'completed')
        .length;

    List<Map<String, dynamic>> stats = [
      {
        'title': 'Total Purchases',
        'value': '$totalTransaksi',
        'icon': Icons.shopping_cart_rounded,
        'color': Colors.blue,
        'subtitle': 'All purchases',
      },
      {
        'title': 'Total Expenses',
        'value': 'Rp ${_formatPrice(totalPengeluaran)}',
        'icon': Icons.trending_down_rounded,
        'color': Colors.red,
        'subtitle': 'Completed only',
      },
      {
        'title': 'Completed',
        'value': '$transaksiSelesai',
        'icon': Icons.check_circle_rounded,
        'color': Colors.teal,
        'subtitle': 'Completed',
      },
      {
        'title': 'Pending',
        'value': '$transaksiPending',
        'icon': Icons.pending_actions_rounded,
        'color': Colors.orange,
        'subtitle': 'Awaiting delivery',
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 20 : 16,
        vertical: 8,
      ),
      child: isDesktop
          ? Row(
              children: stats
                  .map((stat) => Expanded(child: _buildStatCard(stat, isDesktop)))
                  .toList(),
            )
          : Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildStatCard(stats[0], isDesktop)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard(stats[1], isDesktop)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildStatCard(stats[2], isDesktop)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard(stats[3], isDesktop)),
                  ],
                ),
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
            padding: EdgeInsets.all(isDesktop ? 12 : 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(stat['icon'], color: color, size: isDesktop ? 24 : 20),
          ),
          SizedBox(width: isDesktop ? 12 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    stat['value'],
                    style: TextStyle(
                      fontSize: isDesktop ? 20 : 16,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat['title'],
                  style: TextStyle(
                    fontSize: isDesktop ? 13 : 11,
                    color: themeProvider.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (stat['subtitle'] != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    stat['subtitle'],
                    style: TextStyle(
                      fontSize: isDesktop ? 11 : 10,
                      color: themeProvider.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 20 : 16,
        vertical: 8,
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (value) {
              setState(() => _searchQuery = value);
              _debounceSearch();
            },
            decoration: InputDecoration(
              hintText: 'Search by invoice or supplier...',
              hintStyle: TextStyle(color: themeProvider.textTertiary),
              prefixIcon: Icon(Icons.search, color: themeProvider.primaryMain),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() => _searchQuery = '');
                        _loadTransactions(isRefresh: true);
                      },
                    )
                  : null,
              filled: true,
              fillColor: themeProvider.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: themeProvider.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: themeProvider.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: themeProvider.primaryMain, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filters
          if (isDesktop)
            Row(
              children: [
                Expanded(child: _buildStatusFilter()),
                const SizedBox(width: 12),
                Expanded(child: _buildPeriodFilter()),
              ],
            )
          else
            Column(
              children: [
                _buildStatusFilter(),
                const SizedBox(height: 12),
                _buildPeriodFilter(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    final themeProvider = context.read<ThemeProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: DropdownButton<String>(
        value: _filterStatus,
        icon: Icon(
          Icons.filter_list,
          color: themeProvider.primaryMain,
        ),
        underline: const SizedBox(),
        isExpanded: true,
        style: TextStyle(color: themeProvider.textPrimary, fontSize: 14),
        onChanged: (value) {
          setState(() => _filterStatus = value!);
          _loadTransactions(isRefresh: true);
        },
        items: _statusOptions.map((option) {
          return DropdownMenuItem(value: option, child: Text(option));
        }).toList(),
      ),
    );
  }

  Widget _buildPeriodFilter() {
    final themeProvider = context.read<ThemeProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: DropdownButton<String>(
        value: _filterPeriod,
        icon: Icon(
          Icons.calendar_today,
          color: themeProvider.primaryMain,
        ),
        underline: const SizedBox(),
        isExpanded: true,
        style: TextStyle(color: themeProvider.textPrimary, fontSize: 14),
        onChanged: (value) {
          setState(() => _filterPeriod = value!);
          _loadTransactions(isRefresh: true);
        },
        items: _periodOptions.map((option) {
          return DropdownMenuItem(value: option, child: Text(option));
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionsContentContainer(bool isDesktop, bool isTablet) {
    if (_isLoading && _transactions.isEmpty) {
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

    if (_transactions.isEmpty && !_isLoading) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.4,
        child: _buildEmptyState(),
      );
    }

    return _buildTransactionsListContainer(isDesktop, isTablet);
  }

  Widget _buildTransactionsListContainer(bool isDesktop, bool isTablet) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 20 : 16,
        8,
        isDesktop ? 20 : 16,
        8,
      ),
      child: Column(
        children: _transactions
            .map((transaction) => _buildModernTransactionCard(transaction, isDesktop))
            .toList(),
      ),
    );
  }

  Widget _buildModernTransactionCard(
      Map<String, dynamic> transaction, bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();
    final statusColor = _getStatusColor(transaction['status']);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Dismissible(
              key: Key('transaction_${transaction['id']}'),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                return await _showDeleteConfirmation(transaction);
              },
              onDismissed: (direction) async {
                await _deleteTransaction(transaction);
              },
              background: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline, color: Colors.white, size: 32),
                    SizedBox(height: 4),
                    Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: themeProvider.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: statusColor.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showTransactionDetail(transaction),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: EdgeInsets.all(isDesktop ? 20 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Row
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(isDesktop ? 12 : 10),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.shopping_bag_outlined,
                                  color: statusColor,
                                  size: isDesktop ? 24 : 20,
                                ),
                              ),
                              SizedBox(width: isDesktop ? 16 : 12),
                              // Transaction Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            transaction['invoice'] ?? '-',
                                            style: TextStyle(
                                              fontSize: isDesktop ? 16 : 14,
                                              fontWeight: FontWeight.bold,
                                              color: themeProvider.textPrimary,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            transaction['status'] ?? '-',
                                            style: TextStyle(
                                              fontSize: isDesktop ? 12 : 10,
                                              fontWeight: FontWeight.w600,
                                              color: statusColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      transaction['supplier_name'] ?? '-',
                                      style: TextStyle(
                                        fontSize: isDesktop ? 14 : 12,
                                        color: themeProvider.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.store_rounded,
                                          size: isDesktop ? 14 : 12,
                                          color: themeProvider.textTertiary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          transaction['toko_name'] ?? '-',
                                          style: TextStyle(
                                            fontSize: isDesktop ? 12 : 10,
                                            color: themeProvider.textTertiary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(
                                          Icons.inventory_2_rounded,
                                          size: isDesktop ? 14 : 12,
                                          color: themeProvider.textTertiary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${transaction['items_count'] ?? 0} items',
                                          style: TextStyle(
                                            fontSize: isDesktop ? 12 : 10,
                                            color: themeProvider.textTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              _getPaymentIcon(
                                                  transaction['metode_pembayaran']),
                                              size: isDesktop ? 14 : 12,
                                              color: themeProvider.primaryMain,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              transaction['metode_pembayaran'] ?? '-',
                                              style: TextStyle(
                                                fontSize: isDesktop ? 12 : 10,
                                                color: themeProvider.primaryMain,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Rp ${_formatPrice(transaction['total_harga'] ?? 0)}',
                                          style: TextStyle(
                                            fontSize: isDesktop ? 16 : 14,
                                            fontWeight: FontWeight.bold,
                                            color: themeProvider.primaryMain,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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
          ),
        );
      },
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
            _error ?? 'An error occurred',
            style: TextStyle(fontSize: 16, color: themeProvider.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () => _loadTransactions(isRefresh: true),
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
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
            Icons.shopping_cart_outlined,
            size: 64,
            color: themeProvider.primaryMain,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _searchQuery.isNotEmpty
              ? 'No transactions found'
              : 'No purchases yet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: themeProvider.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _searchQuery.isNotEmpty
              ? 'Try different search keywords'
              : 'Get started by creating new purchase order',
          style: TextStyle(fontSize: 14, color: themeProvider.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        if (_searchQuery.isEmpty)
          ElevatedButton.icon(
            onPressed: _showNewTransaction,
            icon: const Icon(Icons.add),
            label: const Text('New Purchase'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildModernFAB(ThemeProvider themeProvider) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: FloatingActionButton.extended(
            onPressed: _showNewTransaction,
            backgroundColor: themeProvider.primaryMain,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add Transaction',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    final statusLower = status.toLowerCase();
    switch (statusLower) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getPaymentIcon(String? method) {
    switch (method) {
      case 'Cash':
        return Icons.money;
      case 'QRIS':
        return Icons.qr_code_scanner;
      case 'Debit Card':
        return Icons.credit_card;
      case 'E-Wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  void _showTransactionDetail(Map<String, dynamic> transaction) async {
    // Show transaction detail in popup dialog
    final result = await OutgoingTransactionShowScreen.show(
      context,
      transaction,
    );

    // Refresh list if transaction was updated
    if (result == true) {
      _loadTransactions(isRefresh: true);
    }
  }

  void _showNewTransaction() async {
    // Navigate to create purchase order screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OutgoingTransactionCreateScreen(),
      ),
    );

    // Refresh list if new purchase order was created
    if (result == true) {
      _loadTransactions(isRefresh: true);
    }
  }

  Future<bool> _showDeleteConfirmation(
      Map<String, dynamic> transaction) async {
    final bool? shouldDelete = await context.showConfirmation(
      title: 'Delete Purchase',
      message:
          'Are you sure you want to delete purchase "${transaction['invoice']}"?\n\nThis action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
    );

    return shouldDelete ?? false;
  }

  Future<void> _deleteTransaction(Map<String, dynamic> transaction) async {
    try {
      final response =
          await OutgoingService.deleteOutgoingTransaction(transaction['id']);

      if (response['success'] == true) {
        await _loadTransactions(isRefresh: true);

        if (mounted) {
          await ValidationHandler.showSuccessDialog(
            context: context,
            title: 'Success',
            message: response['message'] ?? 'Purchase deleted successfully',
          );
        }
      } else {
        await _loadTransactions(isRefresh: true);

        if (mounted) {
          await ValidationHandler.showErrorDialog(
            context: context,
            title: 'Error',
            message: response['message'] ?? 'Failed to delete purchase',
          );
        }
      }
    } catch (e) {
      await _loadTransactions(isRefresh: true);

      if (mounted) {
        await ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'Failed to delete purchase: $e',
        );
      }
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
                    'Showing ${_transactions.isEmpty ? 0 : ((_currentPage - 1) * _perPage) + 1} - ${(_currentPage * _perPage) > _totalItems ? _totalItems : (_currentPage * _perPage)} of $_totalItems items',
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
                            _loadTransactions(isRefresh: true);
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
