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
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Future<UserSettingsTableData?> build() async {
    try {
      final db = ref.read(localDatabaseProvider);

      // Prova dalla cache locale → funziona anche offline
      final local = await db.getSettings();
      if (local != null) return local;

      // Non in locale → fetch dal BE
      return _fetchAndSave();
    } 
    catch (e, st) {
      log.severe('Error loading settings: $e', e, st);
      rethrow;
    }
  }

  // Fetch dal BE e salva in locale
  Future<UserSettingsTableData?> _fetchAndSave() async {
    try {
      log.fine('Fetching settings from BE');
      final remote = await UserSettingsService().fetchSettings();
      await _save(remote);
      return ref.read(localDatabaseProvider).getSettings();
    } 
    catch (e, st) {
      log.severe('Error fetching settings from BE: $e', e, st);
      return null;
    }
  }

  // Salva in locale
  Future<void> _save(UserSettingsModel settings) async {
    log.fine('Saving settings to local database');
    final db = ref.read(localDatabaseProvider);
    await db.upsertSettings(
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
  Future<UserSettingsTableData?> updateThemeSettings(ThemeEnum theme) async {
    log.fine('Updating theme settings');
    UserSettingsTableCompanion updated = UserSettingsTableCompanion(
      userId: Value(supabase.auth.currentUser!.id),
      themeMode: Value(theme.name),
      updatedAt: Value(DateTime.now()),
    );
    return await updateSettings(updated);
  }

  Future<UserSettingsTableData?> updateSettings(UserSettingsTableCompanion settings) async {
    log.fine('Updating settings');
    final db = ref.read(localDatabaseProvider);

    // Aggiornamento ottimistico — UI si aggiorna subito
    await db.upsertSettings(settings);
    state = AsyncData(await db.getSettings());

    // Sync col BE in background
    try {
      final current = await db.getSettings();
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

    return await db.getSettings();
  }

  // Forza reload dal BE
  Future<void> refresh() async {
    log.fine('Refreshing settings from BE');
    state = const AsyncLoading();
    state = AsyncData(await _fetchAndSave());
  }

  // Chiamato al logout
  Future<void> clear() async {
    log.fine('Clearing settings from local database');
    await ref.read(localDatabaseProvider).delete(ref.read(localDatabaseProvider).userSettingsTable).go();
    state = const AsyncData(null);
  }
}