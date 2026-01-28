import 'package:flutter/material.dart';

/// MusicShopRD Theme - Modern dark design matching React version
class AppColors {
  // Neutral Grey Scale (Matching B&W Logo)
  static const Color slate900 = Color(0xFF09090b); // Nearly black
  static const Color slate800 = Color(0xFF18181b); // Dark grey
  static const Color slate700 = Color(0xFF27272a);
  static const Color slate600 = Color(0xFF3f3f46);
  static const Color slate500 = Color(0xFF52525b);
  static const Color slate400 = Color(0xFF71717a);
  static const Color slate300 = Color(0xFFa1a1aa);
  static const Color slate200 = Color(0xFFe4e4e7);
  static const Color slate100 = Color(0xFFf4f4f5);
  static const Color slate50 = Color(0xFFfafafa);

  // Accent colors
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald400 = Color(0xFF34D399);
  
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue400 = Color(0xFF60A5FA);
  
  static const Color orange500 = Color(0xFFF97316);
  static const Color orange400 = Color(0xFFFB923C);
  
  static const Color yellow500 = Color(0xFFEAB308);
  static const Color yellow400 = Color(0xFFFACC15);
  
  static const Color red500 = Color(0xFFEF4444);
  static const Color red400 = Color(0xFFF87171);

  static const Color purple500 = Color(0xFFA855F7);
  static const Color purple400 = Color(0xFFC084FC);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.slate900,
      primaryColor: AppColors.emerald500,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.emerald500,
        secondary: AppColors.blue500,
        surface: AppColors.slate800,
        error: AppColors.red500,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.slate100,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.slate900,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: AppColors.slate400),
      ),
      cardTheme: CardThemeData(
        color: AppColors.slate800,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.slate700, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.slate800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.slate700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.slate700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.emerald500, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.slate400),
        hintStyle: const TextStyle(color: AppColors.slate500),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emerald600,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.slate400,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.emerald500,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.slate900,
        selectedItemColor: AppColors.emerald500,
        unselectedItemColor: AppColors.slate500,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: AppColors.slate900,
        selectedIconTheme: IconThemeData(color: AppColors.emerald400),
        unselectedIconTheme: IconThemeData(color: AppColors.slate500),
        selectedLabelTextStyle: TextStyle(
          color: AppColors.emerald400,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelTextStyle: TextStyle(color: AppColors.slate500),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.slate700,
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.slate800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.slate800,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Extension for text styles
extension AppTextStyles on TextTheme {
  TextStyle get headingLarge => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.emerald400,
  );
  
  TextStyle get headingMedium => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  TextStyle get labelSmall => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.slate400,
  );
}
