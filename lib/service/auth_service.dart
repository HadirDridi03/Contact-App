import 'package:shared_preferences/shared_preferences.dart';
import '../../service/database/app_database.dart';

class LocalAuthService {
  // Singleton
  static final LocalAuthService instance = _singleton;
  static final LocalAuthService _singleton = LocalAuthService._internal();
  factory LocalAuthService() => instance;
  LocalAuthService._internal();

  // Retourne l'ID utilisateur sous forme int? (comme dans la table users)
  Future<int?> getLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final idString = prefs.getString('loggedInUserId');
    if (idString == null) return null;
    return int.tryParse(idString);
  }

  // Méthode magique qui garantit un int non-null → plus jamais de ligne rouge
  Future<int> getRequiredUserId() async {
    final id = await getLoggedInUserId();
    if (id == null) throw Exception("Utilisateur non connecté");
    return id;
  }

  Future<bool> login(String email, String password) async {
    final userMap = await AppDatabase.instance.getUser(email, password);
    if (userMap != null) {
      final prefs = await SharedPreferences.getInstance();
      final userId = userMap['id'] as int;

      await prefs.setBool('logged_in', true);
      await prefs.setString('loggedInUserId', userId.toString());
      await prefs.setString('userEmail', email);
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
    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('logged_in') ?? false;
  }

  Future<String?> getLoggedInUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return (await prefs).getString('userEmail');
  }
}