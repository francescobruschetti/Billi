import 'package:Billy/constants.dart';
import 'package:Billy/enums/time_filter_enum.dart';
import 'package:Billy/enums/transaction_type_enum.dart';
import 'package:Billy/extentions/datetime_extention.dart';
import 'package:Billy/extentions/timefilter_start_end_extention.dart';
import 'package:Billy/models/balance_details_model.dart';
import 'package:Billy/models/category_model.dart';
import 'package:Billy/models/merchant_model.dart';
import 'package:Billy/models/personal_transactions/personal_transaction_model.dart';
import 'package:Billy/pages/prove/logs_prove_page.dart';
import 'package:Billy/pages/transaction/components/segment_control_page.dart';
import 'package:Billy/pages/transaction/transaction_page.dart';
import 'package:Billy/providers/transaction_provider.dart';
import 'package:Billy/services/transaction_service.dart';
import 'package:Billy/utils/generic_util.dart';
import 'package:Billy/widgets/components/balance_bar_widget.dart';
import 'package:Billy/widgets/components/custom_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:Billy/widgets/components/custom_button_widget.dart';
import 'package:Billy/widgets/components/transaction_card_widget.dart';
import 'package:Billy/widgets/components/error_with_retry_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState 
  extends ConsumerState<HomePage>
  with WidgetsBindingObserver // *Added to listen to app lifecycle events (e.g., to refresh data when the app is resumed)*
{
  final Logger log = Logger('HomePage');
  final TransactionService service = TransactionService();
  final ScrollController _scrollController = ScrollController();
  final List<TimeFilterEnum> _timeFilters = ([
    TimeFilterEnum.ONE_DAY,
    TimeFilterEnum.CURRENT_WEEK,
    TimeFilterEnum.CURRENT_MONTH,
    TimeFilterEnum.CURRENT_YEAR,
  ]);

  late BalanceDetailsModel _balanceDetails;
  late DateTime _lastRefreshTime = DateTime.now();

  final int _autoRefreshThresholdMinutes = 5; // Tempo dopo il quale forzare un refresh dei dati al ritorno in foreground
  int _selectedTimeFilterIndex = 2; // default: CURRENT_MONTH

  bool _isLoading = false;
  bool _hasMore = false;
  bool _showFilters = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addObserver(this); // registra observer

    setState(() {
      _isLoading = false;
      _hasMore = false;
      _showFilters = false;
    });

    // Carica i primi N elementi all'avvio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(transactionProvider);
      if (state is AsyncLoading) {
        _applyTimeFilter(_selectedTimeFilterIndex);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // rimuovi observer
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      LogsProvePage.insertLog('App tornata in foreground. Ultimo refresh: ${_lastRefreshTime.toIso8601String()}');
      
      // App tornata in foreground → refresh if last refresh was more than _autoRefreshThresholdMinutes mins ago
      if (DateTime.now().difference(_lastRefreshTime) > Duration(minutes: _autoRefreshThresholdMinutes)) {
        LogsProvePage.insertLog('App tornata in foreground. Forzo refresh dati perché l\'ultimo refresh risale a più di $_autoRefreshThresholdMinutes minuti fa.');
        _refreshTransactions();
      }
    }
  }

  void _applyTimeFilter(int index) {
    setState(() => _selectedTimeFilterIndex = index);
    _loadDataWithCurrentFilter();
  }
  
  Function()? _filterTransactions(TransactionTypeEnum expense) {
    return () {
      ref.read(transactionProvider.notifier).filterTransactionsType(expense);
    };
  }

  void _loadDataWithCurrentFilter({bool reset = true}) {
    final TimeFilterEnum timeFilterEnum = _timeFilters[_selectedTimeFilterIndex]; 
    final (dateStart, dateEnd) = timeFilterEnum.dateRange;
    
    ref.read(transactionProvider.notifier).refresh(
      dateStart: dateStart,
      dateEnd: dateEnd,
    );
  }

  void _navigateToTransactionPage({required TransactionTypeEnum transactionType, required bool isEditAllowed}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TransactionPage(isEditAllowed: isEditAllowed, transactionType: transactionType)),
    )
    .then((result) {
      if (result == true) {
        _refreshTransactions();
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoading) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Carica altri elementi quando si arriva in fondo
    if (currentScroll >= maxScroll - 50) {
      setState(() {
        _hasMore = true;
      });
      ref.read(transactionProvider.notifier).loadMore().then( (_) {
        setState(() {
          _hasMore = false;
        });
      });
    }
  }

  Future<void> _refreshTransactions() async {
    await ref.read(transactionProvider.notifier).refresh();
    _lastRefreshTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {  
    final transactionsState = ref.watch(transactionProvider);

    return Scaffold(
      // debug UI: backgroundColor: Colors.orange,
      body: transactionsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorWithRetryWidget(
          onRetry: _refreshTransactions,
        ),
        data: (transactions) {
          // Aggiorna il balance ogni volta che cambia la lista transazioni
          _balanceDetails = BalanceDetailsModel(
            totalBalance: ref.read(transactionProvider.notifier).totals?.balance ?? 0,
            totalExpenses: ref.read(transactionProvider.notifier).totals?.totalExpenses ?? 0,
            totalIncomes: ref.read(transactionProvider.notifier).totals?.totalIncomes ?? 0,
          );
          
          return Column(
            children: [
              // Page Header
              _pageHeader(transactions),

              _pageHeaderSubtitle(transactions),  

              // Page Header "subtitle"
              _buildTimeFilters(),
              
              // Page Content
              _buildList(transactions),

              // Page footer
              const SizedBox(height: AppConstants.rowVerticalPadding),
              _footer(),
            ],
          );
        }
      ),
    );
  }

  Widget _buildList(List<PersonalTransactionModel> transactions) {
    return Expanded(
      child: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : transactions.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Nessuna transazione trovata', 
                    style: TextStyle(fontSize: AppConstants.textSize)
                  ),
                  SizedBox(height: AppConstants.sizedBoxHeight),
                  IntrinsicWidth( // Note Docs: Force button to take only the necessary width
                    child: CustomButtonWidget(
                      onPressed: _refreshTransactions, // Note Docs: non esegue direttamente _refreshTransactions() per evitare di chiamare la funzione al momento della build. Use () { _refreshTransactions(param1, param2); } or pass the function reference without parentheses.
                      text: 'Ricarica',
                      iconData: Icons.refresh,
                    ),
                  )
                ]
              ),
            )
          : NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollEndNotification) {
                  _onScroll();
                }
                return false;
              },
              child: RefreshIndicator( // Pull from top to refresh
                onRefresh: _refreshTransactions,
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: transactions.length + 1, // +1 per il loader in fondo
                  itemBuilder: (context, index) {
                    if (index < transactions.length) {
                      return _buildTransactionTile(transactions[index]);
                    }

                    // Mostra il loader in fondo se stiamo caricando più elementi
                    return Card(
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_hasMore) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: CircularProgressIndicator(),
                            ),
                          ]
                        ],
                      ),
                    );
                  }
                ),
              ),
            ),
    );
  }

  Widget _buildTimeFilters() {
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: SegmentedControl(
              selectedIndex: _selectedTimeFilterIndex,
              onChanged: (index) => _applyTimeFilter(index),
              segments: _timeFilters.map((filter) => filter.shortValue).toList(),
            ),
          )
        : const SizedBox.shrink(key: ValueKey('nofilters')),
    );
  }

  Widget _buildTransactionTile(PersonalTransactionModel transaction) {
    final String formattedDateTime = transaction.updatedAt.toDateTimeStr();
    final double totalAmount = transaction.totalAmount;
    final MerchantModel? merchant = transaction.merchant;
    final CategoryModel? category = transaction.category;
    
    return TransactionCardWidget(
      merchantName: merchant?.name,
      categoryName: category?.name,
      formattedDateTime: formattedDateTime,
      totalAmount: totalAmount,
      transactionType: transaction.transactionType,
      note: transaction.note,
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
                _navigateToTransactionPage(transactionType: TransactionTypeEnum.EXPENSE, isEditAllowed: true);
              },
              text: 'Uscite',
              customIcon: CustomIconWidget(assetPath: 'assets/images/icons/outward.PNG', size: 24, color: Theme.of(context).colorScheme.onPrimaryContainer),
              backgroundColor: AppConstants.defaultExpenseColor,
            ),
          ),
          const SizedBox(width: AppConstants.mediumSizedBoxWidth),
          Expanded(
            child: 
              CustomButtonWidget(
                onPressed: () async {
                  _navigateToTransactionPage(transactionType: TransactionTypeEnum.INCOME, isEditAllowed: true);
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

  Widget _pageHeader(List<PersonalTransactionModel> transactions) {
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
                Text('Bilancio (${_timeFilters[_selectedTimeFilterIndex].shortValue})', style: TextStyle(fontSize: AppConstants.textSize)),
                const SizedBox(width: AppConstants.mediumSizedBoxWidth),
                SelectableText(
                  '${_balanceDetails.totalBalance}€',
                  style: TextStyle(fontSize: AppConstants.titleTextSize),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppConstants.mediumSizedBoxWidth),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Filtra per periodo',
            onPressed: () => setState(() => _showFilters = !_showFilters),
            color: _showFilters ? Theme.of(context).colorScheme.secondary : null,
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart),
            tooltip: 'Statistiche',
            onPressed: () => GenericUtil.showSnackbar(context, 'Funzione non ancora implementata'), // TODO: implementare pagina statistiche
          ),
        ],
      ),
    );
  }

  Widget _pageHeaderSubtitle(List<PersonalTransactionModel> transactions) {
    return Container(
      // debug UI: color: Colors.red,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.zeroPadding, vertical: AppConstants.rowVerticalPadding),
      child: BalanceBarWidget(
        totalBalance: _balanceDetails.totalBalance, 
        totalExpenses: _balanceDetails.totalExpenses, 
        totalIncomes: _balanceDetails.totalIncomes,
        onExpenseParentCallback: _filterTransactions(TransactionTypeEnum.EXPENSE), 
        onIncomeParentCallback: _filterTransactions(TransactionTypeEnum.INCOME),
      )
    );
  }
}
