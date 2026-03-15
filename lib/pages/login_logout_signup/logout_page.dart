import 'package:Billy/widgets/components/custom_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    // Torna alla pagina di login e rimuovi tutto lo stack
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logout')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const CustomIconWidget(assetPath: 'assets/images/icons/outward.PNG', size: 24),
          label: const Text('Logout'),
          onPressed: () => _logout(context),
        ),
      ),
    );
  }
}
