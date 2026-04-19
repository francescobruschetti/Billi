import 'package:Billy/enums/theme_enum.dart';
import 'package:Billy/languages/app_localizations.dart';
import 'package:Billy/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:Billy/logger.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/main_scaffold.dart';
import 'pages/login_logout_signup/login_page.dart';
import 'pages/login_logout_signup/signup_page.dart';
import 'pages/login_logout_signup/logout_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupLogging(); // Initialize logging

  await Supabase.initialize(
    url: 'https://qislfeuyfqydzocxuwsw.supabase.co',
    anonKey: 'sb_publishable_AKPVXyVowkiKw-j1eGfHlw_D3YRGyGd',
  );

  // TODO: ISAR
  // final dir = await getApplicationDocumentsDirectory();
  // final isar = await Isar.open(
  //   [CategoryLocalSchema], // aggiungi qui tutti i tuoi schema
  //   directory: dir.path,
  // );

  runApp(
    ProviderScope( // *Added in order to use Riverpod providers* 
      // TODO: ISAR
      // overrides: [
      //   isarProvider.overrideWithValue(isar), // inietta l'istanza
      // ],
      child: const BillyApp(),
    ),
  );
}

class BillyApp extends StatefulWidget {
  const BillyApp({super.key});

  @override
  State<BillyApp> createState() => _BillyAppState();

  static void setLocale(BuildContext context, Locale locale) {
    _BillyAppState? state = context.findAncestorStateOfType<_BillyAppState>();
    state?.changeLocale(locale);
  }

  static String getCurrentLanguage(BuildContext context) {
    _BillyAppState? state = context.findAncestorStateOfType<_BillyAppState>();
    return state?.currentLanguage ?? 'en';
  }

  static ThemeMode getThemeMode(BuildContext context) {
    _BillyAppState? state = context.findAncestorStateOfType<_BillyAppState>();
    return state?._themeMode ?? ThemeMode.system;
  }

  static void setToggleThemeMode(BuildContext context, ThemeEnum selectedTheme) {
    _BillyAppState? state = context.findAncestorStateOfType<_BillyAppState>();
    if (state != null) {
      ThemeMode newMode;
      switch (selectedTheme) {
        case ThemeEnum.LIGHT:
          newMode = ThemeMode.light;
          break;
        case ThemeEnum.DARK:
          newMode = ThemeMode.dark;
          break;
        case ThemeEnum.SYSTEM:
          newMode = ThemeMode.system;
          break;
      }

      state.setThemeMode(newMode);
    }
  }
}

class _BillyAppState extends State<BillyApp> {
  String currentLanguage = 'en';
  late Locale _locale = Locale(currentLanguage);
  ThemeMode _themeMode = ThemeMode.system; // automatico: system

  void changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
      currentLanguage = locale.languageCode;
    });
  }

  void setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,

      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const SignupPage(),
        '/logout': (context) => const LogoutPage(),
      },
      home: SplashScreen(),
      
      // Setup ThemeData con ColorScheme personalizzato
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: Colors.blue,
          
          primaryContainer: Colors.blue[300],
          onPrimary: Colors.black,
          onPrimaryContainer: Colors.white,
          
          secondary: Colors.black,
          onSecondary: Colors.black,

          secondaryContainer: Colors.orange[300],
          onSecondaryContainer: Colors.orange[300],

        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: Colors.blue,

          primaryContainer: Colors.blue[300],
          onPrimary: Colors.black,
          onPrimaryContainer: Colors.white,

          secondary: Colors.orange,
          onSecondary: Colors.black,

          secondaryContainer: Colors.orange[300],
          onSecondaryContainer: Colors.black,
        
        ),
      ),
      themeMode: _themeMode,

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
    );
  }
}