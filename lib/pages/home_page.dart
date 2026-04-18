import 'package:Billy/constants.dart';
import 'package:Billy/enums/time_filter_enum.dart';
import 'package:Billy/enums/transaction_type_enum.dart';
import 'package:Billy/models/balance_details_model.dart';
import 'package:Billy/pages/transaction/transaction_page.dart';
import 'package:Billy/providers/transaction_provider.dart';
import 'package:Billy/utils/generic_util.dart';
import 'package:Billy/utils/group_transactions_util.dart';
import 'package:Billy/widgets/components/balance_bar_widget.dart';
import 'package:Billy/widgets/components/custom_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:Billy/enums/theme_enum.dart';
import 'package:Billy/widgets/components/custom_button_widget.dart';
import 'package:Billy/widgets/components/transaction_card_widget.dart';
import 'package:Billy/widgets/components/time_filter_widget.dart';
import '../services/transaction_service.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final Logger log = Logger('HomePage');
  final TransactionService service = TransactionService();
  final ScrollController _scrollController = ScrollController();
  late BalanceDetailsModel _balanceDetails = BalanceDetailsModel(totalBalance: 0, totalExpenses: 0, totalIncomes: 0);

  bool _isLoading = false;
  bool _hasMore = false;
  bool _showFilters = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    setState(() {
      _isLoading = false;
      _hasMore = false;
      _showFilters = false;
    });

    // Carica i primi N elementi all'avvio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(transactionProvider);
      if (state is AsyncLoading) {
        ref.read(transactionProvider.notifier).loadMore(reset: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
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

  void _navigateToTransactionPage({required TransactionTypeEnum transactionType, required bool isEditAllowed}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TransactionPage(isEditAllowed: isEditAllowed, transactionType: transactionType)),
    )
    .then((result) {
      if (result == true) {
        ref.read(transactionProvider.notifier).refresh();
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

  @override
  Widget build(BuildContext context) {  
    final transactionsState = ref.watch(transactionProvider);

    return Scaffold(
      // debug UI: backgroundColor: Colors.orange,
      body: transactionsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Errore durante il caricamento. Riprovare")),
        data: (transactions) {
          // Aggiorna il balance ogni volta che cambia la lista transazioni
          _balanceDetails = GroupTransactionsUtil.computeBalance(transactions);
          
          return Column(
              children: [
                // Page Header
                _pageHeader(transactions),

                _pageHeaderSubtitle(),  

                // Page Header "subtitle" animata
                _animatedTimeFilters(),

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

  Widget _buildList(List<Map<String, dynamic>> transactions) {
    if (transactions.isEmpty) {
      return const Center(child: Text('Nessuna spesa trovata'));
    }

    return Expanded(
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollEndNotification) {
            _onScroll();
          }
          return false;
        },
        child: RefreshIndicator( // Pull from top to refresh
          onRefresh: () => ref.read(transactionProvider.notifier).refresh(),
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

  Widget _buildTransactionTile(Map<String, dynamic> transactions) {
    final formattedDateTime = _formatDateTime(transactions['updated_at'] ?? '');
    final totalAmount = double.tryParse(transactions['total_amount']?.toString() ?? '0') ?? 0;
    final merchant = transactions['merchant'] ?? {};
    final category = transactions['category'] ?? {};
    
    return TransactionCardWidget(
      merchantName: merchant['name'],
      categoryName: category['name'],
      formattedDateTime: formattedDateTime,
      totalAmount: totalAmount,
      transactionType: TransactionTypeEnumExtension.fromValue(transactions['transaction_type']),
      note: transactions['note'],
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
              customIcon: CustomIconWidget(assetPath: 'assets/images/icons/outward.PNG', size: 24, color: Theme.of(context).colorScheme.onSecondary),
              backgroundColor: AppConstants.defaultExpenseColor,
            ),
          ),
          const SizedBox(width: AppConstants.sizedBoxWidth),
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

  Widget _pageHeader(List<Map<String, dynamic>> transactions) {
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
                  '${_balanceDetails.totalBalance}€',
                  style: TextStyle(fontSize: 30),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtra',
            onPressed: () => _filterTransactions(reset: true),
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

  Widget _pageHeaderSubtitle() {
    return Container(
      // debug UI: color: Colors.red,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.zeroPadding, vertical: AppConstants.rowVerticalPadding),
      child: BalanceBarWidget(totalBalance: _balanceDetails.totalBalance, totalExpenses: _balanceDetails.totalExpenses, totalIncomes: _balanceDetails.totalIncomes)
    );
  }
}
