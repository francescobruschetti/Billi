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

  @override
  void initState() {
    super.initState();
    expensesStream = service.subscribeExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            StreamBuilder<List<ExpenseModel>>(
              stream: expensesStream,
              builder: (context, snapshot) {
                final expenses = snapshot.data ?? [];
                final total = expenses.fold<double>(
                  0,
                  (sum, e) => sum + e.amount,
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your expenses are: \$${total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),

            Expanded(
              child: StreamBuilder<List<ExpenseModel>>(
                stream: expensesStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final expenses = snapshot.data!;

                  return ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final e = expenses[index];
                      return Card(
                        child: ListTile(
                          title: Text(e.title),
                          subtitle:
                              Text('${e.merchant ?? ''} · ${e.category ?? ''}'),
                          trailing:
                              Text('\$${e.amount.toStringAsFixed(2)}'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      service.addExpense(
                        title: 'Test expense',
                        amount: 10,
                        merchantId: 'UUID_MERCHANT',
                        categoryId: 'UUID_CATEGORY',
                      );
                    },
                    child: const Text('Confirm'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Cancel'),
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
