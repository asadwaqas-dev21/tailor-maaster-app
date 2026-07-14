import "package:flutter/foundation.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:supabase_flutter/supabase_flutter.dart";

/// Supabase client bootstrap.
///
/// Put your project keys in `.env` at the project root:
/// ```
/// SUPABASE_URL=https://xxxx.supabase.co
/// SUPABASE_ANON_KEY=eyJhbGciOi...
/// ```
class SupabaseService {
  SupabaseService._();

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static SupabaseClient get client {
    if (!_initialized) {
      throw StateError(
        "Supabase is not initialized. Add SUPABASE_URL and "
        "SUPABASE_ANON_KEY to .env, then restart the app.",
      );
    }
    return Supabase.instance.client;
  }

  static Future<void> init() async {
    final url = dotenv.env["SUPABASE_URL"]?.trim() ?? "";
    final anonKey = dotenv.env["SUPABASE_ANON_KEY"]?.trim() ?? "";

    if (url.isEmpty || anonKey.isEmpty) {
      debugPrint(
        "Supabase: missing SUPABASE_URL / SUPABASE_ANON_KEY in .env — "
        "running offline (Hive) only.",
      );
      return;
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
    _initialized = true;
  }
}
