import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;//Instance pour communiquer avec le service d'Authentification

  User? get currentUser => _auth.currentUser;//Retourne le user actuel 
  Stream<User?> get authStateChanges => _auth.authStateChanges();//Retourne un flux (Stream) qui notifie les changements d'état d'authentification (connexion/déconnexion)

  Future<User?> signIn(String email, String password) async {//methode qui retourne l'objet user ou null
    final result = await _auth.signInWithEmailAndPassword(email: email, password: password);//Le résultat ('result') est un objet 'UserCredential' qui contient les informations de connexion, y compris l'objet User
    return result.user;
  }

  Future<User?> register(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return result.user;
  }

  Future<void> signOut() => _auth.signOut();
}