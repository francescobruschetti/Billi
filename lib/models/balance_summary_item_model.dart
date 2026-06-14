import 'package:Billy/models/group/group_participant_summary_model.dart';
import 'package:Billy/models/group/group_participant_summary_balance_model.dart';

class BalanceSummaryItemModel {
  final bool isCurrentUser;
  final GroupParticipantSummaryModel summary;
  final GroupTransactionSummaryBalanceModel balance;

  BalanceSummaryItemModel({
    required this.isCurrentUser,
    required this.summary,
    required this.balance,
  });
}