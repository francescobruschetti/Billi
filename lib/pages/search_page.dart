import 'package:flutter/material.dart';
import 'package:monitoraggio_spese/models/expense_model.dart';
import 'package:monitoraggio_spese/services/expenses_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ExpensesService service = ExpensesService();
  late Stream<List<ExpenseModel>> expensesStream;
  
  @override
  void initState() {
    super.initState();
    expensesStream = service.subscribeExpenses();
    print("Initialized expenses stream");
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
                print("Expenses count: ${expenses.length}");

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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Operazione annullata')),
                    );
                  },
                  child: const Text('Mostra SnackBar'),
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
    );
  }
}