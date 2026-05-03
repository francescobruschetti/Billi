


import 'package:Billy/enums/theme_enum.dart';
import 'package:Billy/local/database/tables/user_settings_table.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart'; // Mandatory to generate file 'app_database.g.dart'. Use command "flutter pub run build_runner build" to generate it.

@DriftDatabase(
  tables: [
    UserSettingsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  static final Logger log = Logger('AppDatabase');

  AppDatabase([QueryExecutor? e])
    : super(
        e ??
        driftDatabase(
          name: 'Billy-app',
          native: const DriftNativeOptions(
            databaseDirectory: getApplicationSupportDirectory,
          ),
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3-2.9.4.wasm'),
            driftWorker: Uri.parse('drift_worker-2.31.0.js'),
            onResult: (result) {
              if (result.missingFeatures.isNotEmpty) {
                log.fine(
                  'Using ${result.chosenImplementation} due to unsupported '
                  'browser features: ${result.missingFeatures}',
                );
              }
            },
          ),
        ),
      );

  @override
  int get schemaVersion => 1;

  // =========================
  // SETTINGS
  // =========================
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
    // v1: await into(userSettingsTable).insertOnConflictUpdate(settings);
    await transaction(() async {
      await delete(userSettingsTable).go(); // elimina tutto
      await into(userSettingsTable).insert(
        settings,
      );
    });
  }

  // @override
  // MigrationStrategy get migration => MigrationStrategy(
  //   onUpgrade: (migrator, from, to) async {
  //     if (from < 2) {
  //       await migrator.addColumn(
  //         userSettingsTable,
  //         userSettingsTable.notificationsEnabled,
  //       );
  //     }
  //   },
  // );
}

// =========================
// PROVIDER
// =========================
final localDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});