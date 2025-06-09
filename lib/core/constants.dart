import 'package:flutter/material.dart';

/// App Colors
class AppColors {
  static const Color lightPrimary = Color(0xffD9534F);
  static const Color lightSecondary = Color(0xffF39C12);
  static const Color lightTertiary = Color(0xff34495E);
  static const Color lightAccent = Color(0xff4A90E2);
  static const Color lightBackground = Color(0xffFFFFFF);
  static const Color lightBoxBackground = Color(0xffF8F8F8);
  static const Color lightActiveButton = Color(0xffD9534F);
  static const Color lightInactiveButton = Color(0xff333333);
  static const Color lightCheckBox = Color(0xffE0E0E0);

  // Dark Mode Colors
  static const Color darkPrimary = Color(0xffD9534F);
  static const Color darkSecondary = Color(0xffE67E22);
  static const Color darkTertiary = Color(0xff121921);
  static const Color darkAccent = Color(0xff3498DB);
  static const Color darkBackground = Color(0xff1E1E1E);
  static const Color darkBoxBackground = Color(0xff252525);
  static const Color darkActiveButton = Color(0xffC0392B);
  static const Color darkInactiveButton = Color(0xff333333);
  static const Color darkCheckBox = Color(0xff3A3A3A);
}

/// BottomNavigationBar
class CustomBottomNavigationBar {
  static List<BottomNavigationBarItem> bottomNavigationBarItem = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
    BottomNavigationBarItem(icon: Icon(Icons.list), label: '번호보기'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
  ];
}
