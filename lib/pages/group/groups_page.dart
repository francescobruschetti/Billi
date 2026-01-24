import 'package:flutter/material.dart';
import 'package:monitoraggio_spese/pages/group/group_expenses.dart';
import 'package:monitoraggio_spese/services/groups_service.dart';
import 'package:monitoraggio_spese/pages/group/group_details.dart';
import 'package:monitoraggio_spese/widgets/components/loading_scaffold.dart';
import 'package:monitoraggio_spese/widgets/components/search_field_widget.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {

  late Future<List<Map<String, dynamic>>> groupsFuture;
  List<Map<String, dynamic>> allGroups = [];
  
  String _searchText = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  void _createGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailsPage(),
      ),
    );
  }

  void _loadGroups() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    groupsFuture = GroupsService().fetchAllGroupsForUser();
    final result = await groupsFuture;

    if (mounted) {
      setState(() {
        allGroups = result;
        _isLoading = false;
      });
    }
  }

  void _openGroupDetails(Map<String, dynamic> groupDetails) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => GroupDetailsPage(groupId: groupDetails['id'], isEditAllowed: true)),
    );
  }

  void _openGroupExpenses(Map<String, dynamic> groupDetails) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => GroupExpensesPage(groupId: groupDetails['id'], isEditAllowed: true)),
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
                  : ListView.builder(
                      itemCount: filteredGroups.length,
                      itemBuilder: (context, index) {
                        final g = filteredGroups[index];
                        return ListTile(
                          title: Text(g['name'] ?? '-'),
                          subtitle: Text('Totale: ${g['role']}, Devi: ${g['has_confirmed']}, Ti devono: ${g['is_enabled']}'), // TODO: da implementare
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(onPressed: () => _openGroupDetails(g), icon: Icon(Icons.more_vert)),
                              Icon(Icons.chevron_right),
                            ],
                          ),
                          onTap: () {
                            _openGroupExpenses(g);
                          },
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}