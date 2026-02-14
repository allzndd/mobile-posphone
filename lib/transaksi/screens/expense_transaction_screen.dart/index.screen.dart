import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme_provider.dart';
import '../../../component/validation_handler.dart';
import '../../services/expense_transaction_service.dart';
import '../../models/expense_transaction.dart' as ExpenseTransactionModel;
import 'create.screen.dart';
import 'show.screen.dart';

class ExpenseTransactionIndexScreen extends StatefulWidget {
  const ExpenseTransactionIndexScreen({super.key});

  @override
  State<ExpenseTransactionIndexScreen> createState() =>
      _ExpenseTransactionIndexScreenState();
}

class _ExpenseTransactionIndexScreenState
    extends State<ExpenseTransactionIndexScreen>
    with TickerProviderStateMixin {
  Timer? _debounceTimer;
  String _searchQuery = '';
  bool _isLoading = false;
  List<ExpenseTransactionModel.PosExpenseTransactionModel> _transactions = [];
  String? _error;
  int _currentPage = 1;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;
  final int _perPage = 10;
  int _totalPages = 1;
  int _totalItems = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();

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
      _hasMoreData = true;
      _transactions.clear();
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ExpenseTransactionService.getExpenseTransactions(
        page: _currentPage,
        perPage: _perPage,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (response['success'] == true) {
        final List<dynamic> transactionData = response['data'] ?? [];
        final List<ExpenseTransactionModel.PosExpenseTransactionModel>
        newTransactions =
            transactionData
                .map(
                  (json) => ExpenseTransactionModel
                      .PosExpenseTransactionModel.fromJson(json),
                )
                .toList();

        final int totalItems = response['total'] ?? transactionData.length;
        final int lastPage = response['last_page'] ?? 1;
        final int currentPage = response['current_page'] ?? _currentPage;

        setState(() {
          _transactions = newTransactions;
          _totalItems = totalItems;
          _totalPages = lastPage > 0 ? lastPage : 1;
          _currentPage = currentPage;
          _hasMoreData = _currentPage < _totalPages;
        });

        if (page != null && _scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load expense transactions';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;

    return Scaffold(
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
                _buildSearchSection(isDesktop),
                _buildTransactionsContentContainer(isDesktop, isTablet),
                SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildModernFAB(themeProvider),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                    Icons.receipt_long_rounded,
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
                        'Expense Transactions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isDesktop ? 28 : 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage your expense transactions',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: isDesktop ? 14 : 12,
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
    final totalTransactions = _transactions.length;
    final totalExpense = _transactions.fold<double>(
      0,
      (sum, item) => sum + item.totalHarga,
    );

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 20 : 16,
        vertical: 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              themeProvider,
              'Total Transactions',
              totalTransactions.toString(),
              Icons.receipt_long_rounded,
              themeProvider.primaryMain,
              isDesktop,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              themeProvider,
              'Total Expense',
              _formatCurrency(totalExpense),
              Icons.attach_money_rounded,
              Colors.red,
              isDesktop,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    ThemeProvider theme,
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDesktop,
  ) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isDesktop ? 14 : 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: isDesktop ? 28 : 24),
          ),
          SizedBox(width: isDesktop ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isDesktop ? 12 : 10,
                    color: theme.textSecondary,
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
        vertical: 12,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: themeProvider.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) {
            setState(() => _searchQuery = value);
            _debounceSearch();
          },
          style: TextStyle(color: themeProvider.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search expense transactions...',
            hintStyle: TextStyle(color: themeProvider.textTertiary),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: themeProvider.primaryMain,
            ),
            suffixIcon:
                _searchQuery.isNotEmpty
                    ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: themeProvider.textSecondary,
                      ),
                      onPressed: () {
                        setState(() => _searchQuery = '');
                        _loadTransactions(isRefresh: true);
                      },
                    )
                    : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(isDesktop ? 20 : 16),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsContentContainer(bool isDesktop, bool isTablet) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      margin: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_isLoading && _transactions.isEmpty)
            _buildLoadingState()
          else if (_error != null)
            _buildErrorState()
          else if (_transactions.isEmpty)
            _buildEmptyState()
          else
            _buildTransactionsList(isDesktop, isTablet),
          if (_transactions.isNotEmpty && !_isLoading)
            _buildPaginationControls(isDesktop),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    final themeProvider = context.watch<ThemeProvider>();
    return Container(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: CircularProgressIndicator(color: themeProvider.primaryMain),
      ),
    );
  }

  Widget _buildErrorState() {
    final themeProvider = context.watch<ThemeProvider>();
    return Container(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: themeProvider.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Unknown error',
            style: TextStyle(color: themeProvider.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _loadTransactions(isRefresh: true),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final themeProvider = context.watch<ThemeProvider>();
    return Container(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: themeProvider.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: themeProvider.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first expense transaction',
            style: TextStyle(color: themeProvider.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(bool isDesktop, bool isTablet) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        return _buildTransactionCard(transaction, isDesktop);
      },
    );
  }

  Widget _buildTransactionCard(
    ExpenseTransactionModel.PosExpenseTransactionModel transaction,
    bool isDesktop,
  ) {
    final themeProvider = context.watch<ThemeProvider>();

    return InkWell(
      onTap: () async {
        final result = await showDialog(
          context: context,
          builder:
              (context) =>
                  ExpenseTransactionShowDialog(transaction: transaction),
        );
        if (result == true) {
          _loadTransactions(isRefresh: true);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 20 : 16),
        decoration: BoxDecoration(
          color: themeProvider.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeProvider.textTertiary.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isDesktop ? 12 : 10),
              decoration: BoxDecoration(
                color: themeProvider.primaryMain.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                color: themeProvider.primaryMain,
                size: isDesktop ? 24 : 20,
              ),
            ),
            SizedBox(width: isDesktop ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.invoice ?? 'No Invoice',
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 14,
                      fontWeight: FontWeight.w600,
                      color: themeProvider.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    transaction.kategoriExpenseName ?? 'Unknown Category',
                    style: TextStyle(
                      fontSize: isDesktop ? 13 : 12,
                      color: themeProvider.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _formatCurrency(transaction.totalHarga),
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _deleteTransaction(transaction),
              icon: Icon(
                Icons.delete,
                size: isDesktop ? 20 : 18,
                color: Colors.red,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
              tooltip: 'Delete Transaction',
            ),
          ],
        ),
      ),
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
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Showing ${_transactions.isEmpty ? 0 : ((_currentPage - 1) * _perPage) + 1} - ${(_currentPage * _perPage) > _totalItems ? _totalItems : (_currentPage * _perPage)} of $_totalItems items',
              style: TextStyle(
                color: themeProvider.textSecondary,
                fontSize: isDesktop ? 14 : 12,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              ..._buildPageNumbers(isDesktop),
              const SizedBox(width: 12),
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
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();
    List<Widget> pageButtons = [];

    int startPage = _currentPage - 5;
    int endPage = _currentPage + 4;

    if (startPage < 1) {
      startPage = 1;
      endPage = _totalPages < 10 ? _totalPages : 10;
    }

    if (endPage > _totalPages) {
      endPage = _totalPages;
      startPage = _totalPages - 9 > 0 ? _totalPages - 9 : 1;
    }

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

    for (int i = startPage; i <= endPage; i++) {
      pageButtons.add(_buildPageButton(i, isDesktop));
    }

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

  Future<void> _deleteTransaction(
    ExpenseTransactionModel.PosExpenseTransactionModel transaction,
  ) async {
    final bool? shouldDelete = await context.showConfirmation(
      title: 'Delete Transaction',
      message:
          'Are you sure you want to delete transaction "${transaction.invoice}"?\n\nThis action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
    );

    if (shouldDelete != true) return;

    try {
      final response = await ExpenseTransactionService.deleteExpenseTransaction(
        transaction.id,
      );

      if (response['success'] == true) {
        await _loadTransactions(isRefresh: true);

        if (mounted) {
          await ValidationHandler.showSuccessDialog(
            context: context,
            title: 'Success',
            message: 'Transaction deleted successfully',
          );
        }
      } else {
        if (mounted) {
          await ValidationHandler.showErrorDialog(
            context: context,
            title: 'Error',
            message: response['message'] ?? 'Failed to delete transaction',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        await ValidationHandler.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'Error deleting transaction: $e',
        );
      }
    }
  }

  Widget _buildModernFAB(ThemeProvider themeProvider) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ExpenseTransactionCreateScreen(),
          ),
        ).then((_) => _loadTransactions(isRefresh: true));
      },
      backgroundColor: themeProvider.primaryMain,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text(
        'Add Transaction',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}
