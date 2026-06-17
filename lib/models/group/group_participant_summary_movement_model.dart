import 'package:Billy/models/group/group_participant_summary_balance_movement_model.dart';

class GroupTransactionSummaryMovementModel extends GroupTransactionSummaryBalanceMovementModel {
  final String transactionId; // Id of the transaction this movement is related to
  final String groupId; // Id of the group this movement is related to

  GroupTransactionSummaryMovementModel({
    required this.transactionId,
    required this.groupId,
    required super.userId,
    required super.otherUserId,
    required super.amount,
    required super.isToPay,
  });
}