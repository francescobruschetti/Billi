import 'package:Billy/enums/transaction_type_enum.dart';
import 'package:Billy/models/category/category_model.dart';
import 'package:Billy/models/group/group_expense_partecipants_model.dart';
import 'package:Billy/models/merchant_model.dart';
import 'package:Billy/models/profile_model.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class GroupTransactionModel {
  @JsonKey(required: true, disallowNullValue: true)

  final String id;
  final String groupId;
  final ProfileModel profileModel;
  final MerchantModel? merchant;
  final CategoryModel? category;
  final List<GroupExpenseParticipantModel> expensePartecipants;

  final double? paidAmount;
  final double totalAmount;
  final String? splitRate; // JSON string representing how the expense is split among participants
  final TransactionTypeEnum transactionType;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  GroupTransactionModel({
    required this.id,
    required this.groupId,
    required this.profileModel,
    this.merchant,
    this.category,
    required this.expensePartecipants,
    this.paidAmount,
    required this.totalAmount,
    this.splitRate,
    required this.transactionType,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupTransactionModel.fromMap(Map<String, dynamic> map) {    
    return GroupTransactionModel(
      id: map['id'],
      groupId: map['group_id'],
      profileModel: ProfileModel.fromMap(map['profile']),
      merchant: map['merchant'] != null ? MerchantModel.fromMap(map['merchant']) : null,
      category: map['category'] != null ? CategoryModel.fromMap(map['category']) : null,

      expensePartecipants: (map['expense_participants'] as List? ?? [])
        .map((e) => GroupExpenseParticipantModel.fromMap(e as Map<String, dynamic>))
        .toList(),

      paidAmount: map['paid_amount'] != null ? (map['paid_amount'] as num).toDouble() : null,
      totalAmount: (map['total_amount'] as num).toDouble(),
      splitRate: map['split_rate'],
      transactionType: TransactionTypeEnumExtension.fromValue(map['transaction_type']),
      note: map['note'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  static List<GroupTransactionModel> fromList(List<Map<String, dynamic>> expensesMap) {
    List<GroupTransactionModel> expenses = [];
    for (var item in expensesMap) {
      expenses.add(GroupTransactionModel.fromMap(item));
    }
    return expenses;
  }
}