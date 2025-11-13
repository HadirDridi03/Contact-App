// lib/presentation/views/auth/login_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AuthController();

    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              TextFormField(
                controller: controller.emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) => v!.isEmpty ? "Requis" : null,
              ),
              TextFormField(
                controller: controller.passwordController,
                decoration: const InputDecoration(labelText: "Mot de passe"),
                obscureText: true,
                validator: (v) => v!.isEmpty ? "Requis" : null,
              ),
              const SizedBox(height: 20),
              controller.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        final success = await controller.login(context);
                        if (success && context.mounted) context.go('/');
                      },
                      child: const Text("Se connecter"),
                    ),
              TextButton(
                onPressed: () => context.go('/register'),
                child: const Text("Créer un compte"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}