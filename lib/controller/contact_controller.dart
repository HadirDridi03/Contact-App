import '../../model/contact_model.dart';
import '../../service/database/app_database.dart';
import '../../service/auth_service.dart'; 

class ContactController {
  final _db = AppDatabase.instance;
  final _authService = LocalAuthService.instance;

  /// Enregistre ou met à jour un contact
  Future<void> saveContact(Contact contact) async {
    try {
      final userId = await _authService.getRequiredUserId();

      // On s'assure que le contact a bien le bon userId (sécurité + cohérence)
      final contactWithUserId = contact.copyWith(userId: userId);

      await _db.saveContact(contactWithUserId, userId);
    } catch (e) {
      // Si l'utilisateur n'est plus connecté on ne fait rien 
      return;
    }
  }

  
  Future<void> deleteContact(String contactId) async {
    try {
      final userId = await _authService.getRequiredUserId();
      await _db.deleteContact(contactId, userId);
    } catch (e) {
      // Session expirée, rien à faire 
      return;
    }
  }

  Future<List<Contact>> getContacts() async {
    try {
      final userId = await _authService.getRequiredUserId();
      return await _db.getAllContacts(userId);
    } catch (e) {
      return [];
    }
  }

  /// Recherche dans les contacts
  Future<List<Contact>> searchContacts(String query) async {
    try {
      final userId = await _authService.getRequiredUserId();
      return await _db.searchContacts(userId, query);
    } catch (e) {
      return [];
    }
  }
}