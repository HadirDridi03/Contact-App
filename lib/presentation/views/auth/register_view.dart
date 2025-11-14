// lib/presentation/views/auth/register_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AuthController();

    return Scaffold(
      appBar: AppBar(title: const Text("Inscription")),
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
                validator: (v) => v!.length < 6 ? "Min 6 caractères" : null,
              ),
              const SizedBox(height: 20),
              controller.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        final success = await controller.register(context);
                        if (success && context.mounted) context.go('/');
                      },
                      child: const Text("S'inscrire"),
                    ),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text("Déjà un compte ?"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}