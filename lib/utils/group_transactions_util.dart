import 'package:Billy/enums/transaction_type_enum.dart';
import 'package:Billy/models/balance_details_model.dart';
import 'package:Billy/models/group_participant_summary_balance_movement_model.dart';
import 'package:Billy/models/group_transaction_model.dart';
import 'package:Billy/utils/number_util.dart';
import 'package:logging/logging.dart';
import 'package:Billy/models/group_participant_model.dart';
import 'package:Billy/models/group_participant_summary_model.dart';

class GroupTransactionsUtil {
  static final Logger log = Logger('GroupTransactionsUtil');

  static BalanceDetailsModel computeBalance(List<Map<String, dynamic>> allTransactions) {
    double totalBalance = 0;
    double totalExpenses = 0;
    double totalIncomes = 0;
    double res = allTransactions.fold<double>(0, (sum, e) {
      final amount = double.tryParse(e['total_amount']?.toString() ?? '0') ?? 0;
      final type = TransactionTypeEnumExtension.fromValue(e['transaction_type']);
      if (type == TransactionTypeEnum.INCOME) {
        totalIncomes += amount;
        return sum + amount;
      } 
      else {
        totalExpenses += amount;
        return sum - amount;
      }
    });
    totalBalance = double.parse(res.toStringAsFixed(2));
    totalExpenses = double.parse(totalExpenses.toStringAsFixed(2));
    totalIncomes = double.parse(totalIncomes.toStringAsFixed(2));
    return BalanceDetailsModel(
      totalBalance: totalBalance,
      totalExpenses: totalExpenses,
      totalIncomes: totalIncomes,
    );
  }

  static Map<String, GroupParticipantSummaryModel> computeParticipantsSummary({
    required List<GroupTransactionModel> transactions, 
    required List<GroupParticipantModel> participants
  }) 
  {    
    Map<String, GroupParticipantSummaryModel> summary = {};

    if (participants.isEmpty) {
      log.warning("Number of participants is zero or negative. Defaulting to 1 to avoid division by zero.");
      return summary;
    }
    
    // Step 1 - Initialize participants summary
    initParticipantsSummary(summary, participants);

    if (transactions.isEmpty) {
      log.info("No transactions found for group. Returning empty summary.");
      return summary;
    }

    // Step 2 - Compute total amount and update summary with active payments
    double totalAmount = computeTotalAmountAndUpdateSummaryActivePayment(summary, transactions);
    log.fine("Total amount for group: $totalAmount. Number of participants: ${summary.length}.");

    // Step 3 - Compute user's movements to balance the transactions
    computeParticipantsMovementsToBalanceTransactions(summary: summary);
    log.fine("Summary: $summary.");

    // Step 4 - Combine movements and compute minimum transactions to balance the transactions
    List<GroupParticipantSummaryModel> finalMovements = getSortedSummaryListByToReceiveNet(summary);
    computeParticipantsFinalMovements(finalMovements, summary);

    return summary;
  }

  // Initialized participants summary with group participants (in case some participants don't have transactions yet)
  static void initParticipantsSummary(Map<String, GroupParticipantSummaryModel> summary, List<GroupParticipantModel> participants) {
    for (GroupParticipantModel participant in participants) {
      summary[participant.userId] = GroupParticipantSummaryModel.basic(
        userId: participant.userId,
        profile: participant.profile
      );
    }
  }

  // Compute how much each participant has anticipated to the group and its share of those transactions
  static double computeTotalAmountAndUpdateSummaryActivePayment(
      Map<String, GroupParticipantSummaryModel> summary,
      List<GroupTransactionModel> transactions)
   {
    double totalAmount = 0;
    for (var transaction in transactions) {
      final profileModel = transaction.profileModel;
      final userId = profileModel.id;
      final paidAmountItself = transaction.paidAmount ?? 0;
      final paidAmountGroup = transaction.totalAmount;
      final splitRate = transaction.splitRate;

      if (!summary.containsKey(userId)) {
        log.fine("Transaction ${transaction.id} has user_id $userId which is not in group participants yet.");
        summary[userId] = GroupParticipantSummaryModel.basic(
          userId: userId,
          profile: profileModel,
        );
      }

      if (splitRate != null) {
        // TODO: da implementare
        log.fine("Transaction ${transaction.id} has a split rate defined.");
        // switch (splitRate.runtimeType) {
        //   case String:
        //     log.warning("Transaction ${transaction.id} has split rate as String. Expected Map. Defaulting to equal split.");
        //     break;
        //   case Map<String, dynamic>:
        //     log.warning("Transaction ${transaction.id} has split rate as Map. Split rate handling is not implemented yet, defaulting to equal split.");
        //     break;
        //   default:
        //     log.warning("Transaction ${transaction.id} has split rate of unexpected type ${splitRate.runtimeType}. Defaulting to equal split.");
        // }
      }
      else {
        log.fine("Transaction ${transaction.id} has NO split rate.");
        summary[userId]?.increasePaidAmountGroup(paidAmountGroup);
        summary[userId]?.increasePaidAmountItself(paidAmountItself);
        summary[userId]?.increasetoReceiveGross(paidAmountGroup - paidAmountItself);
      }
      totalAmount += paidAmountGroup;
    }

    return totalAmount;
  }

