import 'package:Billy/enums/theme_enum.dart';
import 'package:logging/logging.dart';
import 'package:Billy/models/database/user_settings_model.dart';

class UserSettingsService {
  final Logger log = Logger('UserSettingsService');

  Future<UserSettingsModel> fetchSettings() async {
    log.fine('Fetching settings from DB');

    return UserSettingsModel.fromMap({
      'theme_mode': ThemeEnum.DARK.name,
      'notifications_enabled': true,
      'language': 'it',
      'currency': 'EUR',
    });

    // TODO: versione da usare quando avro il DB con user_id
    // final res = await _supabase
    //   .from('user_settings')
    //   .select()
    //   .eq('user_id', _supabase.auth.currentUser!.id)
    //   .single();
    // return UserSettingsModel.fromMap(res);
  }

  Future<void> updateSettings(UserSettingsModel settings) async {
    log.fine('Updating user settings on BE: ${settings.toMap()}');
    // TODO: versione da usare quando avro il DB con user_id
    // await _supabase
    //   .from('user_settings')
    //   .upsert({
    //     'user_id': _supabase.auth.currentUser!.id,
    //     ...settings.toMap().map((key, value) => MapEntry(key, value is ThemeEnum ? value.name : value)),
    //   });
  }
}