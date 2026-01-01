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

  Future<void> addExpense({
    required String title,
    required double amount,
    required String merchantId,
    required String categoryId,
  }) async 
  {
    print("Adding a new expense: $title, $amount");
    
    await supabase.from('expenses').insert({
      'title': title,
      'amount': amount,
      'user_id': supabase.auth.currentUser!.id,
      'merchant_id': merchantId,
      'category_id': categoryId,
    });
  }

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

}
