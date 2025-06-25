import 'package:flutter/material.dart';

/// App Colors
class AppColors {
  static const Color lightPrimary = Color(0xff3BA272);
  static const Color lightSecondary = Color(0xffAFE9C0);
  static const Color lightTertiary = Color(0xffDEF4E2);
  static const Color lightAccent = Color(0xffFFD66E);
  static const Color lightBackground = Color(0xFFFDFDFD);
  static const Color lightInactiveBackground = Color(0xffA0A0A0);
  static const Color lightTabBarSelected = Color(0xff3BA272);
  static const Color lightTabBarUnselected = Color(0xff8E8E8E);
  static const Color lightSurface = Color(0xffEBF7F0);
  static const Color lightBorder = Color(0xffC5E1CE);
  static const Color lightShadow = Color(0x22000000);
  static const Color lightDivider = Color(0xFFE0E0E0); // 밝은 회색 (배경과 대비)
  static const Color lightCard = Color(0xFFF5F5F5); // 밝은 회색 (약간 따뜻한 톤)

  static const Color darkPrimary = Color(0xff70C194);
  static const Color darkSecondary = Color(0xff45785B);
  static const Color darkTertiary = Color(0xff2C4335);
  static const Color darkAccent = Color(0xffFFB74D);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkInactiveBackground = Color(0xff7A7A7A);
  static const Color darkTabBarSelected = Color(0xffAFE9C0);
  static const Color darkTabBarUnselected = Color(0xff666666);
  static const Color darkSurface = Color(0xff1A3024);
  static const Color darkBorder = Color(0xff355043);
  static const Color darkShadow = Color(0x44000000);
  static const Color darkDivider = Color(0xFF2C2C2C);  // 어두운 회색 (배경과 대비)
  static const Color darkCard = Color(0xFF1E1E1E); // 다크 배경보다 살짝 밝은 톤
}

/// BottomNavigationBar
class CustomBottomNavigationBar {
  static List<BottomNavigationBarItem> bottomNavigationBarItem = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
    // BottomNavigationBarItem(icon: Icon(Icons.list), label: '정보'),
    BottomNavigationBarItem(icon: Icon(Icons.search), label: '식물검색'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
  ];
}
