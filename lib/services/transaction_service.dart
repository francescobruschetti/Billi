import 'package:Billy/enums/transaction_type_enum.dart';
import 'package:Billy/models/group_details_model.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionService {

  final Logger log = Logger('TransactionService');
  final SupabaseClient supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> createGroupTransaction({
    required String groupId,
    required double price,
    required TransactionTypeEnum transactionType,
    String? splitRate,
    double? paidAmount,
    String? merchant,
    String? categories,
    String? note,
  }) async {
    
    final userId = supabase.auth.currentUser!.id;
    try {
      final result = await supabase.rpc('insert_group_transaction_with_merchant_category', params: {
        'p_group_id': groupId,
        'p_user_id': userId,
        'p_paid_amount': paidAmount,
        'p_total_amount': price,
        'p_split_rate': splitRate,
        'p_merchant_name': merchant,
        'p_category_name': categories,
        'p_note': note,
        'p_transaction_type': transactionType.toValue(),
      }).select().single();

      
      return result;
    } 
    catch (e) {
      log.severe("Errore salvataggio spesa: $e");
      throw Exception("Errore salvataggio spesa");
    }
  }

  Future<Map<String, dynamic>> createPersonalTransaction({
    required double price,
    required TransactionTypeEnum transactionType,
    String? merchant,
    String? categories,
    String? note,
  }) async {
    
    final userId = supabase.auth.currentUser!.id;
    try {
      final result = await supabase.rpc('insert_transaction_with_merchant_category', params: {
        'p_user_id': userId,
        'p_total_amount': price,
        'p_merchant_name': merchant,
        'p_category_name': categories,
        'p_note': note,
        'p_transaction_type': transactionType.toValue(),
      }).select().single();
      return result;
    } 
    catch (e) {
      log.severe("Errore salvataggio spesa: $e");
      throw Exception("Errore salvataggio spesa");
    }
  }

  Future<List<Map<String, dynamic>>> fetchLatestPersonalTransactions({required int pageIndex, int pageSize = 50}) async {
    final userId = supabase.auth.currentUser!.id;

    final from = pageIndex * pageSize;
    final to = from + pageSize - 1;

    final rows = await supabase
      .from('transactions')
      .select('*, merchant:merchants(*), category:categories(*)')
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .range(from, to);

    return rows;
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
          group_participants:group_participants(user_id, profiles:profiles(*)),
          group_transactions:group_transactions(*, merchant:merchants(*), category:categories(*), profile:profiles(*))
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
    // try {
    //   final res = await supabase.rpc('update_group_and_participants', params: {
    //     'p_group_id': id,
    //     'p_name': name,
    //     'p_description': description,
    //     'p_participants_to_add': participantsToAdd?.map((u) => u['id']).toList() ?? [],
    //     'p_participants_to_remove': participantsToRemoveIds ?? [],
    //   });

    //   return ApiResponseModel<Map<String, dynamic>>(success: true, message: null, data: {'id': res});
    // } 
    // catch (e) {
    //   log.severe("Errore creazione gruppo: $e");
    //   return ApiResponseModel<Map<String, dynamic>>(success: false, message: e.toString(), data: {});
    // }
    throw Exception("Not implemented yet");
  }
  
  Future<Map<String, dynamic>> updatePersonalTransaction({
    required String transactionId, 
    required double price,
    required TransactionTypeEnum transactionType,
    String? merchant, // TODO: da implementare
    String? categories, // TODO: da implementare
    String? note,
  })
  async {
    // try {
    //   final res = await supabase.rpc('update_group_and_participants', params: {
    //     'p_group_id': id,
    //     'p_name': name,
    //     'p_description': description,
    //     'p_participants_to_add': participantsToAdd?.map((u) => u['id']).toList() ?? [],
    //     'p_participants_to_remove': participantsToRemoveIds ?? [],
    //   });

    //   return ApiResponseModel<Map<String, dynamic>>(success: true, message: null, data: {'id': res});
    // } 
    // catch (e) {
    //   log.severe("Errore creazione gruppo: $e");
    //   return ApiResponseModel<Map<String, dynamic>>(success: false, message: e.toString(), data: {});
    // }
    throw Exception("Not implemented yet");
  }
  

}
