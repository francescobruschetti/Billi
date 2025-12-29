import 'package:monitoraggio_spese/models/expense_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpensesService {
  final SupabaseClient supabase = Supabase.instance.client;

  Stream<List<ExpenseModel>> subscribeExpenses() {
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
  }) async {
    await supabase.from('expenses').insert({
      'title': title,
      'amount': amount,
      'user_id': supabase.auth.currentUser!.id,
      'merchant_id': merchantId,
      'category_id': categoryId,
    });
  }
}
