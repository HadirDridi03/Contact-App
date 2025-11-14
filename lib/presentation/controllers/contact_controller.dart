// lib/presentation/controllers/contact_controller.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/contact_model.dart';

class ContactController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  // StreamController pour forcer le rafraîchissement
  final _refreshController = StreamController<void>.broadcast();
  Stream<void> get refreshStream => _refreshController.stream;

  Stream<List<Contact>> getContacts() {
    if (_userId == null) return Stream.value([]);

    return _db
        .collection('users')
        .doc(_userId)
        .collection('contacts')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Contact.fromMap(doc.data())).toList();
    });
  }

  Future<void> addContact(String name, String email, String phone) async {
    if (_userId == null) return;

    final contact = Contact(
      id: const Uuid().v4(),
      name: name,
      email: email,
      phone: phone,
    );

    await _db
        .collection('users')
        .doc(_userId)
        .collection('contacts')
        .doc(contact.id)
        .set(contact.toMap());

    _refreshController.add(null); // Rafraîchit
  }

  Future<void> deleteContact(String id) async {
    if (_userId == null) return;

    await _db
        .collection('users')
        .doc(_userId)
        .collection('contacts')
        .doc(id)
        .delete();

    _refreshController.add(null); // Rafraîchit
  }

  Future<void> updateContact(Contact contact) async {
    if (_userId == null) return;

    await _db
        .collection('users')
        .doc(_userId)
        .collection('contacts')
        .doc(contact.id)
        .update(contact.toMap());

    _refreshController.add(null); // Rafraîchit
  }

  void dispose() {
    _refreshController.close();
  }
}