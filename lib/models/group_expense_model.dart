import 'package:Billy/models/category_model.dart';
import 'package:Billy/models/merchant_model.dart';
import 'package:Billy/models/profile_model.dart';

class GroupExpenseModel {
  final String id;
  final String groupId;
  final ProfileModel profileModel;
  final MerchantModel merchant;
  final CategoryModel category;

  final double? paidAmount;
  final double totalAmount;
  final String? splitRate; // JSON string representing how the expense is split among participants
  final String? note;
  final String? categories;
  final DateTime createdAt;
  final DateTime updatedAt;

  GroupExpenseModel({
    required this.id,
    required this.groupId,
    required this.profileModel,
    required this.merchant,
    required this.category,
    this.paidAmount,
    required this.totalAmount,
    this.splitRate,
    this.note,
    this.categories,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupExpenseModel.fromMap(Map<String, dynamic> map) {    
    return GroupExpenseModel(
      id: map['id'],
      groupId: map['group_id'],
      profileModel: ProfileModel.fromMap(map['profile']),
      merchant: MerchantModel.fromMap(map['merchant']),
      category: CategoryModel.fromMap(map['category']),
      paidAmount: map['paid_amount'] != null ? (map['paid_amount'] as num).toDouble() : null,
      totalAmount: (map['total_amount'] as num).toDouble(),
      splitRate: map['split_rate'],
      note: map['note'],
      categories: map['categories'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  
  static List<GroupExpenseModel> fromList(List<Map<String, dynamic>> expensesMap) {
    List<GroupExpenseModel> expenses = [];
    for (var item in expensesMap) {
      expenses.add(GroupExpenseModel.fromMap(item));
    }
    return expenses;
  }
}