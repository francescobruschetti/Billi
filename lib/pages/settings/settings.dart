import 'package:Billy/constants.dart';
import 'package:Billy/enums/theme_enum.dart';
import 'package:Billy/main.dart';
import 'package:Billy/pages/settings/components/theme_setting_bottom_sheet_widget.dart';
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
  String _themeLabel = 'Caricamento...';
  Icon themeIcon = Icon(Icons.dark_mode, color: Colors.orange);

  @override
  void initState() {
    super.initState();
    signinSignupLogoutService = SigninSignupLogoutService();
    _currentThemeLabel();

    setState(() {
      _isLoading = false;
    });
  }

  String _currentThemeLabel() {
    ThemeMode currentMode = BillyApp.getThemeMode(context);
    switch (currentMode) {
      case ThemeMode.dark:
        setState(() {
          themeIcon = const Icon(Icons.dark_mode, color: Colors.orange);
          _themeLabel = ThemeEnum.DARK.value;
        });
        return ThemeEnum.DARK.value;
      case ThemeMode.light:
        setState(() {
          themeIcon = const Icon(Icons.light_mode, color: Colors.orange);
          _themeLabel = ThemeEnum.LIGHT.value;
        });
        return ThemeEnum.LIGHT.value;
      case ThemeMode.system:
        setState(() {
          themeIcon = const Icon(Icons.settings, color: Colors.orange);
          _themeLabel = ThemeEnum.SYSTEM.value;
        });
        return ThemeEnum.SYSTEM.value;
    }
  }

  Future<void> _openThemeSettingsBottomSheet() async {
    ThemeEnum? selectedTheme = await showModalBottomSheet<ThemeEnum>(
      context: context,
      isScrollControlled: true, // obbligatorio per DraggableScrollableSheet
      backgroundColor: Colors.transparent, // lascia gestire il colore al sheet
      builder: (BuildContext context) => ThemeSettingBottomSheetWidget(
        title: 'Seleziona tema',
      ),
    );

    if (selectedTheme != null && mounted) {
      BillyApp.setToggleThemeMode(context, selectedTheme);
      _currentThemeLabel();
    }
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
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- SYSTEM ---
                _buildMainGroup(),

                // --- ACCOUNT ---
                _buildAccountGroup(),

                // --- OTHER SETTINGS ---
                _buildOtherGroup(),
              ],
            ),
          ),
    );
  }

  Widget _buildAccountGroup() {
    return Column(
      children: [
        const SizedBox(height: AppConstants.sizedBoxHeight),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              _buildListTile(
                icon: Icon(Icons.logout, color: Colors.orange[700]), 
                title: 'Esci',
                onTap: _logout,
              ),
              
              const Divider(height: 1),
              _buildListTile(
                icon: Icon(Icons.key, color: Colors.orange[700]), 
                title: 'Cambia password',
                  // TODO: add onTap
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainGroup() {
    return Column(
      children: [
        const SizedBox(height: AppConstants.sizedBoxHeight),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Sistema',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
        ),
    
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12),
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
                icon: themeIcon,
                title: 'Aspetto',
                subtitle: _themeLabel,
                onTap: () => _openThemeSettingsBottomSheet(),
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
        ),
      ],
    );
  }

  Widget _buildOtherGroup() {
    return Column(
      children: [
        const SizedBox(height: AppConstants.sizedBoxHeight),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Altro',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
        ),

        // --- SHARE APP ---
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              _buildListTile(
                icon: Icon(Icons.share, color: Colors.orange[700]), 
                title: 'Condividi',
                // TODO: add onTap to open share options
              ),
            ],
          ),
        ),
  
        // --- DELETE ACCOUNT ---
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      ]
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
          if (subtitle != null) Text(subtitle),

          const SizedBox(width: 8),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap
    );
  }
}