import 'package:flutter/material.dart';

/// App Colors
class AppColors {
  static const Color signature = Color(0xFF263238);

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
    BottomNavigationBarItem(icon: Icon(Icons.eco), label: '식물관리'),
    // BottomNavigationBarItem(icon: Icon(Icons.search), label: '식물검색'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
  ];
}

/// 유저 타입 도출 위한 매핑 딕셔너리
const Map<String, String> experienceMap = {
  '아직은 어색한 사이예요': 'beginner',
  '조금씩 알아가는 중이에요': 'intermediate',
  '이젠 말 안 해도 통해요': 'expert',
};

const Map<String, String> locationMap = {
  '햇살 가득한 창가': 'window',
  '조용한 방 안': 'bedroom',
  '집안 여기 저기': 'anywhere',
};

const Map<String, String> careTimeMap = {
  '거의 시간이 없어요': 'short',
  '주말엔 괜찮아요': 'moderate',
  '매일 돌볼 수 있어요': 'plenty',
};

const Map<String, String> interestMap = {
  '계절마다 꽃이 피는 식물': 'flower',
  '생김새가 독특한 식물': 'shape',
  '가성비가 좋은 식물': 'price',
};

//
const List<String> plantLocations = [
  '거실',
  '주방',
  '침실',
  '베란다',
  '욕실',
  '서재',
  '현관',
  '기타',
];