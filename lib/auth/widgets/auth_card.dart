import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class AuthCard extends StatefulWidget {
  final Widget child;
  final bool isDesktop;

  const AuthCard({super.key, required this.child, this.isDesktop = false});

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, size) {
        final bool isMobile = size.maxWidth < 600;

        final double padding = isMobile ? 28 : (widget.isDesktop ? 45 : 38);

        return MouseRegion(
          onEnter: (_) {
            if (!isMobile) setState(() => _hover = true);
          },
          onExit: (_) {
            if (!isMobile) setState(() => _hover = false);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,

            // RESPONSIVE WIDTH (mobile penuh, desktop max 480)
            width: isMobile ? size.maxWidth : 480,

            // CARD STYLE
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                width: 2,
                color: AppTheme.primaryMain.withOpacity(0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryMain.withOpacity(isMobile ? 0.15 : (_hover ? 0.25 : 0.20)),
                  blurRadius: isMobile ? 18 : (_hover ? 35 : 22),
                  offset: Offset(0, isMobile ? 6 : 12),
                ),
                BoxShadow(
                  color: AppTheme.primaryLight.withOpacity(isMobile ? 0.12 : (_hover ? 0.20 : 0.15)),
                  blurRadius: isMobile ? 12 : (_hover ? 20 : 14),
                  offset: Offset(0, isMobile ? 4 : 8),
                ),
              ],
            ),

            padding: EdgeInsets.all(padding),

            child: widget.child,
          ),
        );
      },
    );
  }
}
