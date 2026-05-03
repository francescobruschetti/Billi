import 'package:Billy/authGate/auth_gate.dart';
import 'package:Billy/enums/theme_enum.dart';
import 'package:Billy/extentions/user_settings_extensions.dart';
import 'package:Billy/languages/app_localizations.dart';
import 'package:Billy/local/database/app_database.dart';
import 'package:Billy/providers/local-database/user_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:Billy/logger.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/login_logout_signup/login_page.dart';
import 'pages/login_logout_signup/signup_page.dart';
import 'pages/login_logout_signup/logout_page.dart';

late AppDatabase database; // Global variable to hold the instance of the database, accessible from anywhere in the app.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupLogging(); // Initialize logging

  await Supabase.initialize(
    url: 'https://qislfeuyfqydzocxuwsw.supabase.co',
    anonKey: 'sb_publishable_AKPVXyVowkiKw-j1eGfHlw_D3YRGyGd',
  );

  // Load Drift Database
  database = AppDatabase();

  runApp(
    ProviderScope( // *Added in order to use Riverpod providers* 
      overrides: [
        localDatabaseProvider.overrideWithValue(database), // inietta l'istanza nel provider
      ],
      child: const BillyApp(),
    ),
  );
}

class BillyApp extends ConsumerStatefulWidget  {
  const BillyApp({super.key});

  @override
  ConsumerState<BillyApp> createState() => _BillyAppState();

  static void setLocale(BuildContext context, Locale locale) {
    _BillyAppState? state = context.findAncestorStateOfType<_BillyAppState>();
    state?.changeLocale(locale);
  }

  static String getCurrentLanguage(BuildContext context) {
    _BillyAppState? state = context.findAncestorStateOfType<_BillyAppState>();
    return state?.currentLanguage ?? 'en';
  }
}

class _BillyAppState extends ConsumerState<BillyApp> {
  final Logger log = Logger('BillyApp');

  // TODO: valutare se è possibile evitare di usare lo state per la lingua, e gestirla direttamente dalle impostazioni (come per il tema) in modo più "reactive" e meno "imperativo"
  String currentLanguage = 'en';
  late Locale _locale = Locale(currentLanguage);
    void changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
      currentLanguage = locale.languageCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watches settings — loads from DB on first build
    final settingsState = ref.watch(userSettingsProvider);

    return settingsState.when(
      loading: () => const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => MaterialApp(
        home: Scaffold(body: Center(child: Text('Error: $e'))),
      ),
      data: (settings) => MaterialApp(
        locale: _currentLanguage(settings),

        debugShowCheckedModeBanner: false,
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const SignupPage(),
          '/logout': (context) => const LogoutPage(),
        },
        home: AuthGate(), // TODO: custom load page between pages: SplashScreen(),
        
        // Setup ThemeData con ColorScheme personalizzato
        theme: ThemeData(
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            brightness: Brightness.light,
            seedColor: Colors.blue,
            onPrimary: Colors.black, // To be used for elements over background (text, icons, etc.)
            
            primaryContainer: Colors.blue[300], // To be used for main elements (buttons, active elements, etc.)
            onPrimaryContainer: Colors.black, // To be used for elements over main elements (button's text, button's icon, etc.)
            
            secondary: Colors.orange, // To be used for elements that need to stand out (accent color, highlights, etc.)
            onSecondary: Colors.black, // To be used for elements over secondary elements (text, icons, etc.)

            secondaryContainer: Colors.orange, // To be use for elements that need to stand out (accent color, highlights, etc.)
            onSecondaryContainer: Colors.black, // To be used for elements over secondary container elements (text, icons, etc.)

          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            brightness: Brightness.dark,
            seedColor: Colors.blue,
            onPrimary: Colors.white, // To be used for elements over background (text, icons, etc.)

            primaryContainer: Colors.blue[300], // To be used for main elements (buttons, active elements, etc.)
            onPrimaryContainer: Colors.black, // To be used for elements over main elements (button's text, button's icon, etc.)

            secondary: Colors.orange, // To be used for elements that need to stand out (accent color, highlights, etc.)
            onSecondary: Colors.black, // To be used for elements over secondary elements (text, icons, etc.)

            secondaryContainer: Colors.orange, // To be use for elements that need to stand out (accent color, highlights, etc.)
            onSecondaryContainer: Colors.black, // To be used for elements over secondary container elements (text, icons, etc.)
          ),
        ),
        themeMode: _toThemeMode(settings), // Usa il theme mode dalle impostazioni per gestire l'intera app (light/dark/automatico)

        // Configure Language (localization)
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en'), // English
          Locale('it'), // Italian
        ],
      ),
    );
  }

  Locale _currentLanguage(UserSettingsTableData? settings) {
    final language = settings?.language ?? '';
    log.fine('x> Determining current language based on settings: $settings');

    switch (language) {
      case 'it':
        _locale = Locale('it');
      case 'en':
        _locale = Locale('en');
      default:
        _locale = Locale('it'); // fallback
    }

    return _locale;

  }

  ThemeMode _toThemeMode(UserSettingsTableData? settings) {
    log.fine('x> Determining theme mode based on settings: $settings');
    switch (settings?.themeModeEnum) {
      case ThemeEnum.LIGHT: return ThemeMode.light;
      case ThemeEnum.DARK: return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }
}