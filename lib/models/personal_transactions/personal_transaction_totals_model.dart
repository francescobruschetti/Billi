class PersonalTransactionTotalsModel {
  final double totalIncome;
  final double totalExpense;
  final double balance;

  PersonalTransactionTotalsModel.fromJson(Map<String, dynamic> data)
      : totalIncome  = (data['total_income'] as num).toDouble(),
        totalExpense = (data['total_expense'] as num).toDouble(),
        balance = (data['balance'] as num).toDouble();
}