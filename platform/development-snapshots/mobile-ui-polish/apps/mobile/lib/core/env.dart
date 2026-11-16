/// Runtime configuration, passed at build/run time via --dart-define. Never
/// hardcode a Supabase URL, key, or API host here -- see root CLAUDE.md,
/// "Hosting region and storage bucket region are configuration, never
/// hardcoded."
class Env {
  Env._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// services/api base URL. Defaults to local dev per root CLAUDE.md's port
  /// table and packages/shared/openapi/openapi.yaml's local server entry.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static bool get isConfigured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
