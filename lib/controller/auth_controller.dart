import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 
import '../service/auth_service.dart';

class AuthController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<bool> login(BuildContext context) async {
    if (!formKey.currentState!.validate()) return false;

    isLoading = true;
    final success = await AuthService.instance.login(
      emailController.text.trim(),
      passwordController.text,
    );
    isLoading = false;

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email ou mot de passe incorrect")),
      );
    }
    return success;
  }

  Future<bool> register(BuildContext context) async {
    if (!formKey.currentState!.validate()) return false;

    isLoading = true;
    final success = await AuthService.instance.register(
      emailController.text.trim(),
      passwordController.text,
    );
    isLoading = false;

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cet email existe déjà")),
      );
    }
    return success;
  }


  Future<void> logout(BuildContext context) async {
    await AuthService.instance.logout();

    
    if (context.mounted) {
      GoRouter.of(context).go('/login');
    }
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}