import 'package:Billy/local/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final verifier = SchemaVerifier(GeneratedHelper());

  test('upgrade from v1 to v2', () async {

    final connection = await verifier.startAt(1);

    final db = AppDatabase(connection);

    await verifier.migrateAndValidate(
      db,
      2,
    );

    await db.close();
  });
}