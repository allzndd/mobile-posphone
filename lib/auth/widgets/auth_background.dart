import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Widget untuk background gradient yang dapat dikustomisasi
class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient()),
      child: child,
    );
  }
}
