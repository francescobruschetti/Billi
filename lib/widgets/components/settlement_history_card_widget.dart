import 'package:Billy/constants.dart';
import 'package:Billy/models/group/group_settlement_profile_model.dart';
import 'package:flutter/material.dart';

class SettlementHistoryCardWidget extends StatefulWidget {

  final GroupSettlementProfileDetailsModel settlement;
  final String currentUserId;

  const SettlementHistoryCardWidget({
    super.key,
    required this.settlement,
    required this.currentUserId,
  });

  @override
  State<SettlementHistoryCardWidget> createState() => _SettlementHistoryCardWidgetState();
}

class _SettlementHistoryCardWidgetState extends State<SettlementHistoryCardWidget> {

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
          color: widget.settlement.payer.id == widget.currentUserId ? Theme.of(context).colorScheme.primary : Colors.transparent,
          width: 2.0,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child:
          Row(
            children: [
                Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${widget.settlement.payer.name} → ${widget.settlement.receiver.name}'),

                    if (widget.settlement.payer.id == widget.currentUserId) ...[
                      const SizedBox(height: AppConstants.sizedBoxHeight),
                      Text('Devi', style: const TextStyle(fontSize: AppConstants.smallTextSize, fontStyle: FontStyle.italic)),
                    ],
                  ]
                ),
              ),
                
              Text('${widget.settlement.amount.toStringAsFixed(2)}€', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
    );
  }
}