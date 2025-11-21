// lib/controller/contact_controller.dart
import 'package:uuid/uuid.dart';
import '../../model/contact_model.dart';
import '../../service/database/app_database.dart';

class ContactController {
  final _db = AppDatabase.instance;

  // Méthode magique : ajoute OU modifie selon si le contact existe déjà
  Future<void> saveContact(Contact contact) async {
    final userId = await _db.getLoggedInUserId();
    if (userId == null) return;

    final exists = await _db.contactExists(contact.id, userId);
    if (exists) {
      await _db.updateContact(contact, userId);
    } else {
      await _db.insertContact(contact, userId);
    }
  }

  Future<void> deleteContact(String id) async {
    final userId = await _db.getLoggedInUserId();
    if (userId == null) return;
    await _db.deleteContact(id, userId);
  }

  Future<List<Contact>> getContacts() async {
    final userId = await _db.getLoggedInUserId();
    if (userId == null) return [];
    return await _db.getAllContacts(userId);
  }
}