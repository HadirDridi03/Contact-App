import 'package:flutter/material.dart';//importer le package qui fournit les widgets et les outils de base de l'interface utilisateur
import 'package:go_router/go_router.dart';//importer le package qui gère la navigation entre les pages
import '../../controllers/auth_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AuthController();//Crée une nouvelle instance de AuthController à chaque reconstruction du widget

    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              TextFormField(//champ email
                controller: controller.emailController, //Lie ce champ au TextEditingController 'emailController' pour lire et manipuler son contenu
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) => v!.isEmpty ? "Requis" : null,//si la valeur entrée est vide affiche requis sinon null
              ),
              TextFormField(//champ mot de passe
                controller: controller.passwordController,
                decoration: const InputDecoration(labelText: "Mot de passe"),
                obscureText: true,//masquer le texte saisie
                validator: (v) => v!.isEmpty ? "Requis" : null,
              ),
              const SizedBox(height: 20),
              //Affichage conditionnel basé sur l'état de chargement
              controller.isLoading
                  ? const CircularProgressIndicator()//on affiche un indicateur de chargement circulaire
                  : ElevatedButton(//on affiche le bouton de connexion
                      onPressed: () async {
                        final success = await controller.login(context);
                        if (success && context.mounted) context.go('/');//si success=true et la page est affiché sur l'ecran ,naviguer vers la page d'accueil 
                      //context.mounted est une vérification de sécurité cruciale pour éviter d'essayer de naviguer si la page a déjà été retirée de l'écran pendant l'appel réseau.
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