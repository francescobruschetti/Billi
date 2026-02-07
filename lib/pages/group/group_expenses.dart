import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:monitoraggio_spese/enums/time_filter_enum.dart';
import 'package:monitoraggio_spese/models/group_details_model.dart';
import 'package:monitoraggio_spese/models/group_participant_summary_model.dart';
import 'package:monitoraggio_spese/pages/expense/expense_group_page.dart';
import 'package:monitoraggio_spese/pages/group/group_details.dart';
import 'package:monitoraggio_spese/services/expenses_service.dart';
import 'package:monitoraggio_spese/utils/group_expenses_util.dart';
import 'package:monitoraggio_spese/widgets/components/expense_card_widget.dart';
import 'package:monitoraggio_spese/widgets/components/loading_scaffold.dart';
import 'package:monitoraggio_spese/widgets/components/search_field_widget.dart';
import 'package:monitoraggio_spese/widgets/components/time_filter_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupExpensesPage extends StatefulWidget {
  final String groupId; // null = creazione, non null = modifica
  final bool isEditAllowed;

  const GroupExpensesPage({super.key, required this.groupId, this.isEditAllowed = false});

  @override
  State<GroupExpensesPage> createState() => _GroupExpensesPageState();
}

class _GroupExpensesPageState extends State<GroupExpensesPage> {
  final Logger log = Logger('GroupExpensesPage');
  final ExpensesService service = ExpensesService();
  final ScrollController _scrollController = ScrollController();
  final String userId = Supabase.instance.client.auth.currentUser!.id;

  List<Map<String, dynamic>> _allExpenses = []; // TODO: convertire in modello?
  GroupDetailsModel? _groupDetails;
  Map<String, GroupParticipantSummaryModel> _participantsSummary = {};

  int _currentPage = 0;

