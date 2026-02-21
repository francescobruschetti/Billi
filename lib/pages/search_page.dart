import 'package:Billy/widgets/components/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:Billy/models/transaction_model.dart';
import 'package:Billy/services/transaction_service.dart';
import 'package:Billy/widgets/components/loading_scaffold.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TransactionService service = TransactionService();
  late Stream<List<TransactionModel>> transactionsStream;
  
  @override
  void initState() {
    super.initState();
    transactionsStream = service.subscribeTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          StreamBuilder<List<TransactionModel>>(
            stream: transactionsStream,
            builder: (context, snapshot) {
              final transactions = snapshot.data ?? [];
              final total = transactions.fold<double>(
                0,
                (sum, e) => sum + e.amount,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your transactions are: \$${total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),

          Expanded(
            child: StreamBuilder<List<TransactionModel>>(
              stream: transactionsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: LoadingScaffold(message: 'Carico...'));
                }

                final transactions = snapshot.data!;
                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final e = transactions[index];
                    return Card(
                      child: ListTile(
                        title: Text(e.title),
                        subtitle:
                            Text('${e.merchant ?? ''} · ${e.categories ?? ''}'),
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
                      CustomSnackkBarWidget( 
                        text: 'Operazione annullata',
                      ).build(context),
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