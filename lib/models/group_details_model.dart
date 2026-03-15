import 'package:Billy/models/group_model.dart';
import 'package:Billy/models/group_transaction_model.dart';
import 'package:Billy/models/group_participant_model.dart';

class GroupDetailsModel extends GroupModel {
  final double totalAmount;
  final List<GroupParticipantModel> participants;
  final List<GroupTransactionModel> transactions;

  GroupDetailsModel({
    required super.id,
    required super.name,
    required super.link,
    super.description,
    required super.userId,
    required super.createdAt,
    required super.updatedAt,
    required this.totalAmount,
    required this.participants,
    required this.transactions,
  });

  factory GroupDetailsModel.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) { // TODO: gestire meglio questo caso
      throw Exception("Empty map provided to GroupDetailsModel.fromMap");
    }
    return GroupDetailsModel(
      id: map['id'],
      name: map['name'],
      link: map['link'],
      description: map['description'],
      userId: map['user_id'],
      totalAmount: map['total_amount'] ?? 0.0,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : DateTime.fromMillisecondsSinceEpoch(0),
      participants: (map['group_participants'] as List? ?? [])
        .map((e) => GroupParticipantModel.fromMap(e as Map<String, dynamic>))
        .toList(),
      transactions: (map['group_transactions'] as List? ?? [])
        .map((e) => GroupTransactionModel.fromMap(e as Map<String, dynamic>))
        .toList(),
    );
  }
}