// lib/presentation/views/auth/register_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final AuthController controller;

  @override
  void initState() {
    super.initState();
    controller = AuthController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.trim().isEmpty ? "Requis" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.passwordController,
                decoration: const InputDecoration(labelText: "Mot de passe"),
                obscureText: true,
                validator: (v) => v!.length < 6 ? "Min 6 caractères" : null,
              ),
              const SizedBox(height: 20),
              controller.isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final success = await controller.register(context);
                          if (success && context.mounted) {
                            context.go('/');
                          }
                        },
                        child: const Text("S'inscrire"),
                      ),
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