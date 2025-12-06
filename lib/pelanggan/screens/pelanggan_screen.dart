import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/theme_provider.dart';

class PelangganScreen extends StatefulWidget {
  const PelangganScreen({super.key});

  @override
  State<PelangganScreen> createState() => _PelangganScreenState();
}

class _PelangganScreenState extends State<PelangganScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _filterType = 'Semua';
  String _sortBy = 'Nama A-Z';
  bool _isGridView = false;

  final List<String> _typeOptions = ['Semua', 'Reguler', 'VIP', 'Wholesaler'];

  final List<String> _sortOptions = [
    'Nama A-Z',
    'Nama Z-A',
    'Terbaru',
    'Terlama',
    'Transaksi Terbanyak',
    'Total Belanja Tertinggi',
  ];

  // Sample customer data
  final List<Map<String, dynamic>> _customers = [
    {
      'id': 'CST001',
      'name': 'Ahmad Yani',
      'email': 'ahmad.yani@email.com',
      'phone': '081234567890',
      'address': 'Jl. Merdeka No. 123, Jakarta Pusat',
      'type': 'VIP',
      'totalTransactions': 45,
      'totalSpending': 125000000,
      'lastTransaction': '2025-12-04',
      'joinDate': '2024-01-15',
      'avatar': 'AY',
      'color': AppTheme.primaryMain,
    },
    {
      'id': 'CST002',
      'name': 'Siti Nurhaliza',
      'email': 'siti.nur@email.com',
      'phone': '081234567891',
      'address': 'Jl. Sudirman No. 45, Jakarta Selatan',
      'type': 'Reguler',
      'totalTransactions': 12,
      'totalSpending': 35000000,
      'lastTransaction': '2025-12-03',
      'joinDate': '2024-06-20',
      'avatar': 'SN',
      'color': AppTheme.successColor,
    },
    {
      'id': 'CST003',
      'name': 'Budi Santoso',
      'email': 'budi.santoso@email.com',
      'phone': '081234567892',
      'address': 'Jl. Thamrin No. 78, Jakarta Pusat',
      'type': 'Wholesaler',
      'totalTransactions': 87,
      'totalSpending': 450000000,
      'lastTransaction': '2025-12-04',
      'joinDate': '2023-11-10',
      'avatar': 'BS',
      'color': AppTheme.accentOrange,
    },
    {
      'id': 'CST004',
      'name': 'Dewi Lestari',
      'email': 'dewi.lestari@email.com',
      'phone': '081234567893',
      'address': 'Jl. Gatot Subroto No. 90, Jakarta Selatan',
      'type': 'VIP',
      'totalTransactions': 34,
      'totalSpending': 89000000,
      'lastTransaction': '2025-12-02',
      'joinDate': '2024-03-05',
      'avatar': 'DL',
      'color': AppTheme.secondaryMain,
    },
    {
      'id': 'CST005',
      'name': 'Rizki Ramadhan',
      'email': 'rizki.r@email.com',
      'phone': '081234567894',
      'address': 'Jl. Kuningan No. 56, Jakarta Selatan',
      'type': 'Reguler',
      'totalTransactions': 8,
      'totalSpending': 18500000,
      'lastTransaction': '2025-11-28',
      'joinDate': '2024-08-12',
      'avatar': 'RR',
      'color': AppTheme.accentPurple,
    },
    {
      'id': 'CST006',
      'name': 'Rina Wijaya',
      'email': 'rina.wijaya@email.com',
      'phone': '081234567895',
      'address': 'Jl. Rasuna Said No. 34, Jakarta Selatan',
      'type': 'VIP',
      'totalTransactions': 56,
      'totalSpending': 178000000,
      'lastTransaction': '2025-12-04',
      'joinDate': '2023-09-18',
      'avatar': 'RW',
      'color': AppTheme.errorColor,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredCustomers {
    return _customers.where((customer) {
        final matchesSearch =
            customer['name'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            customer['email'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            customer['phone'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
        final matchesType =
            _filterType == 'Semua' || customer['type'] == _filterType;
        return matchesSearch && matchesType;
      }).toList()
      ..sort((a, b) {
        switch (_sortBy) {
          case 'Nama A-Z':
            return a['name'].toString().compareTo(b['name'].toString());
          case 'Nama Z-A':
            return b['name'].toString().compareTo(a['name'].toString());
          case 'Terbaru':
            return b['joinDate'].toString().compareTo(a['joinDate'].toString());
          case 'Terlama':
            return a['joinDate'].toString().compareTo(b['joinDate'].toString());
          case 'Transaksi Terbanyak':
            return (b['totalTransactions'] as int).compareTo(
              a['totalTransactions'] as int,
            );
          case 'Total Belanja Tertinggi':
            return (b['totalSpending'] as int).compareTo(
              a['totalSpending'] as int,
            );
          default:
            return 0;
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;

    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(isDesktop)),
          SliverToBoxAdapter(child: _buildStatsCards(isDesktop)),
          SliverToBoxAdapter(child: _buildFilterSection(isDesktop)),
          _buildCustomerList(isDesktop, isTablet),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [themeProvider.primaryMain, themeProvider.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: themeProvider.primaryMain.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
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
                  'Data Pelanggan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 24 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Kelola informasi & riwayat pelanggan',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isDesktop ? 14 : 12,
                  ),
                ),
              ],
            ),
          ),
          if (isDesktop) ...[
            _buildHeaderAction(
              icon: Icons.person_add,
              label: 'Tambah Pelanggan',
              onTap: () => _showAddCustomer(),
            ),
            const SizedBox(width: 8),
            _buildHeaderAction(
              icon: Icons.file_download_outlined,
              label: 'Export Data',
              onTap: () {},
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(bool isDesktop) {
    final totalCustomers = _customers.length;
    final vipCustomers = _customers.where((c) => c['type'] == 'VIP').length;
    final totalTransactions = _customers.fold<int>(
      0,
      (sum, c) => sum + (c['totalTransactions'] as int),
    );
    final totalRevenue = _customers.fold<int>(
      0,
      (sum, c) => sum + (c['totalSpending'] as int),
    );

    return Container(
      margin: EdgeInsets.all(isDesktop ? 24 : 16),
      child:
          isDesktop
              ? Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Pelanggan',
                      '$totalCustomers',
                      Icons.people_outline,
                      AppTheme.primaryMain,
                      isDesktop,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'VIP Customer',
                      '$vipCustomers',
                      Icons.stars,
                      AppTheme.accentOrange,
                      isDesktop,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Total Transaksi',
                      '$totalTransactions',
                      Icons.shopping_bag_outlined,
                      AppTheme.successColor,
                      isDesktop,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Total Revenue',
                      'Rp ${_formatPrice(totalRevenue)}',
                      Icons.account_balance_wallet,
                      AppTheme.secondaryMain,
                      isDesktop,
                    ),
                  ),
                ],
              )
              : Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Pelanggan',
                          '$totalCustomers',
                          Icons.people_outline,
                          AppTheme.primaryMain,
                          isDesktop,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'VIP',
                          '$vipCustomers',
                          Icons.stars,
                          AppTheme.accentOrange,
                          isDesktop,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Transaksi',
                          '$totalTransactions',
                          Icons.shopping_bag_outlined,
                          AppTheme.successColor,
                          isDesktop,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Revenue',
                          'Rp ${_formatPrice(totalRevenue)}',
                          Icons.account_balance_wallet,
                          AppTheme.secondaryMain,
                          isDesktop,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDesktop,
  ) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Icon(Icons.trending_up, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isDesktop ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      color: Colors.white,
      child: Column(
        children: [
          if (isDesktop)
            Row(
              children: [
                Expanded(flex: 2, child: _buildSearchBar()),
                const SizedBox(width: 16),
                Expanded(child: _buildTypeFilter()),
                const SizedBox(width: 16),
                Expanded(child: _buildSortFilter()),
                const SizedBox(width: 16),
                _buildViewToggle(),
              ],
            )
          else ...[
            _buildSearchBar(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTypeFilter()),
                const SizedBox(width: 12),
                Expanded(child: _buildSortFilter()),
                const SizedBox(width: 12),
                _buildViewToggle(),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Cari nama, email, atau nomor telepon...',
          hintStyle: TextStyle(color: AppTheme.textTertiary),
          prefixIcon: Icon(Icons.search, color: AppTheme.primaryMain),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: AppTheme.textTertiary),
                    onPressed: () => setState(() => _searchQuery = ''),
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: DropdownButton<String>(
        value: _filterType,
        icon: Icon(Icons.filter_list, color: AppTheme.primaryMain),
        underline: const SizedBox(),
        isExpanded: true,
        style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        onChanged: (value) => setState(() => _filterType = value!),
        items:
            _typeOptions.map((option) {
              return DropdownMenuItem(value: option, child: Text(option));
            }).toList(),
      ),
    );
  }

  Widget _buildSortFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: DropdownButton<String>(
        value: _sortBy,
        icon: Icon(Icons.sort, color: AppTheme.primaryMain),
        underline: const SizedBox(),
        isExpanded: true,
        style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        onChanged: (value) => setState(() => _sortBy = value!),
        items:
            _sortOptions.map((option) {
              return DropdownMenuItem(value: option, child: Text(option));
            }).toList(),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewButton(Icons.view_list_rounded, false),
          _buildViewButton(Icons.grid_view_rounded, true),
        ],
      ),
    );
  }

  Widget _buildViewButton(IconData icon, bool isGrid) {
    final isActive = _isGridView == isGrid;
    return Material(
      color: isActive ? AppTheme.primaryMain : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => setState(() => _isGridView = isGrid),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: isActive ? Colors.white : AppTheme.textTertiary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerList(bool isDesktop, bool isTablet) {
    final customers = _filteredCustomers;

    if (customers.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 80,
                color: AppTheme.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'Tidak ada pelanggan',
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isGridView) {
      final crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);
      return SliverPadding(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.85,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) =>
                _buildCustomerGridCard(customers[index], isDesktop),
            childCount: customers.length,
          ),
        ),
      );
    } else {
      return SliverPadding(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildCustomerCard(customers[index], isDesktop),
            childCount: customers.length,
          ),
        ),
      );
    }
  }

  Widget _buildCustomerCard(Map<String, dynamic> customer, bool isDesktop) {
    final typeColor = _getTypeColor(customer['type']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showCustomerDetail(customer),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 20 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: isDesktop ? 30 : 25,
                      backgroundColor: customer['color'].withOpacity(0.1),
                      child: Text(
                        customer['avatar'],
                        style: TextStyle(
                          color: customer['color'],
                          fontSize: isDesktop ? 20 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  customer['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isDesktop ? 18 : 16,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: typeColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  customer['type'],
                                  style: TextStyle(
                                    color: typeColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            customer['id'],
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.email_outlined,
                        'Email',
                        customer['email'],
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.phone_outlined,
                        'Telepon',
                        customer['phone'],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  Icons.location_on_outlined,
                  'Alamat',
                  customer['address'],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Transaksi',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${customer['totalTransactions']}x',
                            style: TextStyle(
                              fontSize: isDesktop ? 18 : 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryMain,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Belanja',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Rp ${_formatPrice(customer['totalSpending'])}',
                              style: TextStyle(
                                fontSize: isDesktop ? 18 : 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.successColor,
                              ),
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
        ),
      ),
    );
  }

  Widget _buildCustomerGridCard(Map<String, dynamic> customer, bool isDesktop) {
    final typeColor = _getTypeColor(customer['type']);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showCustomerDetail(customer),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: customer['color'].withOpacity(0.1),
                      child: Text(
                        customer['avatar'],
                        style: TextStyle(
                          color: customer['color'],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        customer['type'],
                        style: TextStyle(
                          color: typeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  customer['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  customer['email'],
                  style: TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 18,
                          color: AppTheme.primaryMain,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${customer['totalTransactions']}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: AppTheme.borderLight,
                    ),
                    Column(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 18,
                          color: AppTheme.successColor,
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _formatPriceShort(customer['totalSpending']),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
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
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.textTertiary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: AppTheme.textTertiary),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _showAddCustomer,
      backgroundColor: AppTheme.primaryMain,
      icon: const Icon(Icons.person_add, color: Colors.white),
      label: const Text(
        'Tambah Pelanggan',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'VIP':
        return AppTheme.accentOrange;
      case 'Wholesaler':
        return AppTheme.secondaryMain;
      case 'Reguler':
        return AppTheme.successColor;
      default:
        return AppTheme.textTertiary;
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _formatPriceShort(int price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}Jt';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    }
    return price.toString();
  }

  void _showCustomerDetail(Map<String, dynamic> customer) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: customer['color'].withOpacity(0.1),
                          child: Text(
                            customer['avatar'],
                            style: TextStyle(
                              color: customer['color'],
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer['name'],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                customer['id'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow('Tipe', customer['type']),
                    _buildDetailRow('Email', customer['email']),
                    _buildDetailRow('Telepon', customer['phone']),
                    _buildDetailRow('Alamat', customer['address']),
                    _buildDetailRow('Bergabung Sejak', customer['joinDate']),
                    _buildDetailRow(
                      'Transaksi Terakhir',
                      customer['lastTransaction'],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryMain.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${customer['totalTransactions']}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryMain,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Total Transaksi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textTertiary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Rp ${_formatPrice(customer['totalSpending'])}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.successColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Total Belanja',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textTertiary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showEditCustomer(customer),
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // Navigate to transaction history
                            },
                            icon: const Icon(Icons.history),
                            label: const Text('Riwayat'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryMain,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCustomer() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryMain, AppTheme.secondaryMain],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person_add, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Text('Tambah Pelanggan Baru'),
              ],
            ),
            content: const Text(
              'Form tambah pelanggan baru akan ditampilkan di sini',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryMain,
                ),
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  void _showEditCustomer(Map<String, dynamic> customer) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryMain, AppTheme.secondaryMain],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Text('Edit Pelanggan'),
              ],
            ),
            content: Text(
              'Form edit pelanggan ${customer['name']} akan ditampilkan di sini',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryMain,
                ),
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }
}
