


import 'package:Billy/enums/theme_enum.dart';
import 'package:Billy/local/database/data_access_object/logs_dao.dart';
import 'package:Billy/local/database/data_access_object/user_settings_dao.dart';
import 'package:Billy/local/database/tables/logs_table.dart';
import 'package:Billy/local/database/tables/user_settings_table.dart';
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
}
