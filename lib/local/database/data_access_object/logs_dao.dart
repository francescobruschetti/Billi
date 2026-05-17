// lib/local/database/daos/logs_dao.dart
import 'package:Billy/local/database/app_database.dart';
import 'package:Billy/local/database/tables/logs_table.dart';
import 'package:drift/drift.dart';

part 'logs_dao.g.dart'; // Mandatory to generate file 'logs_dao.g.dart'. Use command "flutter pub run build_runner build" to generate it.

@DriftAccessor(tables: [LogsTable])
class LogsDao extends DatabaseAccessor<AppDatabase> with _$LogsDaoMixin {
  LogsDao(super.db);

  // Leggi tutti i log di un utente ordinati per data
  Future<List<LogsTableData>> getLogs(String userId) {
    return (select(logsTable)
      ..where((t) => t.userId.equals(userId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .get();
  }

  // Stream reattivo — si aggiorna automaticamente
  Stream<List<LogsTableData>> watchLogs(String userId) {
    return (select(logsTable)
      ..where((t) => t.userId.equals(userId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .watch();
  }

  Future<List<LogsTableData>> getLogsByLevel(String userId, String level) async {
    return (select(logsTable)
      ..where((t) => t.userId.equals(userId) & t.level.equals(level))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .get();
  }

  Future<void> insertLog(LogsTableCompanion log) async {
    await into(logsTable).insert(log);
  }

  Future<void> deleteLogsForUser(String userId) async {
    await (delete(logsTable)
      ..where((t) => t.userId.equals(userId)))
      .go();
  }

  // Mantieni solo gli ultimi N log per non riempire il disco
  Future<void> pruneOldLogs(String userId, {int keepLast = 1000}) async {
    await customStatement('''
      DELETE FROM logs_table
      WHERE user_id = ? AND id NOT IN (
        SELECT id FROM logs_table
        WHERE user_id = ?
        ORDER BY created_at DESC
        LIMIT ?
      )
    ''', [userId, userId, keepLast]);
  }
}