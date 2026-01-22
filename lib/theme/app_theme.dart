import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primaryLight,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryLight,
      secondary: AppColors.accentLight,
      background: AppColors.bodyBgLight,
      surface: AppColors.cardBgLight,
      onBackground: AppColors.textLight,
      onSurface: AppColors.textLight,
    ),
    scaffoldBackgroundColor: AppColors.bodyBgLight,
    cardColor: AppColors.cardBgLight,
    dividerColor: AppColors.borderLight,
    
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.textLight),
      displayMedium: TextStyle(color: AppColors.textLight),
      displaySmall: TextStyle(color: AppColors.textLight),
      headlineLarge: TextStyle(color: AppColors.textLight),
      headlineMedium: TextStyle(color: AppColors.textLight),
      headlineSmall: TextStyle(color: AppColors.textLight),
      titleLarge: TextStyle(color: AppColors.textLight),
      titleMedium: TextStyle(color: AppColors.textLight),
      titleSmall: TextStyle(color: AppColors.textLight),
      bodyLarge: TextStyle(color: AppColors.textLight),
      bodyMedium: TextStyle(color: AppColors.textLight),
      bodySmall: TextStyle(color: AppColors.lightText),
      labelLarge: TextStyle(color: AppColors.textLight),
      labelMedium: TextStyle(color: AppColors.textLight),
      labelSmall: TextStyle(color: AppColors.lightText),
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textLight,
      elevation: 2,
      shadowColor: Colors.black12,
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderLight, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderLight, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.dangerLight, width: 2),
      ),
      contentPadding: const EdgeInsets.all(16),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      secondary: AppColors.accentDark,
      background: AppColors.bodyBgDark,
      surface: AppColors.cardBgDark,
      onBackground: AppColors.textDark,
      onSurface: AppColors.textDark,
    ),
    scaffoldBackgroundColor: AppColors.bodyBgDark,
    cardColor: AppColors.cardBgDark,
    dividerColor: AppColors.borderDark,
    
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.textDark),
      displayMedium: TextStyle(color: AppColors.textDark),
      displaySmall: TextStyle(color: AppColors.textDark),
      headlineLarge: TextStyle(color: AppColors.textDark),
      headlineMedium: TextStyle(color: AppColors.textDark),
      headlineSmall: TextStyle(color: AppColors.textDark),
      titleLarge: TextStyle(color: AppColors.textDark),
      titleMedium: TextStyle(color: AppColors.textDark),
      titleSmall: TextStyle(color: AppColors.textDark),
      bodyLarge: TextStyle(color: AppColors.textDark),
      bodyMedium: TextStyle(color: AppColors.textDark),
      bodySmall: TextStyle(color: AppColors.lightTextDark),
      labelLarge: TextStyle(color: AppColors.textDark),
      labelMedium: TextStyle(color: AppColors.textDark),
      labelSmall: TextStyle(color: AppColors.lightTextDark),
    ),
    
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.cardBgDark,
      foregroundColor: AppColors.textDark,
      elevation: 2,
      shadowColor: Colors.black26,
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardBgDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderDark, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderDark, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.dangerDark, width: 2),
      ),
      contentPadding: const EdgeInsets.all(16),
    ),
  );
}