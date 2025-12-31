import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/expenses_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ExpensesService service = ExpensesService();

  late Stream<List<ExpenseModel>> expensesStream;
  List<Map<String, dynamic>> expenses = [];

  int currentPage = 0;
  int pageSize = 10;
  bool isLoading = false;
  bool hasMore = true;

  Future<void> loadExpenses() async {
    print("Loading expenses for page $currentPage");
    // Not working correctly if (isLoading || !hasMore) return;

    setState(() => isLoading = true);
    final newItems = await service.fetchLatestExpenses(pageIndex: currentPage, pageSize: pageSize);
    print("Fetched ${newItems.length} new expenses");

    setState(() {
      expenses = newItems;
      isLoading = false;
      if (newItems.length < pageSize) {
        hasMore = false;
      }
    });
  }

  Future<void> loadMoreExpenses() async {
    currentPage++;
    return loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spese Caricate: ${expenses.length}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: loadExpenses,
                  child: const Text('Load expenses'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Totale spese: €${expenses.fold<double>(0, (sum, e) => sum + (double.tryParse(e['total_amount']?.toString() ?? '0') ?? 0)).toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: 
                expenses.isEmpty ? const Center(child: Text('Nessuna spesa caricata')) : ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final e = expenses[index];
                    return Card(
                      child: ListTile(
                        title: Text(e['title']?.toString() ?? ''),
                        subtitle: Text(
                          '${e['merchants']?['name'] ?? '-'} · ${e['categories']?['name'] ?? '-'}'
                        ),
                        trailing: Text('€${e['total_amount']?.toString() ?? '-'}'),
                      ),
                    );
                  },
                ),
            ),
          ],
        ),
      ),
    );
  }
}
