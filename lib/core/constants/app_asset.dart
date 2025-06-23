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
}
