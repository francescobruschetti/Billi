// Nuovo modello per i saldi
import 'package:Billy/models/group/group_settlement_profile_model.dart';

class GroupSettlementModel {
  final String id;
  final String groupId;
  final String payerId; // chi ha saldato
  final String receiverId; // chi ha ricevuto
  final double amount;
  final DateTime settledAt;

  GroupSettlementModel({
    required this.id,
    required this.groupId,
    required this.payerId,
    required this.receiverId,
    required this.amount,
    required this.settledAt,
  });

  factory GroupSettlementModel.fromMap(Map<String, dynamic> map) {
    return GroupSettlementModel(
      id: map['id'],
      groupId: map['group_id'],
      payerId: map['payer_id'],
      receiverId: map['receiver_id'],
      amount: map['amount']?.toDouble() ?? 0.0,
      settledAt: DateTime.parse(map['settled_at']),
    );
  }

  static List<GroupSettlementModel> fromList(List<dynamic> settlementsMap) {
    List<GroupSettlementModel> settlements = [];
    for (var item in settlementsMap) {
      settlements.add(GroupSettlementModel.fromMap(item));
    }
    return settlements;
  }
}