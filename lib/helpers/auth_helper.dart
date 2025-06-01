import 'package:shared_preferences/shared_preferences.dart';

class AuthHelper {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<int?> getUserId() async { // <- perbaikan: getInt, bukan getString
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  static Future<String?> getNamaLengkap() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nama_lengkap');
  }

  static Future<Map<String, dynamic>> getUserData() async { // <- ubah ke dynamic karena user_id bertipe int
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString('token'),
      'user_id': prefs.getInt('user_id'), // <- perbaikan
      'nama_lengkap': prefs.getString('nama_lengkap'),
    };
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }
}
