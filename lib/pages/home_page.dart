import 'package:Billy/constants.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:Billy/enums/time_filter_enum.dart';
import 'package:Billy/pages/expense/expense_group_page.dart';
import 'package:Billy/pages/expense/expense_page.dart';
import 'package:Billy/widgets/components/custom_button_widget.dart';
import 'package:Billy/widgets/components/expense_card_widget.dart';
import 'package:Billy/widgets/components/loading_scaffold.dart';
import 'package:Billy/widgets/components/time_filter_widget.dart';
import '../services/expenses_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Logger log = Logger('HomePage');
  final ExpensesService service = ExpensesService();
  final ScrollController _scrollController = ScrollController();

  late Future<List<Map<String, dynamic>>> expensesFuture;
  List<Map<String, dynamic>> allExpenses = [];

  int _currentPage = 0;
  final int _pageSize = 50;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadExpenses(reset: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _filterExpenses({bool reset = false}) async {
    // TODO: da implementare filtro spese
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
    if (_isLoading) return;
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    if (reset) {
      _currentPage = 0;
      _hasMore = true;
      allExpenses.clear();
    }
    expensesFuture = service.fetchLatestPersonalExpenses(pageIndex: _currentPage, pageSize: _pageSize);
    final result = await expensesFuture;

    if (mounted) {
      setState(() {
        if (reset) {
          allExpenses = result;
        } 
        else {
          allExpenses.addAll(result);
        }
        _isLoading = false;
        _hasMore = result.length == _pageSize;
        if (_hasMore) _currentPage++;
      });
    }
  }

  void _navigateToExpensePage({required bool isPersonalExpense, required bool isEditAllowed}) async {
    var page = isPersonalExpense ? ExpensePage(isEditAllowed: isEditAllowed) : ExpenseGroupPage(isEditAllowed: isEditAllowed);

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
    if (!_scrollController.hasClients || _isLoading || !_hasMore) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll) {
      _loadExpenses();
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
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.zeroPadding, vertical: AppConstants.zeroPadding),
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                      'Totale spese (${allExpenses.length}): ${allExpenses.fold<double>(0, (sum, e) => sum + (double.tryParse(e['total_amount']?.toString() ?? '0') ?? 0)).toStringAsFixed(2)}€',
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
            ),

            // Page Header "subtitle"
            Container(
              // debug UI: color: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.zeroPadding, vertical: AppConstants.zeroPadding),
              child: TimeFilterWidget(
                timeFilters: [ TimeFilterEnum.ONE_DAY, TimeFilterEnum.ONE_WEEK, TimeFilterEnum.ONE_MONTH, TimeFilterEnum.ONE_YEAR ],
                onPressed: (filter) => _filterTimeExpenses(filter: filter),
              ),
            ),

            // Page Content
            Expanded(
              child:
                _isLoading 
                ? const LoadingScaffold(message: 'Caricamento spese...')
                : allExpenses.isEmpty
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
                          itemCount: allExpenses.length + (_isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= allExpenses.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(child: Text('Carico altre spese...')),
                              );
                            }
                            final e = allExpenses[index];
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
                            );
                          },
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
                    child: 
                      CustomButtonWidget(
                        onPressed: () async {
                          _navigateToExpensePage(isPersonalExpense: true, isEditAllowed: true);
                        },
                        text: 'Spesa Personale',
                        icon: Icons.add,
                      ),
                  ),
                  const SizedBox(width: AppConstants.sizedBoxWidth),
                  Expanded(
                    child: CustomButtonWidget(
                        onPressed: () async {
                        _navigateToExpensePage(isPersonalExpense: false, isEditAllowed: true);
                      },
                      text: 'Spesa Condivisa',
                      icon: Icons.group_add_outlined,
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
