import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:monitoraggio_spese/pages/expense/expense_group_page.dart';
import 'package:monitoraggio_spese/pages/expense/expense_page.dart';
import 'package:monitoraggio_spese/widgets/components/loading_scaffold.dart';
import '../services/expenses_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Logger log = Logger('HomePage');
  final ExpensesService service = ExpensesService();

  late Future<List<Map<String, dynamic>>> expensesFuture;
  List<Map<String, dynamic>> allExpenses = [];

  int currentPage = 0;
  int pageSize = 50;
  bool isLoading = false;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();

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
    if (isLoading) return;
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    if (reset) {
      currentPage = 0;
      hasMore = true;
      allExpenses.clear();
    }
    expensesFuture = service.fetchLatestExpenses(pageIndex: currentPage, pageSize: pageSize);
    final result = await expensesFuture;

    if (mounted) {
      setState(() {
        if (reset) {
          allExpenses = result;
        } else {
          allExpenses.addAll(result);
        }
        isLoading = false;
        hasMore = result.length == pageSize;
        if (hasMore) currentPage++;
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
    if (!_scrollController.hasClients || isLoading || !hasMore) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 100) {
      _loadExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Page Header
            Row(
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
            // Page Header "subtitle"
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'TODO: aggiungere selezione periodo: oggi, questa settimana, questo mese, questo anno, personalizzato',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            
            // Page Content
            Expanded(
              child:
                isLoading 
                ? const LoadingScaffold(message: 'Caricamento spese...')
                : allExpenses.isEmpty
                  ? const Center(child: Text('Nessuna spesa presente'))
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: allExpenses.length + (isLoading ? 1 : 0),
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
                        final note = e['note']?.toString() ?? '';

                        return Card(
                          child: ExpansionTile(
                            title: Row(
                              children: [
                                const Icon(Icons.shopping_cart, size: 20, color: Colors.blueGrey),
                                const SizedBox(width: 6),
                                Text(merchant['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w500)),
                                const SizedBox(width: 6),
                                const Icon(Icons.category, size: 20, color: Colors.orange),
                                const SizedBox(width: 6),
                                Text(category['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w500)),
                              ],
                            ),
                            subtitle: Text(formattedDateTime, style: const TextStyle(fontSize: 12)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(width: 4),
                                Text('€${totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Icon(
                                  Icons.expand_more,
                                  color: Colors.grey.shade600,
                                ),
                              ],
                            ),
                            children: [
                              if (note.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(note),
                                )
                              else
                                const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text('Nessuna nota'),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          
            // Page footer
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      _navigateToExpensePage(isPersonalExpense: true, isEditAllowed: true);
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.add),
                        const SizedBox(width: 8),
                        const Text('Spesa Personale'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _navigateToExpensePage(isPersonalExpense: false, isEditAllowed: true);
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.group_add_outlined),
                        const SizedBox(width: 8),
                        const Text('Spesa Condivisa'),
                      ],
                    ),
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
