import 'package:Billy/constants.dart';
import 'package:Billy/enums/theme_enum.dart';
import 'package:Billy/extentions/user_settings_extensions.dart';
import 'package:Billy/local/database/app_database.dart';
import 'package:Billy/pages/settings/components/theme_setting_bottom_sheet_widget.dart';
import 'package:Billy/pages/settings/components/api_token_bottom_sheet_widget.dart';
import 'package:Billy/pages/settings/logs_page.dart';
import 'package:Billy/providers/category_provider.dart';
import 'package:Billy/providers/group_provider.dart';
import 'package:Billy/providers/local-database/user_settings_provider.dart';
import 'package:Billy/providers/transaction_provider.dart';
import 'package:Billy/providers/ui_provider.dart';
import 'package:Billy/services/profile_service.dart';
import 'package:Billy/services/signin_signup_logout_service.dart';
import 'package:Billy/services/api_token_service.dart';
import 'package:Billy/utils/dialog_util.dart';
import 'package:Billy/utils/generic_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum TileName {
  APPLE_PAY,
  CHANGE_PASSWORD,
  CLEAR_LOCAL_DATA,
  DELETE_ACCOUNT,
  GENERATE_ACCESS_TOKEN,
  LANGUAGE,
  LOGOUT,
  NOTIFICATIONS,
  REPORT_BUG,
  SHARE_APP,
  THEME,
}

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final Logger log = Logger('SettingsPage');
  final SigninSignupLogoutService signinSignupLogoutService = SigninSignupLogoutService();
  final ProfileService profileService = ProfileService();
  final ApiTokenService apiTokenService = ApiTokenService();

  bool _isLoadingLogout = false;
  TileName? _loadingTileName;
  String _themeLabel = 'Caricamento...';
  String _appVersion = '...';
  Icon themeIcon = Icon(Icons.dark_mode, color: Colors.orange);

  @override
  void initState() {
    super.initState();

    setState(() {
      _isLoadingLogout = false;
    });
    
    PackageInfo.fromPlatform().then((packageInfo) {
      setState(() {
        _appVersion = packageInfo.version;
      });
    });
  }

  String _currentThemeLabel(UserSettingsTableData? settings) {
    log.fine('x>> Determining current theme label based on settings: $settings');
    final theme = settings?.themeModeEnum ?? ThemeEnum.SYSTEM;
    switch (theme) {
      case ThemeEnum.DARK:
        themeIcon = const Icon(Icons.dark_mode, color: Colors.orange);
        return ThemeEnum.DARK.value;
      case ThemeEnum.LIGHT:
        themeIcon = const Icon(Icons.light_mode, color: Colors.orange);
        return ThemeEnum.LIGHT.value;
      case ThemeEnum.SYSTEM:
        themeIcon = const Icon(Icons.settings, color: Colors.orange);
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
      // TODO: BillyApp.setToggleThemeMode(context, selectedTheme);

      log.fine('User selected theme: $selectedTheme. Updating settings...');
      ref.read(userSettingsProvider.notifier).updateThemeSettings(theme: selectedTheme); // Replace 'currentUserId' with the actual user ID
    }
  }

  Future<void> _clearLocalData({bool askConfirmation = false}) async {
    if (!mounted) return;
    setState(() => _loadingTileName = TileName.CLEAR_LOCAL_DATA);

    bool? proceed = true;
    if (askConfirmation) {
      proceed = await DialogUtil.showConfirmationBeforeDeleteDialog(
        context, 'Conferma eliminazione dati locali', 'Sei sicuro di voler eliminare tutti i dati locali? L\'operazione non è reversibile.'
      );
    }

    if (proceed == true) {
      await ref.read(localDatabaseProvider).wipeDatabase();

      if (mounted) {
        GenericUtil.showSnackbar(context, 'Dati locali eliminati con successo');
      }
    } 
    
    if (mounted) setState(() => _loadingTileName = null);
  }

  void _generateAccessToken() async {
    try {
      if (!mounted) return;

      final String token = apiTokenService.generateApiToken();
      final String hashedToken = apiTokenService.sha256Hash(token);

      // TODO: permettere all'utente di inserire un nome per il token (es: "Apple Pay")
      await apiTokenService.saveHashedTokenToSecureStorage(hashedToken: hashedToken, tokenName: 'Token generato il ${DateTime.now()}');

      await showModalBottomSheet<ApiTokenBottomSheetWidget>(
        context: context,
        isScrollControlled: true, // obbligatorio per DraggableScrollableSheet
        backgroundColor: Colors.transparent, // lascia gestire il colore al sheet
        builder: (BuildContext context) => ApiTokenBottomSheetWidget(
          title: 'Token di Accesso',
          subTitle: 'Il token generato ti permetterà di accedere all\'app senza inserire le credenziali.',
          token: token,
          warningMsg: 'Il token non sarà più visibile dopo la chiusura di questo pannello!',
        ),
    );
    }
    catch (e) {
      log.severe('Errore durante la generazione del token di accesso: $e');
      if (mounted) {
        GenericUtil.showSnackbar(context, 'Errore durante la generazione del token di accesso');
      }
    }
  }

  void _invalidateCache() {

    // !!! IMPORTANT: Invalidate all providers that cache user-specific data to force refetching after logout
    ref.invalidate(categoryProvider);
    ref.invalidate(groupsProvider);
    ref.invalidate(splitRateAndPaidAmountTabProvider);
    ref.invalidate(splitRateModeProvider);
    ref.invalidate(transactionProvider);
    
    // ! Do not reset Drift DB Providers here: ref.invalidate(userSettingsProvider);
  }

  Future<void> _logout() async {
    setState(() {
      _isLoadingLogout = true;
    });

    try {
      await signinSignupLogoutService.logout();
      await _clearLocalData();
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
          _isLoadingLogout = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(userSettingsProvider);
    
    return settingsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text("Errore durante il caricamento. Riprovare")), // TODO: migliorare gestione errori
      data: (settings) {
        _themeLabel = _currentThemeLabel(settings);
        
        return Scaffold(
          appBar: AppBar(title: const Text('Impostazioni')),
          body: _isLoadingLogout
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: AppConstants.mediumSizedBoxHeight),
                    Text('Eseguendo il logout...'),
                  ],
                )
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

                  // --- ACCESS CONFIGURATION ---
                  _buildAccessGroup(),
                  
                  // --- OTHER SETTINGS ---
                  _buildOtherGroup(),

                  // --- DELETE DATA ---
                  _buildDeleteDataGroup(),

                  Text(
                    'Versione $_appVersion', 
                    textAlign: TextAlign.center, 
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
        );
      }
    );
  }

  Widget _buildAccountGroup() {
    return Column(
      children: [
        const SizedBox(height: AppConstants.mediumSizedBoxHeight),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Account',
              style: TextStyle(fontSize: AppConstants.textSize, fontWeight: FontWeight.bold, color: Colors.grey),
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
                tileName: TileName.LOGOUT,
                onTap: _logout,
              ),
              
              const Divider(height: 1),
              _buildListTile(
                icon: Icon(Icons.key, color: Colors.orange[700]), 
                title: 'Cambia password',
                tileName: TileName.CHANGE_PASSWORD,
                // TODO: add onTap
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccessGroup() {
    return Column(
      children: [
        const SizedBox(height: AppConstants.mediumSizedBoxHeight),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Configura Strumenti',
              style: TextStyle(fontSize: AppConstants.textSize, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
        ),

        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              // --- GENERATE ACCESS TOKEN ---
              _buildListTile(
                icon: Icon(Icons.key, color: Colors.orange[700]), 
                title: 'Genera Token di Accesso',
                tileName: TileName.GENERATE_ACCESS_TOKEN,
                onTap: _generateAccessToken,
              ),

              // --- APPLE SHORTCUT ---
              const Divider(height: 1),
              _buildListTile(
                icon: Icon(Icons.apple, color: Colors.orange[700]), 
                title: 'Apple Pay',
                tileName: TileName.APPLE_PAY,
                // TODO: add onTap to open share options
              ),
            ],
          ),
        ),
        
      ],
    );
  }
  
  Widget _buildDeleteDataGroup() {
    return Column(
      children: [
        const SizedBox(height: AppConstants.mediumSizedBoxHeight),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Elimina Dati',
              style: TextStyle(fontSize: AppConstants.textSize, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
        ),
        
        // --- DELETE LOCAL DATA and ACCOUNT ---
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              _buildListTile(
                icon: Icon(Icons.sd_storage, color: Colors.orange[700]), 
                title: 'Elimina Dati locali',    
                tileName: TileName.CLEAR_LOCAL_DATA,                
                onTap: () => _clearLocalData(askConfirmation: true),
              ),

              const Divider(height: 1),
              _buildListTile(
                icon: Icon(Icons.heart_broken_rounded, color: Colors.orange[700]), 
                title: 'Elimina account',        
                tileName: TileName.DELETE_ACCOUNT,            
                // TODO: add onTap to delete account
              ),
            ],
          ),
        ),
      ]
    );
  }

  Widget _buildMainGroup() {
    return Column(
      children: [
        const SizedBox(height: AppConstants.mediumSizedBoxHeight),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Sistema',
              style: TextStyle(fontSize: AppConstants.textSize, fontWeight: FontWeight.bold, color: Colors.grey),
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
                tileName: TileName.LANGUAGE,
                // TODO: add onTap to open language settings
              ),

              const Divider(height: 1),
              _buildListTile(
                icon: themeIcon,
                title: 'Aspetto',
                subtitle: _themeLabel,
                tileName: TileName.THEME,
                onTap: () => _openThemeSettingsBottomSheet(),
              ),

              const Divider(height: 1),
              _buildListTile(
                icon: Icon(Icons.notifications, color: Colors.orange[700]),
                title: 'Notifiche',
                subtitle: 'Attive',
                tileName: TileName.NOTIFICATIONS,
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
        const SizedBox(height: AppConstants.mediumSizedBoxHeight),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Altro',
              style: TextStyle(fontSize: AppConstants.textSize, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
        ),

        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              // --- SHARE APP ---
              _buildListTile(
                icon: Icon(Icons.share, color: Colors.orange[700]), 
                title: 'Condividi',
                tileName: TileName.SHARE_APP,
                // TODO: add onTap to open share options
              ),

              // --- REPORT BUG ---
              const Divider(height: 1),
              _buildListTile(
                icon: Icon(Icons.bug_report, color: Colors.orange[700]), 
                title: 'Segnala un problema',
                tileName: TileName.REPORT_BUG,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LogsPage())),
              ),
            ],
          ),
        ),
        
      ],
    );
  }
  
  Widget _buildListTile({ 
    required Icon icon, required String title, 
    String? subtitle, required TileName? tileName, VoidCallback? onTap}) 
  {
    final isLoading = _loadingTileName == tileName;

    return ListTile(
      leading: icon,
      enabled: !isLoading && onTap != null,
      title: Row(
        children: [
          Text(title),
          const Spacer(),
          if (subtitle != null) Text(subtitle),

          const SizedBox(width: AppConstants.mediumSizedBoxWidth),
          if (isLoading) ...[
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ]
          else ...[
            const Icon(Icons.chevron_right),
          ]
        ],
      ),
      onTap: onTap
    );
  }

}