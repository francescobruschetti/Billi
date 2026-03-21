import 'package:Billy/models/group_participant_summary_model.dart';
import 'package:Billy/pages/group/components/app_bottom_sheet.dart';
import 'package:flutter/material.dart';

class TransactionsBalanceBottomSheetWidget extends AppBottomSheet {
  static final ScrollController _verticalController = ScrollController();
  static final ScrollController _horizontalController = ScrollController();

  @override
  final String? title;
  final Map<String, GroupParticipantSummaryModel> participantsSummary;

  TransactionsBalanceBottomSheetWidget({
    super.key, this.title, required this.participantsSummary
  }) : super( title: title, child: Container());

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: "Riepilogo partecipanti",
      initialSize: 0.5,
      minSize: 0.2,
      maxSize: 1.0,

      child: Scrollbar(
        controller: _verticalController,
        thumbVisibility: true,
        child: Scrollbar(
          controller: _horizontalController,
          thumbVisibility: true,
          notificationPredicate: (notif) => notif.metrics.axis == Axis.horizontal,
          child: SingleChildScrollView(
            controller: _verticalController,
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Chi deve pagare a chi')),
                  DataColumn(label: Text('Importo')),
                ],
                rows: participantsSummary.values.expand((summary) => summary.balanceMovements.map((movement) => DataRow(cells: [
                  DataCell(Text('${summary.profile.name} → ${participantsSummary[movement.otherUserId]?.profile.name ?? 'Utente sconosciuto'}')),
                  DataCell(Text('${movement.amount.toStringAsFixed(2)}€', style: TextStyle(fontWeight: FontWeight.bold))),
                ]))).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}