import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme_provider.dart';
import '../../../component/validation_handler.dart';
import '../../../layouts/screens/main_layout.dart';
import '../../services/history_transaction_service.dart';
import 'show.screen.dart';

class HistoryTransactionIndexScreen extends StatefulWidget {
  const HistoryTransactionIndexScreen({super.key});

  @override
  State<HistoryTransactionIndexScreen> createState() =>
      _HistoryTransactionIndexScreenState();
}

class _HistoryTransactionIndexScreenState
    extends State<HistoryTransactionIndexScreen>
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
  String _filterType = 'All';

  final List<String> _statusOptions = [
    'All',
    'Completed',
    'Pending',
    'Cancelled',
  ];

  final List<String> _typeOptions = [
    'All',
    'Incoming',
    'Outgoing',
  ];

  // Summary data
  int _totalTransactions = 0;
  int _incomingCount = 0;
  int _outgoingCount = 0;
  double _totalRevenue = 0;
  double _totalExpenses = 0;
  int _pendingCount = 0;
  int _completedCount = 0;

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
    _loadSummary();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSummary() async {
    try {
      final response = await HistoryTransactionService.getHistorySummary(
        status: _filterStatus != 'All' ? _filterStatus : null,
        type: _filterType != 'All' ? _filterType : null,
      );

      if (response['success'] == true && mounted) {
        final data = response['data'];
        setState(() {
          _totalTransactions = _toInt(data['total_transactions']);
          _incomingCount = _toInt(data['incoming_transactions']);
          _outgoingCount = _toInt(data['outgoing_transactions']);
          _totalRevenue = _toDouble(data['total_revenue']);
          _totalExpenses = _toDouble(data['total_expenses']);
          _pendingCount = _toInt(data['pending_count']);
          _completedCount = _toInt(data['completed_count']);
        });
      }
    } catch (e) {
      // Silently handle summary errors
      debugPrint('Error loading summary: $e');
    }
  }

  // Helper to safely convert dynamic to int
  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Helper to safely convert dynamic to double
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
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
      final response = await HistoryTransactionService.getHistoryTransactions(
        page: _currentPage,
        perPage: _perPage,
        type: _filterType != 'All' ? _filterType : null,
        status: _filterStatus != 'All' ? _filterStatus : null,
        invoice: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (response['success'] == true) {
        final List<dynamic> historyList = response['data'] ?? [];
        final List<Map<String, dynamic>> newTransactions =
            historyList.map((transaction) {
          final isIncoming = _toInt(transaction.isTransaksiMasuk) == 1;

          return {
            'id': transaction.id,
            'invoice': transaction.invoice ?? '-',
            'total_harga': _toInt(transaction.totalHarga),
            'status': transaction.status ?? 'Unknown',
            'metode_pembayaran': transaction.metodePembayaran ?? 'Unknown',
            'created_at': transaction.createdAt?.toString() ?? '',
            'customer_name': transaction.pelanggan?.nama ?? 
                             (transaction.supplier?.nama ?? '-'),
            'toko_name': transaction.toko?.nama ?? '-',
            'items_count': transaction.items?.length ?? 0,
            'keterangan': transaction.keterangan,
            'is_transaksi_masuk': transaction.isTransaksiMasuk,
            'is_incoming': isIncoming,
            'type': isIncoming ? 'Incoming' : 'Outgoing',
            'pos_pelanggan_id': transaction.posPelangganId,
            'pos_supplier_id': transaction.posSupplierId,
            'pos_toko_id': transaction.posTokoId,
            'pos_tukar_tambah_id': transaction.posTukarTambahId,
            'items': transaction.items?.map((item) => {
              'pos_produk_id': item.posProdukId,
              'pos_service_id': item.posServiceId,
              'product_name': item.produk?.nama ?? 
                            (item.service?.nama ?? '-'),
              'produk_nama': item.produk?.nama ?? 
                           (item.service?.nama ?? '-'),
              'quantity': _toInt(item.quantity),
              'harga_satuan': _toInt(item.hargaSatuan),
              'diskon': _toInt(item.diskon),
              'subtotal': _toInt(item.subtotal),
            }).toList(),
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

        // Reload summary
        _loadSummary();
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
                title: 'Dashboard',
                selectedIndex: 0,
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
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildModernHeader(isDesktop),
                  _buildStatsCards(isDesktop, isTablet),
                  _buildFilterSection(isDesktop),
                  _buildTransactionsContentContainer(isDesktop, isTablet),
                  if (!_isLoading && _transactions.isNotEmpty)
                    _buildPaginationControls(isDesktop),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      margin: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeProvider.primaryMain,
            themeProvider.primaryMain.withOpacity(0.8),
          ],
        ),
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
                    Icons.history_rounded,
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
                        'Transaction History',
                        style: TextStyle(
                          fontSize: isDesktop ? 24 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isDesktop ? 4 : 2),
                      Text(
                        'View all transaction records',
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

    List<Map<String, dynamic>> stats = [
      {
        'title': 'Total Transactions',
        'value': '$_totalTransactions',
        'icon': Icons.receipt_long_rounded,
        'color': Colors.blue,
        'subtitle': 'All records',
      },
      {
        'title': 'Incoming',
        'value': '$_incomingCount',
        'icon': Icons.arrow_downward_rounded,
        'color': Colors.green,
        'subtitle': 'Sales',
      },
      {
        'title': 'Outgoing',
        'value': '$_outgoingCount',
        'icon': Icons.arrow_upward_rounded,
        'color': Colors.red,
        'subtitle': 'Purchases',
      },
      {
        'title': 'Net Revenue',
        'value': 'Rp ${_formatPrice((_totalRevenue - _totalExpenses).toInt())}',
        'icon': Icons.account_balance_wallet_rounded,
        'color': _totalRevenue >= _totalExpenses ? Colors.teal : Colors.orange,
        'subtitle': 'Revenue - Expenses',
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
                  .map(
                    (stat) => Expanded(
                      child: _buildStatCard(stat, isDesktop),
                    ),
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
                Row(
                  children: [
                    Expanded(child: _buildStatCard(stats[2], false)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatCard(stats[3], false)),
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
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    stat['value'],
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 14,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    stat['subtitle'],
                    style: TextStyle(
                      fontSize: isDesktop ? 11 : 10,
                      color: themeProvider.textSecondary,
                    ),
                  ),
                ),
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
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _debounceSearch();
            },
            decoration: InputDecoration(
              hintText: 'Search by invoice...',
              hintStyle: TextStyle(color: themeProvider.textTertiary),
              prefixIcon: Icon(Icons.search, color: themeProvider.primaryMain),
              filled: true,
              fillColor: themeProvider.backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 20 : 16,
                vertical: isDesktop ? 16 : 12,
              ),
            ),
          ),
          SizedBox(height: isDesktop ? 16 : 12),
          // Filter chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Type filter
              _buildFilterDropdown(
                'Type',
                _filterType,
                _typeOptions,
                (value) {
                  setState(() {
                    _filterType = value!;
                  });
                  _loadTransactions(isRefresh: true);
                },
                Icons.swap_vert_rounded,
                isDesktop,
              ),
              // Status filter
              _buildFilterDropdown(
                'Status',
                _filterStatus,
                _statusOptions,
                (value) {
                  setState(() {
                    _filterStatus = value!;
                  });
                  _loadTransactions(isRefresh: true);
                },
                Icons.filter_list_rounded,
                isDesktop,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String currentValue,
    List<String> options,
    Function(String?) onChanged,
    IconData icon,
    bool isDesktop,
  ) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: themeProvider.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isDesktop ? 18 : 16, color: themeProvider.primaryMain),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: currentValue,
            underline: const SizedBox(),
            isDense: true,
            style: TextStyle(
              color: themeProvider.textPrimary,
              fontSize: isDesktop ? 14 : 12,
            ),
            items: options.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text('$label: $value'),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsContentContainer(bool isDesktop, bool isTablet) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 20 : 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _isLoading
          ? Container(
              padding: const EdgeInsets.all(64),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      color: themeProvider.primaryMain,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading transactions...',
                      style: TextStyle(color: themeProvider.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          : _error != null
              ? Padding(
                  padding: const EdgeInsets.all(64),
                  child: _buildErrorState(),
                )
              : _transactions.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(64),
                      child: _buildEmptyState(),
                    )
                  : _buildTransactionsList(isDesktop, isTablet),
    );
  }

  Widget _buildTransactionsList(bool isDesktop, bool isTablet) {
    final themeProvider = context.watch<ThemeProvider>();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      itemCount: _transactions.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: isDesktop ? 12 : 8),
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        final isIncoming = transaction['is_incoming'] == true;
        final statusColor = _getStatusColor(transaction['status'] ?? 'Unknown');
        final typeColor = isIncoming ? Colors.green : Colors.red;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 50)),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Container(
                  decoration: BoxDecoration(
                    color: themeProvider.backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: typeColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: typeColor.withOpacity(0.1),
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
                        child: Row(
                          children: [
                            // Type indicator
                            Container(
                              padding: EdgeInsets.all(isDesktop ? 14 : 12),
                              decoration: BoxDecoration(
                                color: typeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isIncoming
                                    ? Icons.arrow_downward_rounded
                                    : Icons.arrow_upward_rounded,
                                color: typeColor,
                                size: isDesktop ? 28 : 24,
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
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: typeColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          transaction['type'] ?? '-',
                                          style: TextStyle(
                                            fontSize: isDesktop ? 11 : 9,
                                            fontWeight: FontWeight.w600,
                                            color: typeColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          transaction['status'] ?? '-',
                                          style: TextStyle(
                                            fontSize: isDesktop ? 11 : 9,
                                            fontWeight: FontWeight.w600,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    transaction['customer_name'] ?? '-',
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
                                        Icons.shopping_bag_rounded,
                                        size: isDesktop ? 14 : 12,
                                        color: themeProvider.textTertiary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${transaction['items_count']} items',
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
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Rp ${_formatPrice(transaction['total_harga'] ?? 0)}',
                                        style: TextStyle(
                                          fontSize: isDesktop ? 16 : 14,
                                          fontWeight: FontWeight.bold,
                                          color: typeColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
            _error!,
            style: TextStyle(color: themeProvider.textSecondary, fontSize: 16),
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
            Icons.history_rounded,
            size: 64,
            color: themeProvider.primaryMain,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _searchQuery.isNotEmpty
              ? 'No transactions found'
              : 'No transaction history',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: themeProvider.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _searchQuery.isNotEmpty
              ? 'Try adjusting your search or filters'
              : 'Transaction history will appear here',
          style: TextStyle(fontSize: 14, color: themeProvider.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
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
                              _currentPage = 1;
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

          // Pagination controls
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
      case 'Debit':
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

  void _showTransactionDetail(Map<String, dynamic> transaction) {
    HistoryTransactionShowScreen.show(context, transaction);
  }
}
