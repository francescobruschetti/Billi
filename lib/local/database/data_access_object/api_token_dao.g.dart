// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_token_dao.dart';

// ignore_for_file: type=lint
mixin _$ApiTokenDaoMixin on DatabaseAccessor<AppDatabase> {
  $ApiTokenTableTable get apiTokenTable => attachedDatabase.apiTokenTable;
  ApiTokenDaoManager get managers => ApiTokenDaoManager(this);
}

class ApiTokenDaoManager {
  final _$ApiTokenDaoMixin _db;
  ApiTokenDaoManager(this._db);
  $$ApiTokenTableTableTableManager get apiTokenTable =>
      $$ApiTokenTableTableTableManager(_db.attachedDatabase, _db.apiTokenTable);
}
