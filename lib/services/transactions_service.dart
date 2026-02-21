import 'package:logging/logging.dart';
import 'package:Billy/models/api_response_model.dart';
import 'package:Billy/models/transaction_model.dart';
import 'package:Billy/models/group_details_model.dart';
import 'package:Billy/models/group_transaction_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionsService {

  final Logger log = Logger('TransactionsService');
  final SupabaseClient supabase = Supabase.instance.client;

  Stream<List<TransactionModel>> subscribeTransactions() {
    log.fine("Subscribing to transactions stream");
    final userId = supabase.auth.currentUser!.id;

    return supabase
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((rows) =>
            rows.map((row) => TransactionModel.fromMap(row)).toList());
  }

  Future<ApiResponseModel<Map<String, dynamic>>> createGroupTransaction({
    required String groupId,
    required double price,
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
      }).select().single();
      return ApiResponseModel<Map<String, dynamic>>(success: true, message: null, data: result);
    } 
    catch (e) {
      log.severe("Errore salvataggio spesa: $e");
      return ApiResponseModel<Map<String, dynamic>>(success: false, message: e.toString(), data: {});
    }
  }

  Future<ApiResponseModel<Map<String, dynamic>>> createPersonalTransaction({
    required double price,
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
      }).select().single();
      return ApiResponseModel<Map<String, dynamic>>(success: true, message: null, data: result);
    } 
    catch (e) {
      log.severe("Errore salvataggio spesa: $e");
      return ApiResponseModel<Map<String, dynamic>>(success: false, message: e.toString(), data: {});
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

  // TODO: NOT used anymore
  Future<ApiResponseModel<List<GroupTransactionModel>>> fetchLatestGroupTransactions({required String groupId, required int pageIndex, int pageSize = 50}) async {
    
    try {
      final from = pageIndex * pageSize;
      final to = from + pageSize - 1;

      final transactions = await supabase
        .from('group_transactions')
        .select('*, merchant:merchants(*), category:categories(*), profile:profiles(*)')
        .eq('group_id', groupId)
        .order('created_at', ascending: false)
        .range(from, to);

      return ApiResponseModel<List<GroupTransactionModel>>(success: true, message: null, data: GroupTransactionModel.fromList(transactions));
    } 
    catch (e) {
      log.severe("Error fetching group transactions: $e");
      return ApiResponseModel<List<GroupTransactionModel>>(success: false, message: e.toString(), data: []);
    }
  }

  Future<ApiResponseModel<GroupDetailsModel>> fetchGroup({required String groupId, required int pageIndex, int pageSize = 50}) async {
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

      return ApiResponseModel<GroupDetailsModel>(success: true, message: null, data: GroupDetailsModel.fromMap(result));
    }
    catch (e) {
      log.severe("Error fetching group details: $e");
      return ApiResponseModel<GroupDetailsModel>(success: false, message: e.toString(), data: GroupDetailsModel.fromMap({}));
    }
  }

  // TODO: NOT used anymore
  Future<ApiResponseModel<GroupDetailsModel>> fetchGroupParticipants({required String groupId, required int pageIndex, int pageSize = 50}) async {
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
          group_participants:group_participants(user_id, profiles:profiles(*))
        ''')
        .eq('id', groupId)
        .single();

      return ApiResponseModel<GroupDetailsModel>(success: true, message: null, data: GroupDetailsModel.fromMap(result));
    } 
    catch (e) {
      log.severe("Error fetching group participants: $e");
      return ApiResponseModel<GroupDetailsModel>(success: false, message: e.toString(), data: GroupDetailsModel.fromMap({}));
    }
  }

  Future<ApiResponseModel<Map<String, dynamic>>> updateGroupTransaction({
    required String groupId,
    required String transactionId, 
    required double price,
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
    return ApiResponseModel<Map<String, dynamic>>(success: false, message: "Not implemented yet", data: {});
  }
  
  Future<ApiResponseModel<Map<String, dynamic>>> updatePersonalTransaction({
    required String transactionId, 
    required double price,
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
    return ApiResponseModel<Map<String, dynamic>>(success: false, message: "Not implemented yet", data: {});
  }
  

}
