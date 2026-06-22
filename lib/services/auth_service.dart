import '../core/config/supabase_config.dart';

/// Wraps Supabase authentication. The default admin account below is also the
/// credential pair accepted by the offline demo fallback when no backend is
/// configured.
class AuthService {
  /// Default admin account, used by the login screen's one-click shortcut.
  static const adminEmail = 'admin@yammo.app';
  static const adminPassword = 'Yammo12345!';

  bool _demoLoggedIn = false;
  String _demoEmail = '';

  bool get isLoggedIn {
    if (SupabaseConfig.isDemoMode) return _demoLoggedIn;
    return SupabaseConfig.client.auth.currentSession != null;
  }

  String get currentEmail {
    if (SupabaseConfig.isDemoMode) return _demoEmail;
    return SupabaseConfig.client.auth.currentUser?.email ?? '';
  }

  Future<void> signIn(String email, String password) async {
    if (SupabaseConfig.isDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (email.trim().toLowerCase() == adminEmail &&
          password == adminPassword) {
        _demoLoggedIn = true;
        _demoEmail = email.trim();
        return;
      }
      throw Exception('Invalid credentials. Admin login: $adminEmail / $adminPassword');
    }
    await SupabaseConfig.client.auth
        .signInWithPassword(email: email.trim(), password: password);
  }

  Future<void> signUp(String email, String password) async {
    if (SupabaseConfig.isDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      _demoLoggedIn = true;
      _demoEmail = email.trim();
      return;
    }
    await SupabaseConfig.client.auth
        .signUp(email: email.trim(), password: password);
  }

  Future<void> signOut() async {
    if (SupabaseConfig.isDemoMode) {
      _demoLoggedIn = false;
      _demoEmail = '';
      return;
    }
    await SupabaseConfig.client.auth.signOut();
  }

  Future<void> sendPasswordReset(String email) async {
    if (SupabaseConfig.isDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return;
    }
    await SupabaseConfig.client.auth.resetPasswordForEmail(email.trim());
  }
}
