import 'package:Billy/constants.dart';
import 'package:Billy/enums/transaction_type_enum.dart';
import 'package:Billy/pages/transaction/transaction_page.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:Billy/enums/time_filter_enum.dart';
import 'package:Billy/widgets/components/custom_button_widget.dart';
import 'package:Billy/widgets/components/transaction_card_widget.dart';
import 'package:Billy/widgets/components/loading_scaffold.dart';
import 'package:Billy/widgets/components/time_filter_widget.dart';
import '../services/transaction_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Logger log = Logger('HomePage');
  final TransactionService service = TransactionService();
  final ScrollController _scrollController = ScrollController();

  late Future<List<Map<String, dynamic>>> transactionsFuture;
  List<Map<String, dynamic>> allTransactions = [];

  int _currentPage = 0;
  final int _pageSize = 50;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadTransactions(reset: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  double _computeBalance() {
    double res = allTransactions.fold<double>(0, (sum, e) {
      final amount = double.tryParse(e['total_amount']?.toString() ?? '0') ?? 0;
      final type = TransactionTypeEnumExtension.fromValue(e['transaction_type']);
      return type == TransactionTypeEnum.INCOME ? sum + amount : sum - amount;
    });
    return double.parse(res.toStringAsFixed(2));
  }

  void _filterTransactions({bool reset = false}) async {
    // TODO: da implementare filtro spese
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

  Future<void> _loadTransactions({bool reset = false}) async {
    if (_isLoading) return;
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    if (reset) {
      _currentPage = 0;
      _hasMore = true;
      allTransactions.clear();
    }
    transactionsFuture = service.fetchLatestPersonalTransactions(pageIndex: _currentPage, pageSize: _pageSize);
    final result = await transactionsFuture;

    if (mounted) {
      setState(() {
        if (reset) {
          allTransactions = result;
        } 
        else {
          allTransactions.addAll(result);
        }
        _isLoading = false;
        _hasMore = result.length == _pageSize;
        if (_hasMore) _currentPage++;
      });
    }
  }

  void _navigateToTransactionPage({required TransactionTypeEnum transactionType, required bool isEditAllowed}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TransactionPage(isEditAllowed: isEditAllowed, transactionType: transactionType)),
    )
    .then((result) {
      if (result == true) {
        _loadTransactions(reset: true);
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoading || !_hasMore) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll) {
      _loadTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      // debug UI: backgroundColor: Colors.orange,
      body: Padding(
        padding: const EdgeInsets.only(top: AppConstants.rowVerticalPadding, left: AppConstants.rowHorizontalPadding, right: AppConstants.rowHorizontalPadding, bottom: AppConstants.rowVerticalPadding),
        child: Column(
          children: [
            // Page Header
            Container(
              // debug UI: color: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.rowHorizontalPadding, vertical: AppConstants.zeroPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SelectableText(
                        'Totale spese (${allTransactions.length}): ${_computeBalance()}€',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                  ),
                  const SizedBox(width: 5),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Aggiorna',
                    onPressed: () => _loadTransactions(reset: true),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    tooltip: 'Filtra',
                    onPressed: () => _filterTransactions(reset: true),
                  ),
                ],
              ),
            ),

            // Page Header "subtitle"
            Container(
              // debug UI: color: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.zeroPadding, vertical: AppConstants.rowVerticalPadding),
              child: TimeFilterWidget(
                timeFilters: [ TimeFilterEnum.ONE_DAY, TimeFilterEnum.ONE_WEEK, TimeFilterEnum.ONE_MONTH, TimeFilterEnum.ONE_YEAR ],
                onPressed: (filter) => _filterTimeTransactions(filter: filter),
              ),
            ),

            // Page Content
            Expanded(
              child:
                _isLoading 
                ? const LoadingScaffold(message: 'Caricamento spese...')
                : allTransactions.isEmpty
                  ? const Center(child: Text('Nessuna spesa presente'))
                  : NotificationListener<ScrollNotification>(
                      onNotification: (scrollNotification) {
                        if (scrollNotification is ScrollEndNotification) {
                          _onScroll();
                        }
                        return false;
                      },
                      child: RefreshIndicator(
                        onRefresh: () => _loadTransactions(reset: true),
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: allTransactions.length + (_isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= allTransactions.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(child: Text('Carico altre spese...')),
                              );
                            }
                            final e = allTransactions[index];
                            final formattedDateTime = _formatDateTime(e['updated_at'] ?? '');
                            final totalAmount = double.tryParse(e['total_amount']?.toString() ?? '0') ?? 0;
                            final merchant = e['merchant'] ?? {};
                            final category = e['category'] ?? {};

                            return TransactionCardWidget(
                              merchantName: merchant['name'],
                              categoryName: category['name'],
                              formattedDateTime: formattedDateTime,
                              totalAmount: totalAmount,
                              transactionType: TransactionTypeEnumExtension.fromValue(e['transaction_type']),
                              note: e['note'],
                            );
                          },
                        ),
                      ),
                    ),
            ),
          
            // Page footer
            const SizedBox(height: AppConstants.rowVerticalPadding),
            Container(
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
                      icon: Icons.logout,
                      backgroundColor: Colors.red[100],
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
                        icon: Icons.login,
                        backgroundColor: Colors.green[100],
                      ),
                  ),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }
}
