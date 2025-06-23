import 'package:hive_flutter/hive_flutter.dart';

class HivePrefs {
  static Future<void> saveMap(String boxName, Map<String, dynamic> data) async {
    final box = await Hive.openBox(boxName);
    await box.putAll(data);
  }

  static Future<Map<String, dynamic>> readAll(String boxName) async {
    final box = await Hive.openBox(boxName);
    return Map<String, dynamic>.from(box.toMap());
  }

  static Future<void> clear(String boxName) async {
    final box = await Hive.openBox(boxName);
    await box.clear();
  }
}