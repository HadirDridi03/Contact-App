// lib/presentation/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  // Form
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // État
  bool isLoading = false;

  // Nettoyage
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  // CONNEXION
  Future<bool> login(BuildContext context) async {
    if (!formKey.currentState!.validate()) return false;

    setStateLoading(true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _showError(context, e.message ?? "Erreur de connexion");
      return false;
    } finally {
      setStateLoading(false);
    }
  }

  // INSCRIPTION
  Future<bool> register(BuildContext context) async {
    if (!formKey.currentState!.validate()) return false;

    setStateLoading(true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _showError(context, e.message ?? "Erreur d'inscription");
      return false;
    } finally {
      setStateLoading(false);
    }
  }

  // DÉCONNEXION
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) context.go('/login');
  }

  // UTILITAIRES
  void setStateLoading(bool value) {
    isLoading = value;
    // Force rebuild si dans StatefulWidget
    // (ici on utilise ValueNotifier ou setState dans la vue)
  }

  void _showError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}