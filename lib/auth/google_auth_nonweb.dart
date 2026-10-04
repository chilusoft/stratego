import 'package:google_sign_in/google_sign_in.dart';

/// Non-web platforms use google_sign_in package.
class GoogleAuth {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '176187083398-lhfjmlkq87rld56n6bpu50nqddv3pi0h.apps.googleusercontent.com',
  );

  static Future<String?> signIn() async {
    try {
      final user = await _googleSignIn.signIn();
      if (user == null) return null;
      final auth = await user.authentication;
      return auth.idToken;
    } catch (_) {
      return null;
    }
  }
}
