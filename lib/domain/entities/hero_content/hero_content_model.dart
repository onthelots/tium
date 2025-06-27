import 'package:flutter/material.dart';

class HeroContent {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool showLocationBtn;
  final String backgroundImage;
  final bool isDay;

  HeroContent({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isDay,
    this.showLocationBtn = false,
    this.backgroundImage = '',
  });
}