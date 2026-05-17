// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logs_dao.dart';

// ignore_for_file: type=lint
mixin _$LogsDaoMixin on DatabaseAccessor<AppDatabase> {
  $LogsTableTable get logsTable => attachedDatabase.logsTable;
  LogsDaoManager get managers => LogsDaoManager(this);
}

class LogsDaoManager {
  final _$LogsDaoMixin _db;
  LogsDaoManager(this._db);
  $$LogsTableTableTableManager get logsTable =>
      $$LogsTableTableTableManager(_db.attachedDatabase, _db.logsTable);
}
