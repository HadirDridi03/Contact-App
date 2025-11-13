// lib/core/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/contact_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  CollectionReference get _contacts => _db.collection('users/${_user!.uid}/contacts');

  Stream<List<Contact>> getContacts() {
    return _contacts.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Contact.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<void> addContact(Contact contact) => _contacts.doc(contact.id).set(contact.toMap());
  Future<void> updateContact(Contact contact) => _contacts.doc(contact.id).update(contact.toMap());
  Future<void> deleteContact(String id) => _contacts.doc(id).delete();

  Stream<List<Contact>> searchContacts(String query) {
    return _contacts
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Contact.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
    });
  }
}