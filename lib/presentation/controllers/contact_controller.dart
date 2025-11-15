// lib/presentation/controllers/contact_controller.dart
import '../../core/services/firestore_service.dart';
import '../../data/models/contact_model.dart';
import 'package:uuid/uuid.dart';

class ContactController {
  final FirestoreService _service = FirestoreService();

  Stream<List<Contact>> getContacts() => _service.getContacts();
  Future<void> addContact(String name, String email, String phone) async {
    final contact = Contact(id: const Uuid().v4(), name: name, email: email, phone: phone);
    await _service.addContact(contact);
  }
  Future<void> updateContact(Contact contact) => _service.updateContact(contact);
  Future<void> deleteContact(String id) => _service.deleteContact(id);
  Stream<List<Contact>> searchContacts(String query) => _service.searchContacts(query);
}