import 'package:flutter/material.dart';

class HeroContent {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool showLocationBtn;
  final String backgroundImage;  // 추가

  HeroContent({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.showLocationBtn = false,
    this.backgroundImage = '',  // 기본값 빈 문자열
  });
}