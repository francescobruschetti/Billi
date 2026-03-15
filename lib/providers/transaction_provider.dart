import 'package:Billy/services/transaction_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final transactionServiceProvider = Provider((ref) => TransactionService());

final transactionProvider = StateNotifierProvider<TransactionsNotifier, AsyncValue<List<Map<String, dynamic>>>>(
  (ref) => TransactionsNotifier(ref.read(transactionServiceProvider)),
);

class TransactionsNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final TransactionService _service;

  TransactionsNotifier(this._service) : super(const AsyncLoading()) {
    _loadFromServer(pageIndex: 0);
  }

  Future<void> _loadFromServer({required int pageIndex, int pageSize = 50}) async {
    try {
      state = const AsyncLoading();
      final transactions = await _service.fetchLatestPersonalTransactions(pageIndex: pageIndex, pageSize: pageSize);
      state = AsyncData(transactions);
    } 
    catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // Refresh forzato dall'utente (pull-to-refresh)
  Future<void> refresh() => _loadFromServer(pageIndex: 0, pageSize: 50);

  void addGroupLocally(Map<String, dynamic> newGroup) {
    state = state.whenData((transactions) => [newGroup, ...transactions]);
  }

  // Aggiornamento ottimistico locale — nessuna chiamata al server
  void updateGroupLocally(Map<String, dynamic> updated) {
    state = state.whenData((transactions) => [
      for (final g in transactions)
        if (g['id'] == updated['id']) updated else g,
    ]);
  }

  // Rimozione ottimistica locale
  void removeGroupLocally(String id) {
    state = state.whenData(
      (transactions) => transactions.where((g) => g['id'] != id).toList(),
    );
  }
}