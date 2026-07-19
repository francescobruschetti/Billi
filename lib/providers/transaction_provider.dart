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
  int _pageSize = 500000;
  bool _hasMore = true;

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  @override
  AsyncValue<List<PersonalTransactionModel>> build({int pageSize = 500000}) { // TODO: valore di test!!
    // stato iniziale
    _pageSize = pageSize;

    // Ascolta i cambiamenti in realtime
    _subscribeTransactionsRealtime();

    return const AsyncLoading();
  }

  //************************************* Data Management *************************************//
  Future<void> filterTransactionsType(TransactionTypeEnum? type) async { // TODO: filtra solo le transazioni già caricate, senza fare ulteriori chiamate al server (al momento filtra tutto in locale, ma sarebbe meglio filtrare già a livello di query al server)
    // v2:
    currentFilter = type;

    if (type == null) {
      state = AsyncData(periodTransactions);
      return;
    }

    state = AsyncData(
      periodTransactions.where((t) => t.transactionType == type).toList()
    );

    // v1:
    // if (currentFilter == type) {
    //   // Se il filtro selezionato è già attivo, rimuovilo (mostra tutte le transazioni)
    //   currentFilter = null;
    //   state = AsyncData(periodTransactions);
    //   _hasMore = periodTransactions.length == _pageSize;
    //   return;
    // }

    // currentFilter = type;
    // List<PersonalTransactionModel> filteredTransactions = [];
    // for (PersonalTransactionModel t in periodTransactions) {
    //   if (t.transactionType == type) {
    //     filteredTransactions.add(t);
    //   }
    // }

    // state = AsyncData(filteredTransactions);
    // _hasMore = filteredTransactions.length == _pageSize;
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

      if (!append) {
        periodTransactions = transactions.transactions;
      } 
      else {
        periodTransactions.addAll(transactions.transactions);
      }

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
      _isRefreshing = true;
      final response = await _service.fetchLatestPersonalTransactions(
        pageIndex: pageIndex,
        pageSize: pageSize,
        dateStart: dateStart,
        dateEnd: dateEnd,
      );
      
      _handleLoadedTransactions(response, append: append, pageSize: pageSize);
    } 
    catch (e, st) {
      log.severe("Errore caricamento transazioni: $e", e, st);
      state = AsyncError(e, st);
    }
    finally {
      _isRefreshing = false;
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
    _isRefreshing = true;
    state = state; // NOTIFICA UI senza perdere dati

    try {
      await loadMore(reset: true, dateStart: dateStart, dateEnd: dateEnd);
    } 
    finally {
      _isRefreshing = false;
      state = state; // refresh UI finale
    }
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
  void _subscribeTransactionsRealtime() {
    /* IMPORTANTE! By default Supabase non aggiorna in realtime i dati già presenti nella lista, ma solo quelli nuovi che arrivano dopo la subscription
    * → Per attivare il realtime, andare in: Database → Tables → transactions → Edit table -> Enable Realtime → ON */
    final supabase = Supabase.instance.client;
    final userId = profileService.getCurrentUserId();

    final subscription = supabase
      .from('transactions')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .listen(
        (data) {
          log.fine('Realtime event received: ${data.length} transactions');
          refresh();
        },
        onError: (e) {
          log.severe('Realtime transactions subscription error: $e'); // ← errori di connessione
        },
        onDone: () {
          log.fine('Realtime transactions subscription closed'); // ← se si chiude inaspettatamente
        },
      );
  
    // Cancella la subscription quando il provider viene distrutto
    ref.onDispose(() {
      log.fine('Cancelling transactions realtime subscription');
      subscription.cancel();
    });
  }
}