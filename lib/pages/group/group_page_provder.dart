import 'package:Billy/pages/group/create_group_page.dart';
import 'package:Billy/providers/group_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupsPageProvider extends ConsumerWidget {
  const GroupsPageProvider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsState = ref.watch(groupsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Groups")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateGroupPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: groupsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (err, _) => Center(
          child: Text("Error: $err"),
        ),

        data: (groups) => RefreshIndicator(
          onRefresh: () => ref.read(groupsProvider.notifier).refresh(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(groups[index].name),
              );
            },
          ),
        ),
      ),
    );
  }
}