  // Compute how much each participant ows or should receive to balance the transactions, based on how much they paid
  static void computeParticipantsMovementsToBalanceTransactions({required Map<String, GroupParticipantSummaryModel> summary}) {
    for (GroupParticipantSummaryModel userSummary in summary.values) {
      double toReceiveNet = 0;
      double movementAmount = 0;
      for (GroupParticipantSummaryModel otherUserSummary in summary.values) {
        if (userSummary.userId == otherUserSummary.userId) {
          continue; // Skip self
        }

        movementAmount = NumberUtil.roundToTwoDecimals(value: (otherUserSummary.toReceiveGross / (summary.length - 1)));
        toReceiveNet += movementAmount;
        userSummary.movements.add(
          GroupTransactionSummaryBalanceMovementModel(
            otherUserId: otherUserSummary.userId,
            amount: movementAmount,
            isToPay: true
          )
        );
      }

      userSummary.toReceiveNet = NumberUtil.roundToTwoDecimals(value: userSummary.toReceiveGross - toReceiveNet);
    }
  }

  // Compute final movements to balance the transactions, combining the movements of each participant and optimizing the transactions
  static void computeParticipantsFinalMovements(List<GroupParticipantSummaryModel> balanceMovements, Map<String, GroupParticipantSummaryModel> summary) {
    for (int i = 0; i < balanceMovements.length; i++) {
      GroupParticipantSummaryModel currentUser = balanceMovements[i];
      GroupParticipantSummaryModel lastUser = balanceMovements.last;

      // TODO: IMPORTANTE: Questa funziona gestisce MALE gli arrotondamenti.... Bisogna gestire meglio gli arrotondamenti per evitare che rimangano piccoli importi da pagare o ricevere che non vengono gestiti correttamente e che portano a movimenti non ottimali

      double diff = NumberUtil.roundToTwoDecimals(value: currentUser.toReceiveNet + lastUser.toReceiveNet);
      if (diff < 0) {
        summary[currentUser.userId]?.balanceMovements.add(
          GroupTransactionSummaryBalanceMovementModel(
            otherUserId: lastUser.userId,
            amount: lastUser.toReceiveNet.abs(),
            isToPay: true
          )
        );
        currentUser.toReceiveNet = diff;
        lastUser.toReceiveNet = 0;
      }
      else {
        summary[currentUser.userId]?.balanceMovements.add(
          GroupTransactionSummaryBalanceMovementModel(
            otherUserId: lastUser.userId,
            amount: (diff == 0) ? lastUser.toReceiveNet.abs() : currentUser.toReceiveNet.abs(),
            isToPay: true
          )
        );
        currentUser.toReceiveNet = 0;
        lastUser.toReceiveNet = diff;
      }

      if (currentUser.toReceiveNet != 0) {
        i -= 1; // Re-evaluate the same user in the next iteration to further optimize transactions
      }
      else {
        balanceMovements.removeAt(i); // Current user is balanced, remove it from the summary
        i -= 1; // Adjust index after removal
      }
      if (lastUser.toReceiveNet == 0) {
        balanceMovements.removeLast(); // Last user is balanced, remove it from the summary
      }
    }

    log.fine("Final movements to balance transactions: $summary.");
  }

  // Restituisce una lista ordinata dei partecipanti in base a toReceiveNet (decrescente di default)
  static List<GroupParticipantSummaryModel> getSortedSummaryListByToReceiveNet(Map<String, GroupParticipantSummaryModel> summary, {bool descending = false}) {
    // Crea una copia profonda degli oggetti (assumendo che GroupParticipantSummaryModel abbia un metodo copy o from)
    final list = summary.values
      .map((e) => e.duplicate())
      .toList();
    list.sort((a, b) => descending ? b.toReceiveNet.compareTo(a.toReceiveNet) : a.toReceiveNet.compareTo(b.toReceiveNet));
    return list;
  }
}