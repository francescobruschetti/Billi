class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String? merchant;
  final String? categories;
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    this.merchant,
    this.categories,
    required this.createdAt,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'],
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      merchant: map['merchant']?['name'],
      categories: map['categories']?['name'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}