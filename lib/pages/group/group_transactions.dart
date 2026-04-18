
import 'package:Billy/constants.dart';
import 'package:Billy/enums/time_filter_enum.dart';
import 'package:Billy/enums/transaction_type_enum.dart';
import 'package:Billy/models/group_details_model.dart';
import 'package:Billy/pages/group/components/transactions_balance_bottom_sheet_widget.dart';
import 'package:Billy/pages/group/components/transactions_details_bottom_sheet_widget.dart';
import 'package:Billy/widgets/components/custom_button_widget.dart';
import 'package:Billy/widgets/components/time_filter_widget.dart';
import 'package:Billy/widgets/components/transaction_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:Billy/enums/theme_enum.dart';
import 'package:Billy/models/group_transaction_model.dart';
import 'package:Billy/models/group_participant_summary_model.dart';
import 'package:Billy/pages/transaction/transaction_group_page.dart';
import 'package:Billy/pages/group/group_details.dart';
import 'package:Billy/services/transaction_service.dart';
import 'package:Billy/utils/group_transactions_util.dart';
import 'package:Billy/widgets/components/custom_icon_widget.dart';
import 'package:Billy/widgets/components/error_alert_widget.dart';
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
  bool _showSearchBar = false;
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
      _showSearchBar = false;
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

  void _filterTransactions() {
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

  Future<void> _loadData({bool reset = false}) async {
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

  void _navigateToGroupTransactionPage({required String groupId, required TransactionTypeEnum transactionType, required bool isEditAllowed}) async {
    var page = TransactionGroupPage(groupId: groupId, transactionType: transactionType, isEditAllowed: isEditAllowed);

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
      if (result?['deleteGroupId'] != null && mounted) {
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
        title: 'Compensa saldo',
        participantsSummary: _participantsSummary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      // UI AppBar: v1: 
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
                _pageHeader(),

                _animatedTimeFilters(),

                // Alert errore
                if (_errorMessage != null) ...[
                  ErrorAlertWidget(errorMessage: _errorMessage!, onClose: () {
                    setState(() {
                      _errorMessage = null;
                    });
                  }),
                ]
                else ...[
                  // --- How much user owes or is owed
                  const SizedBox(height: 2),
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
                  
                  // -- Azioni di ordinamento e filtro
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.sort_by_alpha),
                        tooltip: 'Ordina',
                        onPressed: () {
                          // TODO: implement sort action
                        },
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.calendar_month_rounded),
                        tooltip: 'Calendario',
                        onPressed: () {
                          // TODO: implement calendar action
                        },
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
                            child: RefreshIndicator( // Pull from top to refresh
                              onRefresh: () => _loadData(reset: true),
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
                                      formattedDateTime: formattedDateTime,
                                      totalAmount: totalAmount,
                                      transactionType: e.transactionType,
                                      categoryName: category?.name,
                                      groupId: widget.groupId,
                                      merchantName: merchant?.name,
                                      note: e.note,
                                      splitRate: e.splitRate,
                                      paidAmount: e.paidAmount,
                                      profileModel: e.profileModel,
                                    );
                                  },
                                ),
                              ),
                            ),
                  ),
                ],
              
                _footer(),
              ],
            ),
          ),
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
            SearchFieldWidget( // TODO: da implementare
              hintText: 'Cerca spesa...',
              icon: Icons.search,
              onChanged: (value) => setState(() => _searchText = value), // Nota: quando SearchFieldWidget._onClose().widget.onChanged('') viene chiamato, _searchText viene resettato a ''
              onClose: () => setState(() { // Aggiunto per sicurezza
                _searchText = '';
                _showSearchBar = false;
              }),
            )
          // debug: )
        : Text('Spese: $_groupName'),
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

  // UI AppBar: v1:
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: _animatedSearchBar(),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 8),
      actions: [
        if (!_showSearchBar) ...[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Cerca',
            onPressed: () => {
              setState(() => _showSearchBar = !_showSearchBar),
            },
          ),
          // IconButton( // TODO: valutare se mantenere o spostare nei filtri
          //   icon: const Icon(Icons.refresh),
          //   tooltip: 'Aggiorna',
          //   onPressed: () => _loadData(reset: true),
          // ),
          // IconButton( // TODO: valutare se mantenere o spostare nei filtri
          //   icon: const Icon(Icons.filter_list),
          //   tooltip: 'Filtra',
          //   onPressed: () => _filterTransactions(reset: true),
          // ),
          IconButton(
            icon: CustomIconWidget(assetPath: 'assets/images/icons/settings.PNG', size: 24),
            tooltip: 'Impostazioni Gruppo',
            onPressed: () => _openPage(GroupDetailsPage(groupId: widget.groupId, isEditAllowed: widget.isEditAllowed)),
          ),
        ],
      ],
    );
  }

  Widget _footer() {
    return Container(
      // debug UI: color: Colors.red,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.rowHorizontalPadding, vertical: AppConstants.rowVerticalPadding),
      child: Row(
        children: [
          Expanded(
            child: CustomButtonWidget(
                onPressed: () async {
                _navigateToGroupTransactionPage(groupId: widget.groupId, transactionType: TransactionTypeEnum.EXPENSE, isEditAllowed: true);
              },
              text: 'Uscite',
              customIcon: CustomIconWidget(assetPath: 'assets/images/icons/outward.PNG', size: 24, color: Theme.of(context).colorScheme.onSecondary),
              backgroundColor: AppConstants.defaultExpenseColor,
            ),
          ),
          const SizedBox(width: AppConstants.sizedBoxWidth),
          Expanded(
            child: 
              CustomButtonWidget(
                onPressed: () async {
                  _navigateToGroupTransactionPage(groupId: widget.groupId, transactionType: TransactionTypeEnum.INCOME, isEditAllowed: true);
                },
                text: 'Entrate',
                iconData: Icons.login,
                backgroundColor: AppConstants.defaultIncomeColor,
              ),
          ),
        ],
      ),
    );
  }

  // UI AppBar: v1:
  Widget _pageHeader() {
    return Container(
      // debug UI: color: Colors.green,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.rowHorizontalPadding, vertical: AppConstants.zeroPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bilancio', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 8),
                SelectableText(
                  '${_computeBalance()}€',
                  style: TextStyle(fontSize: 30),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // UI AppBar: v2:
  // Widget _pageHeader() {
  //   return Container(
  //     // debug UI: color: Colors.green,
  //     padding: const EdgeInsets.symmetric(horizontal: AppConstants.rowHorizontalPadding, vertical: AppConstants.zeroPadding),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         // -- Back button
  //         IconButton(
  //           icon: const Icon(Icons.arrow_back),
  //           tooltip: 'Indietro',
  //           onPressed: () => Navigator.of(context).pop(),
  //         ),

  //         // -- Title + Balance
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text('Bilancio: $_groupName', style: TextStyle(fontSize: 16)),
  //               const SizedBox(width: 8),
  //               SelectableText(
  //                 '${_computeBalance()} €',
  //                 style: TextStyle(fontSize: 28),
  //               ),
  //             ],
  //           ),
  //         ),

  //         // -- Search bar
  //         _animatedSearchBar(),

  //         // -- Actions
  //         if (!_showSearchBar) ...[
  //           IconButton(
  //             icon: const Icon(Icons.search),
  //             tooltip: 'Cerca',
  //             onPressed: () => {
  //               setState(() => _showSearchBar = !_showSearchBar),
  //             },
  //           ),
  //           // IconButton( // TODO: valutare se mantenere o spostare nei filtri
  //           //   icon: const Icon(Icons.refresh),
  //           //   tooltip: 'Aggiorna',
  //           //   onPressed: () => _loadData(reset: true),
  //           // ),
  //           // IconButton( // TODO: valutare se mantenere o spostare nei filtri
  //           //   icon: const Icon(Icons.filter_list),
  //           //   tooltip: 'Filtra',
  //           //   onPressed: () => _filterTransactions(reset: true),
  //           // ),
  //           IconButton(
  //             icon: CustomIconWidget(assetPath: 'assets/images/icons/settings.PNG', size: 24),
  //             tooltip: 'Impostazioni Gruppo',
  //             onPressed: () => _openPage(GroupDetailsPage(groupId: widget.groupId, isEditAllowed: widget.isEditAllowed)),
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }
}
