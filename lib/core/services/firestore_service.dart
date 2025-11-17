import 'package:cloud_firestore/cloud_firestore.dart';//Importe le package pour identifier l'utilisateur actuellement connecté
import 'package:firebase_auth/firebase_auth.dart';//importer le package pour acceder aux données de user
import '../../data/models/contact_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;//l'intance unique pour acceder à la base de données
  final User? _user = FirebaseAuth.instance.currentUser;//recupère l'utilisateur actuel

  CollectionReference<Map<String, dynamic>> get _contacts {
    if (_user == null) throw Exception("Utilisateur non connecté");
    return _db.collection('users').doc(_user.uid).collection('contacts');//Retourne une référence au chemin : /users/{id_utilisateur}/contacts
  }

  Stream<List<Contact>> getContacts() {
    return _contacts.orderBy('name').snapshots().map((snapshot) {//Depuis la collection de contacts, les trie par nom, puis écoute les changements en temps réel avec .snapshots()
      return snapshot.docs.map((doc) => Contact.fromMap(doc.id, doc.data())).toList();// Transforme chaque document ('doc') en un objet Contact, puis rassemble le tout dans une liste 
    });
  }

  Future<void> addContact(Contact contact) => _contacts.doc(contact.id).set(contact.toMap());//Crée ou écrase un document avec l'ID du contact et y insère ses données
  Future<void> updateContact(Contact contact) => _contacts.doc(contact.id).update(contact.toMap());
  Future<void> deleteContact(String id) => _contacts.doc(id).delete();

  Stream<List<Contact>> searchContacts(String query) {
    if (query.isEmpty) return getContacts();
    final start = query;
    final end = '$query\uf8ff';
    return _contacts
        .where('name', isGreaterThanOrEqualTo: start)
        .where('name', isLessThanOrEqualTo: end)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Contact.fromMap(doc.id, doc.data())).toList());
  }
}