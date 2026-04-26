import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  GoogleSignInService._internal();
  static final GoogleSignInService instance = GoogleSignInService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _initialized = false;

  /// ⚙️ Initialisation (OBLIGATOIRE AVANT TOUT)
  Future<void> init() async {
    if (_initialized) return;

    await _googleSignIn.initialize(
      // ❗ OBLIGATOIRE sur Android avec authenticate()

      serverClientId: '451498151439-qqsk74ekp0gueaj5tp9jddkod4snh7j5.apps.googleusercontent.com',
    );

    _initialized = true;
  }

  /// 🔐 Connexion Google (clic utilisateur)
  Future<GoogleSignInAccount?> signIn() async {
    try {
      if (!_googleSignIn.supportsAuthenticate()) return null;

      return await _googleSignIn.authenticate();
    } catch (e) {
      debugPrint('❌ Google Sign-In error: $e');
      return null;
    }
  }

  /// 🔄 Connexion silencieuse (remplace signInSilently)
  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      if (!_googleSignIn.supportsAuthenticate()) return null;

      return await _googleSignIn.authenticate(
          // PAS de popup
          );
    } catch (e) {
      debugPrint('❌ Silent Google Sign-In error: $e');
      return null;
    }
  }

  /// 🚪 Déconnexion complète
  Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect();
    } catch (e) {
      debugPrint('❌ Google Sign-Out error: $e');
    }
  }
}
