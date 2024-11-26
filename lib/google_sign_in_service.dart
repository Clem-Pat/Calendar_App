import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  static Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // L'utilisateur a annulé la connexion
        return null;
      }
      return googleUser;
    } catch (error) {
      debugPrint('Erreur lors de la connexion Google : $error');
      return null;
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      debugPrint("Déconnecté de Google.");
    } catch (error) {
      debugPrint('Erreur lors de la déconnexion Google : $error');
    }
  }

  static Future<GoogleSignInAccount?> getCurrentUser() async {
    return _googleSignIn.currentUser;
  }
}

