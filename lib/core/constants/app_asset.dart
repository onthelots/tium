class AppAsset {
  AppAsset._init();

  static final AppAsset _instance = AppAsset._init();

  factory AppAsset() {
    return _instance;
  }

  static final AppAssetHome home = AppAssetHome();
}

/// 1. 앱 전반적으로 사용하는 이미지 목록
class AppAssetHome {
  AppAssetHome._init();

  static final AppAssetHome _instance = AppAssetHome._init();

  factory AppAssetHome() {
    return _instance;
  }

  final String indoor_bg = 'assets/img/indoor_bg.png';
  final String outdoor_bg = 'assets/img/outdoor_bg.png';

  final String default_bg = 'assets/img/default_bg.png';
  final String night_rainy_bg = 'assets/img/night_rainy_bg.png';
  final String night_bg = 'assets/img/night_bg.png';
  final String clear_day_bg = 'assets/img/clear_day_bg.png';
  final String cloudy_day_bg = 'assets/img/cloudy_day_bg.png';
  final String overcast_day_bg = 'assets/img/overcast_day_bg.png';
  final String rainy_day_bg = 'assets/img/rainy_day_bg.png';
  final String snowy_day_bg = 'assets/img/snowy_day_bg.png';
}
