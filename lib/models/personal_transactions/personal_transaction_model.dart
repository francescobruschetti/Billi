import 'package:Billy/enums/transaction_type_enum.dart';
import 'package:Billy/models/category/category_model.dart';
import 'package:Billy/models/merchant_model.dart';

class PersonalTransactionModel {

  final String id;
  final String userId;
  final String note;
  final double totalAmount;
  final TransactionTypeEnum transactionType;
  final DateTime createdAt;
  final DateTime updatedAt;

  final MerchantModel? merchant;
  final CategoryModel? category;

  PersonalTransactionModel({
    required this.id,
    required this.userId,
    required this.note,
    required this.totalAmount,
    required this.transactionType,
    required this.createdAt,
    required this.updatedAt,
    this.merchant,
    this.category,
  });

  factory PersonalTransactionModel.fromMap(Map<String, dynamic> map) {
    return PersonalTransactionModel(
      id: map['id'],
      userId: map['user_id'],
      note: map['note'],
      totalAmount: (map['total_amount'] as num).toDouble(),
      transactionType: TransactionTypeEnum.values.firstWhere((e) => e.value == map['transaction_type']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      merchant: map['merchant'] != null ? MerchantModel.fromMap(map['merchant']) : null,
      category: map['category'] != null ? CategoryModel.fromMap(map['category']) : null,
    );
  }

  static List<PersonalTransactionModel> fromList(List<dynamic> transactionsMap) {
    List<PersonalTransactionModel> transactions = [];
    for (var item in transactionsMap) {
      transactions.add(PersonalTransactionModel.fromMap(item));
    }
    return transactions;
  }
}