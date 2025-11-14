// lib/presentation/controllers/home_controller.dart
import 'package:flutter/material.dart';
import 'contact_controller.dart';

class HomeController {
  final ContactController contactController;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  HomeController({required this.contactController});

  void updateSearch(String value) {
    searchQuery = value.toLowerCase();
  }

  void dispose() {
    searchController.dispose();
  }
}