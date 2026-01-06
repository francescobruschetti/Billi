import 'package:flutter/material.dart';
import 'package:monitoraggio_spese/services/groups_service.dart';
import 'package:monitoraggio_spese/pages/group/group_details.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {

  late Future<List<Map<String, dynamic>>> groupsFuture;
  String searchText = '';
  bool isLoading = true;
  List<Map<String, dynamic>> allGroups = [];

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
        isLoading = true;
      });
    }
    groupsFuture = GroupsService().fetchAllGroupsForUser();
    final result = await groupsFuture;

    if (mounted) {
      setState(() {
        allGroups = result;
        isLoading = false;
      });
    }
  }

  void _openGroupDetails(Map<String, dynamic> groupDetails) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => GroupDetailsPage(groupId: groupDetails['id'], isEdit: true)),
    );
  }

  @override
  Widget build(BuildContext context) {  

    final filteredGroups = allGroups.where((g) =>
      (g['name'] ?? '').toString().toLowerCase().contains(searchText.toLowerCase())
    ).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Cerca gruppo...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
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
        if (isLoading) // Loading data
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (allGroups.isEmpty) // No groups found
          Expanded(
            child: Center(
              child: Text("Nessun gruppo trovato"),
            ),
          )
        else // Show filtered groups
          Expanded(
          child: filteredGroups.isEmpty
              ? const Center(child: Text('Nessun gruppo trovato'))
              : ListView.builder(
                  itemCount: filteredGroups.length,
                  itemBuilder: (context, index) {
                    final g = filteredGroups[index];
                    return ListTile(
                      title: Text(g['name'] ?? '-'),
                      subtitle: Text('Totale: ${g['role']}, Devi: ${g['has_confirmed']}, Ti devono: ${g['is_enabled']}'), // TODO: da implementare
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _openGroupDetails(g);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}