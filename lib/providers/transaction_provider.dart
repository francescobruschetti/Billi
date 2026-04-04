import 'package:Billy/services/transaction_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

final transactionServiceProvider = Provider((ref) => TransactionService());

final transactionProvider = StateNotifierProvider<TransactionsNotifier, AsyncValue<List<Map<String, dynamic>>>>(
  (ref) => TransactionsNotifier(ref.read(transactionServiceProvider)),
  name: 'transactionProvider',
);

class TransactionsNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  
  final Logger log = Logger('TransactionsNotifier');
  
  final TransactionService _service;
  int _currentPage = 0;
  final int _pageSize;
  bool _isLoading = false;
  bool _hasMore = true;

  TransactionsNotifier(this._service, {int pageSize = 5}) // TODO: 5 valore utilizzato per test
    : _pageSize = pageSize,
    super(const AsyncLoading());

  Future<void> _loadFromServer({required int pageIndex, required int pageSize, bool append = false}) async {
    try {
      log.fine("Caricamento transazioni: pageIndex=$pageIndex, pageSize=$pageSize, append=$append");
      _isLoading = true;
      final transactions = await _service.fetchLatestPersonalTransactions(pageIndex: pageIndex, pageSize: pageSize);
      if (append && state is AsyncData<List<Map<String, dynamic>>>) {
        final current = (state as AsyncData<List<Map<String, dynamic>>>).value;
        final merged = [...current, ...transactions];
        state = AsyncData(merged);
      }
       else {
        state = AsyncData(transactions);
      }
      log.fine("transactions.length: ${transactions.length}, pageSize: $pageSize");
      _hasMore = transactions.length == pageSize;
      log.fine("_hasMore: $_hasMore");

      _isLoading = false;
    } catch (e, st) {
      state = AsyncError(e, st);
      _isLoading = false;
    }
  }

  Future<void> loadMore({bool reset = false}) async {
    if (_isLoading) return;
    if (reset) {
      _currentPage = 0;
      _hasMore = true;
      await _loadFromServer(pageIndex: _currentPage, pageSize: _pageSize, append: false);
    } 
    else if (_hasMore) {
      _currentPage++;
      await _loadFromServer(pageIndex: _currentPage, pageSize: _pageSize, append: true);
    }
  }

  // Refresh forzato dall'utente (pull-to-refresh)
  Future<void> refresh() => loadMore(reset: true);

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