import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../config/theme_provider.dart';
import '../models/admin_user_model.dart';
import '../services/user_management_service.dart';
import '../../layouts/screens/main_layout.dart';
import 'create.screen.dart';
import 'edit.screen.dart';
import 'show_admin_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<AdminUserModel> _admins = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAdminUsers();
  }

  Future<void> _loadAdminUsers() async {
    setState(() => _isLoading = true);

    try {
      final result = await UserManagementService.getAdminUsers();

      if (mounted) {
        setState(() {
          if (result['success'] == true) {
            _admins = result['data'] as List<AdminUserModel>;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load admin users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<AdminUserModel> get _filteredAdmins {
    if (_searchQuery.isEmpty) {
      return _admins;
    }
    return _admins.where((admin) {
      return admin.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          admin.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _showDeleteDialog(AdminUserModel admin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Delete Admin')),
          ],
        ),
        content: Text(
          'Are you sure you want to delete ${admin.nama}?\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAdmin(admin.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAdmin(int id) async {
    final result = await UserManagementService.deleteAdminUser(id);

    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Admin deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadAdminUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to delete admin'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        // Navigate ke dashboard (index 0)
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MainLayout(title: 'Dashboard', selectedIndex: 0),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        body: RefreshIndicator(
        onRefresh: _loadAdminUsers,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(isDesktop)),
            SliverToBoxAdapter(child: _buildSearchBar(isDesktop)),
            if (_isLoading)
              SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: themeProvider.primaryMain,
                  ),
                ),
              )
            else if (_filteredAdmins.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(),
              )
            else
              SliverPadding(
                padding: EdgeInsets.all(isDesktop ? 20 : 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final admin = _filteredAdmins[index];
                      return _buildAdminCard(admin, isDesktop);
                    },
                    childCount: _filteredAdmins.length,
                  ),
                ),
              ),
          ],
        ),
      ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateAdminScreen(),
              ),
            );
            if (result == true) {
              _loadAdminUsers();
            }
          },
          backgroundColor: themeProvider.primaryMain,
          icon: const Icon(
            Icons.add,
            color: Colors.white,
            size: 24,
          ),
          label: const Text(
            'Add Admin',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      margin: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [themeProvider.primaryMain, themeProvider.primaryDark],
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
                        'User Management',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isDesktop ? 28 : 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage admin accounts',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: isDesktop ? 15 : 14,
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

  Widget _buildSearchBar(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 20 : 16,
        vertical: 8,
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search by name or email...',
          prefixIcon: Icon(Icons.search, color: themeProvider.primaryMain),
          filled: true,
          fillColor: themeProvider.surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: themeProvider.borderColor.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: themeProvider.primaryMain,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard(AdminUserModel admin, bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.borderColor.withOpacity(0.3),
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
          onTap: () async {
            final result = await ShowAdminScreen.show(context, admin);
            if (result == true) {
              _loadAdminUsers();
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 20 : 16),
            child: Row(
              children: [
            Container(
              width: isDesktop ? 60 : 50,
              height: isDesktop ? 60 : 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryMain, AppTheme.secondaryMain],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  admin.nama.isNotEmpty
                      ? admin.nama.substring(0, 1).toUpperCase()
                      : 'A',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 24 : 20,
                    fontWeight: FontWeight.bold,
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
                    admin.nama,
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    admin.email,
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 12,
                      color: themeProvider.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.infoColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Admin',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.infoColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (admin.storeName != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryMain.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.store,
                                size: 12,
                                color: AppTheme.primaryMain,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                admin.storeName!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.primaryMain,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _showDeleteDialog(admin),
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Delete',
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final themeProvider = context.watch<ThemeProvider>();

    return Center(
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
            'No admin users found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: themeProvider.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first admin user',
            style: TextStyle(
              fontSize: 14,
              color: themeProvider.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
