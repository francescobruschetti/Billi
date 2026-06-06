import 'package:Billy/enums/split_rate_mode_enum.dart';
import 'package:Billy/enums/transaction_type_enum.dart';
import 'package:Billy/models/balance_details_model.dart';
import 'package:Billy/models/group/group_expense_partecipants_model.dart';
import 'package:Billy/models/group/group_participant_summary_balance_movement_model.dart';
import 'package:Billy/models/group/group_transaction_model.dart';
import 'package:Billy/models/profile_model.dart';
import 'package:Billy/utils/number_util.dart';
import 'package:logging/logging.dart';
import 'package:Billy/models/group/group_participant_model.dart';
import 'package:Billy/models/group/group_participant_summary_model.dart';

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

  static void computeDynamicParticipantsSummary({
    required Map<String, GroupParticipantSummaryModel> summary,
  }) 
  {  
    // Step 4 - Combine movements and compute minimum transactions to balance the transactions
    List<GroupParticipantSummaryModel> finalMovements = getSortedSummaryListByToReceiveNet(summary);
    computeParticipantsFinalMovements(finalMovements, summary);
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
    computeParticipantsMovementsToBalanceTransactions(summary: summary, transactions: transactions);
    log.fine("Summary: $summary.");

    // Step 4 - Combine movements and compute minimum transactions to balance the transactions
    List<GroupParticipantSummaryModel> finalMovements = getSortedSummaryListByToReceiveNet(summary);
    computeParticipantsFinalMovements(finalMovements, summary);

    return summary;
  }

  // Compute final movements to balance the transactions, combining the movements of each participant and optimizing the transactions
  static void computeParticipantsFinalMovements(List<GroupParticipantSummaryModel> balanceMovements, Map<String, GroupParticipantSummaryModel> summary) {

    log.fine("Computing final movements to balance transactions. Initial balance movements: $balanceMovements.");
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

  // Compute how much each participant ows or should receive to balance the transactions, based on how much they paid
  static void computeParticipantsMovementsToBalanceTransactions({
    required Map<String, GroupParticipantSummaryModel> summary,
    required List<GroupTransactionModel> transactions,
  }) {
    for (final transaction in transactions) {
      final payerId = transaction.profileModel.id;
      log.fine("Computing movements for transaction ${transaction.id} with payer ${transaction.profileModel.name}. Total amount: ${transaction.totalAmount}, paid amount itself: ${transaction.paidAmount}, split rate: ${transaction.splitRate}.");

      final participants = [
        payerId,
        ...transaction.expensePartecipants.map((e) => e.userId),
      ];

      final share = transaction.totalAmount / participants.length;
      for (final participantId in participants) {
        if (participantId == payerId) {
          continue;
        }

        summary[participantId]?.toReceiveNet -= share;
        summary[payerId]?.toReceiveNet += share;

        log.fine("Transaction ${transaction.id}. total: ${transaction.totalAmount}, participants: ${participants.length}: $participantId owes $share to payer $payerId. Updated toReceiveNet for participant: ${summary[participantId]?.toReceiveNet}, for payer: ${summary[payerId]?.toReceiveNet}.");
        summary[participantId]?.movements.add(
          GroupTransactionSummaryBalanceMovementModel(
            otherUserId: payerId,
            amount: share,
            isToPay: true
          )
        );
      }
    }
  }

  // Compute how much each participant has anticipated to the group and its share of those transactions
  static double computeTotalAmountAndUpdateSummaryActivePayment(
      Map<String, GroupParticipantSummaryModel> summary,
      List<GroupTransactionModel> transactions)
   {
    double totalAmount = 0;
    for (var transaction in transactions) {
      final ProfileModel profileModel = transaction.profileModel;
      final String userId = profileModel.id;
      double paidAmountItself = transaction.paidAmount ?? 0;
      double paidAmountGroup = transaction.totalAmount;
      String? splitRate = transaction.splitRate;
      double? receiveGrossAmount;
      int expenseParticipantsCount = transaction.expensePartecipants.length + 1; // +1 per includere il profilo del pagatore

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
          case SplitRateModeEnum.EVENLY:
            paidAmountItself = paidAmountGroup / expenseParticipantsCount;
            receiveGrossAmount = paidAmountGroup - paidAmountItself;
            break;

          case SplitRateModeEnum.FIXED_1:
            paidAmountItself = paidAmountGroup / expenseParticipantsCount;
            receiveGrossAmount = paidAmountGroup - paidAmountItself;
            break;
          case SplitRateModeEnum.FIXED_2:
            paidAmountItself = (paidAmountGroup / expenseParticipantsCount) * 2; // TODO: gestire caso in cui FIXED_2 è maggiore del numero di partecipanti
            receiveGrossAmount = paidAmountGroup - paidAmountItself;
            break;
          case SplitRateModeEnum.FIXED_3:
            paidAmountItself = (paidAmountGroup / expenseParticipantsCount) * 3; // TODO: gestire caso in cui FIXED_3 è maggiore del numero di partecipanti
            receiveGrossAmount = paidAmountGroup - paidAmountItself;
            break;
          case SplitRateModeEnum.FIXED_4:
            paidAmountItself = (paidAmountGroup / expenseParticipantsCount) * 4; // TODO: gestire caso in cui FIXED_4 è maggiore del numero di partecipanti
            receiveGrossAmount = paidAmountGroup - paidAmountItself;
            break;

          case SplitRateModeEnum.FIXED_AMOUNT:
            if (transaction.paidAmount == null) {
              log.warning("Transaction ${transaction.id} has split rate FIXED_AMOUNT but paid amount is null. Defaulting to 0.");
              paidAmountItself = 0;
            }
            else {
              paidAmountItself = transaction.paidAmount!;
            }
            receiveGrossAmount = paidAmountGroup - paidAmountItself;
            break;

          default:
            throw Exception("Split rate ${splitRateEnum.value} not implemented yet.");
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

  // Restituisce una lista ordinata dei partecipanti in base a toReceiveNet (decrescente di default)
  static List<GroupParticipantSummaryModel> getSortedSummaryListByToReceiveNet(Map<String, GroupParticipantSummaryModel> summary, {bool descending = false}) {
    // Crea una copia profonda degli oggetti (assumendo che GroupParticipantSummaryModel abbia un metodo copy o from)
    final list = summary.values
      .map((e) => e.duplicate())
      .toList();
    list.sort((a, b) => descending ? b.toReceiveNet.compareTo(a.toReceiveNet) : a.toReceiveNet.compareTo(b.toReceiveNet));
    return list;
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

  static Map<String, GroupParticipantSummaryModel> mergeSummaries(Map<String, GroupParticipantSummaryModel> summary1, Map<String, GroupParticipantSummaryModel> summary2) {
    // Copia summary1 resettando balanceMovements
    final Map<String, GroupParticipantSummaryModel> result = {
      for (final entry in summary1.entries)
        entry.key: entry.value.copyWith(balanceMovements: []),
    };

    for (final entry in summary2.entries) {
      result.update(
        entry.key,
        (existing) => existing.merge(entry.value), // merge già resetta balanceMovements
        ifAbsent: () => entry.value.copyWith(balanceMovements: []),
      );
    }

    return result;
  }

  // TODO: not used
  // static GroupExpenseParticipantModel? checkIfUserIsAmongExpenseParticipants(String userId, GroupTransactionModel transaction) {
  //   if (userId == transaction.profileModel.id) {
  //     log.fine("User $userId is the payer of transaction ${transaction.id}. Skip it.");
  //     return null; // Il pagatore non è considerato tra i partecipanti che devono
  //   }

  //   final index = transaction.expensePartecipants.indexWhere((e) => e.userId == userId);
  //   if (index == -1) {
  //     log.fine("User $userId is not among the expense participants of transaction ${transaction.id}. Skip it.");
  //     return null; // L'utente non è tra i partecipanti che devono pagare per questa transazione
  //   }

  //   return transaction.expensePartecipants[index];
  // }
}