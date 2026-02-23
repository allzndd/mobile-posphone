import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/screens/login_screen.dart';
import '../config/theme_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    // Start animation
    _animationController.forward();

    // Navigate to login screen after delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeProvider.backgroundColor,
              themeProvider.backgroundColor.withOpacity(0.95),
              themeProvider.primaryMain.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Icon (Phone with Graph)
                      Image.asset(
                        'assets/images/logo1.png',
                        width: 240,
                        height: 240,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback icon if logo image not found
                          return Icon(
                            Icons.phone_android_rounded,
                            size: 240,
                            color: themeProvider.primaryMain,
                          );
                        },
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Logo Text (PosPhone)
                      Image.asset(
                        'assets/images/logo2.png',
                        width: 480,
                        height: 140,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback text if logo text image not found
                          return Text(
                            'posphone',
                            style: TextStyle(
                              fontSize: 84,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.textPrimary,
                              letterSpacing: -1,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
