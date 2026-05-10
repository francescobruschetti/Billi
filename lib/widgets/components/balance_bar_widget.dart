import 'package:Billy/constants.dart';
import 'package:Billy/enums/transaction_type_enum.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class BalanceBarWidget extends StatefulWidget {
  final double totalBalance;
  final double totalExpenses;
  final double totalIncomes;
  final Function()? onExpenseParentCallback;
  final Function()? onIncomeParentCallback;

  const BalanceBarWidget({
    super.key,
    required this.totalBalance,
    required this.totalExpenses,
    required this.totalIncomes,
    this.onExpenseParentCallback,
    this.onIncomeParentCallback,
  });

  @override
  State<BalanceBarWidget> createState() => _BalanceBarWidgetState();
}

class _BalanceBarWidgetState extends State<BalanceBarWidget> {
 
  TransactionTypeEnum? _selectedTransactionType;

  Color get expenseColor => AppConstants.defaultExpenseColor;
  Color get incomeColor => AppConstants.defaultIncomeColor;
  Color get notSelectedColor => Colors.grey.shade300;

  Color getBalanceColor(TransactionTypeEnum transactionType, Color expectedColorWhenSelected) {
    return (_selectedTransactionType == transactionType || _selectedTransactionType == null ? expectedColorWhenSelected : notSelectedColor);
  }

   @override


  @override
  Widget build(BuildContext context) {
    final total = widget.totalIncomes + widget.totalExpenses;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.rowHorizontalPadding, vertical: AppConstants.rowVerticalPadding),
      child: Column(
        children: [
          if (total > 0) ...[
            _buildBalanceBar(context),
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

          const SizedBox(height: AppConstants.sizedBoxHeight),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '-${widget.totalExpenses.toStringAsFixed(2)}€', 
                style: TextStyle(color: getBalanceColor(TransactionTypeEnum.EXPENSE, expenseColor), 
                fontWeight: FontWeight.bold)
              ),
              Text('${widget.totalIncomes.toStringAsFixed(2)}€', 
                style: 
                TextStyle(color: getBalanceColor(TransactionTypeEnum.INCOME, incomeColor), 
                fontWeight: FontWeight.bold)
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceBar(BuildContext context) {
    final double total = widget.totalIncomes + widget.totalExpenses;
    final int greenFlex = total > 0 ? (widget.totalIncomes / total * 100).round() : 0;
    final int redFlex = total > 0 ? (widget.totalExpenses / total * 100).round() : 0;

    return Row(
      children: [        
        _buildBalanceExpanded(widget.onExpenseParentCallback, TransactionTypeEnum.EXPENSE, expenseColor, const BorderRadius.horizontal(left: Radius.circular(8)), redFlex),
        const SizedBox(width: AppConstants.smallSizedBoxWidth),
        _buildBalanceExpanded(widget.onIncomeParentCallback, TransactionTypeEnum.INCOME, incomeColor, const BorderRadius.horizontal(right: Radius.circular(8)), greenFlex),
      ],
    );
  }

  Widget _buildBalanceExpanded(Function()? onParentCallback, TransactionTypeEnum transactionType, Color color, BorderRadius borderRadius, int flex) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (_selectedTransactionType == transactionType) {
              _selectedTransactionType = null;
            } 
            else {
              _selectedTransactionType = transactionType;
            }
          });

          // callback del padre
          onParentCallback?.call();          
        },
        child: Container(
          height: 10,
          decoration: BoxDecoration(
            color: getBalanceColor(transactionType, color),
            borderRadius: borderRadius,
          ),
        ),
      ),
    );
  }

}