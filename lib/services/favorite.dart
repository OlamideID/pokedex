import 'package:shared_preferences/shared_preferences.dart';

class FavoriteList {
  Future<bool?> save(String key, List<String> value) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      bool result = await prefs.setStringList(key, value);
      return result;
    } catch (e) {
      print('Error: $e');
    }
    return false;
  }

  Future<List<String>?> get(
    String key,
  ) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? result = await prefs.getStringList(key);
      return result;
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }
}
