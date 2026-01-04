import 'package:monitoraggio_spese/models/api_response_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupsService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<ApiResponseModel<Map<String, dynamic>>> createGroup({ required String name, String? description }) async {
    try {
      final res = await supabase.from('groups').insert({
        'name': name,
        'description': description
      }).select().single();
      return ApiResponseModel<Map<String, dynamic>>(success: true, message: null, data: res);
    } 
    catch (e) {
      print("Errore creazione gruppo: $e");
      return ApiResponseModel<Map<String, dynamic>>(success: false, message: e.toString(), data: {});
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllGroupsForUser() async {
    final res = await supabase.rpc('get_user_groups');
    print("Fetched groups: $res");

    return (res as List)
        .map((g) => g as Map<String, dynamic>)
        .toList();
  }

  Future<ApiResponseModel<Map<String, dynamic>>> updateGroup({ required String id, required String name, String? description }) async {
    try {
      print('Updating group $id as user ${supabase.auth.currentUser!.id}');

      print("Updating group $id with name: $name, description: $description");
      final res = await supabase.from('groups').update({
        'name': name,
        'description': description
      })
      .eq("id", id)
      .select().single();
      return ApiResponseModel<Map<String, dynamic>>(success: true, message: null, data: res);
    } 
    catch (e) {
      print("Errore creazione gruppo: $e");
      return ApiResponseModel<Map<String, dynamic>>(success: false, message: e.toString(), data: {});
    }
  }

}
