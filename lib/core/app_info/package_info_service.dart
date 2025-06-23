import 'package:package_info_plus/package_info_plus.dart';

/// checkApp version
Future<String> checkAppVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String appVersion = packageInfo.version;
  return appVersion;
}