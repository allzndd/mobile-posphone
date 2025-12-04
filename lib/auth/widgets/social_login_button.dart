import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// Widget untuk tombol social login dengan efek hover modern
class SocialLoginButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<SocialLoginButton> createState() => _SocialLoginButtonState();
}

class _SocialLoginButtonState extends State<SocialLoginButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    _isHovered
                        ? AppTheme.primaryMain.withOpacity(0.3)
                        : AppTheme.borderLight,
                width: _isHovered ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      _isHovered
                          ? AppTheme.primaryMain.withOpacity(0.15)
                          : Colors.black.withOpacity(0.05),
                  blurRadius: _isHovered ? 12 : 8,
                  offset: Offset(0, _isHovered ? 4 : 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                widget.icon,
                size: 28,
                color: _isHovered ? AppTheme.primaryMain : AppTheme.primaryDark,
              ),
              onPressed: widget.onPressed,
            ),
          ),
        ),
      ),
    );
  }
}
