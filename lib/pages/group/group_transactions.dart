
import 'package:Billy/enums/transaction_type_enum.dart';
import 'package:Billy/pages/group/components/dialog_transactions_balance_widget.dart';
import 'package:Billy/pages/group/components/dialog_transactions_details_widget.dart';
import 'package:Billy/widgets/components/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:Billy/enums/time_filter_enum.dart';
import 'package:Billy/models/group_model.dart';
import 'package:Billy/models/group_transaction_model.dart';
import 'package:Billy/models/group_participant_summary_model.dart';
import 'package:Billy/pages/transaction/transaction_group_page.dart';
import 'package:Billy/pages/group/group_details.dart';
import 'package:Billy/services/transaction_service.dart';
import 'package:Billy/utils/group_transactions_util.dart';
import 'package:Billy/widgets/components/custom_icon_widget.dart';
import 'package:Billy/widgets/components/error_alert_widget.dart';
import 'package:Billy/widgets/components/transaction_card_widget.dart';
import 'package:Billy/widgets/components/loading_scaffold.dart';
import 'package:Billy/widgets/components/search_field_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupTransactionsPage extends StatefulWidget {
  final String groupId; // null = creazione, non null = modifica
  final bool isEditAllowed;

  const GroupTransactionsPage({super.key, required this.groupId, this.isEditAllowed = false});

  @override
  State<GroupTransactionsPage> createState() => _GroupTransactionsPageState();
}

class _GroupTransactionsPageState extends State<GroupTransactionsPage> {
  final Logger log = Logger('GroupTransactionsPage');
  final TransactionService service = TransactionService();
  final ScrollController _scrollController = ScrollController();
  final String userId = Supabase.instance.client.auth.currentUser!.id;

  Map<String, GroupParticipantSummaryModel> _participantsSummary = {};
  List<GroupTransactionModel> _groupTransactions = [];
  GroupModel? _groupDetails;

  int _currentPage = 0;

