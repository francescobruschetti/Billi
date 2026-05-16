import 'package:Billy/enums/transaction_type_enum.dart';
import 'package:Billy/models/personal_transactions/personal_transaction_model.dart';
import 'package:Billy/models/personal_transactions/personal_transaction_totals_model.dart';
import 'package:Billy/models/personal_transactions/personal_transaction_page_model.dart';
import 'package:Billy/services/profile_service.dart';
import 'package:Billy/services/transaction_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final transactionServiceProvider = Provider((ref) => TransactionService());

final transactionProvider = NotifierProvider<TransactionsNotifier, AsyncValue<List<PersonalTransactionModel>>>(
  TransactionsNotifier.new,
  name: 'transactionProvider',
);

class TransactionsNotifier extends Notifier<AsyncValue<List<PersonalTransactionModel>>> {
  final Logger log = Logger('TransactionsNotifier');
  final ProfileService profileService = ProfileService();

  List<PersonalTransactionModel> periodTransactions = [];
  TransactionTypeEnum? currentFilter;
  
  TransactionService get _service => ref.read(transactionServiceProvider);
  
  PersonalTransactionTotalsModel? _totals;
  PersonalTransactionTotalsModel? get totals => _totals;

  int _currentPage = 0;
  int _pageSize = 50;
  bool _hasMore = true;

  @override
  AsyncValue<List<PersonalTransactionModel>> build({int pageSize = 5}) { // TODO: valore di test!!
    // stato iniziale
    _pageSize = pageSize;

    // Ascolta i cambiamenti in realtime
    _subscribeToRealtime();

    return const AsyncLoading();
  }

  //************************************* Data Management *************************************//
  Future<void> filterTransactionsType(TransactionTypeEnum? type) async { // TODO: filtra solo le transazioni già caricate, senza fare ulteriori chiamate al server (al momento filtra tutto in locale, ma sarebbe meglio filtrare già a livello di query al server)
    if (currentFilter == type) {
      // Se il filtro selezionato è già attivo, rimuovilo (mostra tutte le transazioni)
      currentFilter = null;
      state = AsyncData(periodTransactions);
      _hasMore = periodTransactions.length == _pageSize;
      return;
    }

    currentFilter = type;
    List<PersonalTransactionModel> filteredTransactions = [];
    for (PersonalTransactionModel t in periodTransactions) {
      if (t.transactionType == type) {
        filteredTransactions.add(t);
      }
    }

    state = AsyncData(filteredTransactions);
    _hasMore = filteredTransactions.length == _pageSize;
  }

  Future<void> _handleLoadedTransactions(PersonalTransactionPageModel transactions, {bool append = false, required int pageSize}) async {
    
    try {
      _totals = transactions.totals;

      if (append && state is AsyncData<List<PersonalTransactionModel>> && (state as AsyncData<List<PersonalTransactionModel>>).value.isNotEmpty) {
        final current = (state as AsyncData<List<PersonalTransactionModel>>).value;
        state = AsyncData([...current, ...transactions.transactions]);
      } 
      else {
        state = AsyncData(transactions.transactions);
      }
      periodTransactions = transactions.transactions;

      _hasMore = transactions.transactions.length == pageSize;
    } 
    catch (e, st) {
      log.severe("Errore caricamento transazioni: $e", e, st);
      state = AsyncError(e, st);
    }
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
      
      _handleLoadedTransactions(personalTransactionPageModel, append: append, pageSize: pageSize);      
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

  //************************************* LOCAL Management *************************************//
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

  //************************************* Realtime Updates *************************************//
  void _subscribeToRealtime() {
    final supabase = Supabase.instance.client;
    final userId = profileService.getCurrentUserId();

    final subscription = supabase
      .from('transactions')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .listen((data) {
        // Nuovi dati arrivati → refresh automatico
        refresh();
      });

    // Cancella la subscription quando il provider viene distrutto
    ref.onDispose(() => subscription.cancel());
  }
}