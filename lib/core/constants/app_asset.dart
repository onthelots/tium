class AppAsset {
  AppAsset._init();

  static final AppAsset _instance = AppAsset._init();

  factory AppAsset() {
    return _instance;
  }

  static final AppAssetSplash splash = AppAssetSplash();
  static final AppAssetHome home = AppAssetHome();
  static final AppAssetIcon icon = AppAssetIcon();
  static final AppAssetAvatar avatar = AppAssetAvatar();
}

/// 스플래시 이미지 (Native, custom)
class AppAssetSplash {
  AppAssetSplash._init();

  static final AppAssetSplash _instance = AppAssetSplash._init();

  factory AppAssetSplash() {
    return _instance;
  }

  final String indoor_bg = 'assets/img/indoor_bg.png';
  final String outdoor_bg = 'assets/img/outdoor_bg.png';
}

/// 앱 전반적으로 사용하는 이미지 목록
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

/// Icon
class AppAssetIcon {
  AppAssetIcon._init();

  static final AppAssetIcon _instance = AppAssetIcon._init();

  factory AppAssetIcon() {
    return _instance;
  }

  final String icon = 'assets/icon/icon.png';
  final String icon_circle = 'assets/icon/icon_circle.png';
}

/// Avatar
class AppAssetAvatar {
  AppAssetAvatar._init();

  static final AppAssetAvatar _instance = AppAssetAvatar._init();

  factory AppAssetAvatar() {
    return _instance;
  }

  final String sample = 'assets/avatar/sample.png';
  final String sunnyLover = 'assets/avatar/sunny_lover.png';
  final String quietCompanion = 'assets/avatar/quiet_companion.png';
  final String smartSaver = 'assets/avatar/smart_saver.png';
  final String bloomingWatcher = 'assets/avatar/blomming_watcher.png';
  final String growthSeeker = 'assets/avatar/grow_seeker.png';
  final String seasonalRomantic = 'assets/avatar/seasonal_romantic.png';
  final String plantMaster = 'assets/avatar/plant_master.png';
  final String calmObserver = 'assets/avatar/calm_observer.png';
  final String growthExplorer = 'assets/avatar/growth_explorer.png';
}

