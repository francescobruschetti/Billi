import 'package:Billy/models/group/group_participant_summary_balance_movement_model.dart';

class GroupTransactionSummaryBalanceModel extends GroupTransactionSummaryBalanceMovementModel {
  GroupTransactionSummaryBalanceModel({
    required super.userId,
    required super.otherUserId,
    required super.amount,
    required super.isToPay,
  });
}