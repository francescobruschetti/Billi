import 'package:Billy/constants.dart';
import 'package:Billy/models/balance_summary_item_model.dart';
import 'package:Billy/models/group/group_participant_summary_balance_model.dart';
import 'package:Billy/models/group/group_participant_summary_model.dart';
import 'package:Billy/models/group/group_settlement_profile_model.dart';
import 'package:Billy/pages/transaction/components/segment_control_page.dart';
import 'package:Billy/providers/ui_provider.dart';
import 'package:Billy/services/group_transaction_service.dart';
import 'package:Billy/services/profile_service.dart';
import 'package:Billy/services/transaction_service.dart';
import 'package:Billy/utils/generic_util.dart';
import 'package:Billy/widgets/components/app_bottom_sheet.dart';
import 'package:Billy/widgets/components/balance_card_widget.dart';
import 'package:Billy/widgets/components/custom_button_widget.dart';
import 'package:Billy/widgets/components/settlement_history_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionsBalanceBottomSheetWidget extends ConsumerStatefulWidget {
  final Map<String, GroupParticipantSummaryModel> participantsSummary;
  final void Function(String) onShowMessage;
  final String groupId;

  const TransactionsBalanceBottomSheetWidget({
    super.key,
    required this.participantsSummary,
    required this.onShowMessage,
    required this.groupId,
  });

  @override
  ConsumerState<TransactionsBalanceBottomSheetWidget> createState() => _TransactionsBalanceBottomSheetWidgetState();
}

class _TransactionsBalanceBottomSheetWidgetState extends ConsumerState<TransactionsBalanceBottomSheetWidget> {
  final Logger log = Logger('TransactionsBalanceBottomSheetWidget');
  final ScrollController _scrollController = ScrollController();
  late final PageController _controller;
  final ProfileService profileService = ProfileService();
  final GroupTransactionService groupTransactionService = GroupTransactionService();

  final List<GroupTransactionSummaryBalanceModel> _selectedGroupTransactionSummaryBalanceModels = [];
  GroupSettlementsHistoryPageModel _settlementsHistory = GroupSettlementsHistoryPageModel();
  
  bool _showInfo = false;
  String _infoMessage = '';
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);

    _loadSettlementsHistory(widget.groupId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
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

  Future<void> _loadSettlementsHistory(final String groupId) async {
    try {
      groupTransactionService.loadSettlementsHistoryGroup(groupId: groupId, pageIndex: 0).then((data) {      
        setState(() {
          _settlementsHistory = data;
          _isLoadingHistory = false;
        });
      });
    } 
    catch (e) {
      log.severe("Errore nel caricamento dei dati: $e");
      _showPopupMessage('Impossibile caricare i dati. Riprova più tardi.');
    }
  }

  void _onTabChanged(int index) {
    ref.read(groupSettlementTabProvider.notifier).setTab(index);

    if (mounted) {
      _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _settleAllUserDebts(final BuildContext context, final String groupId) async {
    try {
      GroupParticipantSummaryModel? currentUserSummary = widget.participantsSummary[Supabase.instance.client.auth.currentUser!.id];
      log.fine("Settle all debts pressed: ${currentUserSummary?.movementModels.length ?? 0} movements to settle");

      if (currentUserSummary == null || currentUserSummary.movementModels.isEmpty) {
        _showPopupMessage('Nessun debito da saldare!');
        return;
      }

      groupTransactionService.settleUserGroupExpenses(groupId, _selectedGroupTransactionSummaryBalanceModels).then((_) {      

        // TODO: trovare un modo per non utilizzare context: "Don't use 'BuildContext's across async gaps. Try rewriting the code to not use the 'BuildContext', or guard the use with a 'mounted' check."
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
      initialSize: 0.9,
      minSize: 0.5,
      maxSize: 1.0,
      child: Column(
        children: [
          _buildSegmentController(ref.watch(groupSettlementTabProvider), balanceSummaryItems), 
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

  Widget _buildSegmentController(int tabSelectedIndex, List<BalanceSummaryItemModel> balanceSummaryItems) {
    return Column(
      children: [
        // Segmented control
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedControl(
            selectedIndex: tabSelectedIndex,
            onChanged: _onTabChanged,
            segments: const [
              MapEntry('Da saldare', Icons.monetization_on_outlined),
              MapEntry('Storico', Icons.history),
            ],
          ),
        ),

        // PageView
        SizedBox(
          height: 450, // TODO: da sistemare per evitare che sia troppo grande o troppo piccolo
          child: PageView(
            controller: _controller,
            onPageChanged: _onTabChanged,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                child: _buildActiveSettlementComponents(balanceSummaryItems)
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16), 
                child: _buildHistorySettlementComponents()
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSettlementComponents(List<BalanceSummaryItemModel> balanceSummaryItems) {
    return Column(
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
          text: 'Salda debiti',
          isEnabled: _selectedGroupTransactionSummaryBalanceModels.isNotEmpty,
          onPressed: () => _selectedGroupTransactionSummaryBalanceModels.isNotEmpty ? _settleAllUserDebts(context, widget.groupId) : null,
        )
      ],
    );
  }

  Widget _buildHistorySettlementComponents() {
    return _isLoadingHistory
        ? const Center(child: CircularProgressIndicator())
        : _settlementsHistory.settlements.isEmpty
            ? const Center(child: Text('Nessun pagamento effettuato finora!'))
            : ListView.builder(
                controller: _scrollController,
                itemCount: _settlementsHistory.settlements.length,
                itemBuilder: (context, index) {
                  return SettlementHistoryCardWidget(
                    settlement: _settlementsHistory.settlements[index],
                    currentUserId: profileService.getCurrentUserId(),
                  );
                },
          );
  }
}