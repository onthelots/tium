import 'package:flutter/material.dart';

/// App Colors
class AppColors {
  static const Color lightPrimary = Color(0xff207635);
  static const Color lightSecondary = Color(0xff9CD662);
  static const Color lightTertiary = Color(0xffCFF3A2);
  static const Color lightAccent = Color(0xffFDEE8B);
  static const Color lightBackground = Color(0xffFFFFFF);
  static const Color lightInactiveBackground = Color(0xff757575);
  static const Color lightTabBarSelected = Color(0xff207635); // 강조된 탭
  static const Color lightTabBarUnselected = Color(0xff9E9E9E); // 옅은 회색 (비선택)

  // Dark Mode Colors
  static const Color darkPrimary = Color(0xff2E8B57);
  static const Color darkSecondary = Color(0xff6DA75B);
  static const Color darkTertiary = Color(0xff4F7041);
  static const Color darkAccent = Color(0xffF5D547);
  static const Color darkBackground = Color(0xff121212);
  static const Color darkInactiveBackground = Color(0xffBDBDBD);
  static const Color darkTabBarSelected = Color(0xffA5D6A7); // 강조된 탭 (light green tone)
  static const Color darkTabBarUnselected = Color(0xff757575); // 옅은 회색 (비선택)
}

/// BottomNavigationBar
class CustomBottomNavigationBar {
  static List<BottomNavigationBarItem> bottomNavigationBarItem = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
    BottomNavigationBarItem(icon: Icon(Icons.list), label: '정보'),
    BottomNavigationBarItem(icon: Icon(Icons.search), label: '작물검색'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
  ];
}