  final int _pageSize = 50;
  bool _isComputingUsersSummary = true;
  bool _isLoadingContent = false;
  bool _isLoadingPage = false;
  bool _hasMore = true;
  String _searchText = '';
  String _groupName = '-';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _loadGroupDetails();
    _loadExpenses(reset: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleUsersSummary() {
    setState(() {
      log.finer("Computing users summary for group participants...");
      _isComputingUsersSummary = true;
    });

    _participantsSummary = GroupExpensesUtil.computeParticipantsSummary(expenses: _allExpenses, groupParticipants: _groupDetails?.groupParticipants ?? []);

    setState(() {
      _participantsSummary = Map<String, GroupParticipantSummaryModel>.from(_participantsSummary);
      log.finer("Finished computing users summary for group participants.");
      _isComputingUsersSummary = false;
    });
  }

  void _filterExpenses({bool reset = false}) async {
    // TODO: d_participantsSummarya implementare filtro spese
  }

  void _filterTimeExpenses({required TimeFilterEnum filter}) async {
    log.info('Filtro Time selezionato: ${filter.value}');
    // TODO: da implementare filtro spese
  }

 String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } 
    catch (e) {
      log.severe('Error parsing date: $e');
      return dateTimeStr;
    }
  }

  void _loadExpenses({bool reset = false}) async {
    if (_isLoadingPage || _isLoadingContent) return;
    if (mounted) {
      setState(() {
        if (reset) {
          _isLoadingPage = true;
        } 
        else {
          _isLoadingContent = true;
        }
      });
    }
    if (reset) {
      _currentPage = 0;
      _hasMore = true;
      _allExpenses.clear();
    }

    final expenses = await service.fetchLatestGroupExpenses(groupId: widget.groupId, pageIndex: _currentPage, pageSize: _pageSize);
    if (mounted) {
      setState(() {
        if (reset) {
          _allExpenses = expenses;
          _isLoadingPage = false;
        } 
        else {
          _allExpenses.addAll(expenses);
          _isLoadingContent = false;
        }        
        _handleUsersSummary();
        _hasMore = expenses.length == _pageSize;
        if (_hasMore) {
          _currentPage++;
        }
      });
    }
  }

  void _loadGroupDetails() async {
    final details = await service.fetchGroupParticipants(groupId: widget.groupId, pageIndex: _currentPage, pageSize: _pageSize);

    if (mounted) {
      if (details.success) {
        log.info('Group details loaded successfully');
      } 
      else {
        log.warning('Failed to load group details: ${details.message}');
      }

      setState(() {
        _groupDetails = details.success ? details.data : null;
        _groupName = (_groupDetails != null && _groupDetails!.name.isNotEmpty) ? _groupDetails!.name : '-';
      });
    }
  }

  void _navigateToGroupExpensesPage({required String groupId, required bool isEditAllowed}) async {
    var page = ExpenseGroupPage(groupId: groupId, isEditAllowed: isEditAllowed);

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    )
    .then((result) {
      if (result == true) {
        _loadExpenses(reset: true);
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingPage || !_hasMore) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll) {
      _loadExpenses();
    }
  }

  void _openPage(StatefulWidget widget) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => widget),
    );
  }

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text('Spese: $_groupName'),
            ),
            const SizedBox(width: 5),
            IconButton(
              icon: Image.asset('images/icons/settings.PNG', width: 20, height: 20, color: Colors.black),
              tooltip: 'Impostazioni Gruppo',
              onPressed: () => _openPage(GroupDetailsPage(groupId: widget.groupId, isEditAllowed: widget.isEditAllowed)),
            ),
          ],
        ),
      ),
      body: _isLoadingPage
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [LoadingScaffold(message: 'Caricamento dati gruppo...')],
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Page Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                          'Totale spese (${_allExpenses.length}): ${_allExpenses.fold<double>(0, (sum, e) => sum + (double.tryParse(e['total_amount']?.toString() ?? '0') ?? 0)).toStringAsFixed(2)}€',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                    ),
                    const SizedBox(width: 5),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Aggiorna',
                      onPressed: () => _loadExpenses(reset: true),
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      tooltip: 'Filtra',
                      onPressed: () => _filterExpenses(reset: true),
                    ),
                  ],
                ),
                
                // Page Header "subtitle"
                const SizedBox(height: 4),
                TimeFilterWidget(
                  timeFilters: [ TimeFilterEnum.ONE_DAY, TimeFilterEnum.ONE_WEEK, TimeFilterEnum.ONE_MONTH, TimeFilterEnum.ONE_YEAR ],
                  onPressed: (filter) => _filterTimeExpenses(filter: filter),
                ),

                // How much user owes or is owed
                const SizedBox(height: 4),
                Card(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    title: Text("Riepilogo utenti (${_groupDetails?.groupParticipants.length ?? 0})", style: const TextStyle(fontWeight: FontWeight.w500)),
                    children: [
                      SizedBox(
                        height: 100, // imposta l’altezza desiderata
                        child: _isComputingUsersSummary
                          ? const LoadingScaffold(message: 'Caricamento dettagli...')
                          : _participantsSummary.isEmpty
                            ? const Center(child: Text('Nessun utente presente'))
                            : ListView.builder(
                                itemCount: _participantsSummary.length,
                                itemBuilder: (context, index) {
                                  final e = _participantsSummary.values.elementAt(index);

                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.0),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Row(
                                        children: [
                                          // TODO: da implementare
                                          // const SizedBox(width: 8),
                                          // Text(e.profile.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                          // const SizedBox(width: 12),  
                                          // Text("Paid: ${e.alreadyPaid.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w500)),
                                          // const SizedBox(width: 8), 
                                          // Text("To Pay: ${e.toPay.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w500)),
                                          // const SizedBox(width: 8), 
                                          // Text("To Receive: ${e.toReceive.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w500)),
                                        ]
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                
                // Page Content
                Expanded(
                  child: _isLoadingContent
                    ? const LoadingScaffold(message: 'Caricamento spese...')
                    : _allExpenses.isEmpty
                      ? const Center(child: Text('Nessuna spesa presente'))
                      : NotificationListener<ScrollNotification>(
                          onNotification: (scrollNotification) {
                            if (scrollNotification is ScrollEndNotification) {
                              _onScroll();
                            }
                            return false;
                          },
                          child:
                            ListView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _allExpenses.length + (_isLoadingContent ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index >= _allExpenses.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(child: Text('Carico altre spese...')),
                                  );
                                }
                                final e = _allExpenses[index];
                                final formattedDateTime = _formatDateTime(e['updated_at'] ?? '');
                                final totalAmount = double.tryParse(e['total_amount']?.toString() ?? '0') ?? 0;
                                final merchant = e['merchant'] ?? {};
                                final category = e['category'] ?? {};

                                return ExpenseCardWidget(
                                  merchantName: merchant['name'] ?? '-',
                                  categoryName: category['name'] ?? '-',
                                  formattedDateTime: formattedDateTime,
                                  totalAmount: totalAmount,
                                  note: e['note'],
                                  user: e['user'],
                                  paidAmount: e['paid_amount'],
                                  splitRate: e['split_rate'],
                                );
                              },
                            ),
                          ),
                ),
                
                // Page footer
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 9,
                      child: SearchFieldWidget(
                        text: 'Cerca spesa...',
                        icon: Icons.search,
                        onChanged: (value) {
                          setState(() {
                            _searchText = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child:
                      IconButton(
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.white,
                          shape: const CircleBorder(),
                        ),
                        onPressed: () async {
                          _navigateToGroupExpensesPage(groupId: widget.groupId, isEditAllowed: true);
                        },
                      ),
                    ),
                  ],
                ),
              
              ],
            ),
          ),

    );
  }
}
