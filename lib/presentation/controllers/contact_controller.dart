import '../../core/services/firestore_service.dart';
import '../../data/models/contact_model.dart';
import 'package:uuid/uuid.dart';//importer ce package qui identifie des id uniques universels

class ContactController {
  final FirestoreService _service = FirestoreService();

  Stream<List<Contact>> getContacts() => _service.getContacts();//une fonction qui retourne une liste  des contacts 
  //stream: Retourne un flux (Stream) de la liste des contacts, qui se met à jour en temps réel
  Future<void> addContact(String name, String email, String phone) async {//fonction future qui ajoute 
    final contact = Contact(id: const Uuid().v4()/*créer une instance de uuid et appele la methode v4 pour generer un id unique*/, name: name, email: email, phone: phone);
    await _service.addContact(contact);
  }
  Future<void> updateContact(Contact contact) => _service.updateContact(contact);
  Future<void> deleteContact(String id) => _service.deleteContact(id);
  Stream<List<Contact>> searchContacts(String query) => _service.searchContacts(query);
}