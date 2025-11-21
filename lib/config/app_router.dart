// lib/config/routes/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import de tes vues
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/home/home_view.dart';
import '../views/home/add_contact_view.dart';
import '../views/home/edit_contact_view.dart';

// Import du modèle
import '../model/contact_model.dart';

// Import du service d'authentification locale
import '../service/auth_service.dart';

/// Router global de l'application
final GoRouter router = GoRouter(
  initialLocation: '/login',

  /// Redirection intelligente selon l'état de connexion
  redirect: (context, state) async {
    final bool isLoggedIn = await AuthService.instance.isLoggedIn();
    final String location = state.uri.path;

    // Pas connecté → on force /login
    if (!isLoggedIn && location != '/login' && location != '/register') {
      return '/login';
    }

    // Connecté mais sur login/register → on renvoie à l'accueil
    if (isLoggedIn && (location == '/login' || location == '/register')) {
      return '/';
    }

    // Sinon, on laisse passer
    return null;
  },

  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginView(),
    ),

    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterView(),
    ),

    GoRoute(
      path: '/',
      builder: (context, state) => const HomeView(),
    ),

    GoRoute(
      path: '/add',
      builder: (context, state) => const AddContactView(),
    ),

    GoRoute(
      path: '/edit',
      builder: (context, state) {
        final contact = state.extra as Contact?;
        // Sécurité : si aucun contact n'est passé, on retourne à l'accueil
        if (contact == null) {
          return const HomeView();
        }
        return EditContactView(contact: contact);
      },
    ),
  ],

  // Optionnel : page d'erreur personnalisée
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(
        'Page non trouvée : ${state.uri}',
        style: const TextStyle(fontSize: 18, color: Colors.red),
      ),
    ),
  ),
);