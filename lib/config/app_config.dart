class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // Session timeouts (HIPAA)
  static const Duration inactivityTimeout = Duration(minutes: 5);
  static const Duration accessTokenTtl = Duration(minutes: 15);
  static const Duration refreshTokenTtl = Duration(hours: 8);

  // Password requirements
  static const int minPasswordLength = 12;
}
