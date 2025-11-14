// lib/core/routes/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../presentation/views/auth/login_view.dart';
import '../../presentation/views/auth/register_view.dart';
import '../../presentation/views/home/home_view.dart';
import '../../presentation/views/home/add_contact_view.dart';
import '../../presentation/views/home/edit_contact_view.dart';
import '../../../data/models/contact_model.dart';

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
    // CONNEXION
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginView(),
    ),

    // INSCRIPTION
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterView(),
    ),

    // ACCUEIL
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeView(),
    ),

    // AJOUTER CONTACT
    GoRoute(
      path: '/add',
      builder: (context, state) => const AddContactView(),
    ),

    // MODIFIER CONTACT ← AJOUTÉ ICI
    GoRoute(
      path: '/edit/:id',
      builder: (context, state) {
        final contact = state.extra as Contact;
        return EditContactView(contact: contact);
      },
    ),
  ],
);