import 'package:Billy/local/database/app_database.dart';
import 'package:Billy/local/database/tables/user_settings_table.dart';
import 'package:drift/drift.dart';
import 'package:logging/logging.dart';

part 'user_settings_dao.g.dart'; // Mandatory to generate file 'user_settings_dao.g.dart'. Use command "flutter pub run build_runner build" to generate it.

@DriftAccessor(tables: [UserSettingsTable])
class UserSettingsDao extends DatabaseAccessor<AppDatabase> with _$UserSettingsDaoMixin {
  static final Logger log = Logger('UserSettingsDao');

  UserSettingsDao(super.db);

  Future<UserSettingsTableData?> getSettings() {
    log.fine('Fetching settings from local database');
    return select(userSettingsTable).getSingleOrNull();
  }

  Stream<UserSettingsTableData?> watchSettings() {
    log.fine('Watching settings from local database');
    return select(userSettingsTable).watchSingleOrNull();
  }

  Future<void> upsertSettings(UserSettingsTableCompanion settings) async {
    log.fine('Upserting settings into local database');
    assert(settings.userId.present);
    
    // v1: await into(userSettingsTable).insertOnConflictUpdate(settings);
    await transaction(() async {
      await delete(userSettingsTable).go(); // elimina tutto
      await into(userSettingsTable).insert(
        settings,
      );
    });
  }
}