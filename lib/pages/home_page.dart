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
  final List<Map<String, dynamic>> expenses = [];

  int currentPage = 0;
  int pageSize = 10;
  bool isLoading = false;
  bool hasMore = true;

  Future<void> loadExpenses() async {
    print("Loading expenses: $isLoading");
    // if (isLoading || !hasMore) return;

    setState(() => isLoading = true);

    final newItems = await service.fetchLatestExpenses(pageSize: pageSize, pageIndex: currentPage);

    setState(() {
      currentPage++;
      expenses.addAll(newItems);
      isLoading = false;
      if (newItems.length < pageSize) {
        hasMore = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            ElevatedButton(
              onPressed: loadExpenses,
              child: const Text('Load expenses'),
            ),
          ],
        ),
      ),
    );
  }
}
