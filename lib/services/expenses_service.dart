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

  Future<List<Map<String, dynamic>>> fetchLatestExpenses({int pageSize = 10, required int pageIndex}) async {
    final userId = supabase.auth.currentUser!.id;
    final from = pageIndex * pageSize;
    final to = from + pageSize - 1;

    return await supabase
        .from('expenses')
        .select('*, merchants(name), categories(name)')
        .eq('creator_id', userId)
        .order('created_at', ascending: false)
        .limit(pageSize)
        .range(from, to); // use ".range(from, to)" for pagination
  }

}
