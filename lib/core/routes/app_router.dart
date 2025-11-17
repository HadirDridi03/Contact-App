import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import des vues
import '../../presentation/views/auth/login_view.dart';
import '../../presentation/views/auth/register_view.dart';
import '../../presentation/views/home/home_view.dart';
import '../../presentation/views/home/add_contact_view.dart';
import '../../presentation/views/home/edit_contact_view.dart';

// Import du modèle
import '../../data/models/contact_model.dart';

// ROUTEUR GLOBAL
final GoRouter router = GoRouter(
   // Définit la route de démarrage de l'application
  initialLocation: '/login',
   // Fonction de redirection, agit comme un garde avant chaque navigation
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final currentPath = state.uri.path;

    // Si pas connecté et pas sur login/register → redirige vers login
    if (!isLoggedIn && currentPath != '/login' && currentPath != '/register') {
      return '/login';
    }

    // Si connecté et sur login/register → redirige vers accueil
    if (isLoggedIn && (currentPath == '/login' || currentPath == '/register')) {
      return '/';
    }

    return null;
  },
  routes: [
    // PAGE DE CONNEXION
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => _fadePage(state, const LoginView()),
    ),

    // PAGE D'INSCRIPTION
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => _fadePage(state, const RegisterView()),
    ),

    // PAGE D'ACCUEIL
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _fadePage(state, const HomeView()),
    ),

    // AJOUTER UN CONTACT
    GoRoute(
      path: '/add',
      pageBuilder: (context, state) => _fadePage(state, const AddContactView()),
    ),

    // MODIFIER UN CONTACT
    GoRoute(
      path: '/edit',
      pageBuilder: (context, state) {//Le pageBuilder reçoit un objet state de type GoRouterState. Cet objet contient toutes les informations sur la navigation en cours
         // Tente de récupérer l'objet Contact passé dans le paramètre 'extra' de la navigation
        final contact = state.extra as Contact?;
        if (contact == null) {
          // Si aucun contact retour à l'accueil
          return _fadePage(state, const HomeView());
        }
        return _fadePage(state, EditContactView(contact: contact));
      },
    ),
  ],
);

// Fonction d'aide privée pour créer une transition de page en fondu (fade)
CustomTransitionPage _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    // Durée de l'animation
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
  );
}