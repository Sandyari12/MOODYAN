import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _keyLoggedInEmail = 'logged_in_email';

  static Future<void> setLoggedInEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLoggedInEmail, email);
  }

  static Future<String?> getLoggedInEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLoggedInEmail);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedInEmail);
  }
} 