import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme_provider.dart';
import '../../component/validation_handler.dart';
import '../services/customer_service.dart';
import '../models/customer.dart';
import 'edit.screen.dart';

class CustomerShowScreen extends StatefulWidget {
  final int customerId;
  final Customer? initialCustomer;

  const CustomerShowScreen({
    super.key, 
    required this.customerId,
    this.initialCustomer,
  });

  static Future<void> show(BuildContext context, int customerId) async {
    // Pre-load customer data
    Customer? customer;
    try {
      final customerResult = await CustomerService().getCustomer(customerId);
      if (customerResult.success && customerResult.data != null) {
        customer = customerResult.data!;
      }
    } catch (e) {
      // Handle error silently, will be shown in dialog
    }

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width > 600 ? 40 : 16,
            vertical: 24,
          ),
          child: CustomerShowScreen(
            customerId: customerId,
            initialCustomer: customer,
          ),
        ),
      );
    }
  }

  @override
  State<CustomerShowScreen> createState() => _CustomerShowScreenState();
}

class _CustomerShowScreenState extends State<CustomerShowScreen> {
  Customer? _customer;
  CustomerStats? _customerStats;

  @override
  void initState() {
    super.initState();
    // Use initial customer data if available
    _customer = widget.initialCustomer;
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    try {
      // Only load customer data if not already provided
      if (_customer == null) {
        final customerResult = await CustomerService().getCustomer(widget.customerId);
        
        if (customerResult.success && customerResult.data != null) {
          setState(() {
            _customer = customerResult.data!;
          });
        }
      }

      // Try to load stats separately (optional)
      try {
        final stats = await CustomerService().getCustomerStats();
        setState(() {
          _customerStats = stats;
        });
      } catch (e) {
        // Stats are optional, so ignore errors
        print('Failed to load customer stats: $e');
      }
    } catch (e) {
      if (mounted) {
        ValidationHandler.showErrorSnackBar(
          context: context,
          message: 'Failed to load customer data: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
        maxWidth: isMobile ? double.infinity : (isTablet ? 500 : 600),
      ),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Customer Icon
            _buildCustomerHeader(themeProvider, isMobile),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Name & Title
                    _buildCustomerTitle(themeProvider, isMobile),

                    SizedBox(height: isMobile ? 16 : 20),

                    // Customer Information Section
                    _buildCustomerInfoSection(themeProvider, isMobile),

                    SizedBox(height: isMobile ? 12 : 16),

                    // Contact Information Section
                    _buildContactInfoSection(themeProvider, isMobile),
                  ],
                ),
              ),
            ),

            // Action Buttons
            _buildActionButtons(context, themeProvider, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerHeader(ThemeProvider themeProvider, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeProvider.primaryMain,
            themeProvider.primaryMain.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          // Customer Icon
          Hero(
            tag: 'customer-${widget.customerId}',
            child: Container(
              width: isMobile ? 60 : 80,
              height: isMobile ? 60 : 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
              ),
              child: Center(
                child: Text(
                  _customer?.nama != null && _customer!.nama.isNotEmpty ? _customer!.nama.substring(0, 1).toUpperCase() : '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 28 : 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: isMobile ? 12 : 16),

          // Customer Badge
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 12,
                  vertical: isMobile ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person,
                      color: Colors.white,
                      size: isMobile ? 14 : 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Customer',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: isMobile ? 10 : 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerTitle(ThemeProvider themeProvider, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _customer?.nama ?? 'Customer Details',
          style: TextStyle(
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: themeProvider.textPrimary,
            height: 1.2,
          ),
        ),
        SizedBox(height: isMobile ? 4 : 6),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 10,
            vertical: isMobile ? 4 : 6,
          ),
          decoration: BoxDecoration(
            color: themeProvider.primaryMain.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _customer?.createdAt != null 
                ? 'Member since ${DateFormat('MMM yyyy').format(_customer!.createdAt!)}'
                : 'Customer Information',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.w500,
              color: themeProvider.primaryMain,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(ThemeProvider themeProvider, bool isMobile) {
    return SliverAppBar(
      expandedHeight: isMobile ? 200 : 240,
      floating: false,
      pinned: true,
      backgroundColor: themeProvider.primaryMain,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerEditScreen(
                  customerId: _customer!.id!,
                ),
              ),
            );
            if (result == true) {
              _loadCustomerData();
            }
          },
          icon: const Icon(Icons.edit, color: Colors.white),
          tooltip: 'Edit Customer',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                themeProvider.primaryMain,
                themeProvider.primaryMain.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        width: isMobile ? 60 : 80,
                        height: isMobile ? 60 : 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            _customer?.nama.isNotEmpty == true ? _customer!.nama.substring(0, 1).toUpperCase() : '?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 28 : 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: isMobile ? 12 : 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _customer?.nama ?? 'Customer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 20 : 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 8 : 10,
                                vertical: isMobile ? 4 : 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified_user,
                                    color: Colors.white,
                                    size: isMobile ? 14 : 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Active Customer',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isMobile ? 10 : 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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
      ),
    );
  }

  Widget _buildStatsSection(ThemeProvider themeProvider, bool isMobile) {
    final stats = [
      {
        'title': 'Total Orders',
        'value': '${_customer?.totalTransaksi ?? 0}',
        'icon': Icons.shopping_cart_outlined,
        'color': Colors.blue,
      },
      {
        'title': 'Total Spent',
        'value': 'Rp ${NumberFormat('#,##0').format(_customer?.totalNilaiTransaksi ?? 0)}',
        'icon': Icons.monetization_on_outlined,
        'color': Colors.green,
      },
      {
        'title': 'Join Date',
        'value': _customer?.tanggalBergabung != null 
            ? DateFormat('dd MMM yyyy').format(_customer!.tanggalBergabung!)
            : 'N/A',
        'icon': Icons.calendar_today_outlined,
        'color': Colors.orange,
      },
    ];

    return Container(
      margin: EdgeInsets.all(isMobile ? 16 : 24),
      child: isMobile
          ? Column(
              children: stats.map((stat) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildStatCard(stat, themeProvider, isMobile),
                )
              ).toList(),
            )
          : Row(
              children: stats.map((stat) => 
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildStatCard(stat, themeProvider, isMobile),
                  ),
                )
              ).toList(),
            ),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat, ThemeProvider themeProvider, bool isMobile) {
    final color = stat['color'] as Color;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  stat['icon'],
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            stat['value'],
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat['title'],
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoSection(ThemeProvider themeProvider, bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 8 : 12,
      ),
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeProvider.primaryMain.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: themeProvider.primaryMain,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Customer Information',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildInfoRow(
            'Full Name',
            _customer?.nama ?? '-',
            Icons.person_outline,
            themeProvider,
            isMobile,
          ),
          if (_customer?.createdAt != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              'Member Since',
              DateFormat('dd MMMM yyyy').format(_customer!.createdAt!),
              Icons.calendar_today_outlined,
              themeProvider,
              isMobile,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactInfoSection(ThemeProvider themeProvider, bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 8 : 12,
      ),
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.contact_phone_rounded,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          if (_customer?.nomorHp != null && _customer!.nomorHp!.isNotEmpty) ...[
            _buildInfoRow(
              'Phone Number',
              _customer!.nomorHp!,
              Icons.phone_outlined,
              themeProvider,
              isMobile,
            ),
            const SizedBox(height: 12),
          ],
          if (_customer?.email != null && _customer!.email!.isNotEmpty) ...[
            _buildInfoRow(
              'Email Address',
              _customer!.email!,
              Icons.email_outlined,
              themeProvider,
              isMobile,
            ),
            const SizedBox(height: 12),
          ],
          if (_customer?.alamat != null && _customer!.alamat!.isNotEmpty) ...[
            _buildInfoRow(
              'Address',
              _customer!.alamat!,
              Icons.location_on_outlined,
              themeProvider,
              isMobile,
              isMultiline: true,
            ),
          ],
          if ((_customer?.nomorHp == null || _customer!.nomorHp!.isEmpty) && 
              (_customer?.email == null || _customer!.email!.isEmpty) && 
              (_customer?.alamat == null || _customer!.alamat!.isEmpty)) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Icon(
                      Icons.contact_page_outlined,
                      size: 48,
                      color: themeProvider.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No contact information available',
                      style: TextStyle(
                        color: themeProvider.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    ThemeProvider themeProvider,
    bool isMobile, {
    bool isMultiline = false,
  }) {
    return Row(
      crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: themeProvider.textSecondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: themeProvider.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  color: themeProvider.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 15,
                  color: themeProvider.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeProvider themeProvider, bool isMobile) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 24,
        isMobile ? 12 : 16,
        isMobile ? 16 : 24,
        isMobile ? 16 : 24,
      ),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        border: Border(
          top: BorderSide(
            color: themeProvider.borderColor.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
                side: BorderSide(color: themeProvider.borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Close',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.textSecondary,
                ),
              ),
            ),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _customer != null ? () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerEditScreen(
                      customerId: widget.customerId,
                      initialCustomer: _customer,
                    ),
                  ),
                );
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.primaryMain,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, size: isMobile ? 16 : 18),
                  SizedBox(width: isMobile ? 6 : 8),
                  Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w600,
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
}
