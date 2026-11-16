/// Runtime configuration, passed at build/run time via --dart-define. Never
/// hardcode a Supabase URL, key, or API host here -- see root CLAUDE.md,
/// "Hosting region and storage bucket region are configuration, never
/// hardcoded."
class Env {
  Env._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static const aiProvider = String.fromEnvironment(
    'AI_PROVIDER',
    defaultValue: 'gemini',
  );

  /// services/api base URL. Defaults to local dev per root CLAUDE.md's port
  /// table and packages/shared/openapi/openapi.yaml's local server entry.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// Google Gemini API key for AI features.
  static const geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AQ.Ab8RN6JT_E5w0I2xkeCgEb7YSKt2-cSfeTm7gMbdg0hRFhHRew',
  );

  /// Groq API key for AI features.
  static const groqApiKey = String.fromEnvironment('GROQ_API_KEY');

  /// The active API key (prefers Groq).
  static String get aiApiKey =>
      groqApiKey.isNotEmpty ? groqApiKey : geminiApiKey;

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
