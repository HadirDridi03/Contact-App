// lib/core/routes/app_router.dart
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
  initialLocation: '/login',
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
      pageBuilder: (context, state) {
        // Récupère le contact passé en extra
        final contact = state.extra as Contact?;
        if (contact == null) {
          // Si aucun contact → retour à l'accueil
          return _fadePage(state, const HomeView());
        }
        return _fadePage(state, EditContactView(contact: contact));
      },
    ),
  ],
);

// TRANSITION FLUIDE (FADE)
CustomTransitionPage _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
  );
}