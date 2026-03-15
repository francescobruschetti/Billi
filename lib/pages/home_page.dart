import 'package:Billy/constants.dart';
import 'package:Billy/enums/transaction_type_enum.dart';
import 'package:Billy/models/balance_details_model.dart';
import 'package:Billy/pages/transaction/transaction_page.dart';
import 'package:Billy/providers/transaction_provider.dart';
import 'package:Billy/utils/group_transactions_util.dart';
import 'package:Billy/widgets/components/balance_bar_widget.dart';
import 'package:Billy/widgets/components/custom_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:Billy/enums/time_filter_enum.dart';
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

  final int _currentPage = 0;
  final int _pageSize = 50;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    setState(() {
      _isLoading = false;
      _hasMore = true;
      _showFilters = false;
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
        // TODO: x: _loadTransactions(reset: true);
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoading || !_hasMore) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll) {
      // TODO: x: _loadTransactions();
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
                _buildPageContent(transactions),
                              
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

    return RefreshIndicator(
      onRefresh: () => ref.read(transactionProvider.notifier).refresh(), // TODO: x: _loadTransactions(reset: true),
      child: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) => _buildTransactionTile(transactions[index]),
      ),
    );
  }

  Widget _buildPageContent(List<Map<String, dynamic>> transactions) {
    return Expanded(
      child: 
        _buildList(transactions),
        /* TODO: x:_isLoading 
        ? const LoadingScaffold(message: 'Caricamento spese...')
        : transactions.isEmpty
          ? const Center(child: Text('Nessuna spesa presente'))
          : NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollEndNotification) {
                  _onScroll();
                }
                return false;
              },
              child: RefreshIndicator(
                onRefresh: () => ref.read(transactionProvider.notifier).refresh(), // TODO: x: _loadTransactions(reset: true),
                child: _buildList(transactions),
              ),
            ),
        */
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
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.zeroPadding, vertical: AppConstants.zeroPadding),
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
            child: SelectableText(
              'Saldo (${transactions.length}): ${_balanceDetails.totalBalance}€',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(width: 5),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Aggiorna',
            onPressed: () => ref.read(transactionProvider.notifier).refresh() // TODO: x: _loadTransactions(reset: true),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtra',
            onPressed: () => _filterTransactions(reset: true),
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
