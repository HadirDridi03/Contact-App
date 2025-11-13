// lib/presentation/controllers/home_controller.dart
import 'package:flutter/material.dart';
import '../../core/services/firestore_service.dart';
import '../../data/models/contact_model.dart';

class HomeController {
  final FirestoreService _firestore = FirestoreService();
  final searchController = TextEditingController();
  String searchQuery = '';

  Stream<List<Contact>> get contactsStream {
    return searchQuery.isEmpty
        ? _firestore.getContacts()
        : _firestore.searchContacts(searchQuery);
  }

  void updateSearch(String query) {
    searchQuery = query.trim();
  }
}