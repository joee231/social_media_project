import 'package:shared_preferences/shared_preferences.dart';

class CashHelper {
  static SharedPreferences? sharedPreferences;

  static Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  /// Save bool specifically
  static Future<bool?> putData({
    required String key,
    required bool value,
  }) async {
    return await sharedPreferences?.setBool(key, value);
  }

  /// Generic type-safe data getter
  static dynamic getData({
    required String key,
  }) {
    return sharedPreferences?.get(key); // returns dynamic (String, bool, int, etc.)
  }

  /// Save data of any supported type
  static Future<bool> saveData({
    required String key,
    required dynamic value,
  }) async {
    if (value is String) {
      return await sharedPreferences?.setString(key, value) ?? false;
    } else if (value is int) {
      return await sharedPreferences?.setInt(key, value) ?? false;
    } else if (value is double) {
      return await sharedPreferences?.setDouble(key, value) ?? false;
    } else if (value is bool) {
      return await sharedPreferences?.setBool(key, value) ?? false;
    } else {
      return false; // Unsupported type
    }
  }

  /// Remove data
  static Future<bool> removeData({
    required String key,
  }) async {
    return await sharedPreferences!.remove(key);
  }
}