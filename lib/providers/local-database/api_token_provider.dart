import 'dart:async';

import 'package:Billy/local/database/app_database.dart';
import 'package:Billy/models/database/api_token_model.dart';
import 'package:Billy/services/api_token_service.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

final apiTokenProvider = AsyncNotifierProvider<ApiTokenNotifier, List<ApiTokenTableData>>(
  ApiTokenNotifier.new,
  name: 'apiTokenProvider',
);

class ApiTokenNotifier extends AsyncNotifier<List<ApiTokenTableData>> {
  static final Logger log = Logger('ApiTokenNotifier');

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  @override
  Future<List<ApiTokenTableData>> build() async { // TODO: non c'è un TTL?
    try {
      // Prova dalla cache locale → funziona anche offline
      final local = await ref.read(localDatabaseProvider).apiTokenDao.getApiTokens();
      // if (local != null) {
      //   log.fine('> Loaded apiTokens from local cache: $local');
      //   return local;
      // }

      // // Non in locale → fetch dal BE
      // return fetchAndSave();
      return local;
    } 
    catch (e, st) {
      log.severe('Error loading apiTokens: $e', e, st);
      rethrow;
    }
  }

  // Fetch dal BE e salva in locale
  Future<List<ApiTokenTableData>> fetchAndSave() async {
    try {
      log.fine('Fetching apiTokens from BE');
      final apiTokenModels = await ApiTokenService().fetchApiTokens();
      for (var apiTokenModel in apiTokenModels) {
        await _save(apiTokenModel);
      }

      final local = await ref.read(localDatabaseProvider).apiTokenDao.getApiTokens();
      return local;
    } 
    catch (e, st) {
      log.severe('Error fetching apiTokens from BE: $e', e, st);
      return [];
    }
  }

  // Salva in locale
  Future<void> _save(ApiTokenModel apiTokens) async { // TODO: convert to save list
    log.fine('Saving apiTokens to local database');
    await ref.read(localDatabaseProvider).apiTokenDao.upsertApiTokenDetails(
      ApiTokenTableCompanion(
        id: Value(apiTokens.id),
        userId: Value(apiTokens.userId),
        name: Value(apiTokens.name),
        tokenHash: Value(apiTokens.tokenHash),
        createdAt: Value(apiTokens.createdAt),
        updatedAt: Value(apiTokens.updatedAt),
        validUntil: Value(apiTokens.validUntil),
        lastUsedAt: Value(apiTokens.lastUsedAt),
        revokedAt: Value(apiTokens.revokedAt),

      ),
    );
  }

  // // Aggiorna un campo → salva in locale + sync col BE
  // Future<ApiTokenTableData?> updateThemeSettings({ required ThemeEnum theme }) async {
  //   // TODO: implementare aggiornamento delle impostazioni del tema
  //   // log.fine('Updating theme apiTokens');
  //   // ApiTokenTableCompanion updated = ApiTokenTableCompanion(
  //   //   userId: Value(Supabase.instance.client.auth.currentUser!.id), // TODO: sempre null?
  //   //   themeMode: Value(theme.name),
  //   //   updatedAt: Value(DateTime.now()),
  //   // );
  //   // return await updateSettings(updated);
  //   throw UnimplementedError('Not implemented yet');
  // }

  // Future<ApiTokenTableData?> updateSettings(ApiTokenTableCompanion apiTokens) async {
  //   // TODO: implementare aggiornamento delle impostazioni
  //   // log.fine('Updating apiTokens');
  //   // final db = ref.read(localDatabaseProvider);

  //   // // Aggiornamento ottimistico — UI si aggiorna subito
  //   // await db.apiTokenDao.upsertSettings(apiTokens);
  //   // state = AsyncData(await db.apiTokenDao.getApiTokenDetails());

  //   // // Sync col BE in background
  //   // try {
  //   //   final current = await db.apiTokenDao.getApiTokenDetails();
  //   //   if (current != null) {
  //   //     await ApiTokenService().updateSettings(
  //   //       ApiTokenModel.fromTableData(current),
  //   //     );
  //   //   }
  //   // } 
  //   // catch (e, st) {
  //   //   log.severe('Error updating apiTokens on BE: $e', e, st);
  //   //   // Offline → i dati sono già salvati in locale
  //   //   // syncPending() li invierà al BE al prossimo avvio
  //   // }

  //   // return await db.apiTokenDao.getApiTokenDetails();
  //   throw UnimplementedError('Not implemented yet');
  // }

  // // Forza reload dal BE
  // Future<void> refresh() async {
  //   // TODO: implementare refresh delle impostazioni
  //   // log.fine('Refreshing apiTokens from BE');
  //   // state = const AsyncLoading();
  //   // state = AsyncData(await fetchAndSave());
  //   throw UnimplementedError('Not implemented yet');
  // }

  // // Chiamato al logout
  // Future<void> clear() async {
  //   // TODO: implementare cancellazione delle impostazioni al logout
  //   // try {
  //   //   log.fine('xx> Clearing apiTokens from local database');
  //   //   ref.read(localDatabaseProvider).delete(ref.read(localDatabaseProvider).apiTokenTable).go();
  //   //   // TODO: dà errore perché userId è null...
  //   //   // log.fine('xx> Current user ID: $userId');
  //   //   // if (userId.isEmpty) {
  //   //   //   log.warning('No user is currently logged in. Skipping clear operation.');
  //   //   //   return;
  //   //   // }
  //   //   //
  //   //   // final db = ref.read(localDatabaseProvider);
  //   //   // await (db.delete(db.apiTokenTable)
  //   //   //   ..where((t) => t.userId.equals(userId)))
  //   //   //   .go();

  //   //   state = const AsyncData(null);
  //   // }
  //   // catch (e, st) {
  //   //   log.severe('Error clearing apiTokens: $e', e, st);
  //   //   rethrow;
  //   // }
  //   throw UnimplementedError('Not implemented yet');
  // }
}