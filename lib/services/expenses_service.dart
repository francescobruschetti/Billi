import 'package:logging/logging.dart';
import 'package:Billy/models/api_response_model.dart';
import 'package:Billy/models/expense_model.dart';
import 'package:Billy/models/group_details_model.dart';
import 'package:Billy/models/group_expense_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpensesService {

  final Logger log = Logger('ExpensesService');
  final SupabaseClient supabase = Supabase.instance.client;

  Stream<List<ExpenseModel>> subscribeExpenses() {
    log.fine("Subscribing to expenses stream");
    final userId = supabase.auth.currentUser!.id;

    return supabase
        .from('expenses')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((rows) =>
            rows.map((row) => ExpenseModel.fromMap(row)).toList());
  }

  Future<ApiResponseModel<Map<String, dynamic>>> createGroupExpense({
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
      final result = await supabase.rpc('insert_group_expense_with_merchant_category', params: {
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

  Future<ApiResponseModel<Map<String, dynamic>>> createPersonalExpense({
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
    } 
    catch (e) {
      log.severe("Errore salvataggio spesa: $e");
      return ApiResponseModel<Map<String, dynamic>>(success: false, message: e.toString(), data: {});
    }
  }

  Future<List<Map<String, dynamic>>> fetchLatestPersonalExpenses({required int pageIndex, int pageSize = 50}) async {
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

  // TODO: NOT used anymore
  Future<ApiResponseModel<List<GroupExpenseModel>>> fetchLatestGroupExpenses({required String groupId, required int pageIndex, int pageSize = 50}) async {
    
    try {
      final from = pageIndex * pageSize;
      final to = from + pageSize - 1;

      final expenses = await supabase
        .from('group_expenses')
        .select('*, merchant:merchants(*), category:categories(*), profile:profiles(*)')
        .eq('group_id', groupId)
        .order('created_at', ascending: false)
        .range(from, to);

      return ApiResponseModel<List<GroupExpenseModel>>(success: true, message: null, data: GroupExpenseModel.fromList(expenses));
    } 
    catch (e) {
      log.severe("Error fetching group expenses: $e");
      return ApiResponseModel<List<GroupExpenseModel>>(success: false, message: e.toString(), data: []);
    }
  }

  Future<ApiResponseModel<GroupDetailsModel>> fetchGroup({required String groupId, required int pageIndex, int pageSize = 50}) async {
    try {
      // Example: group_expenses:group_expenses(*, merchant:merchants(*), category:categories(*), profile:profiles(id, username, name))
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
          group_expenses:group_expenses(*, merchant:merchants(*), category:categories(*), profile:profiles(*))
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
      // Example: group_expenses:group_expenses(*, merchant:merchants(*), category:categories(*), profile:profiles(id, username, name))
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

  Future<ApiResponseModel<Map<String, dynamic>>> updateGroupExpense({
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
    //   log.severe("Errore creazione gruppo: $e");
    //   return ApiResponseModel<Map<String, dynamic>>(success: false, message: e.toString(), data: {});
    // }
    return ApiResponseModel<Map<String, dynamic>>(success: false, message: "Not implemented yet", data: {});
  }
  
  Future<ApiResponseModel<Map<String, dynamic>>> updatePersonalExpense({
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
    //   log.severe("Errore creazione gruppo: $e");
    //   return ApiResponseModel<Map<String, dynamic>>(success: false, message: e.toString(), data: {});
    // }
    return ApiResponseModel<Map<String, dynamic>>(success: false, message: "Not implemented yet", data: {});
  }
  

}
