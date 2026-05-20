// VELT — Auth service (Supabase)
//
// Wraps Supabase auth so the rest of the app stays unaware of the SDK.
// If SUPABASE_URL / SUPABASE_ANON_KEY are not provided at build time the
// service is a no-op — the app runs fully offline and `currentUser` stays
// null. UI gates Pro/cloud features off `isSignedIn`.

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../config/env.dart';

class VeltUser {
  const VeltUser({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
  });
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
}

class AuthService {
  AuthService._();

  /// True when Supabase has been initialized with valid credentials.
  static bool _ready = false;
  static bool get isConfigured => Env.supabaseEnabled;

  /// Live notifier for the currently signed-in user (null when signed out).
  static final ValueNotifier<VeltUser?> currentUser =
      ValueNotifier<VeltUser?>(null);
  static bool get isSignedIn => currentUser.value != null;

  static Future<void> init() async {
    if (!isConfigured) {
      debugPrint('[AuthService] Supabase not configured — running offline.');
      return;
    }
    try {
      await sb.Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
        debug: false,
      );
      _ready = true;
      // Restore session if present, then listen for changes
      _emit(sb.Supabase.instance.client.auth.currentUser);
      sb.Supabase.instance.client.auth.onAuthStateChange.listen((event) {
        _emit(event.session?.user);
      });
    } catch (e, st) {
      debugPrint('[AuthService] init failed: $e\n$st');
    }
  }

  static void _emit(sb.User? u) {
    if (u == null) {
      currentUser.value = null;
      return;
    }
    currentUser.value = VeltUser(
      id: u.id,
      email: u.email ?? '',
      displayName: u.userMetadata?['display_name'] as String?,
      avatarUrl: u.userMetadata?['avatar_url'] as String?,
    );
  }

  /// Sign in / sign up with email magic link. The user receives an email
  /// with a one-time link that returns them to the app via deep link.
  static Future<String?> signInWithMagicLink(String email) async {
    if (!_ready) {
      return 'Cloud sign-in is not configured for this build.';
    }
    try {
      await sb.Supabase.instance.client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'veltfitness://auth-callback',
      );
      return null; // success
    } on sb.AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  /// Sign in with Apple. Requires iOS native config + Supabase Apple provider.
  static Future<String?> signInWithApple() async {
    if (!_ready) {
      return 'Cloud sign-in is not configured for this build.';
    }
    try {
      await sb.Supabase.instance.client.auth.signInWithOAuth(
        sb.OAuthProvider.apple,
        redirectTo: 'veltfitness://auth-callback',
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Sign in with Google. Requires Google OAuth client + Supabase config.
  static Future<String?> signInWithGoogle() async {
    if (!_ready) {
      return 'Cloud sign-in is not configured for this build.';
    }
    try {
      await sb.Supabase.instance.client.auth.signInWithOAuth(
        sb.OAuthProvider.google,
        redirectTo: 'veltfitness://auth-callback',
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  static Future<void> signOut() async {
    if (!_ready) return;
    try {
      await sb.Supabase.instance.client.auth.signOut();
    } catch (e) {
      debugPrint('[AuthService] signOut failed: $e');
    }
  }

  /// Delete the user account and all associated rows (cascade).
  /// The server-side `delete_user` RPC must be configured in Supabase.
  static Future<String?> deleteAccount() async {
    if (!_ready) return 'Not configured';
    try {
      await sb.Supabase.instance.client.rpc('delete_user');
      await signOut();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
