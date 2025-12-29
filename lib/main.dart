import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qislfeuyfqydzocxuwsw.supabase.co',
    anonKey: 'sb_publishable_AKPVXyVowkiKw-j1eGfHlw_D3YRGyGd',
  );

  // DEBUG: Login anonimo per testare l'app senza autenticazione completa
  await Supabase.instance.client.auth.signInAnonymously();

  runApp(const MonitoraggioSpeseApp());
}

class MonitoraggioSpeseApp extends StatelessWidget {
  const MonitoraggioSpeseApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScaffold(),
    );
  }
}
