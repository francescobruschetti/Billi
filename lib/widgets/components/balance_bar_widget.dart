import 'package:Billy/constants.dart';
import 'package:flutter/material.dart';

class BalanceBarWidget extends StatelessWidget {
  final double totalBalance;
  final double totalExpenses;
  final double totalIncomes;

  const BalanceBarWidget({
    super.key,
    required this.totalBalance,
    required this.totalExpenses,
    required this.totalIncomes,
  });

  @override
  Widget build(BuildContext context) {
    final total = totalIncomes + totalExpenses;
    final greenFlex = total > 0 ? (totalIncomes / total * 100).round() : 0;
    final redFlex = total > 0 ? (totalExpenses / total * 100).round() : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.rowHorizontalPadding, vertical: AppConstants.rowVerticalPadding),
      child: Column(
        children: [
          if (total > 0) ...[
          Row(
            children: [
              Expanded(
                flex: redFlex,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppConstants.defaultExpenseColor,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                flex: greenFlex,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppConstants.defaultIncomeColor,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
          ]
          else ...[
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],

          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('€-${totalExpenses.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              Text('€${totalIncomes.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        ],
          ),
        ],
      ),
    );
  }
}