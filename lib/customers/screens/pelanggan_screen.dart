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
  String _sortBy = 'Nama A-Z';
  bool _isGridView = false;

  final List<String> _sortOptions = [
    'Nama A-Z',
    'Nama Z-A',
    'Terbaru',
    'Terlama',
  ];

  // Sample customer data - Structure matched with web-posphone (pos_pelanggan table)
  // Fields: id, owner_id, nama, slug, nomor_hp, email, alamat, tanggal_bergabung
  final List<Map<String, dynamic>> _customers = [
    {
      'id': 1,
      'owner_id': 1,
      'nama': 'Ahmad Yani',
      'slug': 'ahmad-yani',
      'nomor_hp': '081234567890',
      'email': 'ahmad.yani@email.com',
      'alamat': 'Jl. Merdeka No. 123, Jakarta Pusat',
      'tanggal_bergabung': '2024-01-15',
      'totalTransactions': 45, // Calculated from transactions
      'totalSpending': 125000000, // Calculated from transactions
      'lastTransaction': '2025-12-04', // Calculated from transactions
      'avatar': 'AY',
      'color': AppTheme.primaryMain,
    },
    {
      'id': 2,
      'owner_id': 1,
      'nama': 'Siti Nurhaliza',
      'slug': 'siti-nurhaliza',
      'nomor_hp': '081234567891',
      'email': 'siti.nur@email.com',
      'alamat': 'Jl. Sudirman No. 45, Jakarta Selatan',
      'tanggal_bergabung': '2024-06-20',
      'totalTransactions': 12,
      'totalSpending': 35000000,
      'lastTransaction': '2025-12-03',
      'avatar': 'SN',
      'color': AppTheme.successColor,
    },
    {
      'id': 3,
      'owner_id': 1,
      'nama': 'Budi Santoso',
      'slug': 'budi-santoso',
      'nomor_hp': '081234567892',
      'email': 'budi.santoso@email.com',
      'alamat': 'Jl. Thamrin No. 78, Jakarta Pusat',
      'tanggal_bergabung': '2023-11-10',
      'totalTransactions': 87,
      'totalSpending': 450000000,
      'lastTransaction': '2025-12-04',
      'avatar': 'BS',
      'color': AppTheme.accentOrange,
    },
    {
      'id': 4,
      'owner_id': 1,
      'nama': 'Dewi Lestari',
      'slug': 'dewi-lestari',
      'nomor_hp': '081234567893',
      'email': 'dewi.lestari@email.com',
      'alamat': 'Jl. Gatot Subroto No. 90, Jakarta Selatan',
      'tanggal_bergabung': '2024-03-05',
      'totalTransactions': 34,
      'totalSpending': 89000000,
      'lastTransaction': '2025-12-02',
      'avatar': 'DL',
      'color': AppTheme.secondaryMain,
    },
    {
      'id': 5,
      'owner_id': 1,
      'nama': 'Rizki Ramadhan',
      'slug': 'rizki-ramadhan',
      'nomor_hp': '081234567894',
      'email': 'rizki.r@email.com',
      'alamat': 'Jl. Kuningan No. 56, Jakarta Selatan',
      'tanggal_bergabung': '2024-08-12',
      'totalTransactions': 8,
      'totalSpending': 18500000,
      'lastTransaction': '2025-11-28',
      'avatar': 'RR',
      'color': AppTheme.accentPurple,
    },
    {
      'id': 6,
      'owner_id': 1,
      'nama': 'Rina Wijaya',
      'slug': 'rina-wijaya',
      'nomor_hp': '081234567895',
      'email': 'rina.wijaya@email.com',
      'alamat': 'Jl. Rasuna Said No. 34, Jakarta Selatan',
      'tanggal_bergabung': '2023-09-18',
      'totalTransactions': 56,
      'totalSpending': 178000000,
      'lastTransaction': '2025-12-04',
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
            customer['nama'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            (customer['email']?.toString().toLowerCase() ?? '').contains(
              _searchQuery.toLowerCase(),
            ) ||
            (customer['nomor_hp']?.toString().toLowerCase() ?? '').contains(
              _searchQuery.toLowerCase(),
            );
        return matchesSearch;
      }).toList()
      ..sort((a, b) {
        switch (_sortBy) {
          case 'Nama A-Z':
            return a['nama'].toString().compareTo(b['nama'].toString());
          case 'Nama Z-A':
            return b['nama'].toString().compareTo(a['nama'].toString());
          case 'Terbaru':
            return b['tanggal_bergabung'].toString().compareTo(
              a['tanggal_bergabung'].toString(),
            );
          case 'Terlama':
            return a['tanggal_bergabung'].toString().compareTo(
              b['tanggal_bergabung'].toString(),
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
              color: themeProvider.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      color: themeProvider.surfaceColor,
      child: Column(
        children: [
          if (isDesktop)
            Row(
              children: [
                Expanded(flex: 2, child: _buildSearchBar()),
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
    final themeProvider = context.watch<ThemeProvider>();
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Cari nama, email, atau nomor telepon...',
          hintStyle: TextStyle(color: themeProvider.textTertiary),
          prefixIcon: Icon(
            Icons.search,
            color: context.read<ThemeProvider>().primaryMain,
          ),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: themeProvider.textTertiary),
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

  Widget _buildSortFilter() {
    final themeProvider = context.watch<ThemeProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: DropdownButton<String>(
        value: _sortBy,
        icon: Icon(
          Icons.sort,
          color: context.read<ThemeProvider>().primaryMain,
        ),
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
    final themeProvider = context.watch<ThemeProvider>();
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
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
    final themeProvider = context.watch<ThemeProvider>();
    final isActive = _isGridView == isGrid;
    return Material(
      color:
          isActive
              ? context.read<ThemeProvider>().primaryMain
              : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => setState(() => _isGridView = isGrid),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: isActive ? Colors.white : themeProvider.textTertiary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerList(bool isDesktop, bool isTablet) {
    final themeProvider = context.watch<ThemeProvider>();
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
                color: themeProvider.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'Tidak ada pelanggan',
                style: TextStyle(
                  fontSize: 18,
                  color: themeProvider.textSecondary,
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
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
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
                                  customer['nama'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isDesktop ? 18 : 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${customer['id']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: themeProvider.textTertiary,
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
                        customer['nomor_hp'] ?? '-',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  Icons.location_on_outlined,
                  'Alamat',
                  customer['alamat'] ?? '-',
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
                              color: themeProvider.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${customer['totalTransactions']}x',
                            style: TextStyle(
                              fontSize: isDesktop ? 18 : 16,
                              fontWeight: FontWeight.bold,
                              color: context.read<ThemeProvider>().primaryMain,
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
                              color: themeProvider.textTertiary,
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
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
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
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  customer['nama'],
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
                  style: TextStyle(
                    fontSize: 11,
                    color: themeProvider.textTertiary,
                  ),
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
                          color: context.read<ThemeProvider>().primaryMain,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${customer['totalTransactions']}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: context.read<ThemeProvider>().textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: context.read<ThemeProvider>().borderColor,
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
    final themeProvider = context.watch<ThemeProvider>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: themeProvider.textTertiary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: themeProvider.textTertiary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.textPrimary,
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
    final themeProvider = context.watch<ThemeProvider>();

    return FloatingActionButton.extended(
      onPressed: _showAddCustomer,
      backgroundColor: themeProvider.primaryMain,
      icon: const Icon(Icons.person_add, color: Colors.white),
      label: const Text(
        'Tambah Pelanggan',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
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
                                customer['nama'],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'ID: ${customer['id']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      context
                                          .read<ThemeProvider>()
                                          .textTertiary,
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
                    _buildDetailRow('Nama', customer['nama']),
                    _buildDetailRow('Email', customer['email'] ?? '-'),
                    _buildDetailRow('Telepon', customer['nomor_hp'] ?? '-'),
                    _buildDetailRow('Alamat', customer['alamat'] ?? '-'),
                    _buildDetailRow(
                      'Bergabung Sejak',
                      customer['tanggal_bergabung'],
                    ),
                    _buildDetailRow(
                      'Transaksi Terakhir',
                      customer['lastTransaction'] ?? '-',
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
                              color: context
                                  .read<ThemeProvider>()
                                  .primaryMain
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${customer['totalTransactions']}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        context
                                            .read<ThemeProvider>()
                                            .primaryMain,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Total Transaksi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        context
                                            .read<ThemeProvider>()
                                            .textTertiary,
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
                                    color:
                                        context
                                            .read<ThemeProvider>()
                                            .textTertiary,
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
                              backgroundColor:
                                  context.read<ThemeProvider>().primaryMain,
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
    final themeProvider = context.watch<ThemeProvider>();
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
                color: themeProvider.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: themeProvider.textPrimary,
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
                  backgroundColor: context.read<ThemeProvider>().primaryMain,
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
                      colors: [
                        context.read<ThemeProvider>().primaryMain,
                        context.read<ThemeProvider>().secondaryMain,
                      ],
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
              'Form edit pelanggan ${customer['nama']} akan ditampilkan di sini',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.read<ThemeProvider>().primaryMain,
                ),
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }
}
