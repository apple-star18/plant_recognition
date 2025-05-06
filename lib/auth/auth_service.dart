import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// AuthService: Handles user authentication using Supabase, including email and Google sign-in.
class AuthService {
  /// Supabase client instance.
  static final SupabaseClient _client = Supabase.instance.client;

  /// Sign up with email and password.
  /// Throws a detailed exception message if signup fails.
  static Future<void> signUpWithEmail(String email, String password) async {
    // Input validation
    if (email.isEmpty || password.isEmpty) {
      throw AuthException('Email or password cannot be empty.');
    }

    try {
      final response = await _client.auth.signUp(email: email, password: password);

      if (response.user == null) {
        throw AuthException('Sign-up failed: No user created.');
      }
    } on AuthException catch (e) {
      // Handle Supabase authentication errors
      throw AuthException('Sign-up failed: ${e.message}');
    } catch (e) {
      // General exception handling
      throw Exception('Unexpected error occurred: $e');
    }
  }

  /// Sign in with email and password.
  /// Throws a detailed exception message if login fails.
  static Future<void> signInWithEmail(String email, String password) async {
    // Input validation
    if (email.isEmpty || password.isEmpty) {
      throw AuthException('Email or password cannot be empty.');
    }

    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('Login failed: Invalid credentials.');
      }
    } on AuthException catch (e) {
      // Handle Supabase authentication errors
      throw AuthException('Login failed: ${e.message}');
    } catch (e) {
      // General exception handling
      throw Exception('Unexpected error occurred: $e');
    }
  }

  /// Sign in with Google using OAuth.
  /// Throws an exception if any step of the Google sign-in process fails.
  static Future<void> signInWithGoogle() async {
    try {
      // Initialize Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
        serverClientId:
        '334143867990-onpepbdbgos434v4n3p10k1eeu11qodt.apps.googleusercontent.com',
      );

      // Prompt user to sign in with Google
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Google sign-in was cancelled.');
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null || accessToken == null) {
        throw AuthException('Google authentication failed: Missing tokens.');
      }

      // Sign in with Supabase using the Google OAuth tokens
      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        throw AuthException('Supabase login failed with Google.');
      }
    } catch (e) {
      // Handle any errors that occur during the Google sign-in process
      throw Exception('Google sign-in failed: $e');
    }
  }

  /// Sign out the currently authenticated user.
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      // Handle errors during sign-out
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Check if the user is currently signed in.
  /// Returns true if the user is signed in, otherwise false.
  static bool isSignedIn() {
    return _client.auth.currentUser != null;
  }

  /// Get the current user, if any.
  /// Returns the current user object or null if not signed in.
  static User? getCurrentUser() {
    return _client.auth.currentUser;
  }
}
