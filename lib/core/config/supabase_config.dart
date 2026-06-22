import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Central place that resolves Supabase credentials and initialises the client.
///
/// Credentials are read (in order) from:
///   1. The `.env` file (loaded by `flutter_dotenv`).
///   2. `--dart-define` compile time variables.
///
/// If credentials are missing or still contain the placeholder values, the app
/// boots into **demo mode** and serves in-memory mock data so the whole portal
/// remains browsable without a backend.
class SupabaseConfig {
  SupabaseConfig._();

  static const String _envUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _envKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Storage bucket that holds uploaded SVG files.
  static const String svgBucket = 'svg_assets';

  static String get url {
    final fromFile = dotenv.maybeGet('SUPABASE_URL');
    if (fromFile != null && fromFile.isNotEmpty) return fromFile;
    return _envUrl;
  }

  static String get anonKey {
    final fromFile = dotenv.maybeGet('SUPABASE_ANON_KEY');
    if (fromFile != null && fromFile.isNotEmpty) return fromFile;
    return _envKey;
  }

  static bool _initialized = false;

  /// `true` once [Supabase.initialize] has completed successfully.
  static bool get isReady => _initialized;

  /// `true` when usable credentials are present.
  static bool get isConfigured =>
      url.startsWith('https://') &&
      !url.contains('YOUR_') &&
      anonKey.isNotEmpty &&
      !anonKey.contains('YOUR_');

  /// When credentials are absent the app runs against the in-memory mock store.
  static bool get isDemoMode => !_initialized;

  static Future<void> init() async {
    if (!isConfigured) return;
    try {
      // Supports both legacy JWT anon keys and new `sb_publishable_...` keys.
      await Supabase.initialize(url: url, publishableKey: anonKey);
      _initialized = true;
    } catch (e, st) {
      _initialized = false;
      // Surface why we fell back to demo mode instead of swallowing silently.
      debugPrint('SupabaseConfig.init failed -> demo mode: $e');
      debugPrint('$st');
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
}
