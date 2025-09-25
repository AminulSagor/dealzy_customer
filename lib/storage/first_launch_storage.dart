// lib/storage/first_launch_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class FirstLaunchStorage {
  static const _keyFirstLaunch = 'is_first_launch';

  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstLaunch) ?? true; // default true
  }

  static Future<void> setLaunched() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstLaunch, false);
  }
}
