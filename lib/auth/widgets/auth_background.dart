import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class AuthBackground extends StatefulWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  State<AuthBackground> createState() => _AuthBackgroundState();
}

class _AuthBackgroundState extends State<AuthBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Widget ikon melayang
  Widget floatingIcon(IconData icon, double size, double top, double left, double offset) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final double movement = (1 - (_controller.value * 2 - 1).abs()) * offset;

        return Positioned(
          top: top + movement,
          left: left,
          child: Icon(
            icon,
            size: size,
            color: AppTheme.brandNeonBlue.withOpacity(0.15),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(AppTheme.brandDeepNavy, AppTheme.brandNeonBlue, _controller.value * 0.8)!,
                Color.lerp(AppTheme.primaryMain, AppTheme.brandTurquoise, _controller.value)!,
                Color.lerp(AppTheme.primaryLight, AppTheme.brandSkySoft, _controller.value)!,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Glow Circle 1 (menggunakan boxShadow untuk efek blur/glow)
              Positioned(
                top: 100,
                left: 40,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  width: 220 + (_controller.value * 70),
                  height: 220 + (_controller.value * 70),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.brandTurquoise.withOpacity(0.12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.brandTurquoise.withOpacity(0.25),
                        blurRadius: 60,
                        spreadRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ),

              // Glow Circle 2
              Positioned(
                bottom: 80,
                right: 40,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  width: 180 + (_controller.value * 50),
                  height: 180 + (_controller.value * 50),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.brandNeonBlue.withOpacity(0.10),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.brandNeonBlue.withOpacity(0.20),
                        blurRadius: 50,
                        spreadRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                ),
              ),

              // Ikon POS melayang
              floatingIcon(Icons.shopping_cart, 48, 160, 60, 12),
              floatingIcon(Icons.qr_code_scanner, 40, 300, 30, 16),
              floatingIcon(Icons.receipt_long, 44, 260, 260, 18),
              floatingIcon(Icons.phone_android, 42, 120, 250, 10),
              floatingIcon(Icons.payments, 46, 380, 200, 14),

              // Overlay soft gradient untuk menyeimbangkan warna
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.brandDeepNavy.withOpacity(0.18),
                      Colors.transparent,
                      AppTheme.primaryMain.withOpacity(0.04),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // Child (form login / konten)
              widget.child,
            ],
          ),
        );
      },
    );
  }
}
