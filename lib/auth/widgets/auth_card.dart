import 'package:flutter/material.dart';

/// Widget untuk card container auth
class AuthCard extends StatelessWidget {
  final Widget child;
  final bool isDesktop;

  const AuthCard({super.key, required this.child, this.isDesktop = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: isDesktop ? 450 : double.infinity),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: EdgeInsets.all(isDesktop ? 48 : 32),
          child: child,
        ),
      ),
    );
  }
}
