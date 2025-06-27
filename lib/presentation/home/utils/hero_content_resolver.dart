import 'package:flutter/material.dart';
import 'package:tium/core/constants/app_asset.dart';
import 'package:tium/presentation/home/bloc/weather/weather_state.dart';
import 'package:tium/domain/entities/hero_content/hero_content_model.dart';
import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/core/constants/constants.dart';

/// 상단 영역 분기처리 (user, location 여부 및 Weather 정보 로드 여부에 따라)
bool isDayTime(DateTime now) {
  final month = now.month;

  // 계절별 일출/일몰 시각 설정 (시:분)
  late DateTime sunrise;
  late DateTime sunset;

  if (month >= 3 && month <= 5) {
    sunrise = DateTime(now.year, now.month, now.day, 6, 0);
    sunset = DateTime(now.year, now.month, now.day, 18, 30);
  } else if (month >= 6 && month <= 8) {
    sunrise = DateTime(now.year, now.month, now.day, 5, 0);
    sunset = DateTime(now.year, now.month, now.day, 19, 30);
  } else if (month >= 9 && month <= 11) {
    sunrise = DateTime(now.year, now.month, now.day, 6, 30);
    sunset = DateTime(now.year, now.month, now.day, 18, 0);
  } else {
    // 12월, 1월, 2월
    sunrise = DateTime(now.year, now.month, now.day, 7, 30);
    sunset = DateTime(now.year, now.month, now.day, 17, 30);
  }

  return now.isAfter(sunrise) && now.isBefore(sunset);
}

HeroContent resolveHeroContent(WeatherState state, UserModel? user) {
  final now = DateTime.now();
  final dayTime = isDayTime(now);

  if (state is! WeatherLoaded) {
    return HeroContent(
      icon: Icons.downloading,
      iconColor: Colors.blueGrey,
      title: '잠시만 기다려 주세요...',
      subtitle: '최신 날씨를 확인하고 있어요',
      backgroundImage: AppAsset.home.default_bg,
      isDay: false,
    );
  }

  final temp = state.weather.temperature.toStringAsFixed(1);
  final condition = state.weather.condition;

  IconData icon;
  Color color;
  String title;
  String subtitle;
  bool isDay;

  if (dayTime) {
    // 낮 문구 및 아이콘
    switch (condition) {
      case '맑음':
        icon = Icons.wb_sunny;
        color = Colors.amberAccent;
        title = '햇살이 가득해요!';
        break;
      case '구름 많음':
        icon = Icons.cloud;
        color = Colors.blueGrey;
        title = '구름이 살포시 있어요';
        break;
      case '흐림':
        icon = Icons.cloud;
        color = Colors.grey;
        title = '하늘이 조금 흐릿해요';
        break;
      case '비':
      case '소나기':
        icon = Icons.umbrella;
        color = Colors.blue.shade300;
        title = '비가 내려요 🌧';
        break;
      case '눈':
        icon = Icons.ac_unit;
        color = Colors.lightBlue.shade100;
        title = '눈송이가 내려요 ❄️';
        break;
      case '비/눈':
        icon = Icons.grain;
        color = Colors.indigo.shade200;
        title = '비와 눈이 함께 내려요';
        break;
      default:
        icon = Icons.thermostat;
        color = Colors.orangeAccent;
        title = '날씨 정보';
        break;
    }

    isDay = true;
    subtitle = '현재 온도 $temp°C';

  } else {

    // 밤 문구 및 아이콘
    switch (condition) {
      case '맑음':
        icon = Icons.nights_stay;
        color = Colors.indigo.shade700;
        title = '맑고 조용한 밤이에요';
        break;
      case '구름 많음':
        icon = Icons.cloud;
        color = Colors.grey.shade700;
        title = '구름 낀 밤하늘이에요';
        break;
      case '흐림':
        icon = Icons.cloud_queue;
        color = Colors.grey.shade800;
        title = '흐린 밤하늘이에요';
        break;
      case '비':
      case '소나기':
        icon = Icons.umbrella;
        color = Colors.blue.shade700;
        title = '비가 내리는 밤이에요';
        break;
      case '눈':
        icon = Icons.ac_unit;
        color = Colors.lightBlue.shade300;
        title = '눈 내리는 밤이에요';
        break;
      case '비/눈':
        icon = Icons.grain;
        color = Colors.indigo.shade400;
        title = '비와 눈이 함께 내려요';
        break;
      default:
        icon = Icons.nights_stay;
        color = Colors.indigo.shade700;
        title = '조용한 밤이에요';
        break;
    }
    isDay = false;
    subtitle = '현재 온도 $temp°C';
  }

  // ✅ 배경 이미지 경로 설정
  final backgroundImage = resolveBackgroundImage(condition, dayTime);

  return HeroContent(
    icon: icon,
    iconColor: color,
    title: title,
    subtitle: subtitle,
    backgroundImage: backgroundImage,
    isDay: isDay
  );
}

String resolveBackgroundImage(String condition, bool dayTime) {
  if (!dayTime) {
    if (condition == '비' || condition == '소나기') {
      return AppAsset.home.night_rainy_bg;
    }
    return AppAsset.home.night_bg;
  }

  switch (condition) {
    case '맑음':
      return AppAsset.home.clear_day_bg;
    case '구름 많음':
      return AppAsset.home.cloudy_day_bg;
    case '흐림':
      return AppAsset.home.overcast_day_bg;
    case '비':
    case '소나기':
      return AppAsset.home.rainy_day_bg;
    case '눈':
      return AppAsset.home.snowy_day_bg;
    case '비/눈':
      return AppAsset.home.snowy_day_bg;  // sleet_day_bg 대신 snowy_day_bg로 변경
    default:
      return AppAsset.home.default_bg;
  }
}

String interpretUVLevel(int uv) {
  if (uv < 3) return '낮음';
  if (uv < 6) return '보통';
  if (uv < 8) return '높음';
  if (uv < 11) return '매우 높음';
  return '위험';
}
