import 'package:flutter/material.dart';
import 'package:tium/core/constants/constants.dart';

/// AppTheme
class AppTheme {

  // Light_Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.lightPrimary,
    highlightColor: AppColors.lightSecondary,
    focusColor: AppColors.lightAccent,
    scaffoldBackgroundColor: AppColors.lightBackground,
    dividerColor: AppColors.lightDivider,
    cardColor: AppColors.lightCard,

    // - color
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      tertiary: AppColors.lightTertiary,
      surface: AppColors.lightSurface,
      error: AppColors.lightAccent,
      onPrimary: Colors.white,
      onSecondary: Colors.black87,
      onSurface: Colors.black87,
      onError: Colors.white,
    ),

    // - text
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.black87,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.1,),
      displayMedium: TextStyle(color: Colors.black54,
          fontSize: 25,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.1),
      titleMedium: TextStyle(color: Colors.black87,
          fontSize: 17,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.2),
      bodyLarge: TextStyle(color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.3),
      bodyMedium: TextStyle(
          color: Colors.black54, fontSize: 16, letterSpacing: -0.3),
      bodySmall: TextStyle(color: Colors.black54,
          fontSize: 13,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.3),
      labelLarge: TextStyle(color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.4),
      // 버튼 라벨 텍스트 크기 (카테고리)
      labelMedium: TextStyle(color: Colors.black54,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4),
      // Section 타이틀
      labelSmall: TextStyle(color: Colors.black54,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4), // 위치, 장소
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightBackground,
      // 탭바 배경색
      selectedItemColor: AppColors.lightTabBarSelected,
      // 선택된 아이콘 색
      unselectedItemColor: AppColors.lightTabBarUnselected,
      // 선택되지 않은 아이콘 색
      showUnselectedLabels: true,
      // 비선택된 아이템에 텍스트도 보이게

      selectedLabelStyle: TextStyle(
        color: AppColors.lightTabBarSelected, // 선택된 텍스트 색상
      ),

      unselectedLabelStyle: TextStyle(
        color: AppColors.lightTabBarUnselected, // 비선택된 텍스트 색상
      ),
    ),
  );


  // Dark_Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimary,
    focusColor: AppColors.darkAccent,
    scaffoldBackgroundColor: AppColors.darkBackground,
    highlightColor: AppColors.darkSecondary,
    dividerColor: AppColors.darkDivider,
    cardColor: AppColors.darkCard,

    // - color
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      tertiary: AppColors.darkTertiary,
      surface: AppColors.darkSurface,
      error: AppColors.darkAccent,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.black,
    ),

    // - text
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          color: Colors.white, fontSize: 32, letterSpacing: -0.1),
      displayMedium: TextStyle(color: Colors.white70,
          fontSize: 25,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.1),
      titleMedium: TextStyle(color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.2),
      bodyLarge: TextStyle(color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.3),
      bodyMedium: TextStyle(
          color: Colors.white70, fontSize: 16, letterSpacing: -0.3),
      bodySmall: TextStyle(color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.3),
      labelLarge: TextStyle(color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.4),
      // 버튼 라벨 텍스트 크기 (카테고리)
      labelMedium: TextStyle(color: Colors.white70,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4),
      // Section 타이틀
      labelSmall: TextStyle(color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4), // 위치, 장소
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkBackground,
      // 탭바 배경색
      selectedItemColor: AppColors.darkTabBarSelected,
      // 선택된 아이콘 색
      unselectedItemColor: AppColors.darkTabBarUnselected,
      // 선택되지 않은 아이콘 색
      showUnselectedLabels: true,
      // 비선택된 아이템에 텍스트도 보이게

      selectedLabelStyle: TextStyle(
        color: AppColors.darkTabBarSelected, // 선택된 텍스트 색상
      ),
      unselectedLabelStyle: TextStyle(
        color: AppColors.darkTabBarUnselected, // 비선택된 텍스트 색상
      ),
    ),
  );
}