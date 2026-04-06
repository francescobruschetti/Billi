import 'package:Billy/constants.dart';
import 'package:Billy/providers/category_provider.dart';
import 'package:Billy/providers/group_provider.dart';
import 'package:Billy/providers/transaction_provider.dart';
import 'package:Billy/services/signin_signup_logout_service.dart';
import 'package:Billy/utils/generic_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late SigninSignupLogoutService signinSignupLogoutService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    signinSignupLogoutService = SigninSignupLogoutService();

    setState(() {
      _isLoading = false;
    });
  }

  void _invalidateCache() {
    // !!! IMPORTANT: Invalidate all providers that cache user-specific data to force refetching after logout
    ref.invalidate(categoryProvider);
    ref.invalidate(groupsProvider);
    ref.invalidate(transactionProvider);
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await signinSignupLogoutService.logout();
      _invalidateCache();

      if (mounted) {
        // Naviga alla login e rimuovi la pagina di logout dallo stack
        Navigator.of(context).pushReplacementNamed('/login');
      }      
    } 
    catch (e) {
      if (mounted) {
        GenericUtil.showSnackbar(context, 'Errore durante il logout');
      }
    }
    finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni')),
      body: _isLoading
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Eseguendo il logout...'),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMainGroup(),

                const SizedBox(height: AppConstants.sizedBoxHeight),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Account',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Column(
                    children: [
                      _buildListTile(
                        icon: Icon(Icons.logout, color: Colors.orange[700]), 
                        title: 'Esci',
                        onTap: _logout,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.sizedBoxHeight),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Column(
                    children: [
                      _buildListTile(
                        icon: Icon(Icons.heart_broken_rounded, color: Colors.orange[700]), 
                        title: 'Elimina account',                    
                        // TODO: add onTap to delete account
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildMainGroup() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        children: [
          _buildListTile(
            icon: Icon(Icons.language, color: Colors.orange[700]),
            title: 'Lingua', 
            subtitle: 'Italiano',
            // TODO: add onTap to open language settings
          ),
          
          const Divider(height: 1),
          _buildListTile(
            icon: Icon(Icons.share, color: Colors.orange[700]), 
            title: 'Condividi',
            // TODO: add onTap to open share options
          ),

          const Divider(height: 1),
          _buildListTile(
            icon: Icon(Icons.dark_mode, color: Colors.orange[700]),
            title: 'Aspetto',
            subtitle: 'Scuro',
            // TODO: add onTap to open theme settings
          ),

          const Divider(height: 1),
          _buildListTile(
            icon: Icon(Icons.notifications, color: Colors.orange[700]),
            title: 'Notifiche',
            subtitle: 'Attive',
            // TODO: add onTap to open notification settings
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({ required Icon icon, required String title, String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      leading: icon,
      enabled: onTap != null,
      title: Row(
        children: [
          Text(title),
          const Spacer(),
          if (subtitle != null) Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: onTap
    );
  }
}