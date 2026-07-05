import 'package:Billy/enums/split_rate_mode_enum.dart';
import 'package:Billy/enums/transaction_type_enum.dart';
import 'package:Billy/models/group/group_details_model.dart';
import 'package:Billy/models/group/group_participant_summary_balance_model.dart';
import 'package:Billy/models/group/group_settlement_profile_model.dart';
import 'package:Billy/services/profile_service.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupTransactionService {
  final Logger log = Logger('GroupTransactionService');
  final SupabaseClient supabase = Supabase.instance.client;
  final ProfileService profileService = ProfileService();
  
  Future<Map<String, dynamic>> createGroupExpenseTransaction({
    required String groupId,
    required double price,
    SplitRateModeEnum? splitRateEnum,
    double? paidAmount,
    String? merchant,
    String? categories,
    String? note,
  }) async {
    return createGroupTransaction(
      groupId: groupId,
      price: price,
      transactionType: TransactionTypeEnum.EXPENSE,
      splitRateEnum: splitRateEnum,
      paidAmount: paidAmount,
      merchant: merchant,
      categories: categories,
      note: note,
    );
  }

  Future<Map<String, dynamic>> createGroupIncomeTransaction({
    required String groupId,
    required double price,
    String? note,
  }) async {
    return createGroupTransaction(
      groupId: groupId,
      price: price,
      transactionType: TransactionTypeEnum.INCOME,
      splitRateEnum: null,
      paidAmount: price,
      merchant: null,
      categories: 'INCOME',
      note: note,
    );
  }

  Future<Map<String, dynamic>> createGroupTransaction({
    required String groupId,
    required double price,
    required TransactionTypeEnum transactionType,
    SplitRateModeEnum? splitRateEnum,
    double? paidAmount,
    String? merchant,
    String? categories,
    String? note,
  }) async {
    
    final userId = profileService.getCurrentUserId();

    try {
      final result = await supabase.rpc('insert_group_transaction_with_merchant_category', params: {
        'p_group_id': groupId,
        'p_user_id': userId,
        'p_paid_amount': paidAmount,
        'p_total_amount': price,
        'p_split_rate': splitRateEnum?.value,
        'p_merchant_name': merchant,
        'p_category_name': categories,
        'p_note': note,
        'p_transaction_type': transactionType.value,
      }).select().single();
      
      return result;
    } 
    catch (e) {
      log.severe("Errore salvataggio spesa: $e");
      throw Exception("Errore salvataggio spesa");
    }
  }

  Future<GroupDetailsModel> fetchGroup({required String groupId}) async {
    try {
      // Example: group_transactions:group_transactions(*, merchant:merchants(*), category:categories(*), profile:profiles(id, username, name))
      final result = await supabase
        .from('groups')
        .select('''
          id,
          name,
          description,
          link,
          user_id,
          created_at,
          updated_at,
          group_participants:group_participants(user_id, is_enabled, left_at, role, profiles:profiles(*)),
          
          group_settlements:group_settlements!group_settlements_group_id_fkey(
            id, group_id, payer_id, receiver_id, amount, settled_at
          ),
          
          group_transactions:group_transactions(
            *,
            merchant:merchants(*),
            category:categories(*),

            profile:profiles!fk_group_transactions_profiles(*),

            expense_participants:group_expense_participants!fk_group_expense_participants_group_transactions(
              *,
              profiles(*)
            )
          )
          ''')
        .eq('id', groupId)
        .single();

      final group = GroupDetailsModel.fromMap(result);
      group.transactions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return group;
    }
    catch (e) {
      log.severe("Error fetching group details: $e");
      throw Exception("Error fetching group details: $e");
    }
  }

  Future<Map<String, dynamic>> updateGroupExpenseTransaction({
    required String groupId,
    required String transactionId, 
    required double price,
    String? merchant, // TODO: da implementare
    String? categories, // TODO: da implementare
    String? note,
  })
  async {
    return updateGroupTransaction(
      groupId: groupId,
      transactionId: transactionId,
      price: price,
      transactionType: TransactionTypeEnum.EXPENSE,
      merchant: merchant,
      categories: categories,
      note: note,
    );
  }

  Future<Map<String, dynamic>> updateGroupIncomeTransaction({
    required String groupId,
    required String transactionId, 
    required double price,
    String? note,
  })
  async {
    return updateGroupTransaction(
      groupId: groupId,
      transactionId: transactionId,
      price: price,
      transactionType: TransactionTypeEnum.INCOME,
      merchant: null,
      categories: null,
      note: note,
    );
  }

  Future<Map<String, dynamic>> updateGroupTransaction({
    required String groupId,
    required String transactionId, 
    required double price,
    required TransactionTypeEnum transactionType,
    String? merchant, // TODO: da implementare
    String? categories, // TODO: da implementare
    String? note,
  })
  async {
    throw Exception("Not implemented yet");
  }
  
  Future<void> settleUserGroupExpenses(final String groupId, final List<GroupTransactionSummaryBalanceModel> balanceModels) async {
    try {
      await supabase.rpc('settle_group_movements', params: {
        'p_group_id': groupId,
        'p_movements': balanceModels.map((m) => {
          'receiver_id': m.otherUserId,  // chi riceve i soldi
          'amount': m.amount,
        }).toList(),
      });
    } 
    catch (e) {
      log.severe("Errore salvataggio saldo debiti: $e");
      throw Exception("Errore salvataggio saldo debiti");
    }
  }

  Future<GroupSettlementsHistoryPageModel> loadSettlementsHistoryGroup({ 
    required String groupId, required int pageIndex,
    int pageSize = 50,
    DateTime? dateStart,
    DateTime? dateEnd 
  }) async {
    try {
      // TODO: al momento carico tutto: final userId = profileService.getCurrentUserId();
      final from = pageIndex * pageSize;
      final to = from + pageSize - 1;

      final result = await supabase.rpc('get_group_settlements_history', params: {
        'p_group_id': groupId,
        'p_from': from,
        'p_to': to,
        'p_date_start': dateStart?.toIso8601String(),
        'p_date_end': dateEnd?.toIso8601String(),
      });

      return GroupSettlementsHistoryPageModel.fromJson(result);
    } 
    catch (e) {
      log.severe("Errore nel caricamento dei dati: $e");
      throw Exception("Errore nel caricamento dei dati");
    }
  }
}
