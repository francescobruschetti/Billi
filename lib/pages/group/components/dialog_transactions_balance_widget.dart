
// import 'package:Billy/models/group_participant_summary_model.dart';
// import 'package:Billy/widgets/components/dialog_widget.dart';
// import 'package:flutter/material.dart';

// /* To be used with:
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return DialogTransactionsBalanceWidget(
//         title: 'Riepilogo saldo',
//         participantsSummary: _participantsSummary,
//       );
//     },
//   );
// */

// class DialogTransactionsBalanceWidget extends StatelessWidget {
//   final String? title;
//   final Map<String, GroupParticipantSummaryModel> participantsSummary;

//   const DialogTransactionsBalanceWidget({
//     super.key,
//     this.title,
//     required this.participantsSummary,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return DialogWidget(
//           title: title,
//           customContent: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               DataTable(
//                 columns: const [
//                   DataColumn(label: Text('Chi deve pagare a chi')),
//                   DataColumn(label: Text('Importo')),
//                 ],
//                 rows: participantsSummary.values.expand((summary) => summary.balanceMovements.map((movement) => DataRow(cells: [
//                   DataCell(Text('${summary.profile.name} → ${participantsSummary[movement.otherUserId]?.profile.name ?? 'Utente sconosciuto'}')),
//                   DataCell(Text('${movement.amount.toStringAsFixed(2)}€', style: TextStyle(fontWeight: FontWeight.bold))),
//                 ]))).toList(),
//               ),
//             ],
//           ),
//         );
//   }
// }