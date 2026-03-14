import 'package:Billy/models/group_model.dart';
import 'package:Billy/pages/group/create_group_page.dart';
import 'package:Billy/widgets/components/custom_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:Billy/providers/group_provider.dart';
import 'package:Billy/pages/group/group_transactions.dart';
import 'package:Billy/services/group_service.dart';
import 'package:Billy/pages/group/group_details.dart';
import 'package:Billy/widgets/components/loading_scaffold.dart';
import 'package:Billy/widgets/components/search_field_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupsPage extends ConsumerStatefulWidget {
  const GroupsPage({super.key});

  @override
  ConsumerState<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends ConsumerState<GroupsPage> {
  final ScrollController _scrollController = ScrollController();

  late Future<List<GroupModel>> groupsFuture;
  List<GroupModel> allGroups = [];
  late List<GroupModel> filteredGroups = [];

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

  void _filterGroups(List<GroupModel> groups) {
    setState(() {
      filteredGroups = groups.where((g) =>
        g.name.toLowerCase().contains(_searchText.toLowerCase())
      ).toList();
    });
  }

  Future<void> _loadGroups() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    groupsFuture = GroupService().fetchGroupsProvider();
    final result = await groupsFuture;

    if (mounted) {
      setState(() {
        allGroups = result;
        _filterGroups(allGroups);
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
    final groupsState = ref.watch(groupsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateGroupPage()),
          );
        },
        child: const CustomIconWidget(assetPath: 'assets/images/icons/add.PNG', size: 24),
      ),
      body: groupsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (err, _) => Center(
          child: Text("Error: $err"),
        ),

        data: (groups) {
          _filterGroups(groups);
          
          return Column(
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
                              _filterGroups(allGroups);
                            });
                          },
                        ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const CustomIconWidget(assetPath: 'assets/images/icons/add.PNG', size: 24),
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
                                  title: Text(g.name),
                                  subtitle: Text('Totale: ${g.totalAmount} €'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () => _openPage(GroupDetailsPage(groupId: g.id, isEditAllowed: true)), 
                                        icon: CustomIconWidget(assetPath: 'assets/images/icons/vertical_dots.PNG', size: 24),
                                      ),
                                      CustomIconWidget(assetPath: 'assets/images/icons/right.PNG', size: 20),
                                    ],
                                  ),
                                  onTap: () {
                                    _openPage(GroupTransactionsPage(groupId: g.id, isEditAllowed: true));
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                ),
            ],
          );
        },
      ),        
    );

    // final filteredGroups = allGroups.where((g) =>
    //   (g['name'] ?? '').toString().toLowerCase().contains(_searchText.toLowerCase())
    // ).toList();

    // return SingleChildScrollView(
    //   padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    //   child: Column(
    //     children: [
    //       Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    //         child: Row(
    //           children: [
    //             Expanded(
    //               child: SearchFieldWidget(
    //                   text: 'Cerca gruppo...',
    //                   icon: Icons.search,
    //                   onChanged: (value) {
    //                     setState(() {
    //                       _searchText = value;
    //                     });
    //                   },
    //                 ),
    //             ),
    //             const SizedBox(width: 8),
    //             IconButton(
    //               icon: const CustomIconWidget(assetPath: 'assets/images/icons/add.PNG', size: 24),
    //               tooltip: 'Crea nuovo gruppo',
    //               onPressed: _createGroup,
    //             ),
    //             const SizedBox(width: 8),
    //             IconButton(
    //               icon: const Icon(Icons.refresh),
    //               tooltip: 'Aggiorna',
    //               onPressed: _loadGroups,
    //             ),
    //           ],
    //         ),
    //       ),
    //       if (_isLoading) // Loading data
    //         const LoadingScaffold(message: 'Caricamento gruppi...')
    //       else if (allGroups.isEmpty) // No groups found
    //         const SizedBox(
    //           height: 300,
    //           child: Center(
    //             child: Text("Nessun gruppo trovato"),
    //           ),
    //         )
    //       else // Show filtered groups
    //         SizedBox(
    //           height: 400,
    //           child: filteredGroups.isEmpty
    //               ? const Center(child: Text('Nessun gruppo trovato'))
    //               : NotificationListener<ScrollNotification>(
    //                   onNotification: (scrollNotification) {
    //                     if (scrollNotification is ScrollEndNotification) {
    //                       _onScroll();
    //                     }
    //                     return false;
    //                   },
    //                   child: RefreshIndicator(
    //                     onRefresh: () => _loadGroups(),
    //                     child: ListView.builder(
    //                       itemCount: filteredGroups.length,
    //                       itemBuilder: (context, index) {
    //                         final g = filteredGroups[index];
    //                         return ListTile(
    //                           title: Text(g['name'] ?? '-'),
    //                           subtitle: Text('Totale: ${g['total_amount'] ?? 0} €'),
    //                           trailing: Row(
    //                             mainAxisSize: MainAxisSize.min,
    //                             children: [
    //                               IconButton(
    //                                 onPressed: () => _openPage(GroupDetailsPage(groupId: g['id'], isEditAllowed: true)), 
    //                                 icon: CustomIconWidget(assetPath: 'assets/images/icons/vertical_dots.PNG', size: 24),
    //                               ),
    //                               CustomIconWidget(assetPath: 'assets/images/icons/right.PNG', size: 20),
    //                             ],
    //                           ),
    //                           onTap: () {
    //                             _openPage(GroupTransactionsPage(groupId: g.id, isEditAllowed: true));
    //                           },
    //                         );
    //                       },
    //                     ),
    //                   ),
    //                 ),
    //         ),
    //     ],
    //   ),
    // );
  }
}