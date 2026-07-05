import 'package:Billy/models/group/group_details_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Billy/services/group_service.dart';
import 'package:logging/logging.dart';

final groupServiceProvider = Provider((ref) => GroupService());

final groupsProvider = NotifierProvider<GroupsNotifier, AsyncValue<List<GroupDetailsModel>>>(
  GroupsNotifier.new,
  name: 'groupsProvider',
);

class GroupsNotifier extends Notifier<AsyncValue<List<GroupDetailsModel>>> {
  final Logger log = Logger('GroupsNotifier');

  GroupService get _service => ref.read(groupServiceProvider);

  @override
  AsyncValue<List<GroupDetailsModel>> build() {
    // stato iniziale
    _loadFromServer();

    return const AsyncLoading();
  }

  //************************************* Data Management *************************************//
  // Carica dal server — chiamato solo all'avvio e su refresh forzato
  Future<void> _loadFromServer() async {
    try {
      state = const AsyncLoading();
      final groups = await _service.fetchGroups();
      state = AsyncData(groups);
    } 
    catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // Refresh forzato dall'utente (pull-to-refresh)
  Future<void> refresh() => _loadFromServer();

  // Aggiunta ottimistica — aggiorna la memoria immediatamente poi sincronizza col server
  Future<void> addGroup({ required String name, String? description }) async {
    try {
      final newGroup = await _service.createGroup(name: name, description: description);
      state = state.whenData((groups) => [newGroup, ...groups]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  //************************************* LOCAL Management *************************************//
  void addGroupLocally(GroupDetailsModel newGroup) {
    state = state.whenData((groups) => [newGroup, ...groups]);
  }

  // Aggiornamento ottimistico locale — nessuna chiamata al server
  void updateGroupLocally(GroupDetailsModel updated) {
    state = state.whenData((groups) => [
      for (final g in groups)
        if (g.id == updated.id) updated else g,
    ]);
  }

  // Rimozione ottimistica locale
  void removeGroupLocally(String id) {
    state = state.whenData(
      (groups) => groups.where((g) => g.id != id).toList(),
    );
  }

}
