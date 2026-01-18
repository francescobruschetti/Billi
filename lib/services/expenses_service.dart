import 'package:monitoraggio_spese/models/api_response_model.dart';
import 'package:monitoraggio_spese/models/expense_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpensesService {
  final SupabaseClient supabase = Supabase.instance.client;

  Stream<List<ExpenseModel>> subscribeExpenses() {
    print("Subscribing to expenses stream");
    final userId = supabase.auth.currentUser!.id;

    return supabase
        .from('expenses')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((rows) =>
            rows.map((row) => ExpenseModel.fromMap(row)).toList());
  }

  Future<ApiResponseModel<Map<String, dynamic>>> createGroup({
    required String groupId,
    required double price,
    String? merchant,
    String? categories,
    String? note,
  }) async {
    
    final userId = supabase.auth.currentUser!.id;
    try {
      final result = await supabase.rpc('insert_group_expense_with_merchant_category', params: {
        'p_user_id': userId,
        'p_total_amount': price,
        'p_merchant_name': merchant,
        'p_category_name': categories,
        'p_note': note,
        'p_group_id': groupId,
      }).select().single();
      return ApiResponseModel<Map<String, dynamic>>(success: true, message: null, data: result);
    } 
    catch (e) {
      print("Errore salvataggio spesa: $e");
      return ApiResponseModel<Map<String, dynamic>>(success: false, message: e.toString(), data: {});
    }
  }

  Future<ApiResponseModel<Map<String, dynamic>>> createPersonal({
    required double price,
    String? merchant,
    String? categories,
    String? note,
  }) async {
    
    final userId = supabase.auth.currentUser!.id;
    try {
      final result = await supabase.rpc('insert_expense_with_merchant_category', params: {
        'p_user_id': userId,
        'p_total_amount': price,
        'p_merchant_name': merchant,
        'p_category_name': categories,
        'p_note': note,
      }).select().single();
      return ApiResponseModel<Map<String, dynamic>>(success: true, message: null, data: result);
    } catch (e) {
      print("Errore salvataggio spesa: $e");
      return ApiResponseModel<Map<String, dynamic>>(success: false, message: e.toString(), data: {});
    }
  }

  Future<List<Map<String, dynamic>>> fetchLatestExpenses({required int pageIndex, int pageSize = 50}) async {
    final userId = supabase.auth.currentUser!.id;

    final from = pageIndex * pageSize;
    final to = from + pageSize - 1;

    final rows = await supabase
      .from('expenses')
      .select('*, merchant:merchants(*), category:categories(*)')
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .range(from, to);

    return rows;
  }

  Future<ApiResponseModel<Map<String, dynamic>>> updateGroup({
    required String groupId,
    required String expenseId, 
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
    //   print("Errore creazione gruppo: $e");
    //   return ApiResponseModel<Map<String, dynamic>>(success: false, message: e.toString(), data: {});
    // }
    return ApiResponseModel<Map<String, dynamic>>(success: false, message: "Not implemented yet", data: {});
  }
  
  Future<ApiResponseModel<Map<String, dynamic>>> updatePersonal({
    required String expenseId, 
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
    //   print("Errore creazione gruppo: $e");
    //   return ApiResponseModel<Map<String, dynamic>>(success: false, message: e.toString(), data: {});
    // }
    return ApiResponseModel<Map<String, dynamic>>(success: false, message: "Not implemented yet", data: {});
  }
  

}
