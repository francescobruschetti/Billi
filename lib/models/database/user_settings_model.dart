import 'package:Billy/enums/theme_enum.dart';
import 'package:Billy/local/database/app_database.dart';

class UserSettingsModel {
  final String userId;
  final ThemeEnum themeMode;
  final bool notificationsEnabled;
  final String language;
  final String currency;

  const UserSettingsModel({
    required this.userId,
    required this.themeMode,
    required this.notificationsEnabled,
    required this.language,
    required this.currency,
  });

  // Dal JSON del BE
  factory UserSettingsModel.fromMap(Map<String, dynamic> map) => UserSettingsModel(
    userId: map['user_id'],
    themeMode: ThemeEnum.values.firstWhere((e) => e.value == map['theme_mode'], orElse: () => ThemeEnum.SYSTEM),
    notificationsEnabled: map['notifications_enabled'] ?? true,
    language: map['language'] ?? 'it',
    currency: map['currency'] ?? 'EUR',
  );

  // Da Drift → utile per sync col BE
  factory UserSettingsModel.fromTableData(UserSettingsTableData data) => UserSettingsModel(
    userId: data.userId,
    themeMode: ThemeEnum.values.firstWhere((e) => e.value == data.themeMode, orElse: () => ThemeEnum.SYSTEM),
    notificationsEnabled: data.notificationsEnabled,
    language: data.language,
    currency: data.currency,
  );

  Map<String, dynamic> toMap() => {
    'theme_mode': themeMode.name,
    'notifications_enabled': notificationsEnabled,
    'language': language,
    'currency': currency,
    'user_id': userId,
  };
}