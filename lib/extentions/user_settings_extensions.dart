import 'package:Billy/enums/theme_enum.dart';
import 'package:Billy/local/database/app_database.dart';

extension UserSettingsExtension on UserSettingsTableData {
  ThemeEnum get themeModeEnum {
    return ThemeEnum.values.firstWhere(
      (e) => e.value == themeMode,
      orElse: () => ThemeEnum.SYSTEM, // fallback se il valore non è valido
    );
  }
}