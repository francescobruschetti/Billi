
import 'package:drift/drift.dart';

@DataClassName('ApiTokenTableData')
class ApiTokenTable extends Table {

  TextColumn get id => text()(); // Mandatory: not is set to UUID in the BE

  TextColumn get userId => text()(); // Mandatory

  TextColumn get name => text()(); // Mandatory

  TextColumn get tokenHash => text()(); // Mandatory
  
  DateTimeColumn get validUntil => dateTime()(); // Mandatory

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  DateTimeColumn? get updatedAt => dateTime().nullable()();

  DateTimeColumn? get lastUsedAt => dateTime().nullable()();
  
  DateTimeColumn? get revokedAt => dateTime().nullable()();

      
  // Specifying which from the field above is the primary key
  @override
  Set<Column> get primaryKey => {id};

}