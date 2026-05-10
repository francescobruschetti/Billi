import 'package:Billy/constants.dart';
import 'package:Billy/models/group_participant_summary_model.dart';
import 'package:Billy/widgets/components/app_bottom_sheet.dart';
import 'package:flutter/material.dart';

class TransactionsBalanceBottomSheetWidget extends AppBottomSheet {
  static final ScrollController _verticalController = ScrollController();
  static final ScrollController _horizontalController = ScrollController();

  @override
  final String title;
  final Map<String, GroupParticipantSummaryModel> participantsSummary;

  TransactionsBalanceBottomSheetWidget({
    super.key, required this.title, required this.participantsSummary
  }) : super( title: title, child: Container());

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: title,
      initialSize: 0.9,
      minSize: 0.5,
      maxSize: 1.0,

      child: Column(
        children: [
          // TODO: mostra versione "intelligente", mostra "tutti i movimenti" in un secondo sheet?
          
          const SizedBox(height: AppConstants.sizedBoxHeight),
          Scrollbar(
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
                child:
                  /* TODO: v1: use all horizontal space: 
                  * ConstrainedBox(
                  *   constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                  * child: */
                  DataTable(
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
        ],
      ),
    );
  }
}