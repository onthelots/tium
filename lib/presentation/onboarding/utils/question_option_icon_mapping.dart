import 'package:flutter/material.dart';

IconData getOptionIcon(String key, String option) {
  switch (key) {
    case 'experience_level':
      if (option.contains('초보')) return Icons.spa_outlined;
      if (option.contains('중급')) return Icons.eco_outlined;
      if (option.contains('상급')) return Icons.local_florist;
      return Icons.help_outline;

    case 'location_preference':
      if (option.contains('창가')) return Icons.wb_sunny_outlined;
      if (option.contains('방')) return Icons.bedroom_baby_outlined;
      if (option.contains('집안')) return Icons.house_siding_outlined;
      return Icons.device_unknown;

    case 'care_time':
      if (option.contains('없어요')) return Icons.schedule;
      if (option.contains('주말')) return Icons.weekend_outlined;
      if (option.contains('매일')) return Icons.access_time_filled;
      return Icons.timelapse;

    case 'interest_tags':
      if (option.contains('꽃')) return Icons.local_florist_outlined;
      if (option.contains('독특')) return Icons.auto_awesome_outlined;
      if (option.contains('가성비')) return Icons.attach_money_outlined;
      return Icons.star_outline;

    default:
      return Icons.help_outline;
  }
}
