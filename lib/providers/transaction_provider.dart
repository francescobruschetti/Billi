import 'package:Billy/models/personal_transactions/personal_transaction_model.dart';
import 'package:Billy/models/personal_transactions/personal_transaction_totals_model.dart';
import 'package:Billy/models/personal_transactions/personal_transaction_page_model.dart';
import 'package:Billy/services/transaction_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

final transactionServiceProvider = Provider((ref) => TransactionService());

final transactionProvider = NotifierProvider<TransactionsNotifier, AsyncValue<List<PersonalTransactionModel>>>(
  TransactionsNotifier.new,
  name: 'transactionProvider',
);

class TransactionsNotifier extends Notifier<AsyncValue<List<PersonalTransactionModel>>> {
  final Logger log = Logger('TransactionsNotifier');

  TransactionService get _service => ref.read(transactionServiceProvider);

  PersonalTransactionTotalsModel? _totals;
  PersonalTransactionTotalsModel? get totals => _totals;

  int _currentPage = 0;
  int _pageSize = 50;
  bool _hasMore = true;

  @override
  AsyncValue<List<PersonalTransactionModel>> build({int pageSize = 5}) {

    // stato iniziale
    _pageSize = pageSize;
    _loadFromServer(pageIndex: _currentPage, pageSize: _pageSize);

    return const AsyncLoading();
  }

  Future<void> _loadFromServer({
    required int pageIndex, 
    required int pageSize, 
    bool append = false,
    DateTime? dateStart,
    DateTime? dateEnd,
  }) async {

    try {
      if (!append) {
        state = const AsyncLoading(); // trigger "loading" state for this provider
      }

      final PersonalTransactionPageModel personalTransactionPageModel = await _service.fetchLatestPersonalTransactions(
        pageIndex: pageIndex,
        pageSize: pageSize,
        dateStart: dateStart,
        dateEnd: dateEnd,
      );
      
      _totals = personalTransactionPageModel.totals;

      if (append && state is AsyncData<List<PersonalTransactionModel>> && (state as AsyncData<List<PersonalTransactionModel>>).value.isNotEmpty) {
        final current = (state as AsyncData<List<PersonalTransactionModel>>).value;
        state = AsyncData([...current, ...personalTransactionPageModel.transactions]);
      } 
      else {
        state = AsyncData(personalTransactionPageModel.transactions);
      }

      log.fine("transactions.length: ${personalTransactionPageModel.transactions.length}, pageSize: $pageSize");
      _hasMore = personalTransactionPageModel.transactions.length == pageSize;
      log.fine("_hasMore: $_hasMore");

    } 
    catch (e, st) {
      log.severe("Errore caricamento transazioni: $e", e, st);
      state = AsyncError(e, st);
    }
  }

  Future<void> loadMore({bool reset = false, DateTime? dateStart, DateTime? dateEnd}) async {  
    if (reset) {
      _currentPage = 0;
      _hasMore = true;
      await _loadFromServer(pageIndex: _currentPage, pageSize: _pageSize, append: false, dateStart: dateStart, dateEnd: dateEnd);
    } 
    else if (_hasMore) {
      _currentPage++;
      await _loadFromServer(pageIndex: _currentPage, pageSize: _pageSize, append: true, dateStart: dateStart, dateEnd: dateEnd);
    }
  }

  // Refresh forzato dall'utente (pull-to-refresh)
  Future<void> refresh({DateTime? dateStart, DateTime? dateEnd}) async {
    await loadMore(reset: true, dateStart: dateStart, dateEnd: dateEnd);
  }

  void addGroupLocally(PersonalTransactionModel newGroup) {
    state = state.whenData((transactions) => [newGroup, ...transactions]);
  }

  // Aggiornamento ottimistico locale — nessuna chiamata al server
  void updateGroupLocally(PersonalTransactionModel updated) {
    state = state.whenData((transactions) => [
      for (final g in transactions)
        if (g.id == updated.id) updated else g,
    ]);
  }

  // Rimozione ottimistica locale
  void removeGroupLocally(String id) {
    state = state.whenData(
      (transactions) => transactions.where((g) => g.id != id).toList(),
    );
  }
}