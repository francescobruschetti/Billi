import 'package:Billy/models/group/group_participant_summary_balance_movement_model.dart';
import 'package:Billy/models/group/group_participant_summary_model.dart';

class BalanceMovementItemModel {
  final bool isCurrentUser;
  final GroupParticipantSummaryModel summary;
  final GroupTransactionSummaryBalanceMovementModel movement;

  BalanceMovementItemModel({
    required this.isCurrentUser,
    required this.summary,
    required this.movement,
  });
}