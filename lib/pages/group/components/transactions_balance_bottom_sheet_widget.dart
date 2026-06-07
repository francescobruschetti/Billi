import 'package:Billy/constants.dart';
import 'package:Billy/models/balance_movement_item_model.dart';
import 'package:Billy/models/group/group_participant_summary_balance_movement_model.dart';
import 'package:Billy/models/group/group_participant_summary_model.dart';
import 'package:Billy/utils/generic_util.dart';
import 'package:Billy/widgets/components/app_bottom_sheet.dart';
import 'package:Billy/widgets/components/balance_card_widget.dart';
import 'package:Billy/widgets/components/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionsBalanceBottomSheetWidget extends AppBottomSheet {
  static final ScrollController _verticalController = ScrollController();
  static final ScrollController _horizontalController = ScrollController();
  final ScrollController _scrollController = ScrollController();


  @override
  final String title;
  final Map<String, GroupParticipantSummaryModel> participantsSummary;

  TransactionsBalanceBottomSheetWidget({
    super.key, required this.title, required this.participantsSummary
  }) : super( title: title, child: Container());

  // v1: data e importo, chi deve pagare a chi
  // @override
  // Widget build(BuildContext context) {
  //   return AppBottomSheet(
  //     title: title,
  //     initialSize: 0.9,
  //     minSize: 0.5,
  //     maxSize: 1.0,

  //     child: Column(
  //       children: [
  //         // TODO: mostra versione "intelligente", mostra "tutti i movimenti" in un secondo sheet?
          
  //         const SizedBox(height: AppConstants.sizedBoxHeight),
  //         Scrollbar(
  //           controller: _verticalController,
  //           thumbVisibility: true,
  //           child: Scrollbar(
  //             controller: _horizontalController,
  //             thumbVisibility: true,
  //             notificationPredicate: (notif) => notif.metrics.axis == Axis.horizontal,
  //             child: SingleChildScrollView(
  //               controller: _verticalController,
  //               scrollDirection: Axis.vertical,
  //               child: SingleChildScrollView(
  //               controller: _horizontalController,
  //               scrollDirection: Axis.horizontal,
  //               child:
  //                 DataTable(
  //                   columns: const [
  //                     DataColumn(label: Text('Chi deve pagare a chi')),
  //                     DataColumn(label: Text('Importo')),
  //                   ],
  //                   rows: participantsSummary.values.expand((summary) => summary.balanceMovements.map((movement) => DataRow(cells: [
  //                     DataCell(Text('${summary.profile.name} → ${participantsSummary[movement.otherUserId]?.profile.name ?? 'Utente sconosciuto'}')),
  //                     DataCell(Text('${movement.amount.toStringAsFixed(2)}€', style: TextStyle(fontWeight: FontWeight.bold))),
  //                   ]))).toList(),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // // v2: list view
  // @override
  // Widget build(BuildContext context) {
  //   final List<BalanceMovementItemModel> currentUserBalanceMovements = [];
  //   final List<BalanceMovementItemModel> otherUserBalanceMovements = [];

  //   for (var summary in participantsSummary.values) {
  //     for (var movement in summary.balanceMovements) {
  //       final item = BalanceMovementItemModel(
  //         summary: summary,
  //         movement: movement,
  //       );

  //       if (summary.userId == Supabase.instance.client.auth.currentUser!.id) {
  //         currentUserBalanceMovements.add(item);
  //       } 
  //       else {
  //         otherUserBalanceMovements.add(item);
  //       }
  //     }
  //   }

  //   return AppBottomSheet(
  //     title: title,
  //     initialSize: 0.9,
  //     minSize: 0.5,
  //     maxSize: 1.0,

  //     child: Column(
  //       children: [
  //         // TODO: mostra versione "intelligente", mostra "tutti i movimenti" in un secondo sheet?
          
  //         _buildUsersBalanceMovements(currentUserBalanceMovements),
          
  //         _buildOtherUsersBalanceMovements(otherUserBalanceMovements),
  //       ],
  //     ),
  //   );
  // }
  
  // Widget _buildUsersBalanceMovements(List<BalanceMovementItemModel> balanceMovements) {
  //   return _buildBalanceMovements(balanceMovements);
  // }

  // Widget _buildOtherUsersBalanceMovements(List<BalanceMovementItemModel> balanceMovements) {
  //   return _buildBalanceMovements(balanceMovements);
  // }

  // Widget _buildBalanceMovements(List<BalanceMovementItemModel> balanceMovements) {
  //   return Expanded(
  //     child: balanceMovements.isEmpty
  //       ? Center(
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Text(
  //                 'Tutto ok, nessun pagamento da saldare!',
  //                 style: TextStyle(fontSize: AppConstants.textSize),
  //               ),
  //             ],
  //           ),
  //         )
  //       : ListView.builder(
  //           controller: _scrollController,
  //           itemCount: balanceMovements.length,
  //           itemBuilder: (context, index) {
  //             final item = balanceMovements[index];

  //             return BalanceCardWidget(
  //               participantsSummary: participantsSummary,
  //               summaryModel: item.summary,
  //               balanceMovement: item.movement,
  //             );
  //           },
  //         ),
  //   );
  // }

  // v3: list view con card (versione attuale)
  @override
  Widget build(BuildContext context) {
    final List<BalanceMovementItemModel> balanceMovements = [];

    for (var summary in participantsSummary.values) {
      for (var movement in summary.balanceMovements) {
        final item = BalanceMovementItemModel(
          isCurrentUser: summary.userId == Supabase.instance.client.auth.currentUser!.id,
          summary: summary,
          movement: movement,
        );

        if (item.isCurrentUser) {
          balanceMovements.insert(0, item);
        } 
        else {
          balanceMovements.add(item);
        }
      }
    }

    return AppBottomSheet(
      title: title,
      initialSize: 0.9,
      minSize: 0.5,
      maxSize: 1.0,

      child: Column(
        children: [
          // TODO: mostra versione "intelligente", mostra "tutti i movimenti" in un secondo sheet?
          
          _buildBalanceMovements(balanceMovements),

          const SizedBox(height: AppConstants.sizedBoxHeight),
          CustomButtonWidget(
            text: 'Salda tutti i debiti',
            onPressed: () => GenericUtil.showSnackbar(context, 'Funzione non ancora implementata'), // TODO: implementare
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceMovements(List<BalanceMovementItemModel> balanceMovements) {
    return Expanded(
      child: balanceMovements.isEmpty
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tutto ok, nessun pagamento da saldare!',
                  style: TextStyle(fontSize: AppConstants.textSize),
                ),
              ],
            ),
          )
        : ListView.builder(
            controller: _scrollController,
            itemCount: balanceMovements.length,
            itemBuilder: (context, index) {
              final item = balanceMovements[index];

              return BalanceCardWidget(
                balanceMovementItem: item,
                participantsSummary: participantsSummary,
              );
            },
          ),
    );
  }

}