import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import '../../component/validation_handler.dart';
import '../../layouts/screens/main_layout.dart';
import '../services/customer_service.dart';
import '../models/customer.dart';
import 'create.screen.dart';
import 'show.screen.dart';

class CustomerIndexScreen extends StatefulWidget {
  const CustomerIndexScreen({super.key});

  @override
  State<CustomerIndexScreen> createState() => _CustomerIndexScreenState();
}

class _CustomerIndexScreenState extends State<CustomerIndexScreen>
    with TickerProviderStateMixin {
  Timer? _debounceTimer;
  final _customerService = CustomerService();
  final _scrollController = ScrollController();
  
  List<Customer> _customers = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _searchQuery = '';
  String _sortBy = 'nama';
  String _sortOrder = 'asc';
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMoreData = true;
  String? _error;
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
    _loadCustomers(isRefresh: true);
    _fadeController.forward();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMore();
      }
    }
  }

  Future<void> _loadCustomers({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _customers.clear();
    }

    if (!_hasMoreData || _isLoading) return;

    setState(() {
      _isLoading = isRefresh || _currentPage == 1;
      _isLoadingMore = !isRefresh && _currentPage > 1;
      _error = null;
    });

    try {
      final result = await _customerService.getCustomers(
        page: _currentPage,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        perPage: _perPage,
      );

      if (result.success) {
        final List<Customer> newCustomers = result.customers ?? [];

        setState(() {
          if (isRefresh || _currentPage == 1) {
            _customers = newCustomers;
          } else {
            _customers.addAll(newCustomers);
          }

          if (result.pagination != null) {
            _totalPages = result.pagination!.lastPage;
            _hasMoreData = newCustomers.length >= _perPage && _currentPage < _totalPages;
            if (_hasMoreData) _currentPage++;
          } else {
            _hasMoreData = newCustomers.length >= _perPage;
            if (_hasMoreData) _currentPage++;
          }
        });
      } else {
        setState(() {
          _error = result.message;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading data: $e';
      });
      
      // If it's an authentication error, show login dialog
      if (e.toString().contains('login ulang') || e.toString().contains('Token tidak valid')) {
        if (mounted) {
          ValidationHandler.showErrorSnackBar(
            context: context,
            message: 'Session expired. Please login again.',
          );
        }
      }
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMoreData || _isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final result = await _customerService.getCustomers(
        page: _currentPage,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        perPage: _perPage,
      );

      if (result.success) {
        final List<Customer> newCustomers = result.customers ?? [];

        setState(() {
          _customers.addAll(newCustomers);
          
          if (result.pagination != null) {
            _totalPages = result.pagination!.lastPage;
            _hasMoreData = newCustomers.length >= _perPage && _currentPage < _totalPages;
            if (_hasMoreData) _currentPage++;
          } else {
            _hasMoreData = newCustomers.length >= _perPage;
            if (_hasMoreData) _currentPage++;
          }
        });
      } else {
        if (mounted) {
          ValidationHandler.showErrorSnackBar(
            context: context,
            message: result.message,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ValidationHandler.showErrorSnackBar(
          context: context,
          message: e.toString(),
        );
      }
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _debounceSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _loadCustomers(isRefresh: true);
    });
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Urutkan Berdasarkan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Nama A-Z'),
                trailing: _sortBy == 'nama' && _sortOrder == 'asc' 
                  ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() {
                    _sortBy = 'nama';
                    _sortOrder = 'asc';
                  });
                  Navigator.pop(context);
                  _loadCustomers(isRefresh: true);
                },
              ),
              ListTile(
                title: const Text('Nama Z-A'),
                trailing: _sortBy == 'nama' && _sortOrder == 'desc' 
                  ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() {
                    _sortBy = 'nama';
                    _sortOrder = 'desc';
                  });
                  Navigator.pop(context);
                  _loadCustomers(isRefresh: true);
                },
              ),
              ListTile(
                title: const Text('Terbaru'),
                trailing: _sortBy == 'created_at' && _sortOrder == 'desc' 
                  ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() {
                    _sortBy = 'created_at';
                    _sortOrder = 'desc';
                  });
                  Navigator.pop(context);
                  _loadCustomers(isRefresh: true);
                },
              ),
              ListTile(
                title: const Text('Terlama'),
                trailing: _sortBy == 'created_at' && _sortOrder == 'asc' 
                  ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() {
                    _sortBy = 'created_at';
                    _sortOrder = 'asc';
                  });
                  Navigator.pop(context);
                  _loadCustomers(isRefresh: true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteCustomer(int customerId, String customerName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.help_outline,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Title
                const Text(
                  'Delete Customer',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Content
                Text(
                  'Are you sure you want to delete "$customerName"?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                
                const Text(
                  'This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      try {
        await _customerService.deleteCustomer(customerId);
        if (mounted) {
          ValidationHandler.showSuccessSnackBar(
            context: context,
            message: 'Customer deleted successfully',
          );
          _loadCustomers(isRefresh: true);
        }
      } catch (e) {
        if (mounted) {
          ValidationHandler.showErrorSnackBar(
            context: context,
            message: e.toString(),
          );
        }
      }
    }
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
        onRefresh: () => _loadCustomers(isRefresh: true),
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
                _buildCustomersContentContainer(isDesktop, isTablet),
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
                    Icons.people_rounded,
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
                        'Customer Management',
                        style: TextStyle(
                          fontSize: isDesktop ? 24 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isDesktop ? 4 : 2),
                      Text(
                        'Manage your customer data and relationships',
                        style: TextStyle(
                          fontSize: isDesktop ? 14 : 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.sort, color: Colors.white),
                  onPressed: _showSortDialog,
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
    final activeCustomers = _customers.length;
    final totalSearchResults = _searchQuery.isNotEmpty ? _customers.length : activeCustomers;

    List<Map<String, dynamic>> stats = [
      {
        'title': 'Total Customers',
        'value': '$activeCustomers',
        'icon': Icons.people_rounded,
        'color': Colors.blue,
        'subtitle': 'Registered customers',
      },
      {
        'title': 'Search Results',
        'value': '$totalSearchResults',
        'icon': Icons.search_rounded,
        'color': Colors.green,
        'subtitle': _searchQuery.isNotEmpty ? 'Found customers' : 'All customers',
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
                Text(
                  stat['title'],
                  style: TextStyle(
                    fontSize: isDesktop ? 12 : 10,
                    color: themeProvider.textSecondary,
                  ),
                ),
                Text(
                  stat['subtitle'],
                  style: TextStyle(
                    fontSize: isDesktop ? 11 : 9,
                    color: themeProvider.textSecondary.withOpacity(0.7),
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
          hintText: 'Search customers by name, email, or phone...',
          hintStyle: TextStyle(
            color: themeProvider.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: themeProvider.textSecondary,
          ),
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
            borderSide: BorderSide(color: themeProvider.borderColor.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: themeProvider.primaryMain,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: themeProvider.surfaceColor,
        ),
      ),
    );
  }

  Widget _buildCustomersContentContainer(bool isDesktop, bool isTablet) {
    if (_isLoading && _customers.isEmpty) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.4,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    } else if (_customers.isEmpty && !_isLoading) {
      return _buildEmptyState(isDesktop);
    } else {
      return _buildCustomersList(isDesktop, isTablet);
    }
  }

  Widget _buildErrorState() {
    final themeProvider = context.watch<ThemeProvider>();
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
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
          Text(
            _error!,
            style: TextStyle(color: themeProvider.textSecondary, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _loadCustomers(isRefresh: true),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();
    return Container(
      padding: EdgeInsets.all(isDesktop ? 60 : 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isDesktop ? 24 : 20),
            decoration: BoxDecoration(
              color: themeProvider.primaryMain.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.people_outline,
              size: isDesktop ? 72 : 64,
              color: themeProvider.primaryMain,
            ),
          ),
          SizedBox(height: isDesktop ? 24 : 16),
          Text(
            _searchQuery.isNotEmpty ? 'No customers found' : 'No customers yet',
            style: TextStyle(
              fontSize: isDesktop ? 20 : 18,
              fontWeight: FontWeight.w600,
              color: themeProvider.textPrimary,
            ),
          ),
          SizedBox(height: isDesktop ? 12 : 8),
          Text(
            _searchQuery.isNotEmpty 
              ? 'Try adjusting your search terms'
              : 'Add your first customer to get started',
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: themeProvider.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isEmpty) ...[
            SizedBox(height: isDesktop ? 24 : 20),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomerCreateScreen(),
                  ),
                );
                if (result == true) {
                  _loadCustomers(isRefresh: true);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Customer'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : 24,
                  vertical: isDesktop ? 16 : 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomersList(bool isDesktop, bool isTablet) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 20 : 16,
        8,
        isDesktop ? 20 : 16,
        80, // Extra bottom padding for FAB clearance
      ),
      itemCount: _customers.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _customers.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return _buildModernCustomerCard(_customers[index], isDesktop);
      },
    );
  }

  Widget _buildModernCustomerCard(Customer customer, bool isDesktop) {
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
                  onTap: () async {
                    await CustomerShowScreen.show(context, customer.id!);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: EdgeInsets.all(isDesktop ? 20 : 16),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'customer-${customer.id}',
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
                                  color: themeProvider.primaryMain.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                customer.nama.isNotEmpty ? customer.nama.substring(0, 1).toUpperCase() : '?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isDesktop ? 20 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: isDesktop ? 16 : 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.nama,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isDesktop ? 18 : 16,
                                  color: themeProvider.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: isDesktop ? 4 : 2),
                              if (customer.nomorHp != null && customer.nomorHp!.isNotEmpty) ...[
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
                                        customer.nomorHp!,
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
                                SizedBox(height: isDesktop ? 2 : 1),
                              ],
                              if (customer.email != null && customer.email!.isNotEmpty) ...[
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
                                        customer.email!,
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
                          onPressed: () => _deleteCustomer(customer.id!, customer.nama),
                          icon: Icon(
                            Icons.delete,
                            size: isDesktop ? 20 : 18,
                            color: Colors.red,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Delete Customer',
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

  Widget _buildModernFAB(ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: themeProvider.primaryMain.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CustomerCreateScreen(),
            ),
          );
          if (result == true) {
            _loadCustomers(isRefresh: true);
          }
        },
        backgroundColor: themeProvider.primaryMain,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Customer'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
