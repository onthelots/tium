import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfoCubit extends Cubit<String> {
  AppInfoCubit() : super('Loading...');

  /// fetch App Version (디바이스)
  Future<void> fetchAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    emit(packageInfo.version);
  }

/// App version vs Remote Config version
}