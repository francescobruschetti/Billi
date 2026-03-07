import 'package:flutter/material.dart';
import 'package:Billy/pages/group/group_transactions.dart';
import 'package:Billy/services/group_service.dart';
import 'package:Billy/pages/group/group_details.dart';
import 'package:Billy/widgets/components/loading_scaffold.dart';
import 'package:Billy/widgets/components/search_field_widget.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final ScrollController _scrollController = ScrollController();

  late Future<List<Map<String, dynamic>>> groupsFuture;
  List<Map<String, dynamic>> allGroups = [];
  
  String _searchText = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadGroups();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _createGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailsPage(),
      ),
    );
  }

  Future<void> _loadGroups() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    groupsFuture = GroupService().fetchAllGroupsForUser();
    final result = await groupsFuture;

    if (mounted) {
      setState(() {
        allGroups = result;
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoading) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll) {
      _loadGroups();
    }
  }

  void _openPage(StatefulWidget widget) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => widget),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredGroups = allGroups.where((g) =>
      (g['name'] ?? '').toString().toLowerCase().contains(_searchText.toLowerCase())
    ).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: SearchFieldWidget(
                      text: 'Cerca gruppo...',
                      icon: Icons.search,
                      onChanged: (value) {
                        setState(() {
                          _searchText = value;
                        });
                      },
                    ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Crea nuovo gruppo',
                  onPressed: _createGroup,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Aggiorna',
                  onPressed: _loadGroups,
                ),
              ],
            ),
          ),
          if (_isLoading) // Loading data
            const LoadingScaffold(message: 'Caricamento gruppi...')
          else if (allGroups.isEmpty) // No groups found
            const SizedBox(
              height: 300,
              child: Center(
                child: Text("Nessun gruppo trovato"),
              ),
            )
          else // Show filtered groups
            SizedBox(
              height: 400,
              child: filteredGroups.isEmpty
                  ? const Center(child: Text('Nessun gruppo trovato'))
                  : NotificationListener<ScrollNotification>(
                      onNotification: (scrollNotification) {
                        if (scrollNotification is ScrollEndNotification) {
                          _onScroll();
                        }
                        return false;
                      },
                      child: RefreshIndicator(
                        onRefresh: () => _loadGroups(),
                        child: ListView.builder(
                          itemCount: filteredGroups.length,
                          itemBuilder: (context, index) {
                            final g = filteredGroups[index];
                            return ListTile(
                              title: Text(g['name'] ?? '-'),
                              subtitle: Text('Totale: ${g['total_expenses'] ?? 0} €'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(onPressed: () => _openPage(GroupDetailsPage(groupId: g['id'], isEditAllowed: true)), icon: Icon(Icons.more_vert)),
                                  Icon(Icons.chevron_right),
                                ],
                              ),
                              onTap: () {
                                _openPage(GroupTransactionsPage(groupId: g['id'], isEditAllowed: true));
                              },
                            );
                          },
                        ),
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}