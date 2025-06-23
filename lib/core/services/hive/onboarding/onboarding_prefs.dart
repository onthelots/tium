import 'package:hive_flutter/hive_flutter.dart';
import 'package:tium/data/models/user/user_model.dart';

class UserPrefs {
  static Future<void> saveUser(UserModel user) async {
    final box = await Hive.openBox<UserModel>('userBox');
    await box.put('user', user);
  }

  static Future<UserModel?> getUser() async {
    final box = await Hive.openBox<UserModel>('userBox');
    return box.get('user');
  }

  static Future<void> clearUser() async {
    final box = await Hive.openBox<UserModel>('userBox');
    await box.clear();
  }
}