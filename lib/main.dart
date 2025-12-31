import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/main_scaffold.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/logout_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qislfeuyfqydzocxuwsw.supabase.co',
    anonKey: 'sb_publishable_AKPVXyVowkiKw-j1eGfHlw_D3YRGyGd',
  );

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
        '/register': (context) => const RegisterPage(),
        '/logout': (context) => const LogoutPage(),
      },
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    print("Current session: $session");
    if (session == null) {
      return const LoginPage();
    }
    else {
      return const MainScaffold();
    }
  }
}
