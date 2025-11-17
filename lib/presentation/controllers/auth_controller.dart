import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  // Form
  final formKey = GlobalKey<FormState>();// Lie ce widget Form à la GlobalKey<FormState> définie dans le contrôleur
  // Cette clé agit comme un identifiant unique, permettant au contrôleur d'accéder à l'état du formulaire (FormState) pour déclencher des actions comme la validation (`.validate()`)
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // État
  bool isLoading = false;

  // Nettoyage
  void dispose() {
    emailController.dispose();//libérer les ressources du contrôleur du champ
    passwordController.dispose();
  }


  // CONNEXION
  Future<bool> login(BuildContext context) async {
    if (!formKey.currentState!.validate()) return false;//Si la validation du formulaire échoue, on arrête le processus
    setStateLoading(true);// Met à jour l'état de chargement à 'true'
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(//donner email et mdp à firebaseAuth pour chercher ces données dans la base de données
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      return true;//si il il ne retourne pas d'erreurs login retourne true
    } on FirebaseAuthException catch (e) {//filtrer les erreurs afficher juste les erreurs venu du FirebaseException
      _showError(context, e.message ?? "Erreur de connexion");
      return false;
    } finally {
      setStateLoading(false);//Met à jour l'état de chargement à 'false'
    }
  }

  // INSCRIPTION
  Future<bool> register(BuildContext context) async {
    if (!formKey.currentState!.validate()) return false;

    setStateLoading(true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        //`FirebaseAuth.instance`:donne l'objet unique et central pour communiquer avec le service d'auth de Firebase depuis n'importe où dans l'app
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _showError(context, e.message ?? "Erreur d'inscription");//si e.message est null affiche "Erreur d'inscription"
      return false;
    } finally {
      setStateLoading(false);
    }
  }

  // DÉCONNEXION
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) context.go('/login');//On navigue vers la page de connexion seulement si la page depuis laquelle on a appuyé sur le bouton de déconnexion est toujours affichée à l'écran au moment où la déconnexion est terminée.
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