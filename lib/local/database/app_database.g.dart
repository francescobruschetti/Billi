// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserSettingsTableTable extends UserSettingsTable
    with TableInfo<$UserSettingsTableTable, UserSettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _themeModeMeta =
      const VerificationMeta('themeMode');
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
      'theme_mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: Constant(ThemeEnum.SYSTEM.value));
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<bool> notificationsEnabled = GeneratedColumn<bool>(
      'notifications_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notifications_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('it'));
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('EUR'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        themeMode,
        notificationsEnabled,
        language,
        currency,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<UserSettingsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('theme_mode')) {
      context.handle(_themeModeMeta,
          themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta));
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
          _notificationsEnabledMeta,
          notificationsEnabled.isAcceptableOrUnknown(
              data['notifications_enabled']!, _notificationsEnabledMeta));
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  UserSettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSettingsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      themeMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}theme_mode'])!,
      notificationsEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}notifications_enabled'])!,
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $UserSettingsTableTable createAlias(String alias) {
    return $UserSettingsTableTable(attachedDatabase, alias);
  }
}

class UserSettingsTableData extends DataClass
    implements Insertable<UserSettingsTableData> {
  final int id;
  final String userId;
  final String themeMode;
  final bool notificationsEnabled;
  final String language;
  final String currency;
  final DateTime updatedAt;
  const UserSettingsTableData(
      {required this.id,
      required this.userId,
      required this.themeMode,
      required this.notificationsEnabled,
      required this.language,
      required this.currency,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['theme_mode'] = Variable<String>(themeMode);
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    map['language'] = Variable<String>(language);
    map['currency'] = Variable<String>(currency);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsTableCompanion(
      id: Value(id),
      userId: Value(userId),
      themeMode: Value(themeMode),
      notificationsEnabled: Value(notificationsEnabled),
      language: Value(language),
      currency: Value(currency),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserSettingsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSettingsTableData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      notificationsEnabled:
          serializer.fromJson<bool>(json['notificationsEnabled']),
      language: serializer.fromJson<String>(json['language']),
      currency: serializer.fromJson<String>(json['currency']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'themeMode': serializer.toJson<String>(themeMode),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
      'language': serializer.toJson<String>(language),
      'currency': serializer.toJson<String>(currency),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserSettingsTableData copyWith(
          {int? id,
          String? userId,
          String? themeMode,
          bool? notificationsEnabled,
          String? language,
          String? currency,
          DateTime? updatedAt}) =>
      UserSettingsTableData(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        themeMode: themeMode ?? this.themeMode,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        language: language ?? this.language,
        currency: currency ?? this.currency,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserSettingsTableData copyWithCompanion(UserSettingsTableCompanion data) {
    return UserSettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
      language: data.language.present ? data.language.value : this.language,
      currency: data.currency.present ? data.currency.value : this.currency,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsTableData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('themeMode: $themeMode, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('language: $language, ')
          ..write('currency: $currency, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, themeMode, notificationsEnabled,
      language, currency, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSettingsTableData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.themeMode == this.themeMode &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.language == this.language &&
          other.currency == this.currency &&
          other.updatedAt == this.updatedAt);
}

class UserSettingsTableCompanion
    extends UpdateCompanion<UserSettingsTableData> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> themeMode;
  final Value<bool> notificationsEnabled;
  final Value<String> language;
  final Value<String> currency;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserSettingsTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.language = const Value.absent(),
    this.currency = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSettingsTableCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    this.themeMode = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.language = const Value.absent(),
    this.currency = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<UserSettingsTableData> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? themeMode,
    Expression<bool>? notificationsEnabled,
    Expression<String>? language,
    Expression<String>? currency,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (themeMode != null) 'theme_mode': themeMode,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (language != null) 'language': language,
      if (currency != null) 'currency': currency,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSettingsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? userId,
      Value<String>? themeMode,
      Value<bool>? notificationsEnabled,
      Value<String>? language,
      Value<String>? currency,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return UserSettingsTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<bool>(notificationsEnabled.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('themeMode: $themeMode, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('language: $language, ')
          ..write('currency: $currency, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LogsTableTable extends LogsTable
    with TableInfo<$LogsTableTable, LogsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LogsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
      'level', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, userId, level, message, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'logs_table';
  @override
  VerificationContext validateIntegrity(Insertable<LogsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
          _levelMeta, level.isAcceptableOrUnknown(data['level']!, _levelMeta));
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LogsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LogsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      level: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}level'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $LogsTableTable createAlias(String alias) {
    return $LogsTableTable(attachedDatabase, alias);
  }
}

class LogsTableData extends DataClass implements Insertable<LogsTableData> {
  final int id;
  final String userId;
  final String level;
  final String message;
  final DateTime createdAt;
  const LogsTableData(
      {required this.id,
      required this.userId,
      required this.level,
      required this.message,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['level'] = Variable<String>(level);
    map['message'] = Variable<String>(message);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LogsTableCompanion toCompanion(bool nullToAbsent) {
    return LogsTableCompanion(
      id: Value(id),
      userId: Value(userId),
      level: Value(level),
      message: Value(message),
      createdAt: Value(createdAt),
    );
  }

  factory LogsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LogsTableData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      level: serializer.fromJson<String>(json['level']),
      message: serializer.fromJson<String>(json['message']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'level': serializer.toJson<String>(level),
      'message': serializer.toJson<String>(message),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LogsTableData copyWith(
          {int? id,
          String? userId,
          String? level,
          String? message,
          DateTime? createdAt}) =>
      LogsTableData(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        level: level ?? this.level,
        message: message ?? this.message,
        createdAt: createdAt ?? this.createdAt,
      );
  LogsTableData copyWithCompanion(LogsTableCompanion data) {
    return LogsTableData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      level: data.level.present ? data.level.value : this.level,
      message: data.message.present ? data.message.value : this.message,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LogsTableData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('level: $level, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, level, message, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LogsTableData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.level == this.level &&
          other.message == this.message &&
          other.createdAt == this.createdAt);
}

class LogsTableCompanion extends UpdateCompanion<LogsTableData> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> level;
  final Value<String> message;
  final Value<DateTime> createdAt;
  const LogsTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.level = const Value.absent(),
    this.message = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  LogsTableCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String level,
    required String message,
    required DateTime createdAt,
  })  : userId = Value(userId),
        level = Value(level),
        message = Value(message),
        createdAt = Value(createdAt);
  static Insertable<LogsTableData> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? level,
    Expression<String>? message,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (level != null) 'level': level,
      if (message != null) 'message': message,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  LogsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? userId,
      Value<String>? level,
      Value<String>? message,
      Value<DateTime>? createdAt}) {
    return LogsTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      level: level ?? this.level,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LogsTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('level: $level, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserSettingsTableTable userSettingsTable =
      $UserSettingsTableTable(this);
  late final $LogsTableTable logsTable = $LogsTableTable(this);
  late final UserSettingsDao userSettingsDao =
      UserSettingsDao(this as AppDatabase);
  late final LogsDao logsDao = LogsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [userSettingsTable, logsTable];
}

typedef $$UserSettingsTableTableCreateCompanionBuilder
    = UserSettingsTableCompanion Function({
  Value<int> id,
  required String userId,
  Value<String> themeMode,
  Value<bool> notificationsEnabled,
  Value<String> language,
  Value<String> currency,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$UserSettingsTableTableUpdateCompanionBuilder
    = UserSettingsTableCompanion Function({
  Value<int> id,
  Value<String> userId,
  Value<String> themeMode,
  Value<bool> notificationsEnabled,
  Value<String> language,
  Value<String> currency,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$UserSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTableTable> {
  $$UserSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get themeMode => $composableBuilder(
      column: $table.themeMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get notificationsEnabled => $composableBuilder(
      column: $table.notificationsEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$UserSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTableTable> {
  $$UserSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get themeMode => $composableBuilder(
      column: $table.themeMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get notificationsEnabled => $composableBuilder(
      column: $table.notificationsEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$UserSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTableTable> {
  $$UserSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<bool> get notificationsEnabled => $composableBuilder(
      column: $table.notificationsEnabled, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserSettingsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserSettingsTableTable,
    UserSettingsTableData,
    $$UserSettingsTableTableFilterComposer,
    $$UserSettingsTableTableOrderingComposer,
    $$UserSettingsTableTableAnnotationComposer,
    $$UserSettingsTableTableCreateCompanionBuilder,
    $$UserSettingsTableTableUpdateCompanionBuilder,
    (
      UserSettingsTableData,
      BaseReferences<_$AppDatabase, $UserSettingsTableTable,
          UserSettingsTableData>
    ),
    UserSettingsTableData,
    PrefetchHooks Function()> {
  $$UserSettingsTableTableTableManager(
      _$AppDatabase db, $UserSettingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> themeMode = const Value.absent(),
            Value<bool> notificationsEnabled = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserSettingsTableCompanion(
            id: id,
            userId: userId,
            themeMode: themeMode,
            notificationsEnabled: notificationsEnabled,
            language: language,
            currency: currency,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String userId,
            Value<String> themeMode = const Value.absent(),
            Value<bool> notificationsEnabled = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserSettingsTableCompanion.insert(
            id: id,
            userId: userId,
            themeMode: themeMode,
            notificationsEnabled: notificationsEnabled,
            language: language,
            currency: currency,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserSettingsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserSettingsTableTable,
    UserSettingsTableData,
    $$UserSettingsTableTableFilterComposer,
    $$UserSettingsTableTableOrderingComposer,
    $$UserSettingsTableTableAnnotationComposer,
    $$UserSettingsTableTableCreateCompanionBuilder,
    $$UserSettingsTableTableUpdateCompanionBuilder,
    (
      UserSettingsTableData,
      BaseReferences<_$AppDatabase, $UserSettingsTableTable,
          UserSettingsTableData>
    ),
    UserSettingsTableData,
    PrefetchHooks Function()>;
typedef $$LogsTableTableCreateCompanionBuilder = LogsTableCompanion Function({
  Value<int> id,
  required String userId,
  required String level,
  required String message,
  required DateTime createdAt,
});
typedef $$LogsTableTableUpdateCompanionBuilder = LogsTableCompanion Function({
  Value<int> id,
  Value<String> userId,
  Value<String> level,
  Value<String> message,
  Value<DateTime> createdAt,
});

class $$LogsTableTableFilterComposer
    extends Composer<_$AppDatabase, $LogsTableTable> {
  $$LogsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$LogsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LogsTableTable> {
  $$LogsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$LogsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LogsTableTable> {
  $$LogsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LogsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LogsTableTable,
    LogsTableData,
    $$LogsTableTableFilterComposer,
    $$LogsTableTableOrderingComposer,
    $$LogsTableTableAnnotationComposer,
    $$LogsTableTableCreateCompanionBuilder,
    $$LogsTableTableUpdateCompanionBuilder,
    (
      LogsTableData,
      BaseReferences<_$AppDatabase, $LogsTableTable, LogsTableData>
    ),
    LogsTableData,
    PrefetchHooks Function()> {
  $$LogsTableTableTableManager(_$AppDatabase db, $LogsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LogsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LogsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LogsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> level = const Value.absent(),
            Value<String> message = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              LogsTableCompanion(
            id: id,
            userId: userId,
            level: level,
            message: message,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String userId,
            required String level,
            required String message,
            required DateTime createdAt,
          }) =>
              LogsTableCompanion.insert(
            id: id,
            userId: userId,
            level: level,
            message: message,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LogsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LogsTableTable,
    LogsTableData,
    $$LogsTableTableFilterComposer,
    $$LogsTableTableOrderingComposer,
    $$LogsTableTableAnnotationComposer,
    $$LogsTableTableCreateCompanionBuilder,
    $$LogsTableTableUpdateCompanionBuilder,
    (
      LogsTableData,
      BaseReferences<_$AppDatabase, $LogsTableTable, LogsTableData>
    ),
    LogsTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserSettingsTableTableTableManager get userSettingsTable =>
      $$UserSettingsTableTableTableManager(_db, _db.userSettingsTable);
  $$LogsTableTableTableManager get logsTable =>
      $$LogsTableTableTableManager(_db, _db.logsTable);
}
