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
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _themeModeMeta =
      const VerificationMeta('themeMode');
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
      'theme_mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: Constant(ThemeEnum.SYSTEM.name));
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
  List<GeneratedColumn> get $columns =>
      [id, themeMode, notificationsEnabled, language, currency, updatedAt];
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserSettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSettingsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
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
  final String themeMode;
  final bool notificationsEnabled;
  final String language;
  final String currency;
  final DateTime updatedAt;
  const UserSettingsTableData(
      {required this.id,
      required this.themeMode,
      required this.notificationsEnabled,
      required this.language,
      required this.currency,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
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
      'themeMode': serializer.toJson<String>(themeMode),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
      'language': serializer.toJson<String>(language),
      'currency': serializer.toJson<String>(currency),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserSettingsTableData copyWith(
          {int? id,
          String? themeMode,
          bool? notificationsEnabled,
          String? language,
          String? currency,
          DateTime? updatedAt}) =>
      UserSettingsTableData(
        id: id ?? this.id,
        themeMode: themeMode ?? this.themeMode,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        language: language ?? this.language,
        currency: currency ?? this.currency,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserSettingsTableData copyWithCompanion(UserSettingsTableCompanion data) {
    return UserSettingsTableData(
      id: data.id.present ? data.id.value : this.id,
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
          ..write('themeMode: $themeMode, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('language: $language, ')
          ..write('currency: $currency, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, themeMode, notificationsEnabled, language, currency, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSettingsTableData &&
          other.id == this.id &&
          other.themeMode == this.themeMode &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.language == this.language &&
          other.currency == this.currency &&
          other.updatedAt == this.updatedAt);
}

class UserSettingsTableCompanion
    extends UpdateCompanion<UserSettingsTableData> {
  final Value<int> id;
  final Value<String> themeMode;
  final Value<bool> notificationsEnabled;
  final Value<String> language;
  final Value<String> currency;
  final Value<DateTime> updatedAt;
  const UserSettingsTableCompanion({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.language = const Value.absent(),
    this.currency = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserSettingsTableCompanion.insert({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.language = const Value.absent(),
    this.currency = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<UserSettingsTableData> custom({
    Expression<int>? id,
    Expression<String>? themeMode,
    Expression<bool>? notificationsEnabled,
    Expression<String>? language,
    Expression<String>? currency,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeMode != null) 'theme_mode': themeMode,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (language != null) 'language': language,
      if (currency != null) 'currency': currency,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserSettingsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? themeMode,
      Value<bool>? notificationsEnabled,
      Value<String>? language,
      Value<String>? currency,
      Value<DateTime>? updatedAt}) {
    return UserSettingsTableCompanion(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('language: $language, ')
          ..write('currency: $currency, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserSettingsTableTable userSettingsTable =
      $UserSettingsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [userSettingsTable];
}

typedef $$UserSettingsTableTableCreateCompanionBuilder
    = UserSettingsTableCompanion Function({
  Value<int> id,
  Value<String> themeMode,
  Value<bool> notificationsEnabled,
  Value<String> language,
  Value<String> currency,
  Value<DateTime> updatedAt,
});
typedef $$UserSettingsTableTableUpdateCompanionBuilder
    = UserSettingsTableCompanion Function({
  Value<int> id,
  Value<String> themeMode,
  Value<bool> notificationsEnabled,
  Value<String> language,
  Value<String> currency,
  Value<DateTime> updatedAt,
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
            Value<String> themeMode = const Value.absent(),
            Value<bool> notificationsEnabled = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              UserSettingsTableCompanion(
            id: id,
            themeMode: themeMode,
            notificationsEnabled: notificationsEnabled,
            language: language,
            currency: currency,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> themeMode = const Value.absent(),
            Value<bool> notificationsEnabled = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              UserSettingsTableCompanion.insert(
            id: id,
            themeMode: themeMode,
            notificationsEnabled: notificationsEnabled,
            language: language,
            currency: currency,
            updatedAt: updatedAt,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserSettingsTableTableTableManager get userSettingsTable =>
      $$UserSettingsTableTableTableManager(_db, _db.userSettingsTable);
}
