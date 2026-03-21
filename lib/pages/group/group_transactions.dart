
import 'package:Billy/constants.dart';
import 'package:Billy/enums/transaction_type_enum.dart';
import 'package:Billy/models/group_details_model.dart';
import 'package:Billy/pages/group/components/transactions_balance_bottom_sheet_widget.dart';
import 'package:Billy/pages/group/components/transactions_details_bottom_sheet_widget.dart';
import 'package:Billy/widgets/components/custom_button_widget.dart';
import 'package:Billy/widgets/components/group_transaction_card_widget.dart';
import 'package:Billy/widgets/components/time_filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:Billy/enums/time_filter_enum.dart';
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
  late GroupDetailsModel _groupDetails;

  bool _isLoadingContent = false;
  bool _isLoadingPage = false;
  bool _showFilters = false;
  String _searchText = '';
  String _groupName = '-';
  String? _errorMessage;
  int _groupParticipantsCnt = 0;
  int _groupTransactionsBalanceCnt = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    setState(() {
      _isLoadingPage = false;
      _showFilters = false;
    });

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

  void _filterTransactions({bool reset = false}) {
    setState(() {
      _showFilters = !_showFilters;
    });
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
    _participantsSummary = GroupTransactionsUtil.computeParticipantsSummary(transactions: _groupTransactions, participants: _groupDetails.participants);

    setState(() {
      _participantsSummary = Map<String, GroupParticipantSummaryModel>.from(_participantsSummary);
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
      _groupTransactions.clear();
    }

    try {
      _groupDetails = await service.fetchGroup(groupId: widget.groupId);

      if (mounted) {
        setState(() {
          if (reset) {
            _groupTransactions = _groupDetails.transactions;

            _groupName = (_groupDetails.name.isNotEmpty) ? _groupDetails.name : '-';
            _isLoadingPage = false;
          } 
          else {
            _groupTransactions.addAll(_groupDetails.transactions);
            _isLoadingContent = false;
          }
          _handleUsersSummary();
          _groupParticipantsCnt = _groupDetails.participants.length;
          _groupTransactionsBalanceCnt = _computeBalanceTransactionsCount();
          
          log.fine('reset: $reset, _groupParticipantsCnt: $_groupParticipantsCnt, _groupTransactionsBalanceCnt: $_groupTransactionsBalanceCnt');
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
    if (!_scrollController.hasClients || _isLoadingPage) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll) {
      _loadData();
    }
  }

  void _openPage(StatefulWidget widget) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => widget),
    ).then((result) {
      log.fine('Result from page: $result');
      if (result?['deleteGroupId'] != null) {
        Navigator.of(context).pop(result);
      }
    });
  }

  void _openSummaryDetailsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // obbligatorio per DraggableScrollableSheet
      backgroundColor: Colors.transparent, // lascia gestire il colore al sheet
      builder: (BuildContext context) => TransactionsDetailsBottomSheetWidget(
        title: 'Riepilogo partecipanti',
        participantsSummary: _participantsSummary,
      ),
    );
  }

  void _openSummaryTransactionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // obbligatorio per DraggableScrollableSheet
      backgroundColor: Colors.transparent, // lascia gestire il colore al sheet
      builder: (BuildContext context) => TransactionsBalanceBottomSheetWidget(
        title: 'Riepilogo saldo',
        participantsSummary: _participantsSummary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(),
      body: _isLoadingPage
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [LoadingScaffold(message: 'Caricamento dati gruppo...')],
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.rowHorizontalPadding),
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
                
                _animatedTimeFilters(),

                // Alert errore
                if (_errorMessage != null) ...[
                  ErrorAlertWidget(errorMessage: _errorMessage!),
                ]
                else ...[
                  // How much user owes or is owed
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CustomButtonWidget(
                          text: "Utenti: $_groupParticipantsCnt", 
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          iconData: Icons.trending_up, 
                          onPressed: _openSummaryDetailsBottomSheet
                        )
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomButtonWidget(
                          text: "Da saldare: $_groupTransactionsBalanceCnt", 
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          iconData: Icons.monetization_on_outlined, 
                          onPressed: _openSummaryTransactionBottomSheet
                        )
                      ),
                    ],
                  ),
                  
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

                                  return GroupTransactionCardWidget(
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

  Widget _animatedTimeFilters() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          axis: Axis.vertical,
          child: child,
        ),
      ),
      child: _showFilters
        ? Container(
            key: const ValueKey('filters'),
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.zeroPadding, vertical: AppConstants.rowVerticalPadding),
            child: TimeFilterWidget(
              timeFilters: [
                TimeFilterEnum.ONE_DAY,
                TimeFilterEnum.ONE_WEEK,
                TimeFilterEnum.ONE_MONTH,
                TimeFilterEnum.ONE_YEAR
              ],
              onPressed: (filter) => _filterTimeTransactions(filter: filter),
            ),
          )
        : const SizedBox.shrink(key: ValueKey('nofilters')),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Spese: $_groupName'),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 8),
      actions: [
        IconButton(
          icon: CustomIconWidget(assetPath: 'assets/images/icons/settings-filled.PNG'),
          tooltip: 'Impostazioni Gruppo',
          onPressed: () => _openPage(GroupDetailsPage(groupId: widget.groupId, isEditAllowed: widget.isEditAllowed)),
        ),
      ],
    );
  }
}
