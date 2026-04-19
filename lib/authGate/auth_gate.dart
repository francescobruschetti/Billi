import 'package:Billy/pages/login_logout_signup/login_page.dart';
import 'package:Billy/widgets/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    return (session == null) ? const LoginPage() : const MainScaffold();
  }
}