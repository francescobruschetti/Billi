import 'package:Billy/models/group/group_model.dart';
import 'package:Billy/models/group/group_settlement_model.dart';
import 'package:Billy/models/group/group_transaction_model.dart';
import 'package:Billy/models/group/group_participant_model.dart';

class GroupDetailsModel extends GroupModel {
  final double totalAmount;
  final List<GroupParticipantModel> participants;
  final List<GroupTransactionModel> transactions;
  final List<GroupSettlementModel> settlements;

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
    required this.settlements,
  });

  factory GroupDetailsModel.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) { // TODO: gestire meglio questo caso
      throw Exception("Empty map provided to GroupDetailsModel.fromMap");
    }
    return GroupDetailsModel(
      id: map['out_id'] ?? map['id'] ?? map['group_id'], // ?? [group_id] usato per: update_group_and_participants
      name: map['out_name'] ?? map['name'],
      link: map['out_link'] ?? map['link'],
      description: map['out_description'] ?? map['description'],
      userId: map['out_user_id'] ?? map['user_id'],
      totalAmount: map['total_amount'] ?? 0.0,
      createdAt: DateTime.parse(map['out_created_at'] ?? map['created_at'] ?? DateTime.fromMillisecondsSinceEpoch(0).toIso8601String()),
      updatedAt: DateTime.parse(map['out_updated_at'] ?? map['updated_at'] ?? DateTime.fromMillisecondsSinceEpoch(0).toIso8601String()),
      participants: (map['group_participants'] as List? ?? [])
        .map((e) => GroupParticipantModel.fromMap(e as Map<String, dynamic>))
        .toList(),
      transactions: (map['group_transactions'] as List? ?? [])
        .map((e) => GroupTransactionModel.fromMap(e as Map<String, dynamic>))
        .toList(),
      settlements: (map['group_settlements'] as List? ?? [])
        .map((e) => GroupSettlementModel.fromMap(e as Map<String, dynamic>))
        .toList(),
    );
  }
}