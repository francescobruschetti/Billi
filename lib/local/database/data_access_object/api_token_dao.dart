
import 'package:Billy/local/database/app_database.dart';
import 'package:Billy/local/database/tables/api_token_table.dart';
import 'package:drift/drift.dart';
import 'package:logging/logging.dart';

part 'api_token_dao.g.dart'; // Mandatory to generate file 'api_token_dao.g.dart'. Use command "dart run build_runner build" to generate it.

@DriftAccessor(tables: [ApiTokenTable])
class ApiTokenDao extends DatabaseAccessor<AppDatabase> with _$ApiTokenDaoMixin {
  static final Logger log = Logger('ApiTokenDao');

  ApiTokenDao(super.db);

  Future<ApiTokenTableData?> getApiTokenDetails() {
    log.fine('Fetching api token from local database');
    //  TODO: da implementare
    // return select(apiTokenTable).getSingleOrNull();
    throw UnimplementedError('getApiTokenDetails is not implemented yet');
  }

  Stream<ApiTokenTableData?> watchApiTokenDetails() {
    log.fine('Watching api token from local database');
    //  TODO: da implementare
    // return select(apiTokenTable).watchSingleOrNull();
    throw UnimplementedError('watchApiTokenDetails is not implemented yet');
  }

  Future<void> upsertApiTokenDetails(ApiTokenTableCompanion settings) async {
    //  TODO: da implementare
    // log.fine('Upserting api token into local database');
    // assert(settings.userId.present); // TODO: da errore 
    
    // // v1: await into(apiTokenTable).insertOnConflictUpdate(settings);
    // await transaction(() async {
    //   await delete(apiTokenTable).go(); // elimina tutto
    //   await into(apiTokenTable).insert(
    //     settings,
    //   );
    // });
    throw UnimplementedError('upsertApiTokenDetails is not implemented yet');
  }
}