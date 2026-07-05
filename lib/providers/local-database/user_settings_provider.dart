import 'dart:async';

import 'package:Billy/enums/theme_enum.dart';
import 'package:Billy/local/database/app_database.dart';
import 'package:Billy/models/database/user_settings_model.dart';
import 'package:Billy/services/user_settings_service.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userSettingsProvider = AsyncNotifierProvider<UserSettingsNotifier, UserSettingsTableData?>(
  UserSettingsNotifier.new,
);

class UserSettingsNotifier extends AsyncNotifier<UserSettingsTableData?> {
  static final Logger log = Logger('UserSettingsNotifier');

  @override
  Future<UserSettingsTableData?> build() async { // TODO: non c'è un TTL?
    try {
      // Prova dalla cache locale → funziona anche offline
      final local = await ref.read(localDatabaseProvider).userSettingsDao.getSettings();
      if (local != null) {
        log.fine('x> Loaded settings from local cache: $local');
        return local;
      }

      // Non in locale → fetch dal BE
      return fetchAndSave();
    } 
    catch (e, st) {
      log.severe('Error loading settings: $e', e, st);
      rethrow;
    }
  }

  // Fetch dal BE e salva in locale
  Future<UserSettingsTableData?> fetchAndSave() async {
    try {
      log.fine('Fetching settings from BE');
      final remote = await UserSettingsService().fetchSettings();
      await _save(remote);
      return ref.read(localDatabaseProvider).userSettingsDao.getSettings();
    } 
    catch (e, st) {
      log.severe('Error fetching settings from BE: $e', e, st);
      return null;
    }
  }

  // Salva in locale
  Future<void> _save(UserSettingsModel settings) async {
    log.fine('Saving settings to local database');
    await ref.read(localDatabaseProvider).userSettingsDao.upsertSettings(
      UserSettingsTableCompanion(
        themeMode: Value(settings.themeMode.name),
        notificationsEnabled: Value(settings.notificationsEnabled),
        language: Value(settings.language),
        currency: Value(settings.currency),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Aggiorna un campo → salva in locale + sync col BE
  Future<UserSettingsTableData?> updateThemeSettings({ required ThemeEnum theme }) async {
    log.fine('Updating theme settings');
    UserSettingsTableCompanion updated = UserSettingsTableCompanion(
      userId: Value(Supabase.instance.client.auth.currentUser!.id), // TODO: sempre null?
      themeMode: Value(theme.name),
      updatedAt: Value(DateTime.now()),
    );
    return await updateSettings(updated);
  }

  Future<UserSettingsTableData?> updateSettings(UserSettingsTableCompanion settings) async {
    log.fine('Updating settings');
    final db = ref.read(localDatabaseProvider);

    // Aggiornamento ottimistico — UI si aggiorna subito
    await db.userSettingsDao.upsertSettings(settings);
    state = AsyncData(await db.userSettingsDao.getSettings());

    // Sync col BE in background
    try {
      final current = await db.userSettingsDao.getSettings();
      if (current != null) {
        await UserSettingsService().updateSettings(
          UserSettingsModel.fromTableData(current),
        );
      }
    } 
    catch (e, st) {
      log.severe('Error updating settings on BE: $e', e, st);
      // Offline → i dati sono già salvati in locale
      // syncPending() li invierà al BE al prossimo avvio
    }

    return await db.userSettingsDao.getSettings();
  }

  // Forza reload dal BE
  Future<void> refresh() async {
    log.fine('Refreshing settings from BE');
    state = const AsyncLoading();
    state = AsyncData(await fetchAndSave());
  }

  // Chiamato al logout
  Future<void> clear() async {
    try {
      log.fine('xx> Clearing settings from local database');
      ref.read(localDatabaseProvider).delete(ref.read(localDatabaseProvider).userSettingsTable).go();
      // TODO: dà errore perché userId è null...
      // log.fine('xx> Current user ID: $userId');
      // if (userId.isEmpty) {
      //   log.warning('No user is currently logged in. Skipping clear operation.');
      //   return;
      // }
      //
      // final db = ref.read(localDatabaseProvider);
      // await (db.delete(db.userSettingsTable)
      //   ..where((t) => t.userId.equals(userId)))
      //   .go();

      state = const AsyncData(null);
    }
    catch (e, st) {
      log.severe('Error clearing settings: $e', e, st);
      rethrow;
    }
  }
}