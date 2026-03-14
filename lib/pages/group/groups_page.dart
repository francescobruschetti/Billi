import 'package:Billy/models/group_model.dart';
import 'package:Billy/widgets/components/custom_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:Billy/providers/group_provider.dart';
import 'package:Billy/pages/group/group_transactions.dart';
import 'package:Billy/pages/group/group_details.dart';
import 'package:Billy/widgets/components/search_field_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupsPage extends ConsumerStatefulWidget {
  const GroupsPage({super.key});

  @override
  ConsumerState<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends ConsumerState<GroupsPage> {
  String _searchText = '';

  List<GroupModel> _filtered(List<GroupModel> groups) {
    if (_searchText.isEmpty) return groups;
    return groups
      .where((g) => g.name.toLowerCase().contains(_searchText.toLowerCase()))
      .toList();
  }

  @override
  Widget build(BuildContext context) {
    final groupsState = ref.watch(groupsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GroupDetailsPage()),
        ),
        child: const CustomIconWidget(
          assetPath: 'assets/images/icons/add.PNG',
          size: 24,
        ),
      ),
      body: groupsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Errore: $err")),
        data: (groups) {
          final filtered = _filtered(groups);

          return Column(
            children: [
              _buildSearchBar(),
              
              Expanded(child: _buildList(filtered)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SearchFieldWidget(
              text: 'Cerca gruppo...',
              icon: Icons.search,
              onChanged: (value) => setState(() => _searchText = value),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Aggiorna',
            onPressed: () => ref.read(groupsProvider.notifier).refresh(),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<GroupModel> groups) {
    if (groups.isEmpty) {
      return const Center(child: Text('Nessun gruppo trovato'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(groupsProvider.notifier).refresh(),
      child: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) => _buildGroupTile(groups[index]),
      ),
    );
  }

  Widget _buildGroupTile(GroupModel g) {
    return ListTile(
      title: Text(g.name),
      subtitle: Text('Totale: ${g.totalAmount} €'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const CustomIconWidget(
              assetPath: 'assets/images/icons/vertical_dots.PNG',
              size: 24,
            ),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => GroupDetailsPage(groupId: g.id, isEditAllowed: true),
            )),
          ),
          const CustomIconWidget(
            assetPath: 'assets/images/icons/right.PNG',
            size: 20,
          ),
        ],
      ),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => GroupTransactionsPage(groupId: g.id, isEditAllowed: true),
      )),
    );
  }

}