import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/group_model.dart';
import '../services/group_service.dart';

final groupServiceProvider = Provider((ref) => GroupService());

final groupsProvider = StateNotifierProvider<GroupsNotifier, AsyncValue<List<GroupModel>>>(
  (ref) => GroupsNotifier(ref.read(groupServiceProvider)),
);

class GroupsNotifier extends StateNotifier<AsyncValue<List<GroupModel>>> {
  final GroupService service;

  GroupsNotifier(this.service) : super(const AsyncLoading()) {
    loadGroups();
  }

  void clear() {
    state = const AsyncData([]);
  }

  Future<void> loadGroups() async {
    try {
      state = const AsyncLoading();
      final groups = await service.fetchGroupsProvider();
      state = AsyncData(groups);
    } 
    catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    final groups = await service.fetchGroupsProvider();
    state = AsyncData(groups);
  }

  Future<void> createGroup(String name) async {
    final newGroup = await service.createGroupProvider(name);

    state.whenData((groups) {
      state = AsyncData([newGroup, ...groups]);
    });
  }
}
