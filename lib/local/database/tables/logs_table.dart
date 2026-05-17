import 'package:drift/drift.dart';

@DataClassName('LogsTableData')
class LogsTable extends Table {

  IntColumn get id => integer().autoIncrement()();

  TextColumn get userId => text()(); // Mandatory

  TextColumn get level => text()();

  TextColumn get message => text()();

  DateTimeColumn get createdAt => dateTime()();
}