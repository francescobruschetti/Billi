import 'package:Billy/enums/split_rate_mode_enum.dart';
import 'package:Billy/enums/transaction_type_enum.dart';
import 'package:Billy/models/balance_details_model.dart';
import 'package:Billy/models/group_participant_summary_balance_movement_model.dart';
import 'package:Billy/models/group_transaction_model.dart';
import 'package:Billy/models/profile_model.dart';
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
    double totalAmount = computeTotalAmountAndUpdateSummaryActivePayment(summary, transactions, participants.length);
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
      List<GroupTransactionModel> transactions,
      int participantsCount)
   {
    double totalAmount = 0;
    for (var transaction in transactions) {
      final ProfileModel profileModel = transaction.profileModel;
      final String userId = profileModel.id;
      double paidAmountItself = transaction.paidAmount ?? 0;
      double paidAmountGroup = transaction.totalAmount;
      String? splitRate = transaction.splitRate;
      double? receiveGrossAmount;

      if (!summary.containsKey(userId)) {
        log.fine("Transaction ${transaction.id} has user_id $userId which is not in group participants yet.");
        summary[userId] = GroupParticipantSummaryModel.basic(
          userId: userId,
          profile: profileModel,
        );
      }

      if (splitRate != null) {
        SplitRateModeEnum splitRateEnum = SplitRateModeEnumExtension.fromValue(splitRate);
        log.fine("Transaction ${transaction.id} has a split rate defined: $splitRate. Enum: ${splitRateEnum.value}.");
        
        switch (splitRateEnum) {
          case SplitRateModeEnum.ONE_QUARTER:
            paidAmountItself = paidAmountGroup * 0.25;
            receiveGrossAmount = paidAmountGroup - paidAmountItself;
            break;
          case SplitRateModeEnum.THREE_QUARTERS:
            paidAmountItself = paidAmountGroup * 0.75;
            receiveGrossAmount = paidAmountGroup - paidAmountItself;
            break;
          case SplitRateModeEnum.HALF:
            paidAmountItself = paidAmountGroup * 0.5;
            receiveGrossAmount = paidAmountGroup - paidAmountItself;
            break;
          case SplitRateModeEnum.ZERO:
            paidAmountItself = 0;
            receiveGrossAmount = paidAmountGroup - paidAmountItself;
            break;
          case SplitRateModeEnum.EQUALLY:
            paidAmountItself = paidAmountGroup / participantsCount;
            receiveGrossAmount = paidAmountGroup - paidAmountItself;
            break;

          case SplitRateModeEnum.FIXED_1:
            paidAmountItself = paidAmountGroup / participantsCount;
            receiveGrossAmount = paidAmountGroup - paidAmountItself;
            break;
          case SplitRateModeEnum.FIXED_2:
            paidAmountItself = (paidAmountGroup / participantsCount) * 2; // TODO: gestire caso in cui FIXED_2 è maggiore del numero di partecipanti
            receiveGrossAmount = paidAmountGroup - paidAmountItself;
            break;
          case SplitRateModeEnum.FIXED_3:
            paidAmountItself = (paidAmountGroup / participantsCount) * 3; // TODO: gestire caso in cui FIXED_3 è maggiore del numero di partecipanti
            receiveGrossAmount = paidAmountGroup - paidAmountItself;
            break;
          case SplitRateModeEnum.FIXED_4:
            paidAmountItself = (paidAmountGroup / participantsCount) * 4; // TODO: gestire caso in cui FIXED_4 è maggiore del numero di partecipanti
            receiveGrossAmount = paidAmountGroup - paidAmountItself;
            break;

          default:
          // TODO: da implementare
            throw Exception("Split rate ${splitRateEnum.value} not implemented yet.");
          //   int participantsCount = summary.length;
          //   if (participantsCount == 0) {
          //     log.warning("Number of participants is zero or negative. Defaulting to 1 to avoid division by zero.");
          //     participantsCount = 1;
          //   }
          //   summary[userId]?.increasePaidAmountGroup(paidAmountGroup);
          //   summary[userId]?.increasePaidAmountItself(paidAmountItself);
          //   summary[userId]?.increasetoReceiveGross(NumberUtil.roundToDecimals(value: paidAmountGroup * (participantsCount - 1) / participantsCount - paidAmountItself));
        }

        summary[userId]?.increasePaidAmountGroup(NumberUtil.roundToDecimals(value: paidAmountGroup));
        summary[userId]?.increasePaidAmountItself(NumberUtil.roundToDecimals(value: paidAmountItself));
        summary[userId]?.increasetoReceiveGross(NumberUtil.roundToDecimals(value: receiveGrossAmount));
      }
      else {
        log.fine("Transaction ${transaction.id} has NO split rate.");
        summary[userId]?.increasePaidAmountGroup(paidAmountGroup);
        summary[userId]?.increasePaidAmountItself(paidAmountItself);
        summary[userId]?.increasetoReceiveGross(NumberUtil.roundToDecimals(value: paidAmountGroup - paidAmountItself));
      }
      totalAmount += paidAmountGroup;
    }

    return NumberUtil.roundToDecimals(value: totalAmount);
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

        movementAmount = NumberUtil.roundToDecimals(value: (otherUserSummary.toReceiveGross / (summary.length - 1)));
        if (movementAmount == 0) {
          continue; // Skip movements of zero amount
        }
        
        toReceiveNet += movementAmount;
        userSummary.movements.add(
          GroupTransactionSummaryBalanceMovementModel(
            otherUserId: otherUserSummary.userId,
            amount: movementAmount,
            isToPay: true
          )
        );
      }

      userSummary.toReceiveNet = NumberUtil.roundToDecimals(value: userSummary.toReceiveGross - toReceiveNet);
    }
  }

  // Compute final movements to balance the transactions, combining the movements of each participant and optimizing the transactions
  static void computeParticipantsFinalMovements(List<GroupParticipantSummaryModel> balanceMovements, Map<String, GroupParticipantSummaryModel> summary) {

    for (int i = 0; i < balanceMovements.length; i++) {
      GroupParticipantSummaryModel currentUser = balanceMovements[i];
      GroupParticipantSummaryModel lastUser = balanceMovements.last;

      if (currentUser.userId != lastUser.userId) {
        /* IMPORTANTE: Questa funzione gestisce MALE gli arrotondamenti. 
        * Il controll if (diff.abs() <= 0.01) permette di considerare resti di 0.01 come bilanciati */

        double diff = NumberUtil.roundToDecimals(value: currentUser.toReceiveNet + lastUser.toReceiveNet);
        if (diff.abs() <= 0.01) {
          diff = 0; // Considera il debito come completamente bilanciato se la differenza è inferiore a 1 centesimo
        }
        
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