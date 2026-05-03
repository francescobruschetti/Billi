// import 'package:Billy/enums/theme_enum.dart';
import 'package:Billy/enums/theme_enum.dart';
import 'package:drift/drift.dart';

@DataClassName('UserSettingsTableData')
class UserSettingsTable extends Table {

  // Chiave fissa — garantisce una sola riga nella tabella
  IntColumn get id => integer().withDefault(const Constant(1))();

  TextColumn get userId => text()
      .withDefault(const Constant('default_user'))(); // Placeholder until we have real user IDs, ensures only one row per user when we implement multi-user support.

  TextColumn get themeMode => text()
      .withDefault(Constant(ThemeEnum.SYSTEM.value))();

  BoolColumn get notificationsEnabled => boolean()
      .withDefault(const Constant(true))();

  TextColumn get language => text()
      .withDefault(const Constant('it'))();

  TextColumn get currency => text()
      .withDefault(const Constant('EUR'))();

  DateTimeColumn get updatedAt => dateTime()
      .withDefault(currentDateAndTime)();
      
  // Specifying which from the field above is the primary key
  @override
  Set<Column> get primaryKey => {userId};
}