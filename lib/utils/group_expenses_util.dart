import 'package:logging/logging.dart';
import 'package:monitoraggio_spese/models/group_participant_model.dart';
import 'package:monitoraggio_spese/models/group_participant_summary_model.dart';

class GroupExpensesUtil {
  static final Logger log = Logger('GroupExpensesUtil');

  static Map<String, GroupParticipantSummaryModel> computeParticipantsSummary({required List<Map<String, dynamic>> expenses, required List<GroupParticipantModel> groupParticipants}) {    
    Map<String, GroupParticipantSummaryModel> summary = {};
    if (expenses.isEmpty) {
      log.info("No expenses found for group. Returning empty summary.");
      return summary;
    }
    if (groupParticipants.isEmpty) {
      log.warning("Number of participants is zero or negative. Defaulting to 1 to avoid division by zero.");
      return summary;
    }
    
    // Initialized participants summary with group participants (in case some participants don't have expenses yet)
    for (GroupParticipantModel participant in groupParticipants) {
      summary[participant.userId] = GroupParticipantSummaryModel.basic(
        userId: participant.userId,
        profile: participant.profile
      );
    }

    // Loop over all expenses and compute how much each participant has paid and owes
    for (var expense in expenses) {
      final userId = expense['user_id'];
      if (userId == null) {
        log.warning("Expense ${expense['id']} has no user ID. Skipping.");
        continue;
      }

      final paidAmount = double.tryParse(expense['paid_amount']?.toString() ?? '0') ?? 0;
      final totalAmount = double.tryParse(expense['total_amount']?.toString() ?? '0') ?? 0;
      final splitRate = expense['split_rate'];

      if (splitRate != null) {
        // TODO: da implementare
        log.fine("Expense ${expense['id']} has a split rate defined. Split rate handling is not implemented yet, defaulting to equal split.");
      }
      else {
        log.fine("Expense ${expense['id']} has no split rate. Using equal split for ${groupParticipants.length} participants.");
      }


      // // Se lo split rate è presente, usalo per calcolare quanto deve pagare ogni partecipante
      // // Altrimenti, dividi semplicemente per il numero di partecipanti
      // double owedAmount = 0;
      // if (splitRate != null) {
      //   // try { // TODO: da implementare
      //   //   final Map<String, dynamic> splitRatesMap = Map<String, dynamic>.from(splitRate);
      //   //   final userSplitRate = double.tryParse(splitRatesMap[userId]?.toString() ?? '0') ?? 0;
      //   //   owedAmount = totalAmount * userSplitRate;
      //   // } 
      //   // catch (e) {
      //   //   log.warning("Error parsing split rate for expense ${expense['id']}: $e. Defaulting to equal split.");
      //   //   owedAmount = totalAmount / max(1, numberOfParticipants);
      //   // }
      // } 
      // else {
      //   owedAmount = totalAmount / max(1, numberOfParticipants);
      // }

      // if (summary.containsKey(userId)) {
      //   summary[userId]!.increaseAlreadyPaid(paidAmount);
      //   summary[userId]!.increaseToPay(owedAmount);
      // } 
      // else {
      //   // TODO: gestire meglio questo caso, in teoria non dovrebbe mai accadere perché inizializziamo la mappa con tutti i partecipanti del gruppo, ma è meglio essere sicuri
      //   // summary[userId] = GroupParticipantSummaryModel(
      //   //   userId: userId,
      //   //   profile: _groupDetails?.groupParticipants.firstWhere((p) => p.userId == userId, orElse: () => ProfileModel.empty()) ?? ProfileModel.empty(),
      //   //   alreadyPaid: paidAmount,
      //   //   toPay: owedAmount,
      //   // );
      // }
    }
    return summary;
  }
}