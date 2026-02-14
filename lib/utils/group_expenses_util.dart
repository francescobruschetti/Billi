import 'package:logging/logging.dart';
import 'package:monitoraggio_spese/models/group_expense_model.dart';
import 'package:monitoraggio_spese/models/group_participant_model.dart';
import 'package:monitoraggio_spese/models/group_participant_summary_model.dart';

class GroupExpensesUtil {
  static final Logger log = Logger('GroupExpensesUtil');

  static Map<String, GroupParticipantSummaryModel> computeParticipantsSummary({required List<GroupExpenseModel> expenses, required List<GroupParticipantModel> groupParticipants}) {    
    Map<String, GroupParticipantSummaryModel> summary = {};

    if (expenses.isEmpty) {
      log.info("No expenses found for group. Returning empty summary.");
      return summary;
    }
    if (groupParticipants.isEmpty) {
      log.warning("Number of participants is zero or negative. Defaulting to 1 to avoid division by zero.");
      return summary;
    }
    
    // Step 1:
    initParticipantsSummary(summary, groupParticipants);

    // Step 2:
    double totalAmount = computeTotalAmountAndUpdateSummaryActivePayment(summary, expenses);
    double averageExpensePerUser = totalAmount / groupParticipants.length;
    log.fine("Total amount for group: $totalAmount. Average expense per user: $averageExpensePerUser.");

    // Step 3:
    computeToPayAndToReceiveForParticipants(summary, averageExpensePerUser: averageExpensePerUser);
    return summary;
  }

  // Initialized participants summary with group participants (in case some participants don't have expenses yet)
  static void initParticipantsSummary(Map<String, GroupParticipantSummaryModel> summary, List<GroupParticipantModel> groupParticipants) {
    for (GroupParticipantModel participant in groupParticipants) {
      summary[participant.userId] = GroupParticipantSummaryModel.basic(
        userId: participant.userId,
        profile: participant.profile
      );
    }
  }

  // Compute how much each participant has anticipated to the group and its share of those expenses
  static double computeTotalAmountAndUpdateSummaryActivePayment(Map<String, GroupParticipantSummaryModel> summary, List<GroupExpenseModel> expenses) {
    double totalAmount = 0;
    for (var expense in expenses) {
      final profileModel = expense.profileModel;
      final userId = profileModel.id;
      final paidAmountItself = expense.paidAmount ?? 0;
      final paidAmountGroup = expense.totalAmount;
      final splitRate = expense.splitRate;

      if (!summary.containsKey(userId)) {
        log.fine("Expense ${expense.id} has user_id $userId which is not in group participants yet.");
        summary[userId] = GroupParticipantSummaryModel.basic(
          userId: userId,
          profile: profileModel,
        );
      }

      if (splitRate != null) {
        // TODO: da implementare
        log.fine("Expense ${expense.id} has a split rate defined.");
        // switch (splitRate.runtimeType) {
        //   case String:
        //     log.warning("Expense ${expense.id} has split rate as String. Expected Map. Defaulting to equal split.");
        //     break;
        //   case Map<String, dynamic>:
        //     log.warning("Expense ${expense.id} has split rate as Map. Split rate handling is not implemented yet, defaulting to equal split.");
        //     break;
        //   default:
        //     log.warning("Expense ${expense.id} has split rate of unexpected type ${splitRate.runtimeType}. Defaulting to equal split.");
        // }
      }
      else {
        log.fine("Expense ${expense.id} has NO split rate.");
        summary[userId]?.increasePaidAmountGroup(paidAmountGroup);
        summary[userId]?.increasePaidAmountItself(paidAmountItself);
        summary[userId]?.increaseToReceive(paidAmountGroup - paidAmountItself);
      }
      totalAmount += paidAmountGroup;
    }

    return totalAmount;
  }

  static void computeToPayAndToReceiveForParticipants(Map<String, GroupParticipantSummaryModel> summary, {required final double averageExpensePerUser}) {
    // Compute how much each participant should pay or receive to balance the expenses
    for (var entry in summary.entries) {
      final userId = entry.key;
      final participantSummary = entry.value;

      final toPay = averageExpensePerUser - participantSummary.paidAmountGroup;
      if (toPay < 0) {
        participantSummary.updateToReceive = -toPay;
        participantSummary.updateToPay = 0;
      }
      else {
        participantSummary.updateToReceive = 0;
        participantSummary.updateToPay = toPay;
      }
      log.fine("Participant $userId summary: paidAmountGroup=${participantSummary.paidAmountGroup}, paidAmountItself=${participantSummary.paidAmountItself}, toReceive=${participantSummary.toReceive}, toPay=${participantSummary.toPay}.");
    }
  }

}