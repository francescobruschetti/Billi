class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String? merchant;
  final String? categories;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    this.merchant,
    this.categories,
    required this.createdAt,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      merchant: map['merchant']?['name'],
      categories: map['categories']?['name'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  static List<TransactionModel> fromList(List<Map<String, dynamic>> transactionsMap) {
    List<TransactionModel> transactions = [];
    for (var item in transactionsMap) {
      transactions.add(TransactionModel.fromMap(item));
    }
    return transactions;
  }
}