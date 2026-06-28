class AppConfig {

  // ENV: flutter run --dart-define=ENV=local
  // ANDROID; flutter build apk --dart-define=ENV=prod
  // IOS: flutter build ipa --dart-define=ENV=prod

  static const env = String.fromEnvironment(
    'ENV',
    defaultValue: 'local',
  );

  static String get supabaseUrl {
    switch (env) {
      case 'prod':
        return 'https://qislfeuyfqydzocxuwsw.supabase.co';
      // case 'test':
      //   return 'https://test-project.supabase.co';
      default:
        return 'http://127.0.0.1:54321';
    }
  }

  static String get supabaseAnonKey {
    switch (env) {
      case 'prod':
        return 'sb_publishable_AKPVXyVowkiKw-j1eGfHlw_D3YRGyGd';
      // case 'test':
      //   return 'sb_publishable_TEST';
      default:
        // ottenuto facendo: supabase status
        return 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH';
    }
  }
}