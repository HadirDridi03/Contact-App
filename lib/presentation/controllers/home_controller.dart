// lib/presentation/controllers/home_controller.dart
import 'package:flutter/material.dart';
import 'contact_controller.dart';

class HomeController {
  final ContactController contactController;
  final TextEditingController searchController = TextEditingController();
  final ValueNotifier<String> searchQuery = ValueNotifier<String>('');

  HomeController({required this.contactController}) {
    searchController.addListener(() {
      searchQuery.value = searchController.text.trim();
    });
  }

  void dispose() {
    searchController.dispose();
    searchQuery.dispose();
  }
}