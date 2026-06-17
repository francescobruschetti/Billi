import 'package:Billy/constants.dart';
import 'package:Billy/enums/category_enum.dart';
import 'package:Billy/models/balance_summary_item_model.dart';
import 'package:Billy/models/group/group_participant_summary_model.dart';
import 'package:flutter/material.dart';

class BalanceCardWidget extends StatefulWidget {

  final BalanceSummaryItemModel balanceSummaryItem;
  final Map<String, GroupParticipantSummaryModel> participantsSummary;

  final bool isSelected;
  final void Function(bool?) onToggle;

  const BalanceCardWidget({
    super.key,
    required this.balanceSummaryItem,
    required this.participantsSummary,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  State<BalanceCardWidget> createState() => _BalanceCardWidgetState();
}

class _BalanceCardWidgetState extends State<BalanceCardWidget> {

  late CategoryEnum categoryEnum;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        side: BorderSide(
          color: widget.balanceSummaryItem.isCurrentUser ? Theme.of(context).colorScheme.primary : Colors.transparent,
          width: 2.0,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child:
          Row(
            children: [
              if (widget.balanceSummaryItem.isCurrentUser) ...[
                Checkbox(
                  value: widget.isSelected,
                  onChanged: widget.onToggle,
                  checkColor: Theme.of(context).colorScheme.primaryContainer,

                ),
              ],

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${widget.balanceSummaryItem.summary.profile.name} → ${widget.participantsSummary[widget.balanceSummaryItem.balance.otherUserId]?.profile.name ?? 'Utente sconosciuto'}'),

                    if (widget.balanceSummaryItem.isCurrentUser) ...[
                      const SizedBox(height: AppConstants.sizedBoxHeight),
                      Text('Devi', style: const TextStyle(fontSize: AppConstants.smallTextSize, fontStyle: FontStyle.italic)),
                    ],
                  ]
                ),
              ),
                
              Text('${widget.balanceSummaryItem.balance.amount.toStringAsFixed(2)}€', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
    );
  }
}