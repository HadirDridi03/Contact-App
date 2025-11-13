// lib/presentation/controllers/auth_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';

class AuthController {
  final AuthService _auth = AuthService();
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController(); // Champ Nom complet
  bool isLoading = false;

  Future<bool> login(BuildContext context) async {
    if (!formKey.currentState!.validate()) return false;
    isLoading = true;
    try {
      await _auth.signIn(emailController.text, passwordController.text);
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
      return false;
    } finally {
      isLoading = false;
    }
  }

  Future<bool> register(BuildContext context) async {
    if (!formKey.currentState!.validate()) return false;
    isLoading = true;
    try {
      // 1. Créer le compte
      final userCredential = await _auth.register(emailController.text, passwordController.text);
      final user = userCredential;

      if (user != null) {
        // 2. Mettre à jour le displayName dans Firebase Auth
        await user.updateDisplayName(nameController.text);
        await user.reload();

        // 3. Sauvegarder le profil dans Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': nameController.text,
          'email': emailController.text,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
      return false;
    } finally {
      isLoading = false;
    }
  }

  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
  }

  // Nettoyage des contrôleurs
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
  }
}