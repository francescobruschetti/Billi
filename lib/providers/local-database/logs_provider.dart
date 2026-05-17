import 'dart:async';

import 'package:Billy/enums/log_level_enum.dart';
import 'package:Billy/local/database/app_database.dart';
import 'package:Billy/models/database/log_model.dart';
import 'package:Billy/services/profile_service.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

final logsProvider = AsyncNotifierProvider<LogsNotifier, List<LogsTableData>>(
  LogsNotifier.new,
  name: 'logsProvider',
);

class LogsNotifier extends AsyncNotifier<List<LogsTableData>> {
  static final Logger log = Logger('LogsNotifier');
  final ProfileService _profileService = ProfileService();

  @override
  Future<List<LogsTableData>> build() async {
    try {
      // Prova dalla cache locale → funziona anche offline
      final userId = _profileService.getCurrentUserId();
      final List<LogsTableData> local = await ref.read(localDatabaseProvider).logsDao.getLogs(userId);
      log.fine('y> Loaded logs from local cache: $local');
      return local;
    } 
    catch (e, st) {
      log.severe('Error loading logs: $e', e, st);
      rethrow;
    }
  }

  Future<void> loadUserLogs() async {
    try {
      final userId = _profileService.getCurrentUserId();
      final List<LogsTableData> local = await ref.read(localDatabaseProvider).logsDao.getLogs(userId);
      log.fine('y> Loading logs from local cache: $local');
      state = AsyncValue.data(local);
    }
    catch (e, st) {
      log.severe('Error loading logs: $e', e, st);
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
  
  Future<void> loadUserLogsByLevel(String level) async {
    try {
      final userId = _profileService.getCurrentUserId();
      final List<LogsTableData> local = await ref.read(localDatabaseProvider).logsDao.getLogsByLevel(userId, level);
      log.fine('y> Loading logs from local cache: $local');
      state = AsyncValue.data(local);
    } 
    catch (e, st) {
      log.severe('Error loading logs: $e', e, st);
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Salva in locale
  Future<void> saveMessage(LogLevelEnum level, String message) async {
    await save(LogModel(
      userId: _profileService.getCurrentUserId(),
      level: level,
      message: message,
      createdAt: DateTime.now(),
    ));
  }

  Future<void> save(LogModel logModel) async {
    log.fine('y> Saving log to local database');
    await ref.read(localDatabaseProvider).logsDao.insertLog(
      LogsTableCompanion(
        userId: Value(_profileService.getCurrentUserId()),
        message: Value(logModel.message),
        level: Value(logModel.level.value),
        createdAt: Value(logModel.createdAt),
      ),
    );
  }

}