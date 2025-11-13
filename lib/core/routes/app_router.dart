// lib/core/routes/app_router.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../presentation/views/auth/login_view.dart';
import '../../presentation/views/auth/register_view.dart';
import '../../presentation/views/home/home_view.dart';
//import '../../presentation/views/home/add_contact_view.dart';
//import '../../presentation/views/home/edit_contact_view.dart';
import '../../data/models/contact_model.dart';

// lib/core/routes/app_router.dart

final GoRouter router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isAuthPage = state.uri.toString() == '/login' || state.uri.toString() == '/register';

    if (!isLoggedIn && !isAuthPage) return '/login';
    if (isLoggedIn && isAuthPage) return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginView()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterView()),
    GoRoute(path: '/', builder: (context, state) => const HomeView()),
    // SUPPRIMÉ : /add et /edit
  ],
);