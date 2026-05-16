class PersonalTransactionTotalsModel {
  final double totalIncomes;
  final double totalExpenses;
  final double balance;

  PersonalTransactionTotalsModel({
    required this.totalIncomes,
    required this.totalExpenses,
    required this.balance,
  });

  PersonalTransactionTotalsModel.fromJson(Map<String, dynamic> data)
      : totalIncomes  = (data['total_incomes'] as num).toDouble(),
        totalExpenses = (data['total_expenses'] as num).toDouble(),
        balance = (data['balance'] as num).toDouble();
}