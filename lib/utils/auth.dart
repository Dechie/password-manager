import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  Future<bool> checkAuthed() async {
    final prefs = await _prefs;
    return prefs.getBool("registered") ?? false;
  }

  Future<bool> checkPin(String insertPin) async {
    final prefs = await _prefs;
    String userPin = prefs.getString("PIN") ?? "";
    return userPin == insertPin;
  }

  Future<bool> register(String pinCode) async {
    final prefs = await _prefs;
    try {
      await prefs.setBool("registered", true);
      await prefs.setString("PIN", pinCode);
    } catch (e) {
      return false;
    }
    return true;
  }
}
