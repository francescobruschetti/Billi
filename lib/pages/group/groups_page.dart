import 'package:Billy/models/group/group_details_model.dart';
import 'package:Billy/widgets/components/custom_icon_widget.dart';
import 'package:Billy/widgets/components/floating_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:Billy/providers/group_provider.dart';
import 'package:Billy/pages/group/group_transactions.dart';
import 'package:Billy/pages/group/group_details.dart';
import 'package:Billy/widgets/components/search_field_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

class GroupsPage extends ConsumerStatefulWidget {
  const GroupsPage({super.key});

  @override
  ConsumerState<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends ConsumerState<GroupsPage> {
  final Logger log = Logger('GroupsPage');

  String _searchText = '';
  bool _showSearchBar = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      _showSearchBar = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<GroupDetailsModel> _filtered(List<GroupDetailsModel> groups) {
    if (_searchText.isEmpty) return groups;
    return groups
      .where((g) => g.name.toLowerCase().contains(_searchText.toLowerCase()))
      .toList();
  }

  @override
  Widget build(BuildContext context) {
    final groupsState = ref.watch(groupsProvider);

    return Scaffold(
      appBar: _buildAppBar(),
      floatingActionButton: FloatingButtonWidget(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupDetailsPage())),
        iconButton: CustomIconWidget(
          assetPath: 'assets/images/icons/add.PNG',
          size: 24,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
      body: groupsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Errore durante il caricamento. Riprovare")), // TODO: migliorare gestione errori
        data: (groups) {
          final filtered = _filtered(groups);

          return Column(
            children: [
              Expanded(child: _buildList(filtered)),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      // debug: backgroundColor: Colors.yellowAccent,
      title: _animatedSearchBar(),

      actionsPadding: const EdgeInsets.symmetric(horizontal: 0),
      actions: [      
        if (!_showSearchBar) ...[
          IconButton(
            // debug: 
            // style: IconButton.styleFrom(
            //   backgroundColor: Colors.blue
            // ),
            icon: const Icon(Icons.search),
            tooltip: 'Cerca',
            onPressed: () => {
              setState(() => _showSearchBar = !_showSearchBar),
            },
          ),
        ],
        IconButton(
          // debug: 
          // style: IconButton.styleFrom(
          //   backgroundColor: Colors.green
          // ),
          icon: const Icon(Icons.refresh),
          tooltip: 'Aggiorna',
          onPressed: () => ref.read(groupsProvider.notifier).refresh(),
        ),
      ],
    );
  }
  
  Widget _animatedSearchBar() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          axis: Axis.horizontal,
          child: child,
        ),
      ),
      child: _showSearchBar
        ? // debug: Container(
          // debug: color: Colors.redAccent, 
          // debug: child: 
            SearchFieldWidget(
              hintText: 'Cerca gruppo...',
              icon: Icons.search,
              onChanged: (value) => setState(() => _searchText = value), // Nota: quando SearchFieldWidget._onClose().widget.onChanged('') viene chiamato, _searchText viene resettato a ''
              onClose: () => setState(() { // Aggiunto per sicurezza
                _searchText = '';
                _showSearchBar = false;
              }),
            )
          // debug: )
        : const Text('Gruppi'),
    );
  }

  Widget _buildGroupTile(GroupDetailsModel g) {
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

  Widget _buildList(List<GroupDetailsModel> groups) {
    if (groups.isEmpty) {
      return const Center(child: Text('Nessun gruppo trovato'));
    }

    return RefreshIndicator( // Pull from top to refresh
      onRefresh: () => ref.read(groupsProvider.notifier).refresh(),
      child: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) => _buildGroupTile(groups[index]),
      ),
    );
  }

}