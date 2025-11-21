import 'package:shared_preferences/shared_preferences.dart';
import './database/app_database.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  Future<bool> login(String email, String password) async {
    final user = await AppDatabase.instance.getUser(email, password);
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('logged_in', true);
      return true;
    }
    return false;
  }

  Future<bool> register(String email, String password) async {
    try {
      await AppDatabase.instance.createUser(email, password);
      return await login(email, password);
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged_in', false);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('logged_in') ?? false;
  }
}