  final int _pageSize = 50;
  bool _isComputingUsersSummary = true;
  bool _isLoadingContent = false;
  bool _isLoadingPage = false;
  bool _hasMore = true;
  String _searchText = '';
  String _groupName = '-';
  String? _errorMessage;
  int _groupParticipantsCnt = 0;
  int _groupTransactionsBalanceCnt = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _loadData(reset: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  double _computeBalance() {
    double res = _groupTransactions.fold<double>(0, (sum, e) {
      final amount = e.totalAmount;
      final type = e.transactionType;
      return type == TransactionTypeEnum.INCOME ? sum + amount : sum - amount;
    });
    return double.parse(res.toStringAsFixed(2));
  }

  int _computeBalanceTransactionsCount() {
    int count = 0;
    for (var summary in _participantsSummary.values) {
      count += summary.balanceMovements.length;
    }
    return count;
  }

  void _filterTransactions({bool reset = false}) async {
    // TODO: d_participantsSummarya implementare filtro spese
  }

  void _filterTimeTransactions({required TimeFilterEnum filter}) async {
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

  void _handleUsersSummary() { // TODO: capire come chiamarla all'avvio, dopo che le chiamate transactions e group details hanno caricato i dati necessari
    setState(() {
      _isComputingUsersSummary = true;
    });

    _participantsSummary = GroupTransactionsUtil.computeParticipantsSummary(transactions: _groupTransactions, participants: _groupDetails?.participants ?? []);

    setState(() {
      _participantsSummary = Map<String, GroupParticipantSummaryModel>.from(_participantsSummary);
      _isComputingUsersSummary = false;
    });
  }

  void _loadData({bool reset = false}) async {
    if (_isLoadingPage || _isLoadingContent) return;
    if (mounted) {
      setState(() {
        _errorMessage = null;
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
      _groupTransactions.clear();
    }

    try {
      final groupDetails = await service.fetchGroup(groupId: widget.groupId, pageIndex: _currentPage, pageSize: _pageSize);

      if (mounted) {
        setState(() {
          if (reset) {
            _groupTransactions = groupDetails.transactions;

            _groupName = (groupDetails.name.isNotEmpty) ? groupDetails.name : '-';
            _isLoadingPage = false;
          } 
          else {
            _groupTransactions.addAll(groupDetails.transactions);
            _isLoadingContent = false;
          }
          _handleUsersSummary();
          _groupParticipantsCnt = groupDetails.participants.length;
          _groupTransactionsBalanceCnt = _computeBalanceTransactionsCount();
          
          log.fine('reset: $reset, _groupParticipantsCnt: $_groupParticipantsCnt, _groupTransactionsBalanceCnt: $_groupTransactionsBalanceCnt');
          _hasMore = groupDetails.transactions.length == _pageSize;            
          if (_hasMore) {
            _currentPage++;
          }
        });
      }
    } 
    catch (e) {
      log.severe('Error loading group transactions data: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Errore durante il caricamento dei dati';
          _isLoadingPage = false;
          _isLoadingContent = false;
        });
      }
    }
  }

  void _navigateToGroupTransactionsPage({required String groupId, required bool isEditAllowed}) async {
    var page = TransactionGroupPage(groupId: groupId, isEditAllowed: isEditAllowed);

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    )
    .then((result) {
      if (result == true) {
        _loadData(reset: true);
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingPage || !_hasMore) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll) {
      _loadData();
    }
  }

  void _openPage(StatefulWidget widget) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => widget),
    );
  }

  void _openSummaryDetailsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogTransactionsDetailsWidget(
          title: 'Riepilogo partecipanti',
          participantsSummary: _participantsSummary,
        );
      },
    );
  }

  void _openSummaryTransactionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogTransactionsBalanceWidget(
          title: 'Riepilogo saldo',
          participantsSummary: _participantsSummary,
        );
      },
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
              icon: CustomIconWidget(assetPath: 'assets/images/icons/settings-filled.PNG'),
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
                      child: SelectableText(
                          'Totale spese (${_groupTransactions.length}): ${_computeBalance()}€',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                    ),
                    const SizedBox(width: 5),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Aggiorna',
                      onPressed: () => _loadData(reset: true),
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      tooltip: 'Filtra',
                      onPressed: () => _filterTransactions(reset: true),
                    ),
                  ],
                ),
                
                // Alert errore
                if (_errorMessage != null) ...[
                  ErrorAlertWidget(errorMessage: _errorMessage!),
                ]
                else ...[
                  // TODO: NOT USED FOR NOW, DA IMPLEMENTARE FILTRO PER DATA
                  // Page Header "subtitle"
                  // const SizedBox(height: 4),
                  // TimeFilterWidget(
                  //   timeFilters: [ TimeFilterEnum.ONE_DAY, TimeFilterEnum.ONE_WEEK, TimeFilterEnum.ONE_MONTH, TimeFilterEnum.ONE_YEAR ],
                  //   onPressed: (filter) => _filterTimeTransactions(filter: filter),
                  // ),

                  // How much user owes or is owed
                  // v2:                  
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CustomButtonWidget(
                          text: "Utenti: $_groupParticipantsCnt", 
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          iconData: Icons.trending_up, 
                          onPressed: _openSummaryDetailsDialog
                        )
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomButtonWidget(
                          text: "Da saldare: $_groupTransactionsBalanceCnt", 
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          iconData: Icons.monetization_on_outlined, 
                          onPressed: _openSummaryTransactionDialog
                        )
                      ),
                    ],
                  ),

                  // v1: 
                  // const SizedBox(height: 4),
                  // Card(
                  //   shape: RoundedRectangleBorder(
                  //     side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: ExpansionTile(
                  //     title: Text("Riepilogo utenti (${_groupDetails?.participants.length ?? 0})", style: const TextStyle(fontWeight: FontWeight.w500)),
                  //     children: [
                  //       SizedBox(
                  //         height: 100,
                  //         child: _isComputingUsersSummary
                  //           ? const LoadingScaffold(message: 'Caricamento dettagli...')
                  //           : _participantsSummary.isEmpty
                  //             ? const Center(child: Text('Nessun utente presente'))
                  //             : SingleChildScrollView(
                  //                 scrollDirection: Axis.horizontal,
                  //                 child: SingleChildScrollView(
                  //                   scrollDirection: Axis.vertical,
                  //                   child: DataTable(
                  //                     columns: [
                  //                       DataColumn(label: Text('Nome')),
                  //                       DataColumn(label: Text('Versati')),
                  //                       DataColumn(label: Text('Spesi')),
                  //                       DataColumn(label: Text('Da Incassare (lordi)')),
                  //                       DataColumn(label: Text('Da Incassare (netti)')),
                  //                       DataColumn(label: Text('Azioni')),
                  //                     ],
                  //                     rows: _participantsSummary.values.map((e) => DataRow(cells: [
                  //                       DataCell(Text(e.profile.name)),
                  //                       DataCell(Text(e.paidAmountGroup.toStringAsFixed(2))),
                  //                       DataCell(Text(e.paidAmountItself.toStringAsFixed(2))),
                  //                       DataCell(Text(e.toReceiveGross.toStringAsFixed(2))),
                  //                       DataCell(Text(e.toReceiveNet.toStringAsFixed(2))),
                  //                       DataCell(
                  //                         IconButton(
                  //                           icon: const Icon(Icons.info_outline),
                  //                           tooltip: 'Dettagli',
                  //                           onPressed: () => _openSummaryDialog(),
                  //                         ),
                  //                       ),
                  //                     ])).toList(),
                  //                   ),
                  //                 ),
                  //               )
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  
                  // Page Content
                  Expanded(
                    child: _isLoadingContent
                      ? const LoadingScaffold(message: 'Caricamento spese...')
                      : _groupTransactions.isEmpty
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
                                itemCount: _groupTransactions.length + (_isLoadingContent ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index >= _groupTransactions.length) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      child: Center(child: Text('Carico altre spese...')),
                                    );
                                  }
                                  final e = _groupTransactions[index];
                                  final formattedDateTime = _formatDateTime(e.updatedAt.toString());
                                  final totalAmount = e.totalAmount;
                                  final merchant = e.merchant;
                                  final category = e.category;

                                  return TransactionCardWidget(
                                    isGroupTransaction: true,
                                    merchantName: merchant?.name,
                                    categoryName: category?.name,
                                    formattedDateTime: formattedDateTime,
                                    totalAmount: totalAmount,
                                    transactionType: e.transactionType,
                                    note: e.note,
                                    profileModel: e.profileModel,
                                    paidAmount: e.paidAmount,
                                    splitRate: e.splitRate,
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
                          icon: Image.asset('assets/images/icons/add.png'),
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Colors.white,
                            shape: const CircleBorder(),
                          ),
                          onPressed: () async {
                            _navigateToGroupTransactionsPage(groupId: widget.groupId, isEditAllowed: true);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

    );
  }
}
