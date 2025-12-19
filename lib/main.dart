import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth/screens/login_screen.dart';
import 'auth/providers/branding_provider.dart';
import 'config/theme_provider.dart';
import 'config/logo_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BrandingProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LogoProvider()),
      ],
      child: MaterialApp(
        title: 'PosPhone',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3B82F6),
            primary: const Color(0xFF3B82F6),
          ),
          useMaterial3: true,
          fontFamily: 'SF Pro Display',
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
