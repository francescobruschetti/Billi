import 'package:flutter/material.dart';
import 'package:monitoraggio_spese/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/main_scaffold.dart';
import 'pages/login_logout_signup/login_page.dart';
import 'pages/login_logout_signup/signup_page.dart';
import 'pages/login_logout_signup/logout_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qislfeuyfqydzocxuwsw.supabase.co',
    anonKey: 'sb_publishable_AKPVXyVowkiKw-j1eGfHlw_D3YRGyGd',
  );

  setupLogging(); // Initialize logging
  runApp(const MonitoraggioSpeseApp());
}

class MonitoraggioSpeseApp extends StatelessWidget {
  const MonitoraggioSpeseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const SignupPage(),
        '/logout': (context) => const LogoutPage(),
      },
      home: AuthGate(),

      // Setup ThemeData con ColorScheme personalizzato
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue, // Colore principale
          secondary: Colors.orange
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    log.fine("Current session: $session");
    if (session == null) {
      return const LoginPage();
    }
    else {
      return const MainScaffold();
    }
  }
}
