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
  late final AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AuthController(); // Crée une seule fois
  }

  @override
  void dispose() {
    _controller.dispose(); // Libère les contrôleurs
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inscription")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _controller.formKey,
          child: Column(
            children: [
              // CHAMP NOM COMPLET
              TextFormField(
                controller: _controller.nameController,
                decoration: const InputDecoration(
                  labelText: "Nom complet",
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v!.trim().isEmpty ? "Requis" : null,
              ),
              const SizedBox(height: 12),

              // EMAIL
              TextFormField(
                controller: _controller.emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.trim().isEmpty ? "Requis" : null,
              ),
              const SizedBox(height: 12),

              // MOT DE PASSE
              TextFormField(
                controller: _controller.passwordController,
                decoration: const InputDecoration(
                  labelText: "Mot de passe",
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (v) => v!.length < 6 ? "Min 6 caractères" : null,
              ),
              const SizedBox(height: 24),

              // BOUTON INSCRIPTION
              _controller.isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final success = await _controller.register(context);
                          if (success && context.mounted) {
                            context.go('/');
                          }
                        },
                        child: const Text("S'inscrire"),
                      ),
                    ),

              // LIEN CONNEXION
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text("Déjà un compte ? Se connecter"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}