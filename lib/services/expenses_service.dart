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

  Future<ApiResponseModel<Map<String, dynamic>>> create({required double price, String? merchant, String? note}) async {
    try {
      final res = await supabase.from('expenses').insert({
        'total_amount': price,
        // TODO: qui serve l'id merchant: 'merchant': merchant,
        'note': note
      }).select().single();
      return ApiResponseModel<Map<String, dynamic>>(success: true, message: null, data: res);
    } 
    catch (e) {
      print("Errore salvataggio spesa: $e");
      return ApiResponseModel<Map<String, dynamic>>(success: false, message: e.toString(), data: {});
    }
  }

  Future<List<Map<String, dynamic>>> fetchLatestExpenses({required int pageIndex, int pageSize = 10}) async {
    final from = pageIndex * pageSize;
    final to = from + pageSize - 1;

    final rows = await supabase
      .from('creator_expenses_with_participants')
      .select('*')
      .order('created_at', ascending: false)
      .limit(pageSize)
      .range(from, to); // pagination

    return rows;
  }

  // Note: old tests
  // Only fetch expenses created by the current user, no matter if there are participants or not
  // Future<List<Map<String, dynamic>>> fetchLatestExpenses({required int pageIndex, int pageSize = 10}) async {
  //   final userId = supabase.auth.currentUser!.id;
  //   final from = pageIndex * pageSize;
  //   final to = from + pageSize - 1;
  //   return await supabase
  //       .from('expenses')
  //       .select('*, merchants(name), categories(name)')
  //       .eq('creator_id', userId)
  //       .order('created_at', ascending: false)
  //       .limit(pageSize)
  //       .range(from, to); // pagination
  // }

  Future<ApiResponseModel<Map<String, dynamic>>> update({ 
    required String id, 
    required double price,
    String? merchant, // TODO: da implementare
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
