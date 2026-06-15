import 'package:Billy/constants.dart';
import 'package:Billy/models/balance_summary_item_model.dart';
import 'package:Billy/models/group/group_participant_summary_balance_model.dart';
import 'package:Billy/models/group/group_participant_summary_model.dart';
import 'package:Billy/services/transaction_service.dart';
import 'package:Billy/utils/generic_util.dart';
import 'package:Billy/widgets/components/app_bottom_sheet.dart';
import 'package:Billy/widgets/components/balance_card_widget.dart';
import 'package:Billy/widgets/components/custom_button_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionsBalanceBottomSheetWidget extends StatefulWidget {
  final String title;
  final Map<String, GroupParticipantSummaryModel> participantsSummary;
  final void Function(String) onShowMessage;
  final String groupId;

  const TransactionsBalanceBottomSheetWidget({
    super.key,
    required this.title,
    required this.participantsSummary,
    required this.onShowMessage,
    required this.groupId,
  });

  @override
  State<TransactionsBalanceBottomSheetWidget> createState() => _TransactionsBalanceBottomSheetWidgetState();
}

class _TransactionsBalanceBottomSheetWidgetState extends State<TransactionsBalanceBottomSheetWidget> {
  final Logger log = Logger('TransactionsBalanceBottomSheetWidget');
  final ScrollController _scrollController = ScrollController();
  final TransactionService transactionService = TransactionService();

  List<GroupTransactionSummaryBalanceModel> _selectedGroupTransactionSummaryBalanceModels = [];
  bool _showInfo = false;
  String _infoMessage = '';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<BalanceSummaryItemModel> _computeBalanceSummaryItems() {
    final balanceSummaryItems = <BalanceSummaryItemModel>[];
    for (final entry in widget.participantsSummary.entries) {
      final summary = entry.value;
      for (final balanceModel in summary.balanceModels) {
        final item = BalanceSummaryItemModel(
          isCurrentUser: summary.userId == Supabase.instance.client.auth.currentUser!.id,
          summary: summary,
          balance: balanceModel,
        );

        if (item.isCurrentUser) {
          balanceSummaryItems.insert(0, item);
        } 
        else {
          balanceSummaryItems.add(item);
        }
      }
    }
    
    return balanceSummaryItems; 
  }

  Future<void> _settleAllUserDebts(final BuildContext context, final String groupId) async {
    try {
      GroupParticipantSummaryModel? currentUserSummary = widget.participantsSummary[Supabase.instance.client.auth.currentUser!.id];
      log.fine("Settle all debts pressed: ${currentUserSummary?.movementModels.length ?? 0} movements to settle");

      if (currentUserSummary == null || currentUserSummary.movementModels.isEmpty) {
        _showPopupMessage('Nessun debito da saldare!');
        return;
      }

      transactionService.settleUserGroupExpenses(groupId, _selectedGroupTransactionSummaryBalanceModels).then((_) {
       
        // workaround con delay per evitare che il bottom sheet venga chiuso prima che venga mostrato lo snackbar
        final rootContext = Navigator.of(context).context; // Salva PRIMA del pop!
        Navigator.of(context).pop();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (rootContext.mounted) {
            GenericUtil.showSnackbar(rootContext, 'Tutti i debiti saldati!');
          }
        });
      });
    } 
    catch (e) {
      log.severe("Errore salvataggio saldo debiti: $e");
      _showPopupMessage('Impossibile aggiornare i pagamenti. Riprova più tardi.');
    }
  }

  void _showPopupMessage(String message) {
    setState(() {
      _showInfo = true;
      _infoMessage = message;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _showInfo = false;
        _infoMessage = '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final balanceSummaryItems = _computeBalanceSummaryItems();

    return AppBottomSheet(
      title: widget.title,
      initialSize: 0.9,
      minSize: 0.5,
      maxSize: 1.0,
      child: Column(
        children: [
          _buildBalanceMovementItem(balanceSummaryItems),

          if (_showInfo) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
              child: Text(_infoMessage, textAlign: TextAlign.center, style: TextStyle(fontSize: AppConstants.textSize, color: Theme.of(context).colorScheme.onSecondaryContainer)),
            ),
          ],
          
          CustomButtonWidget(
            text: 'Salda tutti i debiti',
            onPressed: () => _settleAllUserDebts(context, widget.groupId),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceMovementItem(List<BalanceSummaryItemModel> balanceSummaryItems) {
    return Expanded(
      child: balanceSummaryItems.isEmpty
        ? const Center(child: Text('Tutto ok, nessun pagamento da saldare!'))
        : ListView.builder(
            controller: _scrollController,
            itemCount: balanceSummaryItems.length,
            itemBuilder: (context, index) {
              final item = balanceSummaryItems[index];
              final isSelected = _selectedGroupTransactionSummaryBalanceModels.contains(item.balance);
              return BalanceCardWidget(
                balanceSummaryItem: item,
                participantsSummary: widget.participantsSummary,
                isSelected: isSelected,
                onToggle: (checked) {
                  setState(() {
                    if (checked == true) {
                      _selectedGroupTransactionSummaryBalanceModels.add(item.balance);
                    } else {
                      _selectedGroupTransactionSummaryBalanceModels.remove(item.balance);
                    }
                  });
                },
              );
            },
          ),
    );
  }
}