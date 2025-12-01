import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// Profile Screen - Profil Customer
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            color: AppTheme.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.primaryMain.withOpacity(0.1),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: AppTheme.primaryMain,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'John Doe',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'john.doe@email.com',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '+62 812 3456 7890',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.edit, color: AppTheme.primaryMain),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Menu Items
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildMenuItem(
                    Icons.location_on_outlined,
                    'Alamat Saya',
                    () {},
                  ),
                  _buildMenuItem(Icons.favorite_outline, 'Wishlist', () {}),
                  _buildMenuItem(
                    Icons.payment_outlined,
                    'Metode Pembayaran',
                    () {},
                  ),
                  _buildMenuItem(
                    Icons.notifications_outlined,
                    'Notifikasi',
                    () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildMenuItem(Icons.help_outline, 'Bantuan', () {}),
                  _buildMenuItem(Icons.info_outline, 'Tentang Aplikasi', () {}),
                  _buildMenuItem(
                    Icons.privacy_tip_outlined,
                    'Kebijakan Privasi',
                    () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              color: Colors.white,
              child: _buildMenuItem(
                Icons.logout,
                'Keluar',
                () {},
                textColor: Colors.red,
                iconColor: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.grey.shade700),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }
}
