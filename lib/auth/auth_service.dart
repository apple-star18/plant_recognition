import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

// class AuthService {
//   static final SupabaseClient _client = Supabase.instance.client;
//
//   static Future<void> signInWithGoogle() async {
//     final GoogleSignIn _googleSignIn = GoogleSignIn(
//       scopes: ['email'],
//       serverClientId: '334143867990-onpepbdbgos434v4n3p10k1eeu11qodt.apps.googleusercontent.com',
//     );
//
//     final googleUser = await _googleSignIn.signIn();
//     if (googleUser == null) throw Exception('Google sign-in cancelled');
//
//     final googleAuth = await googleUser.authentication;
//         final idToken = googleAuth.idToken;
//     final accessToken = googleAuth.accessToken;
//
//     if (idToken == null) throw Exception('Don\'t have take idToken.');
//
//     final res = await _client.auth.signInWithIdToken(
//         provider: OAuthProvider.google,
//         idToken: idToken,
//         accessToken: accessToken,
//     );
//
//     if (res.user == null) throw Exception('Supabase sign-in failed');
//   }
//
//   static Future<void> signOut() async {
//     await _client.auth.signOut();
//   }
//
//   static bool isSignedIn() {
//     return _client.auth.currentUser != null;
//   }
// }


class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<void> signInWithGoogle() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: ['email'],
      serverClientId: '334143867990-onpepbdbgos434v4n3p10k1eeu11qodt.apps.googleusercontent.com',
    );

    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) throw Exception('No idToken received.');

    final res = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    if (res.user == null) throw Exception('Supabase sign-in failed');
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static bool isSignedIn() {
    return _client.auth.currentUser != null;
  }
}