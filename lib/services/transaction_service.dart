import 'package:Billy/enums/transaction_type_enum.dart';
import 'package:Billy/models/personal_transactions/personal_transaction_page_model.dart';
import 'package:Billy/services/profile_service.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionService {
  final Logger log = Logger('TransactionService');
  final SupabaseClient supabase = Supabase.instance.client;
  final ProfileService profileService = ProfileService();

  Future<Map<String, dynamic>> createPersonalTransaction({
    required double price,
    required TransactionTypeEnum transactionType,
    String? merchant,
    String? categories,
    String? note,
  }) async {
    
    final userId = profileService.getCurrentUserId();

    try {
      final result = await supabase.rpc('insert_transaction_with_merchant_category', params: {
        'p_user_id': userId,
        'p_total_amount': price,
        'p_merchant_name': merchant,
        'p_category_name': categories,
        'p_note': note,
        'p_transaction_type': transactionType.value,
      }).select().single();
      return result;
    } 
    catch (e) {
      log.severe("Errore salvataggio spesa: $e");
      throw Exception("Errore salvataggio spesa");
    }
  }

  Future<PersonalTransactionPageModel> fetchLatestPersonalTransactions({
    required int pageIndex,
    int pageSize = 50,
    DateTime? dateStart,
    DateTime? dateEnd
  }) async {

    final userId = profileService.getCurrentUserId();
    final from = pageIndex * pageSize;
    final to = from + pageSize - 1;

    // TODO: remove merchant_id, category_id from root model
    final result = await supabase.rpc('get_personal_transactions', params: {
      'p_user_id': userId,
      'p_from': from,
      'p_to': to,
      'p_date_start': dateStart?.toIso8601String(),
      'p_date_end': dateEnd?.toIso8601String(),
    });

    return PersonalTransactionPageModel.fromJson(result);
  }

  Future<Map<String, dynamic>> updatePersonalTransaction({
    required String transactionId, 
    required double price,
    required TransactionTypeEnum transactionType,
    String? merchant, // TODO: da implementare
    String? categories, // TODO: da implementare
    String? note,
  })
  async {
    throw Exception("Not implemented yet");
  }
}
