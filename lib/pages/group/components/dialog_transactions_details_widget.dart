
import 'package:Billy/models/group_participant_summary_model.dart';
import 'package:Billy/widgets/components/dialog_widget.dart';
import 'package:flutter/material.dart';

class DialogTransactionsDetailsWidget extends StatelessWidget {
  static final ScrollController _verticalController = ScrollController();
  static final ScrollController _horizontalController = ScrollController();
  
  final String? title;
  final Map<String, GroupParticipantSummaryModel> participantsSummary;

  const DialogTransactionsDetailsWidget({
    super.key,
    this.title,
    required this.participantsSummary,
  });

  @override
  Widget build(BuildContext context) {
    return DialogWidget(
      title: 'Riepilogo partecipanti',
      customContent: SizedBox(
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
                  columns: [
                    DataColumn(label: Text('Nome')),
                    DataColumn(label: Text('Versati')),
                    DataColumn(label: Text('Spesi')),
                    DataColumn(label: Text('Da Incassare (lordi)')),
                    DataColumn(label: Text('Da Incassare (netti)', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: participantsSummary.values.map((e) => DataRow(cells: [
                    DataCell(Text(e.profile.name)),
                    DataCell(Text(e.paidAmountGroup.toStringAsFixed(2))),
                    DataCell(Text(e.paidAmountItself.toStringAsFixed(2))),
                    DataCell(Text(e.toReceiveGross.toStringAsFixed(2))),
                    DataCell(Text(e.toReceiveNet.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold))),
                  ])).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}