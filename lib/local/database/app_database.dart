


import 'package:Billy/enums/log_level_enum.dart';
import 'package:Billy/enums/theme_enum.dart';
import 'package:Billy/local/database/data_access_object/logs_dao.dart';
import 'package:Billy/local/database/data_access_object/user_settings_dao.dart';
import 'package:Billy/local/database/tables/logs_table.dart';
import 'package:Billy/local/database/tables/user_settings_table.dart';
import 'package:Billy/providers/local-database/logs_provider.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart'; // Mandatory to generate file 'app_database.g.dart'. Use command "flutter pub run build_runner build" to generate it.

// =========================
// PROVIDER
// =========================
final localDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

@DriftDatabase(
  tables: [UserSettingsTable, LogsTable],
  daos: [UserSettingsDao, LogsDao],
)
class AppDatabase extends _$AppDatabase {
  static final Logger log = Logger('AppDatabase');
  static final LogsNotifier logsNotifier = LogsNotifier();

  AppDatabase([QueryExecutor? e])
    : super(
        e ??
        driftDatabase(
          name: 'Billy-app',
          native: const DriftNativeOptions(
            databaseDirectory: getApplicationSupportDirectory,
          ),
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3-2.9.4.wasm'), // *Required* for web: specifica la posizione del file wasm di sqlite3 (in web/)
            driftWorker: Uri.parse('drift_worker-2.31.0.js'), // *Required* for web: specifica la posizione del file wasm di sqlite3 (in web/)
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
  int get schemaVersion => 2;

  // getter per accedere ai DAO
  late final userSettingsDao = UserSettingsDao(this);
  late final logsDao = LogsDao(this);

  // TODO: da implelmentare
  // Metodo per resettare il database (usato in fase di sviluppo/testing e al logout)
  Future<void> wipeDatabase() async {
    await transaction(() async {
      final deletedLogs = await delete(logsTable).go();
      final deletedUserSettings = await delete(userSettingsTable).go();

      // TODO: add here all tables to be deleted...
      
      log.fine('Deleted rows from logsTable: $deletedLogs');
      log.fine('Deleted rows from userSettingsTable: $deletedUserSettings ');

    });
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // Così un utente che passa dalla v1 alla v5 eseguirà automaticamente tutte le migration necessarie.
      if (from < 2) {
        logsNotifier.saveMessage(LogLevelEnum.FINE, 'Migration from v1 to v2: creating logsTable');
        await m.createTable(logsTable);
      }

      // if (from < 3) { ... }
      // if (from < 4) { ... }
    },
  );
}
