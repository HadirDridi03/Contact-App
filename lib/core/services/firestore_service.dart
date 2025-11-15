// lib/core/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/contact_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  CollectionReference<Map<String, dynamic>> get _contacts {
    if (_user == null) throw Exception("Utilisateur non connecté");
    return _db.collection('users').doc(_user!.uid).collection('contacts');
  }

  Stream<List<Contact>> getContacts() {
    return _contacts.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Contact.fromMap(doc.id, doc.data())).toList();
    });
  }

  Future<void> addContact(Contact contact) => _contacts.doc(contact.id).set(contact.toMap());
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