import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/loading_screen.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/cart_service.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FBSCApp());
}

// In main.dart - update FBSCApp class:
class FBSCApp extends StatelessWidget {
  const FBSCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => CartService()),
        ChangeNotifierProvider(create: (_) => ApiService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'Four Brothers Sports Center',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode,
            home: const LoadingScreen(),
          );
        },
      ),
    );
  }
}