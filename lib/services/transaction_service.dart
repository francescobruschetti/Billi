import 'package:Billy/enums/split_rate_mode_enum.dart';
import 'package:Billy/enums/transaction_type_enum.dart';
import 'package:Billy/models/group_details_model.dart';
import 'package:Billy/models/personal_transactions/personal_transaction_page_model.dart';
import 'package:Billy/services/profile_service.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionService {
  final Logger log = Logger('TransactionService');
  final SupabaseClient supabase = Supabase.instance.client;
  final ProfileService profileService = ProfileService();

  Future<Map<String, dynamic>> createGroupExpenseTransaction({
    required String groupId,
    required double price,
    SplitRateModeEnum? splitRateEnum,
    double? paidAmount,
    String? merchant,
    String? categories,
    String? note,
  }) async {
    return createGroupTransaction(
      groupId: groupId,
      price: price,
      transactionType: TransactionTypeEnum.EXPENSE,
      splitRateEnum: splitRateEnum,
      paidAmount: paidAmount,
      merchant: merchant,
      categories: categories,
      note: note,
    );
  }

  Future<Map<String, dynamic>> createGroupIncomeTransaction({
    required String groupId,
    required double price,
    String? note,
  }) async {
    return createGroupTransaction(
      groupId: groupId,
      price: price,
      transactionType: TransactionTypeEnum.INCOME,
      splitRateEnum: null,
      paidAmount: price,
      merchant: null,
      categories: 'INCOME',
      note: note,
    );
  }

  Future<Map<String, dynamic>> createGroupTransaction({
    required String groupId,
    required double price,
    required TransactionTypeEnum transactionType,
    SplitRateModeEnum? splitRateEnum,
    double? paidAmount,
    String? merchant,
    String? categories,
    String? note,
  }) async {
    
    final userId = profileService.getCurrentUserId();

    try {
      final result = await supabase.rpc('insert_group_transaction_with_merchant_category', params: {
        'p_group_id': groupId,
        'p_user_id': userId,
        'p_paid_amount': paidAmount,
        'p_total_amount': price,
        'p_split_rate': splitRateEnum?.value,
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

  Future<GroupDetailsModel> fetchGroup({required String groupId}) async {
    try {
      // Example: group_transactions:group_transactions(*, merchant:merchants(*), category:categories(*), profile:profiles(id, username, name))
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
          group_transactions:group_transactions(*, merchant:merchants(*), category:categories(*), profile:profiles(*))
        ''')
        .eq('id', groupId)
        .single();

      final group = GroupDetailsModel.fromMap(result);
      group.transactions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return group;
    }
    catch (e) {
      log.severe("Error fetching group details: $e");
      throw Exception("Error fetching group details: $e");
    }
  }

  Future<Map<String, dynamic>> updateGroupExpenseTransaction({
    required String groupId,
    required String transactionId, 
    required double price,
    String? merchant, // TODO: da implementare
    String? categories, // TODO: da implementare
    String? note,
  })
  async {
    return updateGroupTransaction(
      groupId: groupId,
      transactionId: transactionId,
      price: price,
      transactionType: TransactionTypeEnum.EXPENSE,
      merchant: merchant,
      categories: categories,
      note: note,
    );
  }

  Future<Map<String, dynamic>> updateGroupIncomeTransaction({
    required String groupId,
    required String transactionId, 
    required double price,
    String? note,
  })
  async {
    return updateGroupTransaction(
      groupId: groupId,
      transactionId: transactionId,
      price: price,
      transactionType: TransactionTypeEnum.INCOME,
      merchant: null,
      categories: null,
      note: note,
    );
  }

  Future<Map<String, dynamic>> updateGroupTransaction({
    required String groupId,
    required String transactionId, 
    required double price,
    required TransactionTypeEnum transactionType,
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
    throw Exception("Not implemented yet");
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
    throw Exception("Not implemented yet");
  }
  

}
