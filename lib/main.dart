import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/loading_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/return_policy_screen.dart';
import 'screens/initiate_return_screen.dart';
import 'screens/return_history_screen.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/cart_service.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FBSCApp());
}

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
            initialRoute: '/',
            routes: {
              '/': (context) => const LoadingScreen(),
              '/home': (context) => const HomeScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/forgot-password': (context) => const ForgotPasswordScreen(),
              '/orders': (context) => const OrdersScreen(),
              '/return-policy': (context) => const ReturnPolicyScreen(),
              '/return-history': (context) => const ReturnHistoryScreen(),
            },
          );
        },
      ),
    );
  }
}